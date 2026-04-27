# Graph-RAG Models for Agricultural Knowledge Graph
# This file defines the graph structure for connecting crops, diseases, pests, 
# treatments, regions, and case studies

include utils;

# ============================================
# GRAPH NODES
# ============================================

node Crop {
    has crop_id: str;
    has crop_name: str;
    has common_names: list[str, ...] = [];
    has description: str = "";
    has growing_season: str = "";
    has created_at: str = get_current_datetime();
}

node Disease {
    has disease_id: str;
    has disease_name: str;
    has disease_type: str = "disease";  # "disease", "pest", "nutrient_deficiency"
    has description: str = "";
    has symptoms: str = "";
    has severity: str = "medium";  # "low", "medium", "high"
    has created_at: str = get_current_datetime();
}

node Pest {
    has pest_id: str;
    has pest_name: str;
    has common_names: list[str, ...] = [];
    has description: str = "";
    has symptoms: str = "";
    has life_cycle: str = "";
    has created_at: str = get_current_datetime();
}

node Treatment {
    has treatment_id: str;
    has treatment_name: str;
    has treatment_type: str = "";  # "chemical", "biological", "cultural", "mechanical"
    has description: str = "";
    has application_method: str = "";
    has dosage: str = "";
    has price_kes: float = 0.0;
    has availability: str = "";
    has created_at: str = get_current_datetime();
}

node Region {
    has region_id: str;
    has region_name: str;
    has county: str = "";
    has sub_county: str = "";
    has latitude: float = 0.0;
    has longitude: float = 0.0;
    has agro_zone: str = "";
    has rainfall_mm: float = 0.0;
    has temp_range_c: str = "";
    has created_at: str = get_current_datetime();
}

node GraphCaseStudy {
    has case_id: str;
    has title: str;
    has description: str;
    has farmer_story: str = "";
    has outcome: str = "";
    has success: bool = True;
    has cost_kes: float = 0.0;
    has timeline_days: int = 0;
    has created_at: str = get_current_datetime();
}

# ============================================
# GRAPH EDGES WITH PROPERTIES
# ============================================

edge AFFECTED_BY {
    has severity: str = "medium";  # "low", "medium", "high"
    has frequency: str = "";  # "common", "occasional", "rare"
    has season: str = "";  # when this typically occurs
}

edge OCCURS_IN {
    has prevalence_pct: float = 0.0;  # percentage of occurrence in this region
    has cases_reported: int = 0;
    has last_outbreak: str = "";
    has risk_level: str = "medium";  # "low", "medium", "high"
}

edge TREATED_WITH {
    has effectiveness_pct: float = 0.0;  # 0-100
    has application_timing: str = "";
    has cost_kes: float = 0.0;
    has recommendation_level: str = "recommended";  # "highly_recommended", "recommended", "alternative"
}

edge AVAILABLE_IN {
    has price_kes: float = 0.0;
    has stock_level: str = "";  # "high", "medium", "low", "out_of_stock"
    has suppliers: list[str, ...] = [];
}

edge CASE_STUDY_OF {
    has success_rate_pct: float = 0.0;
    has recovery_time_days: int = 0;
}

edge GROWS_IN {
    has suitability: str = "suitable";  # "highly_suitable", "suitable", "marginal"
    has yield_potential: str = "";
}

edge SIMILAR_TO {
    has similarity_score: float = 0.0;  # 0-1
    has shared_symptoms: list[str, ...] = [];
}

# ============================================
# GRAPH QUERY RESULT OBJECTS
# ============================================

obj DiseaseForCrop {
    has disease_id: str;
    has disease_name: str;
    has severity: str;
    has symptoms: str;
    has treatments: list[str, ...] = [];
}

obj TreatmentForDisease {
    has treatment_id: str;
    has treatment_name: str;
    has effectiveness_pct: float;
    has cost_kes: float;
    has application: str;
}

obj CaseStudyForRegion {
    has case_id: str;
    has title: str;
    has disease_name: str;
    has outcome: str;
    has success: bool;
}

obj RegionalDiseaseInfo {
    has disease_name: str;
    has prevalence_pct: float;
    has cases_reported: int;
    has risk_level: str;
    has recommended_treatments: list[str, ...] = [];
}

obj GraphQueryResult {
    has query_type: str;
    has results: list[dict, ...] = [];
    has total_matches: int = 0;
}
