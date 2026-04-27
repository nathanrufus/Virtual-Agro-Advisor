# RAG Knowledge Base for agroAdvisor
# Contains diseases, pests, treatments data

include utils;
include intergrations;

sv import from backend.models {
    DiseaseDoc,
    CaseStudy
}

# ============================================
# DISEASE KNOWLEDGE BASE
# ============================================

def seed_diseases() {
    
    # DISEASE 1: Nitrogen Deficiency
    disease_1 = DiseaseDoc(
        disease_id="N_DEF",
        disease_name="Nitrogen Deficiency",
        description="""
        Nitrogen deficiency in maize causes progressive yellowing of leaves.
        Starts from lower leaves and moves upward. The entire leaf may turn yellow
        without spots. Plant height is reduced. This is very common in Kiambu, Nakuru,
        and Nyeri regions after continuous cropping without fertilizer application.
        Nitrogen is essential for leaf growth and protein synthesis.
        """,
        symptoms="Yellowing leaves starting from lower leaves moving upward. Overall pale appearance. Stunted growth. Purple tints in severe cases. Thin stalks.",
        treatments="Apply urea fertilizer (46% N) at 200-250 kg/ha. Apply DAP (18-46-0) at 150-200 kg/ha. Apply farm yard manure 3-5 tons/acre. Second application at V6-V8 growth stage. Foliar spray of urea solution (5%)."
    );
    root ++> disease_1;
    
    # DISEASE 2: Maize Streak Virus
    disease_2 = DiseaseDoc(
        disease_id="MSV",
        disease_name="Maize Streak Virus",
        description="""
        Maize Streak Virus causes distinctive yellowing and white streaks along
        the main leaf veins. Plants are severely stunted with very reduced grain
        production. The disease is transmitted by leafhoppers. Very common in Kiambu
        during March-April. No cure exists - management is through resistant varieties
        and vector control.
        """,
        symptoms="Yellow/white streaks along leaf veins in characteristic pattern. Severe stunting of plant. Premature maturity. Reduced grain size. Plant death in severe cases.",
        treatments="Use resistant varieties (H614, H516, H625). Control leafhoppers with appropriate insecticides. Remove infected plants immediately. Avoid planting near infected fields. Crop rotation away from maize for 1-2 seasons."
    );
    root ++> disease_2;
    
    # DISEASE 3: Northern Corn Leaf Blight
    disease_3 = DiseaseDoc(
        disease_id="NCLB",
        disease_name="Northern Corn Leaf Blight",
        description="""
        Fungal disease caused by Exserohilum turcicum. Causes long, narrow lesions
        on maize leaves that are gray-brown in color. Common in cool, wet highland
        areas like Nyeri and Muranga. The disease spreads rapidly in humid conditions.
        Can significantly reduce yields if not managed.
        """,
        symptoms="Long, narrow gray-brown lesions on leaves. Lesions appear first on lower leaves. Chlorotic halo around lesions. Lesions may merge causing leaf death. Affected leaves dry and hang down.",
        treatments="Use resistant varieties. Spray with Mancozeb or Tebuconazole fungicide starting when disease first appears. Avoid overhead irrigation. Improve spacing for air circulation. Remove infected leaves and plant residues."
    );
    root ++> disease_3;
    
    # DISEASE 4: Maize Rust
    disease_4 = DiseaseDoc(
        disease_id="RUST",
        disease_name="Maize Rust",
        description="""
        Common fungal disease in East Africa. Causes rusty pustules on leaf surfaces.
        Found in most maize growing regions of Kenya. Less damaging than leaf blight
        but can reduce yield in severe cases. More common in humid conditions.
        """,
        symptoms="Rust-colored pustules on upper leaf surface. Pustules appear as small brown bumps. May appear on leaf sheath and stalk. Premature leaf senescence. Reduced photosynthesis.",
        treatments="Use tolerant varieties. Fungicide spray if severe (Mancozeb, Sulfur). Good field sanitation. Crop rotation. Proper spacing and balanced fertilization."
    );
    root ++> disease_4;
    
    # DISEASE 5: Maize Lethal Necrosis
    disease_5 = DiseaseDoc(
        disease_id="MLN",
        disease_name="Maize Lethal Necrosis",
        description="""
        Serious viral disease that causes rapid plant death. Combination of
        Maize chlorotic mottle virus (MCMV) and Maize dwarf mosaic virus (MDMV).
        Emerging threat in Kenya. Plant death occurs within weeks of infection.
        """,
        symptoms="Rapid wilting of plant. Necrotic spots on leaves. Plant death within 2-3 weeks. No recovery possible. Severe stunting if plant survives initial infection.",
        treatments="Use resistant varieties. Vector control (aphids). Remove infected plants immediately. Sanitation of tools and equipment. Avoid planting susceptible varieties in high-risk areas."
    );
    root ++> disease_5;
    
    # DISEASE 6: Beans - Anthracnose
    disease_6 = DiseaseDoc(
        disease_id="ANTH",
        disease_name="Bean Anthracnose",
        description="""
        Fungal disease affecting beans (Colletotrichum species). Causes dark sunken
        lesions on pods, leaves, and stems. High moisture and moderate temperatures
        favor disease development. Can cause total crop loss if not controlled.
        """,
        symptoms="Small dark circular lesions on leaves and pods. Lesions have concentric rings. Severe infection causes leaf drop. Pod damage makes beans unmarketable. Stem cankers.",
        treatments="Use disease-free seeds. Avoid overhead irrigation. Improve air circulation. Remove infected plant material. Apply fungicides if available. Crop rotation (avoid beans for 2-3 years)."
    );
    root ++> disease_6;
    
    print(f"[RAG] Seeded 6 diseases");
}

