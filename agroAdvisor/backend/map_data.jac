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
    "ke-baringo": {"name": "Baringo", "lat": 0.4667, "lon": 35.9667},
    "ke-bomet": {"name": "Bomet", "lat": -0.7813, "lon": 35.3416},
    "ke-bungoma": {"name": "Bungoma", "lat": 0.5693, "lon": 34.5584},
    "ke-busia": {"name": "Busia", "lat": 0.4600, "lon": 34.1110},
    "ke-elgeyo-marakwet": {"name": "Elgeyo Marakwet", "lat": 0.8029, "lon": 35.5362},
    "ke-embu": {"name": "Embu", "lat": -0.5389, "lon": 37.4576},
    "ke-garissa": {"name": "Garissa", "lat": -0.4536, "lon": 39.6401},
    "ke-homa-bay": {"name": "Homa Bay", "lat": -0.5273, "lon": 34.4571},
    "ke-isiolo": {"name": "Isiolo", "lat": 0.3556, "lon": 37.5833},
    "ke-kajiado": {"name": "Kajiado", "lat": -1.8523, "lon": 36.7760},
    "ke-kakamega": {"name": "Kakamega", "lat": 0.2827, "lon": 34.7519},
    "ke-kericho": {"name": "Kericho", "lat": -0.3670, "lon": 35.2831},
    "ke-kiambu": {"name": "Kiambu", "lat": -1.1714, "lon": 36.8356},
    "ke-kilifi": {"name": "Kilifi", "lat": -3.5107, "lon": 39.9093},
    "ke-kirinyaga": {"name": "Kirinyaga", "lat": -0.6591, "lon": 37.3827},
    "ke-kisii": {"name": "Kisii", "lat": -0.6817, "lon": 34.7667},
    "ke-kisumu": {"name": "Kisumu", "lat": -0.0917, "lon": 34.7680},
    "ke-kitui": {"name": "Kitui", "lat": -1.3741, "lon": 38.0106},
    "ke-kwale": {"name": "Kwale", "lat": -4.1816, "lon": 39.4606},
    "ke-laikipia": {"name": "Laikipia", "lat": 0.3606, "lon": 36.7819},
    "ke-lamu": {"name": "Lamu", "lat": -2.2717, "lon": 40.9020},
    "ke-makueni": {"name": "Makueni", "lat": -1.8031, "lon": 37.6200},
    "ke-mandera": {"name": "Mandera", "lat": 3.9366, "lon": 41.8670},
    "ke-marsabit": {"name": "Marsabit", "lat": 2.3347, "lon": 37.9899},
    "ke-meru": {"name": "Meru", "lat": 0.0476, "lon": 37.6493},
    "ke-migori": {"name": "Migori", "lat": -1.0634, "lon": 34.4731},
    "ke-mombasa": {"name": "Mombasa", "lat": -4.0435, "lon": 39.6682},
    "ke-muranga": {"name": "Murang'a", "lat": -0.7833, "lon": 37.0333},
    "ke-nairobi": {"name": "Nairobi", "lat": -1.2921, "lon": 36.8219},
    "ke-nakuru": {"name": "Nakuru", "lat": -0.3031, "lon": 36.0800},
    "ke-nandi": {"name": "Nandi", "lat": 0.1833, "lon": 35.1000},
    "ke-narok": {"name": "Narok", "lat": -1.0853, "lon": 35.8711},
    "ke-nyamira": {"name": "Nyamira", "lat": -0.5667, "lon": 34.9333},
    "ke-nyandarua": {"name": "Nyandarua", "lat": -0.1807, "lon": 36.5220},
    "ke-nyeri": {"name": "Nyeri", "lat": -0.4167, "lon": 36.9500},
    "ke-samburu": {"name": "Samburu", "lat": 1.2150, "lon": 36.9540},
    "ke-siak": {"name": "Siaya", "lat": 0.0607, "lon": 34.2881},
    "ke-taita-taveta": {"name": "Taita Taveta", "lat": -3.3167, "lon": 38.3167},
    "ke-tana-river": {"name": "Tana River", "lat": -1.5000, "lon": 40.0000},
    "ke-tharaka-nithi": {"name": "Tharaka Nithi", "lat": -0.2963, "lon": 37.7238},
    "ke-trans-nzoia": {"name": "Trans Nzoia", "lat": 1.0157, "lon": 35.0062},
    "ke-turkana": {"name": "Turkana", "lat": 3.3122, "lon": 35.5658},
    "ke-uasin-gishu": {"name": "Uasin Gishu", "lat": 0.5143, "lon": 35.2698},
    "ke-vihiga": {"name": "Vihiga", "lat": 0.0762, "lon": 34.7077},
    "ke-wajir": {"name": "Wajir", "lat": 1.7471, "lon": 40.0573},
    "ke-west-pokot": {"name": "West Pokot", "lat": 1.6210, "lon": 35.2700}
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

        # =========================
        # WEATHER + ALERTS
        # =========================
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

            # =========================
            # MARKET DATA
            # =========================
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

        # =========================
        # GRAPH-RAG DISEASE + CASES
        # =========================

        disease_points = [];
        case_points = [];

        # Build region → case map
        region_case_map = {};

        for cs in [root -->][?:CaseStudy] {
            region_key = normalize_region(cs.region);
            rid = "ke-" + region_key;

            if not (rid in region_case_map) {
                region_case_map[rid] = [];
            }

            region_case_map[rid] = region_case_map[rid] + [cs];
        }

        # Traverse diseases properly
        for d in [root -->][?:DiseaseDoc] {

            if self.disease_filter and self.disease_filter.lower() not in d.disease_name.lower() {
                continue;
            }

            for rid in KENYA_REGIONS {

                coords = KENYA_REGIONS[rid];

                # === CASE LINK ===
                related_cases = [];
                case_count = 0;

                if rid in region_case_map {
                    for cs in region_case_map[rid] {
                        if (
                            cs.crop
                            and normalize_crop(cs.crop) == normalize_crop(self.crop)
                            and cs.diagnosis
                            and d.disease_name
                            and cs.diagnosis.lower() in d.disease_name.lower()
                        ) {
                            related_cases = related_cases + [cs];
                            case_count += 1;
                        }
                    }
                }

                # === WEATHER LINK ===
                weather_risk = "low";

                for wp in weather_points {
                    if wp.region_id == rid {
                        weather_risk = wp.disease_risk_level.lower();
                    }
                }

                # === GRAPH-RAG SCORING ===
                risk_score = case_count;

                if weather_risk == "high" {
                    risk_score += 3;
                } elif weather_risk == "medium" {
                    risk_score += 1;
                }

                risk_level = "low";
                if risk_score >= 4 {
                    risk_level = "high";
                } elif risk_score >= 2 {
                    risk_level = "medium";
                }

                disease_points = disease_points + [MapDiseasePoint(
                    region_id=rid,
                    region_name=coords.get("name", rid),
                    lat=coords.get("lat", 0.0),
                    lon=coords.get("lon", 0.0),
                    disease_name=d.disease_name,
                    cases_reported=case_count,
                    risk_level=risk_level,
                    radius=15000 + (risk_score * 2000)
                )];

                # === CASE POINTS ===
                for cs in related_cases {

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
            }
        }

        payload.disease_points = disease_points;
        payload.case_points = case_points;

        report payload;
    }
}