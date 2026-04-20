walker SeedKnowledge {
    can run with Root entry {

     

        d1 = DiseaseDoc("N_DEF","Nitrogen Deficiency","Low nitrogen in soil leading to poor maize growth","Yellowing of lower leaves, stunted plants","Apply urea or manure");
        d2 = DiseaseDoc("P_DEF","Phosphorus Deficiency","Occurs in acidic soils affecting root development","Purple leaves, slow growth","Apply DAP fertilizer");
        d3 = DiseaseDoc("K_DEF","Potassium Deficiency","Nutrient imbalance in soils","Leaf edge scorching, weak stems","Apply potassium fertilizers");

        d4 = DiseaseDoc("MSV","Maize Streak Virus","Viral disease spread by leafhoppers","Yellow streaks, stunted growth","Use resistant varieties");
        d5 = DiseaseDoc("MLN","Maize Lethal Necrosis","Deadly viral disease common in East Africa","Leaf necrosis, plant death","Use certified seeds, rogue infected plants");

        d6 = DiseaseDoc("NCLB","Northern Corn Leaf Blight","Fungal disease in humid highlands","Long grey lesions","Apply fungicides");
        d7 = DiseaseDoc("SCLB","Southern Corn Leaf Blight","Fungal disease in warm areas","Small tan lesions","Use resistant varieties");

        d8 = DiseaseDoc("RUST","Maize Rust","Fungal disease in mid-altitudes","Brown pustules","Apply fungicides");
        d9 = DiseaseDoc("SMUT","Maize Smut","Fungal disease causing galls","Swollen black galls","Remove infected plants");

        d10 = DiseaseDoc("EAR_ROT","Ear Rot","Fungal infection affecting maize cobs","Rotten kernels","Dry maize properly");

    

        d11 = DiseaseDoc("FAW","Fall Armyworm","Highly destructive pest affecting maize","Holes in leaves, frass","Apply pesticides early");
        d12 = DiseaseDoc("STALK_BORER","Stalk Borer","Larvae bore into stems","Dead hearts, weak stems","Destroy residues, apply insecticides");

        d13 = DiseaseDoc("APHIDS","Aphids","Sap-sucking insects","Curled leaves, sticky residue","Use neem or insecticides");
        d14 = DiseaseDoc("THRIPS","Thrips","Small insects damaging crops","Silvery leaves","Use insecticides");

    

        d15 = DiseaseDoc("BB","Bean Blight","Bacterial disease in beans","Leaf spots, wilting","Use clean seeds");
        d16 = DiseaseDoc("ANTH","Anthracnose","Fungal disease in beans","Dark lesions","Apply fungicides");
        d17 = DiseaseDoc("RUST_BEAN","Bean Rust","Fungal disease","Brown spots","Use resistant varieties");

    

        d18 = DiseaseDoc("PM","Powdery Mildew","Fungal disease in dry climates","White powder","Apply sulfur fungicides");
        d19 = DiseaseDoc("DM","Downy Mildew","Occurs in humid conditions","Yellow patches","Use fungicides");

        d20 = DiseaseDoc("FW","Fusarium Wilt","Soil-borne fungus","Wilting plants","Crop rotation");
        d21 = DiseaseDoc("BW","Bacterial Wilt","Bacterial disease","Sudden wilting","Use resistant crops");

        d22 = DiseaseDoc("ROOT_ROT","Root Rot","Fungal disease in wet soils","Root decay","Improve drainage");

  

        d23 = DiseaseDoc("EB","Early Blight","Common in tomatoes","Dark rings on leaves","Apply fungicides");
        d24 = DiseaseDoc("LB","Late Blight","Serious potato/tomato disease","Water-soaked lesions","Use resistant varieties");

        d25 = DiseaseDoc("TSWV","Tomato Spotted Wilt Virus","Viral disease spread by thrips","Spots and wilting","Control vectors");

 

        d26 = DiseaseDoc("LEAF_SPOT","Leaf Spot","General fungal infection","Spots on leaves","Apply fungicides");
        d27 = DiseaseDoc("LEAF_SCORCH","Leaf Scorch","Stress or disease related","Burnt leaf edges","Improve irrigation");

        d28 = DiseaseDoc("MOSAIC","Mosaic Virus","Viral disease affecting many crops","Mosaic patterns","Use clean seeds");

        d29 = DiseaseDoc("DAMPING_OFF","Damping Off","Seedling disease","Seedling collapse","Improve drainage");

        d30 = DiseaseDoc("CHARCOAL_ROT","Charcoal Rot","Fungal disease in dry areas","Stem rot","Crop rotation");

    

        root ++> d1; root ++> d2; root ++> d3; root ++> d4; root ++> d5;
        root ++> d6; root ++> d7; root ++> d8; root ++> d9; root ++> d10;
        root ++> d11; root ++> d12; root ++> d13; root ++> d14;
        root ++> d15; root ++> d16; root ++> d17;
        root ++> d18; root ++> d19; root ++> d20; root ++> d21;
        root ++> d22; root ++> d23; root ++> d24; root ++> d25;
        root ++> d26; root ++> d27; root ++> d28; root ++> d29; root ++> d30;
    }
}