def seed_case_studies() {
    
    # CASE STUDY 1: Kiambu Nitrogen Deficiency Success
    case_1 = CaseStudy(
        case_id="CS001",
        crop="maize",
        region="kiambu",
        problem="Farmer noticed yellowing of maize leaves in March",
        diagnosis="Nitrogen deficiency after continuous maize cropping",
        outcome="Applied urea at V6, recovery in 2 weeks, good harvest"
    );
    root ++> case_1;
    
    # CASE STUDY 2: MSV in Nakuru
    case_2 = CaseStudy(
        case_id="CS002",
        crop="maize",
        region="nakuru",
        problem="White streaks on maize leaves in April, stunted growth",
        diagnosis="Maize Streak Virus",
        outcome="Switched to H614 resistant variety for next season, avoided loss"
    );
    root ++> case_2;
    
    # CASE STUDY 3: NCLB in Nyeri
    case_3 = CaseStudy(
        case_id="CS003",
        crop="maize",
        region="nyeri",
        problem="Brown lesions on leaves after heavy rains",
        diagnosis="Northern Corn Leaf Blight",
        outcome="Improved spacing, sprayed Mancozeb, saved 70% of crop"
    );
    root ++> case_3;
    
    # CASE STUDY 4: Bean Anthracnose in Kiambu
    case_4 = CaseStudy(
        case_id="CS004",
        crop="beans",
        region="kiambu",
        problem="Dark spots on bean pods before harvest",
        diagnosis="Anthracnose",
        outcome="Used disease-free seeds next season, problem resolved"
    );
    root ++> case_4;
    
    print(f"[RAG] Seeded 4 case studies");
}

walker:pub SeedKnowledgeBase {
    
    can run with Root entry {
        print("[RAG] Initializing knowledge base...");
        
        seed_diseases();
        seed_case_studies();
        
        print("[RAG] Knowledge base initialized");
        
        report {
            "status": "success",
            "message": "Knowledge base seeded with diseases and case studies"
        };
    }
}

with entry {
    #  Uncomment to auto-seed on startup:
    # SeedKnowledgeBase();
}