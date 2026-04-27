include utils;
include backend.models;
import from backend.models { DiseaseDoc, CaseStudy }
# sv import from backend.helpers {  normalize_crop, normalize_region }
include backend.helpers;

obj MapWeatherPoint {
    has region_id: str;
    has region_name: str;
    has lat: float;
    has lon: float;
    has temperature_c: float;
    has humidity_pct: float;
    has disease_risk_level: str;
    has disease_risk_score: int;
    has risk_color: str;
    has summary: str;
}

obj MapDiseasePoint {
    has region_id: str;
    has region_name: str;
    has lat: float;
    has lon: float;
    has disease_name: str;
    has cases_reported: int;
    has risk_level: str;
    has radius: int;
}

obj MapMarketPoint {
    has region_id: str;
    has region_name: str;
    has market_name: str;
    has lat: float;
    has lon: float;
    has crop: str;
    has price: float;
    has currency: str;
    has unit: str;
    has trend: str;
    has price_color: str;
}

obj MapCasePoint {
    has case_id: str;
    has region_name: str;
    has lat: float;
    has lon: float;
    has title: str;
    has disease_name: str;
    has outcome: str;
    has success: bool;
}

obj MapAlertPoint {
    has alert_id: str;
    has region_name: str;
    has lat: float;
    has lon: float;
    has alert_type: str;
    has alert_message: str;
    has severity: str;
}

obj MapDataPayload {
    has weather_points: list[MapWeatherPoint, ...] = [];
    has disease_points: list[MapDiseasePoint, ...] = [];
    has market_points: list[MapMarketPoint, ...] = [];
    has case_points: list[MapCasePoint, ...] = [];
    has alert_points: list[MapAlertPoint, ...] = [];
}

glob KENYA_REGIONS = {
    "ke-kiambu":      {"name": "Kiambu",   "lat": -1.1714, "lon": 36.8356},
    "ke-nairobi":     {"name": "Nairobi",  "lat": -1.2921, "lon": 36.8219},
    "ke-nakuru":      {"name": "Nakuru",   "lat": -0.3031, "lon": 36.0800},
    "ke-kisumu":      {"name": "Kisumu",   "lat": -0.0917, "lon": 34.7680},
    "ke-nyeri":       {"name": "Nyeri",    "lat": -0.4167, "lon": 36.9500},
    "ke-meru":        {"name": "Meru",     "lat":  0.0476, "lon": 37.6493},
    "ke-machakos":    {"name": "Machakos", "lat": -1.5177, "lon": 37.2634},
    "ke-mombasa":     {"name": "Mombasa",  "lat": -4.0435, "lon": 39.6682},
    "ke-kakamega":    {"name": "Kakamega", "lat":  0.2827, "lon": 34.7519},
    "ke-uasin-gishu": {"name": "Eldoret",  "lat":  0.5143, "lon": 35.2698}
};
def hours_since(dt_str: str) -> float {
    dt = parse_datetime_safe(dt_str);

    if not dt {
        return 10000.0;
    }

    try {
        delta = datetime.now() - dt;
        return delta.total_seconds() / 3600.0;
    } except Exception {
        return 10000.0;
    }
}

def get_coords(region_id: str) -> dict {
    return KENYA_REGIONS.get(region_id, {});
}

def risk_to_color(risk_level: str) -> str {
    if risk_level == "HIGH" {
        return "#ef4444";
    }
    if risk_level == "MEDIUM" {
        return "#f59e0b";
    }
    return "#22c55e";
}

def price_to_color(price: float) -> str {
    if price >= 45.0 {
        return "#16a34a";
    }
    if price >= 30.0 {
        return "#f59e0b";
    }
    return "#dc2626";
}

def price_to_trend(price: float) -> str {
    if price >= 45.0 {
        return "Good price";
    }
    if price >= 30.0 {
        return "Stable";
    }
    return "Low price";
}

