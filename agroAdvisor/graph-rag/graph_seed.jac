# Graph-RAG Knowledge Base Seeder
# Populates the agricultural knowledge graph with crops, diseases, treatments, regions, and relationships

include utils;
include backend.graph_models;

def seed_graph_knowledge_base() {
    """
    Seeds the complete knowledge graph with:
    - Crops
    - Diseases & Pests
    - Treatments
    - Regions
    - Case Studies
    - All relationships between them
    """
    
    print("\n[GRAPH-RAG SEED] ========================================");
    print("[GRAPH-RAG SEED] INITIALIZING KNOWLEDGE GRAPH");
    print("[GRAPH-RAG SEED] ========================================\n");
    
    # ============================================
    # 1. CREATE CROP NODES
    # ============================================
    
    print("[GRAPH-RAG SEED] Creating Crop nodes...");
    
    maize = Crop(
        crop_id="crop_maize",
        crop_name="Maize",
        common_names=["Corn", "Mahindi"],
        description="Major cereal crop in Kenya, staple food",
        growing_season="March-July (long rains), October-December (short rains)"
    );
    root ++> maize;
    
    beans = Crop(
        crop_id="crop_beans",
        crop_name="Beans",
        common_names=["Common beans", "Maharagwe"],
        description="Important legume crop, protein source",
        growing_season="March-June, October-December"
    );
    root ++> beans;
    
    print("[GRAPH-RAG SEED]   ✓ Created 2 crops");
    
    # ============================================
    # 2. CREATE REGION NODES
    # ============================================
    
    print("[GRAPH-RAG SEED] Creating Region nodes...");
    
    kiambu = Region(
        region_id="ke-kiambu",
        region_name="Kiambu",
        county="Kiambu",
        latitude=-1.1714,
        longitude=36.8356,
        agro_zone="Upper Midland",
        rainfall_mm=1200.0,
        temp_range_c="12-24"
    );
    root ++> kiambu;
    
    nakuru = Region(
        region_id="ke-nakuru",
        region_name="Nakuru",
        county="Nakuru",
        latitude=-0.3031,
        longitude=36.0800,
        agro_zone="Upper Midland",
        rainfall_mm=900.0,
        temp_range_c="10-26"
    );
    root ++> nakuru;
    
    nyeri = Region(
        region_id="ke-nyeri",
        region_name="Nyeri",
        county="Nyeri",
        latitude=-0.4197,
        longitude=36.9475,
        agro_zone="Upper Highland",
        rainfall_mm=1400.0,
        temp_range_c="10-22"
    );
    root ++> nyeri;
    
    print("[GRAPH-RAG SEED]   ✓ Created 3 regions");
    
    # ============================================
    # 3. CREATE DISEASE NODES
    # ============================================
    
    print("[GRAPH-RAG SEED] Creating Disease nodes...");
    
    n_deficiency = Disease(
        disease_id="dis_n_def",
        disease_name="Nitrogen Deficiency",
        disease_type="nutrient_deficiency",
        description="Nitrogen deficiency causes progressive yellowing of leaves starting from lower leaves",
        symptoms="Yellowing leaves starting from lower leaves moving upward. Overall pale appearance. Stunted growth. Purple tints in severe cases. Thin stalks.",
        severity="medium"
    );
    root ++> n_deficiency;
    
    msv = Disease(
        disease_id="dis_msv",
        disease_name="Maize Streak Virus",
        disease_type="disease",
        description="Viral disease causing distinctive yellowing and white streaks along leaf veins",
        symptoms="Yellow/white streaks along leaf veins in characteristic pattern. Severe stunting of plant. Premature maturity.",
        severity="high"
    );
    root ++> msv;
    
    nclb = Disease(
        disease_id="dis_nclb",
        disease_name="Northern Corn Leaf Blight",
        disease_type="disease",
        description="Fungal disease causing long, narrow lesions on maize leaves",
        symptoms="Long, narrow gray-brown lesions on leaves. Lesions appear first on lower leaves. Chlorotic halo around lesions.",
        severity="medium"
    );
    root ++> nclb;
    
    rust = Disease(
        disease_id="dis_rust",
        disease_name="Maize Rust",
        disease_type="disease",
        description="Common fungal disease causing rusty pustules on leaf surfaces",
        symptoms="Rust-colored pustules on upper leaf surface. Pustules appear as small brown bumps. Premature leaf senescence.",
        severity="low"
    );
    root ++> rust;
    
    anthracnose = Disease(
        disease_id="dis_anthracnose",
        disease_name="Bean Anthracnose",
        disease_type="disease",
        description="Fungal disease affecting beans, causes dark sunken lesions on pods",
        symptoms="Small dark circular lesions on leaves and pods. Lesions have concentric rings. Severe infection causes leaf drop.",
        severity="high"
    );
    root ++> anthracnose;
    
    faw = Disease(
        disease_id="pest_faw",
        disease_name="Fall Armyworm",
        disease_type="pest",
        description="Major pest that feeds on maize leaves and developing cobs",
        symptoms="Window-pane feeding on leaves. Frass in whorl. Holes in leaves. Damage to developing cobs.",
        severity="high"
    );
    root ++> faw;
    
    print("[GRAPH-RAG SEED]   ✓ Created 6 diseases/pests");
    
    # ============================================
    # 4. CREATE TREATMENT NODES
    # ============================================
    
    print("[GRAPH-RAG SEED] Creating Treatment nodes...");
    
    urea = Treatment(
        treatment_id="treat_urea",
        treatment_name="Urea Fertilizer (46% N)",
        treatment_type="chemical",
        description="Nitrogen fertilizer for correcting N deficiency",
        application_method="Top dressing or basal application",
        dosage="200-250 kg/ha",
        price_kes=3500.0,
        availability="Widely available"
    );
    root ++> urea;
    
    dap = Treatment(
        treatment_id="treat_dap",
        treatment_name="DAP Fertilizer (18-46-0)",
        treatment_type="chemical",
        description="Compound fertilizer with nitrogen and phosphorus",
        application_method="Basal application at planting",
        dosage="150-200 kg/ha",
        price_kes=4200.0,
        availability="Widely available"
    );
    root ++> dap;
    
    manure = Treatment(
        treatment_id="treat_manure",
        treatment_name="Farm Yard Manure",
        treatment_type="biological",
        description="Organic fertilizer from animal waste",
        application_method="Incorporate into soil before planting",
        dosage="3-5 tons/acre",
        price_kes=1500.0,
        availability="Locally available"
    );
    root ++> manure;
    
    resistant_var = Treatment(
        treatment_id="treat_resist_var",
        treatment_name="Resistant Varieties (H614, H516)",
        treatment_type="cultural",
        description="Maize varieties resistant to MSV",
        application_method="Use resistant seed at planting",
        dosage="25 kg/ha seed rate",
        price_kes=8000.0,
        availability="Agrovets, KALRO"
    );
    root ++> resistant_var;
    
    mancozeb = Treatment(
        treatment_id="treat_mancozeb",
        treatment_name="Mancozeb Fungicide",
        treatment_type="chemical",
        description="Broad-spectrum fungicide for leaf diseases",
        application_method="Foliar spray",
        dosage="2-3 kg/ha in 400-600L water",
        price_kes=800.0,
        availability="Agrovets"
    );
    root ++> mancozeb;
    
    bt_spray = Treatment(
        treatment_id="treat_bt",
        treatment_name="Bt (Bacillus thuringiensis) Spray",
        treatment_type="biological",
        description="Biological insecticide for Fall Armyworm",
        application_method="Spray into maize whorl",
        dosage="1-2 L/ha",
        price_kes=1200.0,
        availability="Selected agrovets"
    );
    root ++> bt_spray;
    
    print("[GRAPH-RAG SEED]   ✓ Created 6 treatments");
    
    # ============================================
    # 5. CREATE CASE STUDY NODES
    # ============================================
    
    print("[GRAPH-RAG SEED] Creating Case Study nodes...");
    
    case1 = GraphCaseStudy(
        case_id="case_001",
        title="N-Deficiency Recovery in Kiambu",
        description="Farmer noticed yellowing of maize in March 2024",
        farmer_story="Applied urea at V6 stage after observing pale yellow leaves on lower leaves moving upward",
        outcome="Full recovery in 2 weeks, achieved 4.5 tons/ha yield",
        success=True,
        cost_kes=3500.0,
        timeline_days=14
    );
    root ++> case1;
    
    case2 = GraphCaseStudy(
        case_id="case_002",
        title="MSV Prevention in Nakuru",
        description="Switched to resistant variety after MSV outbreak",
        farmer_story="Lost 60% of crop to MSV in 2023, switched to H614 variety for 2024 season",
        outcome="No MSV infection in 2024, normal yield achieved",
        success=True,
        cost_kes=8000.0,
        timeline_days=120
    );
    root ++> case2;
    
    case3 = GraphCaseStudy(
        case_id="case_003",
        title="NCLB Control in Nyeri",
        description="Leaf blight outbreak after heavy rains",
        farmer_story="Sprayed Mancozeb twice at 14-day intervals, improved plant spacing",
        outcome="Saved 70% of crop, yield reduced to 3.2 tons/ha",
        success=True,
        cost_kes=1600.0,
        timeline_days=28
    );
    root ++> case3;
    
    case4 = GraphCaseStudy(
        case_id="case_004",
        title="FAW Management in Kiambu",
        description="Fall Armyworm detected at V4 stage",
        farmer_story="Applied Bt spray to whorl every 5 days for 3 applications",
        outcome="Controlled infestation, minor leaf damage, yield 4 tons/ha",
        success=True,
        cost_kes=2400.0,
        timeline_days=15
    );
    root ++> case4;
    
    print("[GRAPH-RAG SEED]   ✓ Created 4 case studies");
    
    # ============================================
    # 6. CREATE RELATIONSHIPS (EDGES)
    # ============================================
    
    print("\n[GRAPH-RAG SEED] Creating relationships...");
    
    # Crop -> Disease relationships (AFFECTED_BY)
    print("[GRAPH-RAG SEED]   Creating AFFECTED_BY edges...");
    
    maize +>: AFFECTED_BY(severity="medium", frequency="common", season="March-July") :+> n_deficiency;
    maize +>: AFFECTED_BY(severity="high", frequency="common", season="March-April") :+> msv;
    maize +>: AFFECTED_BY(severity="medium", frequency="occasional", season="May-July") :+> nclb;
    maize +>: AFFECTED_BY(severity="low", frequency="occasional", season="June-August") :+> rust;
    maize +>: AFFECTED_BY(severity="high", frequency="common", season="Year-round") :+> faw;
    
    beans +>: AFFECTED_BY(severity="high", frequency="common", season="April-June") :+> anthracnose;
    
    # Disease -> Region relationships (OCCURS_IN)
    print("[GRAPH-RAG SEED]   Creating OCCURS_IN edges...");
    
    n_deficiency +>: OCCURS_IN(prevalence_pct=65.0, cases_reported=23, risk_level="medium") :+> kiambu;
    n_deficiency +>: OCCURS_IN(prevalence_pct=45.0, cases_reported=12, risk_level="medium") :+> nakuru;
    n_deficiency +>: OCCURS_IN(prevalence_pct=55.0, cases_reported=18, risk_level="medium") :+> nyeri;
    
    msv +>: OCCURS_IN(prevalence_pct=40.0, cases_reported=15, risk_level="high") :+> kiambu;
    msv +>: OCCURS_IN(prevalence_pct=35.0, cases_reported=10, risk_level="high") :+> nakuru;
    
    nclb +>: OCCURS_IN(prevalence_pct=30.0, cases_reported=8, risk_level="medium") :+> nyeri;
    nclb +>: OCCURS_IN(prevalence_pct=20.0, cases_reported=5, risk_level="low") :+> kiambu;
    
    faw +>: OCCURS_IN(prevalence_pct=55.0, cases_reported=28, risk_level="high") :+> kiambu;
    faw +>: OCCURS_IN(prevalence_pct=45.0, cases_reported=20, risk_level="high") :+> nakuru;
    
    anthracnose +>: OCCURS_IN(prevalence_pct=50.0, cases_reported=12, risk_level="high") :+> kiambu;
    
    # Disease -> Treatment relationships (TREATED_WITH)
    print("[GRAPH-RAG SEED]   Creating TREATED_WITH edges...");
    
    n_deficiency +>: TREATED_WITH(
        effectiveness_pct=85.0,
        application_timing="V6-V8 stage",
        cost_kes=3500.0,
        recommendation_level="highly_recommended"
    ) :+> urea;
    
    n_deficiency +>: TREATED_WITH(
        effectiveness_pct=90.0,
        application_timing="Basal at planting",
        cost_kes=4200.0,
        recommendation_level="highly_recommended"
    ) :+> dap;
    
    n_deficiency +>: TREATED_WITH(
        effectiveness_pct=70.0,
        application_timing="Before planting",
        cost_kes=1500.0,
        recommendation_level="recommended"
    ) :+> manure;
    
    msv +>: TREATED_WITH(
        effectiveness_pct=95.0,
        application_timing="Use resistant seed",
        cost_kes=8000.0,
        recommendation_level="highly_recommended"
    ) :+> resistant_var;
    
    nclb +>: TREATED_WITH(
        effectiveness_pct=75.0,
        application_timing="At first symptoms, repeat 14 days",
        cost_kes=800.0,
        recommendation_level="recommended"
    ) :+> mancozeb;
    
    rust +>: TREATED_WITH(
        effectiveness_pct=65.0,
        application_timing="Early infection",
        cost_kes=800.0,
        recommendation_level="alternative"
    ) :+> mancozeb;
    
    faw +>: TREATED_WITH(
        effectiveness_pct=80.0,
        application_timing="Early morning spray to whorl",
        cost_kes=1200.0,
        recommendation_level="highly_recommended"
    ) :+> bt_spray;
    
    # Treatment -> Region availability (AVAILABLE_IN)
    print("[GRAPH-RAG SEED]   Creating AVAILABLE_IN edges...");
    
    urea +>: AVAILABLE_IN(price_kes=3500.0, stock_level="high", suppliers=["Yara", "MEA"]) :+> kiambu;
    dap +>: AVAILABLE_IN(price_kes=4200.0, stock_level="high", suppliers=["Yara", "MEA"]) :+> kiambu;
    mancozeb +>: AVAILABLE_IN(price_kes=800.0, stock_level="medium", suppliers=["Local agrovets"]) :+> kiambu;
    
    # Case Study relationships
    print("[GRAPH-RAG SEED]   Creating CASE_STUDY_OF edges...");
    
    n_deficiency +>: CASE_STUDY_OF(success_rate_pct=78.0, recovery_time_days=14) :+> case1;
    msv +>: CASE_STUDY_OF(success_rate_pct=95.0, recovery_time_days=120) :+> case2;
    nclb +>: CASE_STUDY_OF(success_rate_pct=70.0, recovery_time_days=28) :+> case3;
    faw +>: CASE_STUDY_OF(success_rate_pct=80.0, recovery_time_days=15) :+> case4;
    
    # Case Study -> Region
    case1 +>: OCCURS_IN(prevalence_pct=0.0, cases_reported=1, risk_level="medium") :+> kiambu;
    case2 +>: OCCURS_IN(prevalence_pct=0.0, cases_reported=1, risk_level="high") :+> nakuru;
    case3 +>: OCCURS_IN(prevalence_pct=0.0, cases_reported=1, risk_level="medium") :+> nyeri;
    case4 +>: OCCURS_IN(prevalence_pct=0.0, cases_reported=1, risk_level="high") :+> kiambu;
    
    # Disease similarity relationships (SIMILAR_TO)
    print("[GRAPH-RAG SEED]   Creating SIMILAR_TO edges...");
    
    nclb +>: SIMILAR_TO(
        similarity_score=0.7,
        shared_symptoms=["leaf lesions", "brown spots", "fungal"]
    ) :+> rust;
    
    rust +>: SIMILAR_TO(
        similarity_score=0.7,
        shared_symptoms=["leaf lesions", "brown spots", "fungal"]
    ) :+> nclb;
    
    # Crop -> Region suitability (GROWS_IN)
    print("[GRAPH-RAG SEED]   Creating GROWS_IN edges...");
    
    maize +>: GROWS_IN(suitability="highly_suitable", yield_potential="4-6 tons/ha") :+> kiambu;
    maize +>: GROWS_IN(suitability="suitable", yield_potential="3-5 tons/ha") :+> nakuru;
    maize +>: GROWS_IN(suitability="highly_suitable", yield_potential="5-7 tons/ha") :+> nyeri;
    
    beans +>: GROWS_IN(suitability="highly_suitable", yield_potential="1-1.5 tons/ha") :+> kiambu;
    
    print("\n[GRAPH-RAG SEED] ========================================");
    print("[GRAPH-RAG SEED] GRAPH INITIALIZATION COMPLETE");
    print("[GRAPH-RAG SEED] Summary:");
    print("[GRAPH-RAG SEED]   - 2 Crops");
    print("[GRAPH-RAG SEED]   - 3 Regions");
    print("[GRAPH-RAG SEED]   - 6 Diseases/Pests");
    print("[GRAPH-RAG SEED]   - 6 Treatments");
    print("[GRAPH-RAG SEED]   - 4 Case Studies");
    print("[GRAPH-RAG SEED]   - 50+ Relationships");
    print("[GRAPH-RAG SEED] ========================================\n");
    
    return {
        "status": "success",
        "crops": 2,
        "regions": 3,
        "diseases": 6,
        "treatments": 6,
        "case_studies": 4
    };
}

walker:pub SeedGraphRAG {
    can run with Root entry {
        result = seed_graph_knowledge_base();
        report result;
    }
}
