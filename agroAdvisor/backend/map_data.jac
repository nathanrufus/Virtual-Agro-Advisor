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
    has region: str = "";

    can run with Root entry {
        payload = MapDataPayload();

        # Fetch FRESH weather for this region
        if self.region {
            raw_weather = fetch_weather_raw(self.region);
            weather_data = build_weather_snapshot_data(raw_weather, self.region);
            
            region_id = normalize_region_to_id(self.region);
            coords = get_coords(region_id);
            
            if coords {
                weather_points = [MapWeatherPoint(
                    region_id=region_id,
                    region_name=self.region,
                    lat=coords.get("lat", 0.0),
                    lon=coords.get("lon", 0.0),
                    temperature_c=weather_data["temperature_c"],
                    humidity_pct=weather_data["humidity_pct"],
                    disease_risk_level=weather_data["disease_risk_level"],
                    disease_risk_score=weather_data["disease_risk_score"],
                    risk_color=risk_to_color(weather_data["disease_risk_level"]),
                    summary=weather_data["summary"]
                )];
                
                payload.weather_points = weather_points;
                
                if weather_data["disease_risk_level"] == "HIGH" {
                    alert_points = [MapAlertPoint(
                        alert_id="alert_" + region_id,
                        region_name=self.region,
                        lat=coords.get("lat", 0.0),
                        lon=coords.get("lon", 0.0),
                        alert_type="disease_risk",
                        alert_message="High disease risk: " + weather_data["disease_risk_reason"],
                        severity="high"
                    )];
                    payload.alert_points = alert_points;
                }
            }
        }

        # Fetch FRESH market data for this crop/region
        if self.crop and self.region {
            kamis_result = fetch_best_kamis_price(self.crop, self.region);
            
            if kamis_result.get("success") {
                region_id = normalize_region_to_id(self.region);
                coords = get_coords(region_id);
                
                if coords {
                    market_points = [MapMarketPoint(
                        region_id=region_id,
                        region_name=self.region,
                        market_name=kamis_result.get("best_market", self.region),
                        lat=coords.get("lat", 0.0),
                        lon=coords.get("lon", 0.0),
                        crop=self.crop,
                        price=kamis_result.get("best_price", 0.0),
                        currency="KES",
                        unit="kg",
                        trend=price_to_trend(kamis_result.get("best_price", 0.0)),
                        price_color=price_to_color(kamis_result.get("best_price", 0.0))
                    )];
                    payload.market_points = market_points;
                }
            }
        }

        # Show ONLY diseases for this crop
        disease_points = [];
        case_points = [];
        
        crop_key = normalize_crop(self.crop);
        region_key = normalize_region(self.region);
        region_id = normalize_region_to_id(self.region);
        coords = get_coords(region_id);

        if not coords {
            report payload;
            disengage;
        }

        # Get diseases for this crop from graph
        for d in [root -->][?:DiseaseDoc] {
            if self.disease_filter and self.disease_filter.lower() not in d.disease_name.lower() {
                continue;
            }
            
            # Only show if disease affects this crop
            # Check description for crop mention
            if crop_key.lower() not in d.description.lower() and crop_key.lower() not in d.disease_name.lower() {
                continue;
            }

            # Get cases for this disease in this region
            case_count = 0;
            related_cases = [];
            
            for cs in [root -->][?:CaseStudy] {
                cs_region_key = normalize_region(cs.region);
                cs_crop_key = normalize_crop(cs.crop);
                
                if cs_region_key == region_key and cs_crop_key == crop_key {
                    if cs.diagnosis and d.disease_name and cs.diagnosis.lower() in d.disease_name.lower() {
                        case_count += 1;
                        related_cases = related_cases + [cs];
                    }
                }
            }

            # Get weather risk for this region
            weather_risk = "low";
            if payload.weather_points and len(payload.weather_points) > 0 {
                weather_risk = payload.weather_points[0].disease_risk_level.lower();
            }

            # Score the disease
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
                region_id=region_id,
                region_name=coords.get("name", self.region),
                lat=coords.get("lat", 0.0),
                lon=coords.get("lon", 0.0),
                disease_name=d.disease_name,
                cases_reported=case_count,
                risk_level=risk_level,
                radius=15000 + (risk_score * 2000)
            )];

            # Add case points
            for cs in related_cases {
                case_points = case_points + [MapCasePoint(
                    case_id=cs.case_id,
                    region_name=cs.region,
                    lat=coords.get("lat", 0.0),
                    lon=coords.get("lon", 0.0),
                    title="Case: " + cs.crop + " - " + cs.diagnosis,
                    disease_name=cs.diagnosis,
                    outcome=cs.outcome,
                    success=True
                )];
            }
        }

        payload.disease_points = disease_points;
        payload.case_points = case_points;

        report payload;
    }
}