walker:pub GetMapData {
    has crop: str = "maize";
    has disease_filter: str = "";

    can run with Root entry {
        payload = MapDataPayload();

        mem_list = [root -->][?:Memory];
        if not mem_list {
            report payload;
            disengage;
        }

        memory = mem_list[0];

        weather_points = [];
        market_points = [];
        alert_points = [];
        seen_weather = [];
        seen_market = [];

        for session in [memory ->:HAS_SESSION:->] {

            for ws in [session ->:HAS_WEATHER:->] {
                rid = ws.region_id;

                if not rid {
                    continue;
                }
                if rid in seen_weather {
                    continue;
                }
                if hours_since(ws.created_at) > 24.0 {
                    continue;
                }

                coords = get_coords(rid);
                if not coords {
                    continue;
                }

                seen_weather = seen_weather + [rid];

                weather_points = weather_points + [MapWeatherPoint(
                    region_id=rid,
                    region_name=ws.region_name or coords.get("name", rid),
                    lat=coords.get("lat", 0.0),
                    lon=coords.get("lon", 0.0),
                    temperature_c=ws.temperature_c,
                    humidity_pct=ws.humidity_pct,
                    disease_risk_level=ws.disease_risk_level,
                    disease_risk_score=ws.disease_risk_score,
                    risk_color=risk_to_color(ws.disease_risk_level),
                    summary=ws.summary
                )];

                if ws.disease_risk_level == "HIGH" {
                    alert_msg = "High disease risk in " + ws.region_name + ": " + ws.disease_risk_reason;
                    alert_points = alert_points + [MapAlertPoint(
                        alert_id="alert_" + rid,
                        region_name=ws.region_name or coords.get("name", rid),
                        lat=coords.get("lat", 0.0),
                        lon=coords.get("lon", 0.0),
                        alert_type="disease_risk",
                        alert_message=alert_msg,
                        severity="high"
                    )];
                }
            }

            crop_key = normalize_crop(self.crop);

            for ms in [session ->:HAS_MARKET:->] {
                if ms.crop_key != crop_key {
                    continue;
                }

                rid = ms.region_id;
                if not rid {
                    continue;
                }

                mkey = crop_key + "|" + rid;
                if mkey in seen_market {
                    continue;
                }
                if ms.price <= 0.0 {
                    continue;
                }

                coords = get_coords(rid);
                if not coords {
                    continue;
                }

                seen_market = seen_market + [mkey];

                market_points = market_points + [MapMarketPoint(
                    region_id=rid,
                    region_name=ms.region_name or coords.get("name", rid),
                    market_name=ms.market_name or coords.get("name", rid),
                    lat=coords.get("lat", 0.0),
                    lon=coords.get("lon", 0.0),
                    crop=self.crop,
                    price=ms.price,
                    currency=ms.currency,
                    unit=ms.unit,
                    trend=price_to_trend(ms.price),
                    price_color=price_to_color(ms.price)
                )];
            }
        }

        payload.weather_points = weather_points;
        payload.market_points = market_points;
        payload.alert_points = alert_points;

        disease_points = [];

       for d in [root -->] {

                if not hasattr(d, "disease_name") {
                    continue;
                }

                if self.disease_filter and self.disease_filter.lower() not in d.disease_name.lower() {
                    continue;
                }

                for rid in KENYA_REGIONS {
                    coords = KENYA_REGIONS[rid];

                    disease_points = disease_points + [MapDiseasePoint(
                        region_id=rid,
                        region_name=coords.get("name", rid),
                        lat=coords.get("lat", 0.0),
                        lon=coords.get("lon", 0.0),
                        disease_name=d.disease_name,
                        cases_reported=0,
                        risk_level="medium",
                        radius=15000
                    )];
                }
            }
        payload.disease_points = disease_points;

        case_points = [];

        for cs in [root -->][?:CaseStudy] {
            region_key = normalize_region(cs.region);
            rid = "ke-" + region_key;
            coords = get_coords(rid);

            if not coords {
                continue;
            }

            case_title = "Case in " + cs.region + ": " + cs.crop;

            case_points = case_points + [MapCasePoint(
                case_id=cs.case_id,
                region_name=cs.region,
                lat=coords.get("lat", 0.0),
                lon=coords.get("lon", 0.0),
                title=case_title,
                disease_name=cs.diagnosis,
                outcome=cs.outcome,
                success=True
            )];
        }

        payload.case_points = case_points;

        report payload;
    }
}
