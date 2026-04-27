# Graph-RAG Knowledge Seeding
include utils;
include backend.models;

walker:pub SeedGraphRAG {
    
    can run with Root entry {
        print("[GRAPH-RAG] Seeding knowledge graph...");
        
        # STEP 1: Create Crops
        maize = Crop(
            crop_id="CROP_001",
            crop_name="Maize",
            scientific_name="Zea mays",
            common_varieties=["H614", "H516", "H625", "DH04"],
            growing_season="Long rains (March-May), Short rains (Oct-Dec)",
            maturity_days=120
        );
        root ++> maize;
        
        beans = Crop(
            crop_id="CROP_002",
            crop_name="Beans",
            scientific_name="Phaseolus vulgaris",
            common_varieties=["Rose coco", "Canadian Wonder", "Mwitemania"],
            growing_season="March-May, October-December",
            maturity_days=90
        );
        root ++> beans;
        
        # STEP 2: Create Seasons
        long_rains = Season(
            season_id="SEASON_001",
            season_name="Long Rains",
            months=["March", "April", "May"],
            typical_weather="Heavy rainfall, humid, cooler temperatures"
        );
        root ++> long_rains;
        
        short_rains = Season(
            season_id="SEASON_002",
            season_name="Short Rains",
            months=["October", "November", "December"],
            typical_weather="Moderate rainfall, warm temperatures"
        );
        root ++> short_rains;
        
        # STEP 3: Create Diseases (using existing DiseaseDoc or creating new)
        n_def = DiseaseDoc(
            disease_id="N_DEF",
            disease_name="Nitrogen Deficiency",
            description="Progressive yellowing of maize leaves from lower to upper",
            symptoms="Yellowing leaves, pale appearance, stunted growth",
            treatments="Urea fertilizer 200-250 kg/ha, DAP 150-200 kg/ha"
        );
        root ++> n_def;
        
        msv = DiseaseDoc(
            disease_id="MSV",
            disease_name="Maize Streak Virus",
            description="Viral disease causing white streaks along leaf veins",
            symptoms="Yellow/white streaks, severe stunting, reduced grain",
            treatments="Resistant varieties (H614, H516), control leafhoppers"
        );
        root ++> msv;
        
        nclb = DiseaseDoc(
            disease_id="NCLB",
            disease_name="Northern Corn Leaf Blight",
            description="Fungal disease with long narrow lesions",
            symptoms="Gray-brown lesions, chlorotic halo, leaf death",
            treatments="Resistant varieties, Mancozeb fungicide, improve spacing"
        );
        root ++> nclb;
        
        # STEP 4: Create Treatments
        urea = Treatment(
            treatment_id="TREAT_001",
            treatment_name="Urea Fertilizer",
            method="chemical",
            effectiveness=0.85,
            cost_kes=2500.0,
            timing="V6-V8 growth stage"
        );
        root ++> urea;
        
        mancozeb = Treatment(
            treatment_id="TREAT_002",
            treatment_name="Mancozeb Fungicide",
            method="chemical",
            effectiveness=0.80,
            cost_kes=1500.0,
            timing="At first sign of disease"
        );
        root ++> mancozeb;
        
        # STEP 5: Create Relationships
        
        # Disease → Crop
        n_def +>: AFFECTS_CROP() :+> maize;
        msv +>: AFFECTS_CROP() :+> maize;
        nclb +>: AFFECTS_CROP() :+> maize;
        
        # Disease → Season
        n_def +>: OCCURS_IN_SEASON() :+> long_rains;
        n_def +>: OCCURS_IN_SEASON() :+> short_rains;
        msv +>: OCCURS_IN_SEASON() :+> long_rains;
        nclb +>: OCCURS_IN_SEASON() :+> long_rains;
        
        # Disease → Treatment
        n_def +>: TREATED_BY() :+> urea;
        nclb +>: TREATED_BY() :+> mancozeb;
        
        # Disease co-occurrence
        msv +>: CO_OCCURS_WITH() :+> n_def;  # Often seen together
        
        print("[GRAPH-RAG] Knowledge graph seeded successfully!");
        print(f"[GRAPH-RAG]   - Crops: 2");
        print(f"[GRAPH-RAG]   - Seasons: 2");
        print(f"[GRAPH-RAG]   - Diseases: 3");
        print(f"[GRAPH-RAG]   - Treatments: 2");
        print(f"[GRAPH-RAG]   - Relationships: 10+");
        
        report {
            "status": "success",
            "message": "Graph-RAG knowledge base created"
        };
    }
}