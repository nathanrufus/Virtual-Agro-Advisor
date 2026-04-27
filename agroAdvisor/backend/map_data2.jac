include utils;

sv import from backend.models {
    Memory,
    Session,
    WeatherSnapshot,
    MarketSnapshot,
    RegionProfile,
    HAS_WEATHER,
    HAS_MARKET
}

sv import from graph_rag.graph_models {
    Region,
    Disease,
    GraphCaseStudy,
    OCCURS_IN,
    CASE_STUDY_OF
}

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
}

obj MapDiseasePoint {
    has region_id: str;
    has region_name: str;
    has lat: float;
    has lon: float;
    has disease_id: str;
    has disease_name: str;
    has cases_reported: int;
    has prevalence_pct: float;
    has risk_level: str;
    has intensity_color: str;
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

obj MapCaseStudyPoint {
    has case_id: str;
    has region_id: str;
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
    has region_id: str;
    has region_name: str;
    has lat: float;
    has lon: float;
    has alert_type: str;
    has alert_message: str;
    has severity: str;
    has alert_color: str;
}

obj MapData {
    has weather_points: list = [];
    has disease_points: list = [];
    has market_points: list = [];
    has case_study_points: list = [];
    has alert_points: list = [];
}

walker:pub GetMapData {
    has crop: str = "maize";
    has disease_filter: str = "";

    can run with Root entry {
        map_data = MapData();

        mem_list = [root -->][?:Memory];
        if not mem_list {
            memory = Memory();
            root ++> memory;
        } else {
            memory = mem_list[0];
        };

        weather_points = [];

        for region in [root -->][?:Region] {
            weather_snap = None;

            for session in [memory ->:HAS_SESSION:->] {
                for ws in [session ->:HAS_WEATHER:->] {
                    if ws.region_id == region.region_id {
                        if not weather_snap or hours_since(ws.created_at) < hours_since(weather_snap.created_at) {
                            weather_snap = ws;
                        };
                    };
                };
            };

            if weather_snap {
                risk_color = "#22c55e";

                if weather_snap.disease_risk_level == "HIGH" {
                    risk_color = "#ef4444";
                } elif weather_snap.disease_risk_level == "MEDIUM" {
                    risk_color = "#f59e0b";
                };

                weather_points = weather_points + [MapWeatherPoint(
                    region_id=region.region_id,
                    region_name=region.region_name,
                    lat=region.latitude,
                    lon=region.longitude,
                    temperature_c=weather_snap.temperature_c,
                    humidity_pct=weather_snap.humidity_pct,
                    disease_risk_level=weather_snap.disease_risk_level,
                    disease_risk_score=weather_snap.disease_risk_score,
                    risk_color=risk_color
                )];
            };
        };

        disease_points = [];

        for region in [root -->][?:Region] {
            for disease in [region <-:OCCURS_IN:<-] {
                edge_data = [region <-:OCCURS_IN:<- disease][0];

                if self.disease_filter and self.disease_filter not in disease.disease_name.lower() {
                    continue;
                };

                intensity = edge_data.prevalence_pct or 0.0;
                alpha_val = min(0.3 + (intensity / 100.0) * 0.7, 1.0);

                intensity_color = "rgba(239, 68, 68, " + str(alpha_val) + ")";

                disease_points = disease_points + [MapDiseasePoint(
                    region_id=region.region_id,
                    region_name=region.region_name,
                    lat=region.latitude,
                    lon=region.longitude,
                    disease_id=disease.disease_id,
                    disease_name=disease.disease_name,
                    cases_reported=edge_data.cases_reported or 0,
                    prevalence_pct=edge_data.prevalence_pct or 0.0,
                    risk_level=edge_data.risk_level or "medium",
                    intensity_color=intensity_color
                )];
            };
        };

        market_points = [];

        for region in [root -->][?:Region] {
            market_snap = None;

            for session in [memory ->:HAS_SESSION:->] {
                for ms in [session ->:HAS_MARKET:->] {
                    if ms.region_id == region.region_id and ms.crop_key == normalize_crop(self.crop) {
                        if not market_snap or hours_since(ms.created_at) < hours_since(market_snap.created_at) {
                            market_snap = ms;
                        };
                    };
                };
            };

            if market_snap and market_snap.price > 0 {
                price_color = "#22c55e";
                trend = "stable";

                if market_snap.price < 30.0 {
                    price_color = "#ef4444";
                    trend = "low";
                } elif market_snap.price > 50.0 {
                    price_color = "#10b981";
                    trend = "high";
                };

                market_points = market_points + [MapMarketPoint(
                    region_id=region.region_id,
                    region_name=region.region_name,
                    market_name=market_snap.market_name or region.region_name,
                    lat=region.latitude,
                    lon=region.longitude,
                    crop=self.crop,
                    price=market_snap.price,
                    currency=market_snap.currency,
                    unit=market_snap.unit,
                    trend=trend,
                    price_color=price_color
                )];
            };
        };

        case_study_points = [];

        for region in [root -->][?:Region] {
            for case_study in [root -->][?:GraphCaseStudy] {
                for disease in [case_study ->:CASE_STUDY_OF:->] {
                    for region_check in [disease ->:OCCURS_IN:->] {
                        if region_check.region_id == region.region_id {
                            case_study_points = case_study_points + [MapCaseStudyPoint(
                                case_id=case_study.case_id,
                                region_id=region.region_id,
                                region_name=region.region_name,
                                lat=region.latitude,
                                lon=region.longitude,
                                title=case_study.title,
                                disease_name=disease.disease_name,
                                outcome=case_study.outcome,
                                success=case_study.success
                            )];
                        };
                    };
                };
            };
        };

        alert_points = [];

        for region in [root -->][?:Region] {
            for ws in [root -->][?:WeatherSnapshot] {
                if ws.region_id == region.region_id and hours_since(ws.created_at) < 24.0 {
                    if ws.disease_risk_level == "HIGH" {
                        alert_points = alert_points + [MapAlertPoint(
                            alert_id="weather_" + region.region_id,
                            region_id=region.region_id,
                            region_name=region.region_name,
                            lat=region.latitude,
                            lon=region.longitude,
                            alert_type="disease_risk",
                            alert_message="High disease risk in " + region.region_name + ": " + ws.disease_risk_reason,
                            severity="high",
                            alert_color="#ef4444"
                        )];
                    };
                };
            };

            for disease in [region <-:OCCURS_IN:<-] {
                edge_data = [region <-:OCCURS_IN:<- disease][0];

                if edge_data.cases_reported and edge_data.cases_reported > 50 {
                    alert_points = alert_points + [MapAlertPoint(
                        alert_id="outbreak_" + region.region_id + "_" + disease.disease_id,
                        region_id=region.region_id,
                        region_name=region.region_name,
                        lat=region.latitude,
                        lon=region.longitude,
                        alert_type="disease_outbreak",
                        alert_message=disease.disease_name + " outbreak: " + str(edge_data.cases_reported) + " cases in " + region.region_name,
                        severity="high",
                        alert_color="#dc2626"
                    )];
                };
            };
        };

        map_data.weather_points = weather_points;
        map_data.disease_points = disease_points;
        map_data.market_points = market_points;
        map_data.case_study_points = case_study_points;
        map_data.alert_points = alert_points;

        report map_data;
    };
}