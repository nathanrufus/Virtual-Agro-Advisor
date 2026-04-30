include backend.models;
include backend.graph_rag_seed;

walker SeedKnowledge {
    can run with Root entry {

        print("[SEED] Clearing old DiseaseDoc nodes...");
        for old in [root -->][?:DiseaseDoc] {
            del old;
        }
        for old in [root -->][?:CaseStudy] {
            del old;
        }

        print("[SEED] Seeding 100+ diseases from KALRO/KEPHIS/CABI sources...");

        # ============================================================
        # MAIZE DISEASES (Sources: KALRO, CIMMYT, PMC/PeerJ 2023)
        # ============================================================

        d1 = DiseaseDoc(
            disease_id="N_DEF",
            disease_name="Nitrogen Deficiency",
            description="Most common nutrient deficiency in Kenyan maize. Occurs after continuous cropping without fertilisation. Widespread in Kiambu, Nakuru, Nyeri and Trans Nzoia.",
            symptoms="Yellowing of lower leaves progressing upward, pale green plant, stunted growth, thin stalks, reduced grain fill",
            treatments="Apply urea (46% N) at 200-250 kg/ha at planting and top-dress at V6 stage. Apply DAP (18-46-0) at 150 kg/ha. Use farm yard manure 3-5 tonnes/acre as supplement"
        );

        d2 = DiseaseDoc(
            disease_id="P_DEF",
            disease_name="Phosphorus Deficiency",
            description="Common in acidic highland soils of Kenya including Kiambu, Muranga and Nyeri. Limits root development and early plant establishment.",
            symptoms="Purple or reddish discolouration of leaves and stems, slow growth, delayed maturity, poor root development",
            treatments="Apply DAP (18-46-0) at 150-200 kg/ha at planting. Apply TSP (triple super phosphate). Lime acidic soils to raise pH above 5.5. Use Minjingu rock phosphate for long-term improvement"
        );

        d3 = DiseaseDoc(
            disease_id="K_DEF",
            disease_name="Potassium Deficiency",
            description="Occurs in sandy or over-leached soils. Common in coastal Kenya and low-lying areas. Worsened by heavy rainfall leaching.",
            symptoms="Scorching and browning of leaf edges starting from tips, weak stems prone to lodging, poor drought tolerance, shrivelled kernels",
            treatments="Apply muriate of potash (MOP) at 100-150 kg/ha. Use NPK compound fertilisers (17:17:17 or 23:23:0+4S). Incorporate crop residues to improve soil K"
        );

        d4 = DiseaseDoc(
            disease_id="ZN_DEF",
            disease_name="Zinc Deficiency",
            description="Increasingly common in intensively cultivated Kenyan soils. Reported by KALRO in Rift Valley and Western Kenya regions.",
            symptoms="White or yellow striping on young leaves, broad white band along midrib, stunted plants, shortened internodes",
            treatments="Apply zinc sulphate at 20-25 kg/ha to soil. Apply foliar zinc spray (0.5% zinc sulphate solution). Use Zincated DAP or NPK fertilisers"
        );

        d5 = DiseaseDoc(
            disease_id="MSV",
            disease_name="Maize Streak Virus",
            description="Serious viral disease transmitted by leafhoppers (Cicadulina mbila). Widespread across all maize-growing zones in Kenya. Reported by KALRO as a major constraint since the 1930s. No cure exists once infected.",
            symptoms="Continuous yellow or white streaks along leaf veins, severe stunting, reduced cob size, premature plant death in severe cases",
            treatments="Plant resistant varieties: H614, H516, H625, WE3128. Control leafhopper vectors with Lambda-cyhalothrin. Early planting to avoid peak leafhopper populations. Remove and destroy infected plants"
        );

        d6 = DiseaseDoc(
            disease_id="MLN",
            disease_name="Maize Lethal Necrosis",
            description="Devastating viral disease caused by co-infection of MCMV and SCMV. First confirmed in Kenya in 2012 in Bomet county, now present in all maize zones. CIMMYT-KALRO collaboration developed MLN-tolerant varieties. Can cause 100% crop loss.",
            symptoms="Necrosis starting from leaf margins, mottling, plant death within 2-3 weeks of severe infection, premature drying of whole plant, poor pollination",
            treatments="Plant MLN-tolerant varieties: MLN(SC439), KDH414-12(UKAMEZ), FAWTH2001, FAWTH2002. Use certified seeds only. Remove and burn infected plants. Control aphid and thrip vectors. Avoid planting near sugarcane"
        );

        d7 = DiseaseDoc(
            disease_id="MDMV",
            disease_name="Maize Dwarf Mosaic Virus",
            description="Potyvirus transmitted by aphids. Component virus of MLN complex in Kenya. Occurs throughout maize growing regions.",
            symptoms="Mosaic patterns on leaves, dwarfing of plants, leaf distortion, reduced tassel development",
            treatments="Control aphid vectors with systemic insecticides. Remove infected plants early. Use virus-free certified seeds. Plant resistant or tolerant varieties"
        );

        d8 = DiseaseDoc(
            disease_id="NCLB",
            disease_name="Northern Corn Leaf Blight",
            description="Fungal disease caused by Exserohilum turcicum. Common in cool, humid highland areas of Kenya including Nyeri, Muranga, Kiambu and Nyandarua. Worsened by morning dew and frequent rainfall.",
            symptoms="Long, narrow grey-brown lesions 2-15cm parallel to leaf veins, lesions with tan centres and darker borders, premature drying of leaves from tip downwards",
            treatments="Plant resistant varieties: H614D, DK8031. Apply Mancozeb at 2.5 kg/ha when disease first appears. Improve plant spacing for air circulation. Practice crop rotation. Remove infected crop residue after harvest"
        );

        d9 = DiseaseDoc(
            disease_id="SCLB",
            disease_name="Southern Corn Leaf Blight",
            description="Fungal disease caused by Cochliobolus heterostrophus. More common in warmer lowland areas of Kenya. Associated with wet humid conditions.",
            symptoms="Small oval to rectangular tan lesions with yellow halos, lesions limited by leaf veins giving rectangular appearance, severe infection causes leaf death",
            treatments="Use resistant varieties. Apply Mancozeb or Propiconazole fungicide. Practice crop rotation. Remove infected debris. Improve field drainage"
        );

        d10 = DiseaseDoc(
            disease_id="GLS",
            disease_name="Grey Leaf Spot",
            description="Fungal disease caused by Cercospora zeae-maydis. Increasingly important in Kenya highlands with high humidity. Reported by KALRO as emerging threat in Uasin Gishu and Trans Nzoia.",
            symptoms="Rectangular grey to tan lesions bounded by leaf veins, lesions run parallel to veins, tan lesions with grey centres, heavy infection causes leaf death",
            treatments="Plant tolerant varieties. Apply Strobilurin fungicides (Azoxystrobin) at first sign. Crop rotation for at least 2 seasons. Minimum tillage to bury infected residue. Ensure good air circulation"
        );

        d11 = DiseaseDoc(
            disease_id="POLYSORA_RUST",
            disease_name="Polysora Rust",
            description="Fungal disease caused by Puccinia polysora. Common in lowland and coastal Kenya. More severe in warm humid conditions. Reported widely in Western Kenya and Coastal regions.",
            symptoms="Small circular to oval orange-yellow pustules on upper leaf surface, pustules rupture releasing orange powder, severe infection causes premature leaf death",
            treatments="Apply Triazole fungicides (Propiconazole, Tebuconazole). Use resistant varieties. Early planting to avoid peak disease period. Spray at first sign of pustules"
        );

        d12 = DiseaseDoc(
            disease_id="COMMON_RUST",
            disease_name="Common Rust",
            description="Fungal disease caused by Puccinia sorghi. Common in Kenyan highlands with cool temperatures. Less damaging than polysora rust but widespread.",
            symptoms="Circular to elongated brown pustules on both leaf surfaces, pustules break open releasing red-brown powdery spores, yellow halos around pustules",
            treatments="Apply Mancozeb or Triazole fungicides. Plant resistant varieties. Monitor fields weekly during cool wet periods. Apply fungicide at first sign before pustules rupture"
        );

        d13 = DiseaseDoc(
            disease_id="HEAD_SMUT",
            disease_name="Head Smut",
            description="Fungal disease caused by Sphacelotheca reiliana. Soil-borne pathogen. Reported in Kenya's drier areas. Affects tassels and ears turning them into smut balls.",
            symptoms="Smut replacing tassels and ears entirely, plant appears normal until heading, smut balls contain dark powdery spores, infected ears produce no grain",
            treatments="Use resistant varieties. Seed treatment with Carboxin or Thiram. Avoid planting in infested soil. Remove smut balls before they burst. Crop rotation for 3+ years"
        );

        d14 = DiseaseDoc(
            disease_id="SMUT",
            disease_name="Common Smut",
            description="Fungal disease caused by Ustilago maydis. Widespread in all maize-growing areas of Kenya. Causes economic loss through reduced grain yields and contaminated feeds.",
            symptoms="Large galls on cobs, tassels and leaves filled with black powdery spores, galls start white then turn grey-black as spores mature",
            treatments="Remove and burn galls before they rupture. Use resistant varieties. Avoid injuring plants during cultivation. Apply seed treatment fungicides. Crop rotation"
        );

        d15 = DiseaseDoc(
            disease_id="EAR_ROT_FUSA",
            disease_name="Fusarium Ear Rot",
            description="Fungal disease caused by Fusarium species. Major post-harvest concern in Kenya. Produces mycotoxins (fumonisins) harmful to humans and livestock. Common in highland Kenya.",
            symptoms="Pinkish-white mould on kernels, starburst pattern of white mycelium on cob, discoloured brown kernels, musty odour, premature drying",
            treatments="Harvest at correct moisture (13-14%). Dry maize immediately after harvest. Store in aerated structures. Use resistant varieties. Avoid insect damage to cobs. Apply biological control (Aflasafe)"
        );

        d16 = DiseaseDoc(
            disease_id="EAR_ROT_ASP",
            disease_name="Aspergillus Ear Rot",
            description="Caused by Aspergillus flavus. Produces aflatoxins - dangerous mycotoxins. Major food safety concern in Kenya especially in ASAL (arid and semi-arid) regions. Monitored by KEPHIS.",
            symptoms="Olive green powdery mould on and between kernels, musty smell, discoloured kernels, most visible at tip of cob",
            treatments="Use certified seeds. Apply Aflasafe Kenya (IITA/KALRO biological control product). Harvest on time. Dry to below 13% moisture within 72 hours. Proper storage in airtight containers"
        );

        d17 = DiseaseDoc(
            disease_id="DIPLODIA_ROT",
            disease_name="Diplodia Ear Rot",
            description="Fungal disease caused by Stenocarpella maydis. Common in maize areas with frequent rainfall at silking. Reported in Western and Rift Valley regions of Kenya.",
            symptoms="White mould starting at base of cob, husks bleached and tightly bound to cob, kernels rotted and lightweight, black pycnidia visible on husks",
            treatments="Harvest early when moisture is around 30%. Use resistant varieties. Practice crop rotation. Remove crop residue. Avoid late planting. Improve field drainage"
        );

        d18 = DiseaseDoc(
            disease_id="STALK_ROT_FUSA",
            disease_name="Fusarium Stalk Rot",
            description="Soil-borne fungal disease. Common throughout Kenya. Plants become susceptible under drought stress then re-watering. One of the top causes of pre-harvest loss.",
            symptoms="Yellowing and death of lower leaves, brown discolouration inside lower stalk nodes, stalk collapses easily when pushed, pinkish rot inside stalk",
            treatments="Maintain balanced soil nutrition especially K and N. Avoid water stress then sudden irrigation. Control stalk borers to reduce entry wounds. Harvest early when signs appear. Plant tolerant varieties"
        );

        d19 = DiseaseDoc(
            disease_id="CHARCOAL_ROT",
            disease_name="Charcoal Rot",
            description="Caused by Macrophomina phaseolina. Common in ASAL regions of Kenya under drought stress conditions. Kills plants at maturity causing lodging.",
            symptoms="Premature ripening, grey streaking inside lower stalk, tiny black sclerotia visible inside stalk tissue, stalk breakage near harvest",
            treatments="Maintain adequate soil moisture. Avoid excessive N fertilisation. Use tolerant varieties. Practice crop rotation with legumes. Harvest as soon as physiological maturity reached"
        );

        d20 = DiseaseDoc(
            disease_id="FAW",
            disease_name="Fall Armyworm",
            description="Invasive pest (Spodoptera frugiperda) first detected in Kenya in 2016. Now the most damaging maize pest nationwide. KALRO and CABI have developed IPM protocols for Kenya.",
            symptoms="Ragged holes in leaves, frass (sawdust-like droppings) in leaf whorl, window pane feeding on young leaves, caterpillars with four dots in square pattern on last abdominal segment, cob damage",
            treatments="Scout weekly and spray when more than 10% plants show fresh damage. Apply Lambda-cyhalothrin, Emamectin benzoate or Spinosad. Use push-pull with Desmodium. Encourage natural enemies (parasitic wasps). Apply Bacillus thuringiensis (Bt) for organic control"
        );

        d21 = DiseaseDoc(
            disease_id="STALK_BORER",
            disease_name="Spotted Stalk Borer",
            description="Chilo partellus - most important stalk borer in Kenya. Widespread in all maize zones. Larvae bore into stems causing dead hearts in young plants and stalk tunnelling in older plants.",
            symptoms="Dead heart in young plants (central shoot dies), pin holes in leaves, frass in leaf axils, hollowed stalk, tunnels visible when stalk cut open, plant lodging",
            treatments="Apply Chlorpyrifos or Lambda-cyhalothrin into leaf whorl before age of 3 weeks. Use push-pull technology (Napier grass + Desmodium). Destroy crop residues after harvest. Plant early. Use Bt varieties where available"
        );

        d22 = DiseaseDoc(
            disease_id="PINK_BORER",
            disease_name="Pink Stalk Borer",
            description="Sesamia calamistis. Second most important stalk borer in Kenya. More common in humid coastal and western regions. Attacks at any growth stage.",
            symptoms="Dead hearts, pinholes in leaves, pink-coloured larvae inside stalk, deadening of upper stalk, stalk breakage at internodes",
            treatments="Same as spotted stalk borer. Apply insecticides at early larval stage. Encourage parasitic wasp populations. Destroy infected crop residues promptly"
        );

        d23 = DiseaseDoc(
            disease_id="MAIZE_WEEVIL",
            disease_name="Maize Weevil",
            description="Sitophilus zeamais. Most destructive storage pest in Kenya. Can cause 50-100% post-harvest losses within 3-6 months if not controlled. Monitored by KEPHIS.",
            symptoms="Round holes in kernels, fine flour-like dust inside grain store, live weevils visible in stored grain, heating of grain mass",
            treatments="Clean and dry grain thoroughly to below 13%. Apply Actellic Super dust (pirimiphos-methyl) at 1g/kg. Use hermetic storage (PICS bags, metal silos). Sun-dry grain on tarpaulins. Apply diatomaceous earth for organic storage"
        );

        d24 = DiseaseDoc(
            disease_id="APHIDS_MAIZE",
            disease_name="Corn Leaf Aphid",
            description="Rhopalosiphum maidis. Sap-sucking pest transmitting MDMV and other viruses. Common in dry periods. Found throughout Kenya maize zones.",
            symptoms="Colonies of bluish-green aphids on upper leaves and tassels, sticky honeydew on leaves, black sooty mould on honeydew, curling and yellowing of affected leaves, reduced tassel function",
            treatments="Apply systemic insecticide (Dimethoate, Imidacloprid) when colonies first appear. Encourage ladybirds and lacewings. Avoid excessive nitrogen which promotes aphid populations. Remove heavily infested plants"
        );

        d25 = DiseaseDoc(
            disease_id="QUELEA",
            disease_name="Quelea Bird Damage",
            description="Red-billed quelea (Quelea quelea) causes severe grain loss at milking and dough stages. Seasonal pest affecting Kenya especially Trans Nzoia, Uasin Gishu and Rift Valley.",
            symptoms="Stripped grain from cobs, denuded cobs at milk/dough stage, large flocks of small birds roosting in fields",
            treatments="Use bird scarers (noise, reflective tape). Apply Quelea control at roosting sites through KALRO/Ministry. Plant early to avoid quelea season. Use bird-resistant varieties with tight husk cover"
        );

        # ============================================================
        # BEANS DISEASES (Sources: CIAT, KALRO, MMUST research)
        # ============================================================

        d26 = DiseaseDoc(
            disease_id="ALS_BEAN",
            disease_name="Angular Leaf Spot",
            description="Caused by Phaeoisariopsis griseola. Most important bean disease in Kenya. Reported to cause yield losses up to 80% in Western Kenya (MMUST/KALRO). Found in all bean-growing areas.",
            symptoms="Angular reddish-brown spots on leaves limited by leaf veins, grey powdery growth on lower leaf surface, dark brown lesions on pods and stems, premature defoliation",
            treatments="Use resistant varieties: Lyamungu 85, GLP2 (Miezi Mbili), KK22, Lyamungu 90. Apply Mancozeb or Chlorothalonil fungicide. Use certified disease-free seeds. Practice crop rotation for 2 seasons. Remove crop residues"
        );

        d27 = DiseaseDoc(
            disease_id="ANTH_BEAN",
            disease_name="Bean Anthracnose",
            description="Caused by Colletotrichum lindemuthianum. Serious in cool, wet highland areas of Kenya. Seed-borne disease. Found in Kiambu, Nyeri, Muranga and Meru bean zones.",
            symptoms="Dark brown to black sunken lesions on pods with pink or salmon spore masses, dark lesions on leaves along veins, chocolate brown lesions on stems, seed infection causes brown discolouration",
            treatments="Use certified disease-free seeds. Apply Mancozeb at first sign. Avoid overhead irrigation. Practice 3-year crop rotation. Remove and destroy infected plant material. Use tolerant varieties"
        );

        d28 = DiseaseDoc(
            disease_id="RUST_BEAN",
            disease_name="Bean Rust",
            description="Caused by Uromyces appendiculatus. Common in moderate to cool temperatures in Kenya. Worse during long and short rains. Widespread in Western and Central Kenya.",
            symptoms="Small white flecks developing into yellow pustules on upper leaf surface, brown powdery pustules on lower leaf surface, severe infection causes premature leaf drop",
            treatments="Apply Mancozeb, Sulfur or Triazole fungicide at first sign. Use resistant varieties. Avoid dense planting. Improve air circulation. Remove infected leaves. Practice crop rotation"
        );

        d29 = DiseaseDoc(
            disease_id="CBB",
            disease_name="Common Bacterial Blight",
            description="Caused by Xanthomonas axonopodis pv. phaseoli. Seed-borne and soil-borne bacterial disease. Major yield constraint in Kenya especially in warm humid conditions. Transmitted by rain splash and wind.",
            symptoms="Water-soaked spots on leaves turning yellow with brown centre, yellow border around lesions, greasy lesions on pods, brown seed staining, wilting of entire branches",
            treatments="Use certified disease-free seeds. Avoid overhead irrigation. Apply copper-based bactericides (Copper hydroxide) preventively. Remove infected plants. Practice crop rotation. Avoid working in field when wet"
        );

        d30 = DiseaseDoc(
            disease_id="BCMV",
            disease_name="Bean Common Mosaic Virus",
            description="Major viral disease of beans in Kenya. Transmitted by aphids. Seed-borne. Prevalent in Western Kenya (ScienceDirect 2025 survey). Can cause complete crop failure in susceptible varieties.",
            symptoms="Mosaic yellowing on leaves, leaf distortion and crumpling, dark green blisters on lighter green areas, stunted plants, malformed pods with few seeds",
            treatments="Plant resistant varieties: BILL 82, KK22, Lyamungu 85. Control aphid vectors immediately. Remove and destroy infected plants. Use certified virus-free seeds. Avoid replanting from infected stock"
        );

        d31 = DiseaseDoc(
            disease_id="ROOT_ROT_BEAN",
            disease_name="Bean Root Rot",
            description="Caused by Fusarium and Pythium species. Major problem in waterlogged and poorly drained soils in Kenya. Common in Lake Victoria basin and low-lying areas of Central Kenya.",
            symptoms="Reddish-brown to dark lesions on roots, wilting of above-ground plant in middle of season, orange-brown internal discolouration of tap root, poor nodulation",
            treatments="Improve field drainage. Avoid planting in waterlogged areas. Treat seeds with Thiram or Metalaxyl. Practice 3-year crop rotation. Use raised beds. Select fields with good drainage history"
        );

        d32 = DiseaseDoc(
            disease_id="HALO_BLIGHT",
            disease_name="Halo Blight",
            description="Caused by Pseudomonas syringae pv. phaseolicola. Common in cool highland areas of Kenya. Seed-borne and spread by rain splash. More severe in Nyeri, Muranga and Kiambu.",
            symptoms="Small circular spots surrounded by yellow-green halo on leaves giving bacterium its name, water-soaked spots on pods turning brown, greasy appearance of infected pods",
            treatments="Use clean certified seeds. Apply copper bactericides before rains. Avoid working in wet crop. Practice 2-year rotation. Use resistant varieties where available"
        );

        d33 = DiseaseDoc(
            disease_id="BEAN_APHID",
            disease_name="Bean Aphid",
            description="Aphis fabae. Major vector of BCMV and BCMNV viruses in Kenyan bean fields. Colonies build up rapidly in dry weather. Widespread throughout Kenya.",
            symptoms="Black aphid colonies on stems and undersides of leaves, sticky honeydew with sooty mould, leaf curling and yellowing, reduced pod set",
            treatments="Apply Dimethoate or Imidacloprid when colonies first detected. Encourage natural enemies. Use yellow sticky traps for monitoring. Apply neem extract (0.5%). Avoid excessive nitrogen fertilisation"
        );

        d34 = DiseaseDoc(
            disease_id="BEAN_FLY",
            disease_name="Bean Stem Maggot",
            description="Ophiomyia phaseoli. Very common in Kenya causing 20-100% bean seedling losses. Attacks soon after germination. Worst in warm humid conditions. One of top 3 bean pests in Kenya.",
            symptoms="Yellow cotyledons on young seedlings, swollen and cracked stem at soil level, white maggots inside stem base, wilting and death of young seedlings, surviving plants stunted",
            treatments="Treat seeds with Imidacloprid before planting. Apply soil drench of Chlorpyrifos at planting. Plant in optimal growing conditions (adequate moisture, good soil). Avoid delayed planting. Plant dense to compensate for losses"
        );

        d35 = DiseaseDoc(
            disease_id="BEAN_WEEVIL",
            disease_name="Bean Bruchid Weevil",
            description="Acanthoscelides obtectus and Zabrotes subfasciatus. Major storage pests of beans in Kenya. Infestation starts in the field and continues in store. Can destroy entire stored harvest within 2-3 months.",
            symptoms="Round holes in stored bean seeds, powdery frass around seeds, live beetles in grain, loss of seed weight and viability",
            treatments="Dry beans thoroughly to below 13% moisture. Use hermetic PICS bags for storage. Apply Actellic dust (pirimiphos-methyl) at 1g/kg. Mix beans with wood ash or diatomaceous earth. Store in cool dry conditions"
        );

        # ============================================================
        # POTATO DISEASES (Sources: NPCK, KEPHIS, Springer 2014, CABI)
        # ============================================================

        d36 = DiseaseDoc(
            disease_id="LB_POT",
            disease_name="Potato Late Blight",
            description="Caused by Phytophthora infestans. Most serious potato disease in Kenya - affects 67% of farms (KEPHIS). Occurs in all potato-growing highland areas especially Nyandarua, Meru, Nakuru. Can destroy entire crop in 2 weeks in ideal conditions.",
            symptoms="Water-soaked dark lesions on leaves starting from tips and margins, white fungal growth on underside in humid conditions, lesions turn brown and papery, rotting of tubers with coppery-brown internal rot, oily appearance on stems",
            treatments="Apply Ridomil Gold (metalaxyl-mancozeb) preventively before rains. Apply Dithane (mancozeb) at 2.5kg/ha every 7-10 days. Plant certified disease-free seed tubers. Use resistant varieties: Unica, Kenya Karibu, Shangi. Ridge soil around plants. Destroy infected haulms before harvest"
        );

        d37 = DiseaseDoc(
            disease_id="BW_POT",
            disease_name="Potato Bacterial Wilt",
            description="Caused by Ralstonia solanacearum. Most damaging potato disease in Kenya - affects 70%+ of farms (KEPHIS, Academia 2014). Present in all potato-growing areas. No effective cure once soil is infested. First reported in Kenya 1945 near Embu.",
            symptoms="Sudden wilting of plants starting with youngest leaves, brown vascular tissue visible when stem cut, slimy bacterial ooze from cut stem in water, rotted tubers with bacterial slime",
            treatments="Plant certified disease-free seed tubers only (KEPHIS certified). Practice strict 4-year rotation with non-solanaceous crops. Disinfect tools with bleach solution. Remove and burn infected plants. Improve drainage. Test seed before planting"
        );

        d38 = DiseaseDoc(
            disease_id="EB_POT",
            disease_name="Potato Early Blight",
            description="Caused by Alternaria solani. Common in all potato-growing areas of Kenya. Less severe than late blight but causes significant yield loss in warm conditions. Attacks older leaves first.",
            symptoms="Dark brown-black circular spots with concentric rings giving target-board appearance, yellow halo around lesions, lesions on older lower leaves first, premature defoliation, dark lesions on tuber surface",
            treatments="Apply Mancozeb or Chlorothalonil at first sign. Ensure balanced nutrition (adequate K and N). Destroy crop debris after harvest. Crop rotation 2-3 years. Improve air circulation. Plant in well-drained fields"
        );

        d39 = DiseaseDoc(
            disease_id="BLACKLEG_POT",
            disease_name="Potato Blackleg",
            description="Caused by Pectobacterium atrosepticum (Erwinia atroseptica). Seed-borne bacterial disease. More severe in wet soils. Detected in Kenya highlands including Meru, Nyandarua and Nakuru. Identified as emerging threat by NPCK 2021.",
            symptoms="Black slimy rot at base of stem from soil level, yellowing and wilting of stems, plants easily pulled from soil due to rotten stems, soft wet rot in tubers",
            treatments="Use certified disease-free seed tubers. Avoid planting in waterlogged soils. Let seed cuts dry before planting. Remove and destroy infected plants. Practice strict rotation. Disinfect equipment"
        );

        d40 = DiseaseDoc(
            disease_id="PCN",
            disease_name="Potato Cyst Nematode",
            description="Globodera rostochiensis and G. pallida. First reported in Kenya in 2014 (Nyandarua). Classified as quarantine pest by KEPHIS. Spreading to other potato-growing areas. Causes severe yield loss in infested soils.",
            symptoms="Patches of stunted yellow plants, wilting in warm afternoons, tiny golden/white cysts on roots visible with magnifying glass, reduced tuber size and number",
            treatments="Plant certified nematode-free seed tubers. Practice long rotation (7+ years) with non-host crops. Apply Carbofuran nematicide at planting (where registered). Use resistant varieties where available. Avoid moving soil from infested fields"
        );

        d41 = DiseaseDoc(
            disease_id="PTM",
            disease_name="Potato Tuber Moth",
            description="Phthorimaea operculella. Major pest in storage and field in Kenya. Attacks tubers in field and store. Widespread in all potato zones. Identified as most important potato pest in East Africa (UoN 2019).",
            symptoms="Mines under leaf surface, tunnels in tubers and stems, webbing over tuber eyes in store, caterpillars visible inside tubers, tubers become inedible",
            treatments="Hill up soil to cover tubers completely. Harvest immediately at crop maturity. Apply Chlorpyrifos or Bacillus thuringiensis (Bt) in field. Store tubers in dark cool conditions. Use pheromone traps. Avoid green tubers in field"
        );

        d42 = DiseaseDoc(
            disease_id="PLRV",
            disease_name="Potato Leafroll Virus",
            description="Transmitted by peach-potato aphid (Myzus persicae). Common in Kenyan potato zones. Seed-borne. Causes 'net necrosis' in tubers making them unmarketable. Prevalence survey confirmed widespread in Kenya highlands.",
            symptoms="Upward rolling of lower leaves, pale yellow discolouration, leathery texture of leaves, net-like brown necrosis in tubers when cut, reduced tuber size",
            treatments="Use certified virus-free seed tubers. Apply systemic insecticides to control aphid vectors. Remove volunteer potato plants. Practice 3-year crop rotation. Avoid planting near other solanaceous crops"
        );

        d43 = DiseaseDoc(
            disease_id="COMMON_SCAB",
            disease_name="Potato Common Scab",
            description="Caused by Streptomyces scabies. Common in neutral to alkaline Kenyan potato soils. Reduces marketability of tubers. Found widely in Nyandarua and Meru potato zones.",
            symptoms="Raised corky scab-like lesions on tuber surface, rough or pitted tuber skin, lesions do not affect eating quality but reduce market value",
            treatments="Maintain soil pH between 5.0-5.5 (lime reduces effectiveness of control). Use certified seed tubers. Avoid fresh manure application. Practice crop rotation. Irrigate to maintain even soil moisture at tuber initiation"
        );

        d44 = DiseaseDoc(
            disease_id="POWDERY_SCAB",
            disease_name="Potato Powdery Scab",
            description="Caused by Spongospora subterranea. Common in cool wet potato soils in Kenya highlands. NPCK identified as significant disease. Also causes corky ringspot disease. Soil persists for 10+ years.",
            symptoms="Raised scabby pustules on tuber surface filled with dry powdery spores, galls on roots, lesions break open releasing spore powder",
            treatments="Maintain soil pH at 5.2-6.0. Use certified seed tubers. Practice 5-year rotation with non-host crops. Improve soil drainage. Avoid importing soil or machinery from infested areas"
        );

        # ============================================================
        # TOMATO DISEASES (Sources: HortFresh, Kenya Farmer, KALRO)
        # ============================================================

        d45 = DiseaseDoc(
            disease_id="EB_TOM",
            disease_name="Tomato Early Blight",
            description="Caused by Alternaria solani. Very common in all Kenyan tomato growing areas. More severe in warm and humid conditions with overhead irrigation. Major constraint in Kirinyaga, Meru and Rift Valley tomato zones.",
            symptoms="Circular dark brown lesions with concentric rings on older leaves, yellow halo around lesions, premature defoliation starting from bottom, dark lesions at stem base (collar rot)",
            treatments="Apply Mancozeb or Chlorothalonil at first appearance. Ensure adequate K and Ca nutrition. Avoid overhead watering. Remove lower infected leaves. Plant at wider spacing. Mulch soil surface"
        );

        d46 = DiseaseDoc(
            disease_id="LB_TOM",
            disease_name="Tomato Late Blight",
            description="Caused by Phytophthora infestans. Extremely destructive in cool humid conditions in Kenya highlands. Can destroy entire tomato crop in 2-3 weeks during rainy season. Same pathogen as potato late blight.",
            symptoms="Greasy water-soaked lesions on leaves and stems, white mould on underside in humid conditions, lesions turn brown and papery, hard dark brown rot on green or ripe tomatoes",
            treatments="Apply Ridomil Gold preventively before and during rains. Avoid overhead irrigation. Destroy infected plants immediately. Use resistant varieties (Anna F1, Kilele F1). Improve air circulation. Ridge to protect stems"
        );

        d47 = DiseaseDoc(
            disease_id="BW_TOM",
            disease_name="Tomato Bacterial Wilt",
            description="Caused by Ralstonia solanacearum. Major disease in all Kenyan tomato zones including Kirinyaga, Meru, Naivasha. Soil persists for years. Spreads through infected water, tools and soil.",
            symptoms="Sudden wilting of plants in warm afternoons, quick recovery at night initially, permanent wilting and plant death, bacterial ooze from cut stem in water, brown vascular discolouration",
            treatments="Use resistant rootstocks (grafting onto resistant varieties). Plant certified seedlings. Strict rotation 4+ years. Disinfect tools. Solarise soil before planting. Remove infected plants with surrounding soil"
        );

        d48 = DiseaseDoc(
            disease_id="TSWV",
            disease_name="Tomato Spotted Wilt Virus",
            description="Transmitted by thrips (Frankliniella occidentalis). Common in greenhouse and open-field tomatoes in Kenya. Causes significant losses in Naivasha and Rift Valley greenhouse sector.",
            symptoms="Bronze discolouration of young leaves, ring spots on leaves and fruits, stunted plants, necrosis of growing tips, streaks on stems and petioles",
            treatments="Control thrips with Spinosad or Abamectin. Use silver reflective mulch to repel thrips. Remove infected plants immediately. Plant resistant varieties. Use insect-proof netting in greenhouses"
        );

        d49 = DiseaseDoc(
            disease_id="TOM_MOTH",
            disease_name="Tomato Leaf Miner",
            description="Tuta absoluta. Highly invasive pest first reported in Kenya in 2014. Now established in all tomato zones. Can cause 80-100% crop loss if unmanaged. Major threat to Kenyan tomato industry.",
            symptoms="Irregular leaf mines with frass, tunnels inside stems and fruits, small entry holes in fruits, caterpillars inside green and ripe tomatoes, massive defoliation",
            treatments="Apply Spinosad, Abamectin or Chlorantraniliprole. Use pheromone mass trapping. Install insect-proof nets. Release parasitic wasps (Necremnus). Remove infested leaves. Scout twice weekly"
        );

        d50 = DiseaseDoc(
            disease_id="BER_TOM",
            disease_name="Blossom End Rot",
            description="Physiological disorder caused by calcium deficiency at blossom end of fruit. Common in Kenyan tomatoes during irregular watering or drought stress. Very common in Rift Valley tomato production.",
            symptoms="Dark sunken leathery area at blossom end of fruit, affected area turns black, internal browning of affected tissue, fruits not marketable",
            treatments="Apply calcium nitrate foliar spray (0.4%). Maintain even soil moisture through mulching and consistent irrigation. Raise soil pH to 6.0-6.5. Avoid excessive nitrogen. Apply gypsum (calcium sulphate) to soil"
        );

        d51 = DiseaseDoc(
            disease_id="FUSA_WILT_TOM",
            disease_name="Tomato Fusarium Wilt",
            description="Caused by Fusarium oxysporum f.sp. lycopersici. Soil-borne disease. Increasingly common in Kenya as tomato monoculture increases. Once soil is infested, disease persists indefinitely.",
            symptoms="Yellowing of lower leaves on one side of plant, browning of vascular tissue in stem, progressive wilting from bottom, plant death over several weeks",
            treatments="Use resistant varieties: Kilele F1, Anna F1. Graft onto resistant rootstocks. Practice 4-year rotation. Solarise soil. Avoid wounding roots. Apply Trichoderma harzianum to transplanting holes"
        );

        # ============================================================
        # WHEAT DISEASES (Sources: KALRO Njoro, IntechOpen 2022)
        # ============================================================

        d52 = DiseaseDoc(
            disease_id="STEM_RUST",
            disease_name="Wheat Stem Rust",
            description="Caused by Puccinia graminis f.sp. tritici. Historically most feared wheat disease in Kenya - epidemics reported since 1908 (KALRO). Ug99 race discovered in Uganda 1999, present in Kenya and threatens global wheat. KALRO Njoro is monitoring centre.",
            symptoms="Brick-red elongated pustules on stems and leaf sheaths, pustules rupture releasing reddish-brown spore powder, leaves may collapse, weakened stems prone to lodging",
            treatments="Apply Propiconazole (Tilt) fungicide at first sign. Plant resistant varieties: Robin, Fahari, Kwale. Monitor for new virulent races. Apply fungicide preventively when disease pressure is high"
        );

        d53 = DiseaseDoc(
            disease_id="YELLOW_RUST",
            disease_name="Wheat Yellow (Stripe) Rust",
            description="Caused by Puccinia striiformis. Common in cool moist highland wheat areas of Kenya including Uasin Gishu, Trans Nzoia and Nyandarua. Highly destructive and can spread rapidly.",
            symptoms="Yellow to orange stripe patterns of pustules arranged in lines along leaf veins, yellow powdery pustules in stripes, whitish older pustules, leaves die from tips",
            treatments="Apply Propiconazole or Tebuconazole at first stripe appearance. Plant resistant varieties. Early planting before peak disease period. Monitor weekly during cool wet periods. Apply fungicide preventively in high-risk seasons"
        );

        d54 = DiseaseDoc(
            disease_id="LEAF_RUST_WHEAT",
            disease_name="Wheat Leaf Rust",
            description="Caused by Puccinia triticina. Most common and widely distributed of the three wheat rusts in Kenya. Occurs in low to medium altitude wheat areas. Yield losses 5-40% depending on variety and season (IntechOpen 2022).",
            symptoms="Small round orange-brown pustules on upper leaf surface, random distribution unlike stripe rust, dark brown-black telial pustules in dry conditions",
            treatments="Apply Triazole fungicides (Propiconazole, Epoxiconazole). Plant varieties with leaf rust resistance. Time planting to avoid peak disease. Scout monthly and spray at first sign"
        );

        d55 = DiseaseDoc(
            disease_id="SEP_WHEAT",
            disease_name="Wheat Septoria",
            description="Caused by Mycosphaerella graminicola (Septoria tritici). Common in humid wheat areas of Kenya. Increasing in importance as it affects yield forming leaves in heavy seasons.",
            symptoms="Initially water-soaked lesions on lower leaves, lesions turn tan to brown with yellow margins, pycnidia (tiny black dots) visible in lesion centres, lesions merge causing leaf death",
            treatments="Apply Strobilurin + Triazole mixture. Plant resistant varieties. Burn or plough crop residue. Avoid planting in same field two seasons running. Apply fungicide from flag leaf stage"
        );

        d56 = DiseaseDoc(
            disease_id="BUNTS_WHEAT",
            disease_name="Bunt Wheat",
            description="Covered smut of wheat. Tilletia tritici. Seed-borne disease. Managed by KALRO through certified seed programme. Still found when uncertified seed used.",
            symptoms="Infected plants appear normal until heading, grain replaced by dark powdery smut balls, fishy smell from infected grain, smut balls visible among normal grain",
            treatments="Treat seeds with Carboxin or Thiram before planting. Use certified clean seed. Avoid using seed from infected fields. Rotate crops"
        );

        # ============================================================
        # CASSAVA DISEASES (Sources: KALRO, MMUST, IITA)
        # ============================================================

        d57 = DiseaseDoc(
            disease_id="CBSD",
            disease_name="Cassava Brown Streak Disease",
            description="Caused by Cassava brown streak virus (CBSV). Devastating viral disease of cassava. Spreading rapidly in Kenya especially Western and Coastal regions. MMUST/KALRO monitoring programme in Western Kenya. Can cause 100% storage root loss.",
            symptoms="Yellow streaks and blotches on leaves, brown-black necrotic streaks on stems, dry corky brown necrotic patches in cassava roots making them inedible",
            treatments="Use certified virus-free planting material. Plant CMD and CBSD resistant varieties: Tajirika, Kizimbani, Migyera. Rogue and destroy infected plants immediately. Control whitefly vectors. Never replant from diseased fields"
        );

        d58 = DiseaseDoc(
            disease_id="CMD",
            disease_name="Cassava Mosaic Disease",
            description="Caused by East African cassava mosaic virus (EACMV). Most widespread cassava disease in Kenya. Transmitted by whitefly Bemisia tabaci. Present in all cassava-growing regions.",
            symptoms="Mosaic yellowing of leaves, leaf distortion and curling, chlorosis between leaf veins, stunted plants, severely reduced root yield",
            treatments="Plant resistant varieties: MM8, Tajirika, Sili. Use whitefly-resistant varieties. Control Bemisia tabaci with systemic insecticides or yellow sticky traps. Use certified planting material. Rogue infected plants"
        );

        d59 = DiseaseDoc(
            disease_id="CASSAVA_BACT_BLIGHT",
            disease_name="Cassava Bacterial Blight",
            description="Caused by Xanthomonas axonopodis pv. manihotis. Common in Kenya cassava zones during rainy season. Spread by rain splash and infected cuttings.",
            symptoms="Angular water-soaked lesions on leaves turning brown, wilting of shoot tips (die-back), gummy exudate on stems, brown discolouration inside stems",
            treatments="Use healthy certified cuttings. Remove infected shoots. Apply copper-based bactericide. Avoid working in wet crops. Practice crop rotation. Select resistant varieties"
        );

        d60 = DiseaseDoc(
            disease_id="CGMCC",
            disease_name="Cassava Green Mite",
            description="Mononychellus tanajoa. Serious pest of cassava in dryland Kenya. Severe in ASAL areas including Eastern and Coastal regions. Biological control using predatory mites released by CABI/IITA.",
            symptoms="Pale green, yellowing of young leaves, leaf distortion and curling, silvery sheen on leaf undersurface, stunted shoot tips",
            treatments="Apply Abamectin miticide where economically justified. Encourage predatory mite populations. Use resistant varieties. Biological control using Typhlodromalus aripo (released by CABI)"
        );

        # ============================================================
        # SORGHUM DISEASES (Sources: ICRISAT, KALRO ASAL research)
        # ============================================================

        d61 = DiseaseDoc(
            disease_id="STRIGA",
            disease_name="Striga Witchweed",
            description="Striga hermonthica and S. asiatica. Parasitic weed devastating cereals in Kenya ASAL regions. Most damaging constraint in Western Kenya and Nyanza where it causes 30-100% yield loss. ICIPE/KALRO push-pull technology developed to manage it.",
            symptoms="Yellow stunted crop plants, small reddish-purple flowers of Striga emerging at base of crop, early crop death in severe infestations, patchy crop stand",
            treatments="Use Imazapyr-treated sorghum/maize seed (IR Maize). Plant Desmodium as intercrop (push-pull technology from ICIPE). Apply Strigaway herbicide. Hand-pull Striga before flowering. Plant IR maize varieties. Use thick mulch"
        );

        d62 = DiseaseDoc(
            disease_id="ANTHRAC_SORG",
            disease_name="Sorghum Anthracnose",
            description="Caused by Colletotrichum sublineolum. Most important sorghum disease in humid regions of Kenya. Common in Western Kenya and Rift Valley highland areas.",
            symptoms="Red or tan spots with dark borders on leaves, small spots merging to large blighted areas, pinkish spore masses on stem, stalk rot in severe cases",
            treatments="Use resistant varieties. Apply Mancozeb or Carbendazim. Destroy infected residue. Practice crop rotation. Avoid planting susceptible varieties in high-rainfall areas"
        );

        d63 = DiseaseDoc(
            disease_id="SORG_MIDGE",
            disease_name="Sorghum Midge",
            description="Stenodiplosis sorghicola. Small orange fly attacking sorghum heads at flowering. Widespread in Kenya sorghum areas. Causes chaffy unfilled grains.",
            symptoms="Tiny orange maggots inside florets, shrivelled empty grains, chaffy heads, pink-orange adult flies visible at flowering stage",
            treatments="Plant early to avoid peak midge populations. Use resistant varieties (varieties with tight glumes). Apply Lambda-cyhalothrin at 50% flowering. Stagger planting dates. Synchronise planting with neighbours"
        );

        # ============================================================
        # GENERAL VEGETABLE DISEASES (Sources: KALRO, Kenya Farmers)
        # ============================================================

        d64 = DiseaseDoc(
            disease_id="PM_VEG",
            disease_name="Powdery Mildew",
            description="Caused by various Erysiphe and Podosphaera species. Affects many vegetables in Kenya including cucurbits, peas, beans. Common in dry conditions with moderate temperatures. Widespread in Rift Valley vegetable zones.",
            symptoms="White powdery growth on upper leaf surfaces, leaves turn yellow then brown, premature defoliation, distorted young shoots, reduced fruit quality",
            treatments="Apply Sulfur-based fungicide (Kumulus) or Myclobutanil. Improve air circulation. Avoid overhead irrigation. Apply potassium bicarbonate. Remove heavily infected plant parts. Plant resistant varieties"
        );

        d65 = DiseaseDoc(
            disease_id="DOWNY_MILDEW",
            disease_name="Downy Mildew",
            description="Caused by Peronospora and Plasmopara species. Common in humid conditions in Kenya. Affects many crops including onions, cucumbers, peas. Worse during long rains season.",
            symptoms="Yellow patches on upper leaf surface, grey-purple fuzzy sporulation on lower leaf surface corresponding to yellow patches, leaves turn brown and dry",
            treatments="Apply Ridomil Gold or Mancozeb preventively. Improve air circulation. Avoid overhead irrigation. Use resistant varieties. Remove infected plant material. Apply copper-based fungicide"
        );

        d66 = DiseaseDoc(
            disease_id="THRIPS_VEG",
            disease_name="Thrips",
            description="Thrips tabaci and Frankliniella species. Major pest of onions, French beans, tomatoes and many vegetables in Kenya. Vector of tospoviruses. Serious in greenhouse production in Naivasha and Rift Valley.",
            symptoms="Silvery streaking on leaves, white flecking on petals, distortion of young tissue, scarring on onion leaves, reduced yield and quality",
            treatments="Apply Spinosad, Abamectin or Chlorpyrifos. Use yellow and blue sticky traps for monitoring. Encourage predatory mites. Remove crop debris promptly. Use silver reflective mulch"
        );

        d67 = DiseaseDoc(
            disease_id="WHITEFLY",
            disease_name="Whitefly",
            description="Bemisia tabaci and Trialeurodes vaporariorum. Major pest and virus vector across Kenya. Transmits TYLCV (tomatoes), CMD (cassava) and other viruses. Serious greenhouse pest. Resistance to many insecticides developing.",
            symptoms="Tiny white flies rising from plant when disturbed, sticky honeydew on leaves, sooty mould growing on honeydew, yellowing of leaves, virus symptoms on host",
            treatments="Apply Thiamethoxam, Spirotetramat or Pymetrozine. Rotate insecticide classes to delay resistance. Use yellow sticky traps. Introduce Encarsia formosa biological control. Remove heavily infested plants"
        );

        d68 = DiseaseDoc(
            disease_id="SPIDERMITE",
            disease_name="Red Spider Mite",
            description="Tetranychus urticae. Common pest of many crops in Kenya especially in dry seasons. Severe in greenhouses and during droughts. Attacks French beans, tomatoes, vegetables.",
            symptoms="Fine stippling on upper leaf surface, bronzing or yellowing of leaves, fine webbing on underside of leaves in heavy infestations, premature leaf drop",
            treatments="Apply Abamectin, Bifenazate or Hexythiazox miticide. Avoid broad-spectrum insecticides that kill natural enemies. Maintain humidity. Introduce predatory mites (Phytoseiulus persimilis). Spray water to dislodge mites"
        );

        # ============================================================
        # ONION AND ALLIUM DISEASES (Sources: KALRO, Kenya Farmers)
        # ============================================================

        d69 = DiseaseDoc(
            disease_id="ONION_BLIGHT",
            disease_name="Onion Purple Blotch",
            description="Caused by Alternaria porri. Common in all onion growing areas in Kenya especially Karatina, Isinya, Mwea. Worse in warm humid conditions.",
            symptoms="Small white lesions with purple centres on leaves, lesions enlarge with yellow margins, leaves collapse in severe cases, storage rot on bulbs",
            treatments="Apply Mancozeb or Iprodione fungicide. Ensure good drainage and air circulation. Avoid overhead irrigation. Remove infected leaves. Practice crop rotation"
        );

        d70 = DiseaseDoc(
            disease_id="ONION_SMUDGE",
            disease_name="Onion Neck Rot",
            description="Caused by Botrytis allii. Major post-harvest disease of onions in Kenya causing storage losses. Enters through neck at harvest.",
            symptoms="Grey mould at neck of bulb spreading inward, soft watery rot of outer scales, grey spore masses on infected tissue, shrivelled necks",
            treatments="Cure bulbs at 28-35C for 10-14 days before storage. Harvest when 50% of tops have fallen. Apply Iprodione at harvest. Store in well-ventilated conditions. Avoid bruising during harvest"
        );

        # ============================================================
        # BANANA DISEASES (Sources: KALRO, Bioversity International)
        # ============================================================

        d71 = DiseaseDoc(
            disease_id="BXW",
            disease_name="Banana Xanthomonas Wilt",
            description="Caused by Xanthomonas vasicola pv. musacearum. Devastating banana disease. Present in Western Kenya (Kisumu, Kakamega, Bungoma). Can destroy entire plantation. Spreading rapidly.",
            symptoms="Wilting and yellowing of leaves starting with outer leaves, premature ripening of individual fingers, brown internal discolouration of fruit, bacterial ooze from cut stem",
            treatments="Remove and destroy entire infected mat with surrounding soil. Disinfect machetes with bleach between plants. Male bud removal to reduce bee spread. Plant resistant varieties when available. Community-wide management essential"
        );

        d72 = DiseaseDoc(
            disease_id="FUSARIUM_WILT_BAN",
            disease_name="Banana Fusarium Wilt (Panama Disease)",
            description="Caused by Fusarium oxysporum f.sp. cubense. Present in coastal Kenya affecting Cavendish varieties. Soil-borne disease that persists indefinitely. Historical race 1 devastated Gros Michel bananas globally.",
            symptoms="Yellowing of outer leaves progressing inward, leaf collapse at petiole, yellow-brown vascular discolouration in pseudostem when cut, plant death",
            treatments="No effective fungicide control. Remove and destroy infected mats. Practice strict movement controls. Plant resistant varieties (NARITA hybrids). Avoid movement of soil from infested areas. Solarise infested soil"
        );

        d73 = DiseaseDoc(
            disease_id="BLACK_SIGATOKA",
            disease_name="Black Sigatoka",
            description="Caused by Mycosphaerella fijiensis. Most serious banana leaf disease in Kenya. Widespread in coastal and western banana areas. Destroys photosynthetic capacity and reduces bunch weight.",
            symptoms="Small pale yellow spots on lower leaf surface, spots enlarge to dark brown-black streaks, leaves dry from tips, white-grey centre in mature lesions, premature leaf death",
            treatments="Apply Propiconazole or Chlorothalonil regularly. Remove infected leaves. Maintain proper spacing. Apply potassium to improve resistance. Avoid water stress. Use recommended spray programme from KALRO"
        );

        # ============================================================
        # COFFEE DISEASES (Sources: CRI Kenya, KALRO)
        # ============================================================

        d74 = DiseaseDoc(
            disease_id="CBD",
            disease_name="Coffee Berry Disease",
            description="Caused by Colletotrichum kahawae. Most economically important coffee disease in Kenya. Affects Arabica coffee in Central and Eastern highlands. First discovered in Kenya. CRI (Coffee Research Institute) managed by KALRO.",
            symptoms="Dark brown-black lesions on green berries, infected berries dry and remain on tree as mummies, pinkish spore masses in wet conditions, shrivelled brown berries",
            treatments="Apply Copper oxychloride or Carbendazim spray programme (5-7 sprays per season). Plant resistant or tolerant varieties: Ruiru 11, Batian. Remove mummified berries. Maintain proper canopy management"
        );

        d75 = DiseaseDoc(
            disease_id="CLR",
            disease_name="Coffee Leaf Rust",
            description="Caused by Hemileia vastatrix. Increasingly important in Kenyan coffee. More severe in lower altitude zones. Climate change is expanding its range upward in Kenya highlands.",
            symptoms="Pale yellow spots on upper leaf surface, orange powdery pustules on lower leaf surface corresponding to yellow spots, premature defoliation",
            treatments="Apply Copper oxychloride or Triazole fungicides. Plant tolerant varieties (Ruiru 11, Batian). Prune for air circulation. Maintain proper tree spacing. Spray preventively at start of rains"
        );

        d76 = DiseaseDoc(
            disease_id="ANTESTIA_BUG",
            disease_name="Antestia Bug",
            description="Antestiopsis spp. Major pest of Arabica coffee in Kenya highlands. Causes potato taste defect in coffee and significant bean damage. Spreads Nematospora (yeast infection). Monitored by KALRO CRI.",
            symptoms="Oozing sap on attacked berries, spotted appearance on berries, premature berry drop, potato taste defect in processed coffee",
            treatments="Apply Endosulfan or Pyrethroids when populations exceed threshold. Remove alternative host plants. Proper shade management to reduce breeding sites. Train pickers to report infestations"
        );

        # ============================================================
        # TEA DISEASES (Sources: TRFK, KALRO)
        # ============================================================

        d77 = DiseaseDoc(
            disease_id="BLISTER_BLIGHT",
            disease_name="Tea Blister Blight",
            description="Caused by Exobasidium vexans. Most important tea disease in Kenya. Severe during cool wet periods. Kenya is major global tea producer (Nyeri, Kiambu, Kericho, Nandi) - managed by TRFK/KALRO.",
            symptoms="Circular water-soaked blisters on young leaves turning white with powdery spore mass, leaf curling around blister, leaf and shoot distortion",
            treatments="Apply Copper oxychloride or Mancozeb at 10-day intervals. Improve shade regulation. Avoid high-canopy management that traps moisture. Use tolerant clones recommended by TRFK"
        );

        d78 = DiseaseDoc(
            disease_id="RED_SPIDER_TEA",
            disease_name="Red Spider Mite on Tea",
            description="Oligonychus coffeae. Serious pest in drought periods. Causes significant crop loss in Kenyan tea during dry spells. Managed under TRFK integrated pest management programme.",
            symptoms="Bronze or brick-red discolouration of mature leaves, fine webbing on leaf undersides, stippling of leaf surface, loss of green colour, leaf fall in severe cases",
            treatments="Apply Abamectin or Bifenazate. Maintain adequate soil moisture. Avoid drought stress. Introduce predatory mites. Apply acaricide rotation to prevent resistance"
        );

        # ============================================================
        # MANGO DISEASES (Sources: KALRO, CoAgroF UoN)
        # ============================================================

        d79 = DiseaseDoc(
            disease_id="ANTH_MANGO",
            disease_name="Mango Anthracnose",
            description="Caused by Colletotrichum gloeosporioides. Most important mango disease in Kenya affecting all mango-growing areas (Coast, Eastern, Rift Valley). Major cause of post-harvest losses.",
            symptoms="Dark brown-black lesions on leaves, flowers and fruits, shot-hole symptoms on leaves, blossom blight, black spots on ripe fruit, internal dark rot in stored mangoes",
            treatments="Apply Mancozeb or Copper hydroxide during flowering and fruit development. Avoid wetting foliage during irrigation. Harvest promptly. Apply hot water treatment post-harvest (52C for 5 min). Store correctly"
        );

        d80 = DiseaseDoc(
            disease_id="MANGO_WEEVIL",
            disease_name="Mango Seed Weevil",
            description="Sternochetus mangiferae. Quarantine pest of mango in Kenya. Lays eggs in small fruits, larvae develop inside seed. Restricts Kenyan mango export to EU markets. Monitored by KEPHIS.",
            symptoms="No external signs in fruit, larvae and pupae found inside mango seed only, adult exit holes in skin when mature, premature fruit drop in heavy infestations",
            treatments="No effective in-field control. Bag fruits at marble size with paper or plastic bags. Early harvest and immediate processing. Certified pest-free areas maintained by KEPHIS. Use clean seedling material"
        );

        # ============================================================
        # AVOCADO DISEASES (Sources: KALRO, HCDA)
        # ============================================================

        d81 = DiseaseDoc(
            disease_id="AVOCADO_ROT",
            disease_name="Avocado Root Rot",
            description="Caused by Phytophthora cinnamomi. Most serious avocado disease in Kenya's growing avocado export sector. Common in heavy, poorly-drained soils. Major constraint in Muranga, Kiambu and Meru avocado zones.",
            symptoms="Yellowing of leaves, small pale green leaves, wilting during warm afternoons, death of feeder roots, black-brown discolouration of roots",
            treatments="Plant in well-drained soils or raised beds. Apply Ridomil Gold to soil and as trunk injection. Use tolerant rootstocks (Dusa, Duke 7). Avoid waterlogging. Fumigate nursery soil. Remove severely affected trees"
        );

        d82 = DiseaseDoc(
            disease_id="AVOCADO_SCAB",
            disease_name="Avocado Scab",
            description="Caused by Sphaceloma perseae. Common in Kenyan highland avocado production. Reduces fruit quality and marketability. Affects Kenya's growing export market.",
            symptoms="Rough corky lesions on young fruits, cracking of fruit skin, dirty brown scabby spots on skin, fruit malformation in severe cases",
            treatments="Apply Copper oxychloride or Mancozeb at fruit set. Prune for air circulation. Avoid wetting fruit during irrigation. Remove infected tissue. Apply fungicide after each flush of new growth"
        );

        # ============================================================
        # SOIL AND ENVIRONMENTAL ISSUES (Sources: KALRO, UoN)
        # ============================================================

        d83 = DiseaseDoc(
            disease_id="ROOT_KNOT_NEM",
            disease_name="Root Knot Nematode",
            description="Meloidogyne species. Most common nematode affecting vegetables, tomatoes and other crops in Kenya. Widespread in sandy soils of Central and Eastern regions. Major constraint in intensively farmed plots.",
            symptoms="Galls (knots) on roots, stunted pale plants, wilting in warm afternoons, poor yield despite good rainfall, roots with swollen sections",
            treatments="Apply Carbofuran or Ethoprophos nematicide at planting. Solarise soil with clear plastic for 6-8 weeks in hot season. Apply Trichoderma and Paecilomyces bioagents. Plant resistant varieties. Practice 2-year rotation with cereals or brassicas"
        );

        d84 = DiseaseDoc(
            disease_id="SOIL_SALINITY",
            disease_name="Soil Salinity",
            description="Increasingly common in irrigated areas of Kenya including Mwea, Ahero, Perkerra and coastal plains. Excess salts from poor-quality irrigation water or over-fertilisation.",
            symptoms="White crust on soil surface, wilting of plants despite adequate water, brown leaf margins, stunted plants, poor germination",
            treatments="Improve drainage to leach salts below root zone. Apply gypsum to displace sodium. Use good quality low-salt irrigation water. Mulch surface. Grow salt-tolerant crops. Conduct soil EC tests"
        );

        d85 = DiseaseDoc(
            disease_id="MG_DEF",
            disease_name="Magnesium Deficiency",
            description="Common in highly leached highland soils of Kenya and in acidic soils. Aggravated by high K and Ca fertilisation without Mg. Seen in mature crop leaves.",
            symptoms="Interveinal chlorosis on older leaves (yellowing between green veins), veins remain green while tissue turns yellow, starts at leaf margins, progresses inward",
            treatments="Apply dolomitic lime (contains Mg) instead of calcitic lime. Foliar spray with Epsom salt (magnesium sulphate) at 2%. Apply Kieserite (MgSO4) to soil at 100 kg/ha"
        );

        d86 = DiseaseDoc(
            disease_id="FE_DEF",
            disease_name="Iron Deficiency",
            description="Occurs in alkaline and waterlogged soils in Kenya. Common in Mwea rice scheme and in over-limed soils. Seen in young leaves first.",
            symptoms="Interveinal chlorosis on youngest leaves (opposite pattern to Mg deficiency), very pale yellow to white young leaves, normal-looking older leaves",
            treatments="Reduce soil pH below 6.5. Apply chelated iron (Fe-EDTA) foliar spray. Avoid overwatering in poorly-drained soils. Apply sulphur to reduce pH. Improve drainage"
        );

        d87 = DiseaseDoc(
            disease_id="BORON_DEF",
            disease_name="Boron Deficiency",
            description="Increasingly reported in Kenyan soils especially in areas with high rainfall leaching. Affects reproductive development. Reported in sunflower and vegetable production.",
            symptoms="Hollow or corky stem tissue in brassicas, poor seed set and fruit formation, distorted young leaves, flower and bud abortion, cracked fruit",
            treatments="Apply Borax at 1 kg/ha to soil before planting. Foliar spray of boric acid (0.1%) at flowering. Do not over-apply as boron toxicity occurs at relatively low levels"
        );

        # ============================================================
        # FRENCH BEANS (Sources: HCDA, Kenya Flowers Council research)
        # ============================================================

        d88 = DiseaseDoc(
            disease_id="HALO_FB",
            disease_name="French Bean Halo Blight",
            description="Caused by Pseudomonas syringae pv. phaseolicola. Major disease of French bean export crop in Kenya. Causes rejection at European markets. Common in highland export zones of Kirinyaga, Meru.",
            symptoms="Water-soaked spots with yellow halos on leaves and pods, halos give disease its name, greasy appearance of lesions, pod spotting causing export rejection",
            treatments="Use certified disease-free seeds. Avoid overhead irrigation especially in mornings. Apply copper bactericide preventively. Avoid working in wet crop. Strict export packing standards"
        );

        d89 = DiseaseDoc(
            disease_id="ANGULAR_FB",
            disease_name="French Bean Angular Leaf Spot",
            description="Same pathogen as bean ALS - Phaeoisariopsis griseola. Major export quality constraint in Kenyan French bean production. Causes consignment rejection. Common in Meru, Kirinyaga, Embu.",
            symptoms="Angular lesions on leaves and pods, grey sporulation on lower leaf surface, pod lesions cause export rejection at destination",
            treatments="Use certified disease-free seeds. Apply Mancozeb or Copper fungicide. Strict 3-year rotation. Export protocols require zero tolerance on pods. Improve air circulation"
        );

        d90 = DiseaseDoc(
            disease_id="PYTHIUM_DAMP",
            disease_name="Damping Off",
            description="Caused by Pythium and Rhizoctonia species. Very common seedling disease in Kenya affecting nurseries and direct-sown crops. Worse in cold wet conditions with poor drainage.",
            symptoms="Seedling collapse at soil level, pinched brown stem at soil surface, water-soaked lesion at base, seedlings fall over in groups, poor germination patches",
            treatments="Use well-drained nursery mix. Treat seeds with Thiram or Metalaxyl + Thiram. Avoid overwatering. Improve drainage with coarse sand. Apply Ridomil drench to nursery. Solarise nursery soil before use"
        );

        # ============================================================
        # PYRETHRUM (Sources: KALRO Pyrethrum Board)
        # ============================================================

        d91 = DiseaseDoc(
            disease_id="PYRET_APHID",
            disease_name="Pyrethrum Aphid",
            description="Brachycaudus helichrysi. Serious pest of pyrethrum in Kenya highlands especially Nakuru, Nyandarua and Meru zones. Causes stunting and reduces flower yield.",
            symptoms="Colonies of yellow-green aphids on young shoots and flower buds, distortion of shoot tips, reduced flower production",
            treatments="Apply Dimethoate or Pirimicarb. Encourage natural enemies. Monitor weekly from October to March peak season. Apply early before populations build up"
        );

        # ============================================================
        # SUNFLOWER (Sources: KALRO, KEPHIS)
        # ============================================================

        d92 = DiseaseDoc(
            disease_id="SUNFLOWER_ALT",
            disease_name="Sunflower Alternaria Blight",
            description="Caused by Alternaria helianthi. Common in sunflower growing areas of Kenya especially Rift Valley, Eastern and Western Kenya during humid periods.",
            symptoms="Dark brown circular lesions with yellow halos on leaves, lesions on stems and seed heads, premature defoliation, dark-brown seed infection",
            treatments="Apply Mancozeb at first sign. Use certified disease-free seeds. Practice crop rotation. Remove infected plant debris. Improve plant spacing"
        );

        d93 = DiseaseDoc(
            disease_id="SUNFLOWER_BRO",
            disease_name="Broomrape",
            description="Orobanche spp. Parasitic weed attacking sunflower and tomato in drier Kenya regions. Becoming more prevalent in Eastern and Rift Valley zones. No effective in-crop control.",
            symptoms="Yellow-white flowering parasitic plants at crop base, crops severely stunted and yellowed, multiple broomrape shoots per crop plant",
            treatments="Use resistant varieties. Apply Imazapic herbicide to resistant varieties. Practice 5+ year rotation away from host crops. Avoid moving infested soil. Solarise field before planting"
        );

        # ============================================================
        # RICE (Sources: National Irrigation Authority, KALRO Mwea)
        # ============================================================

        d94 = DiseaseDoc(
            disease_id="RICE_BLAST",
            disease_name="Rice Blast",
            description="Caused by Magnaporthe oryzae. Most serious rice disease in Mwea, Ahero and Bunyala rice schemes in Kenya. Can cause 50-100% yield loss in severe epidemics.",
            symptoms="Diamond-shaped grey-brown lesions on leaves with dark border, lesions on panicle neck causing neck rot and empty panicles, whitening of panicles",
            treatments="Apply Tricyclazole or Propiconazole fungicide preventively before heading. Use resistant varieties. Apply balanced fertilisation (avoid excess N). Drain fields periodically. Use certified blast-free seed"
        );

        d95 = DiseaseDoc(
            disease_id="RICE_BLB",
            disease_name="Rice Bacterial Leaf Blight",
            description="Caused by Xanthomonas oryzae pv. oryzae. Common in Mwea and Ahero rice schemes in Kenya. Severe in warm humid conditions especially after flooding.",
            symptoms="Yellowing and wilting starting at leaf tips and margins, water-soaked margins with wavy lines, white to yellow lesions from tips, milky bacterial ooze from cut leaf tip in water",
            treatments="Use resistant varieties. Apply copper bactericide at first sign. Drain flooded fields promptly. Avoid excess nitrogen. Plant at correct density. Remove infected straw after harvest"
        );

        # ============================================================
        # GROUNDNUT (Sources: KALRO, ICRISAT)
        # ============================================================

        d96 = DiseaseDoc(
            disease_id="ROSETTE",
            disease_name="Groundnut Rosette",
            description="Caused by Groundnut rosette virus. Transmitted by aphid Aphis craccivora. Major groundnut disease in Kenya especially Western and Nyanza regions. Can cause 100% loss in early infection.",
            symptoms="Severe stunting of plants, bunchy rosette appearance, small yellow-green mottled leaves, greatly reduced pod and seed production",
            treatments="Plant early at start of rains. Plant at recommended density. Apply insecticide at emergence to control aphid vectors. Use resistant varieties. Remove and destroy infected plants immediately"
        );

        d97 = DiseaseDoc(
            disease_id="CERCOSPORA_GNUT",
            disease_name="Groundnut Leaf Spots",
            description="Early leaf spot (Cercospora arachidicola) and late leaf spot (Cercosporidium personatum). Common in all groundnut areas of Kenya. Causes premature defoliation reducing yield.",
            symptoms="Brown to black circular spots on leaves, yellow halos on early leaf spot lesions, dark lesions without halos on late leaf spot, premature defoliation",
            treatments="Apply Chlorothalonil or Mancozeb at 14-day intervals. Plant resistant varieties. Practice crop rotation. Remove infected debris. Monitor from 30 days after planting"
        );

        # ============================================================
        # KALE (SUKUMA WIKI) DISEASES (Sources: KALRO, Kenya Farmer)
        # ============================================================

        d98 = DiseaseDoc(
            disease_id="DOWNY_BRASSICA",
            disease_name="Brassica Downy Mildew",
            description="Caused by Peronospora parasitica. Very common in kale (sukuma wiki), cabbage and other brassicas in Kenya. Worst during cool wet periods. Widespread in all brassica-growing areas.",
            symptoms="Yellow patches on upper leaf surface, white-grey fluffy growth on lower surface, leaves turn brown and papery in severe cases, seedling damping off",
            treatments="Apply Ridomil Gold or Chlorothalonil. Avoid overcrowding. Improve air circulation. Avoid overhead irrigation. Remove infected leaves. Apply preventively at transplanting"
        );

        d99 = DiseaseDoc(
            disease_id="DIAMONDBACK",
            disease_name="Diamondback Moth",
            description="Plutella xylostella. Most damaging pest of brassicas in Kenya. Highly resistant to many insecticides. Found throughout Kenya in all brassica growing areas. Major constraint for cabbage, kale and broccoli.",
            symptoms="Window pane feeding leaving translucent patches, small caterpillars with characteristic wriggling when disturbed, holes in leaves, defoliation in severe cases",
            treatments="Apply Emamectin benzoate or Chlorantraniliprole (rotate to prevent resistance). Avoid Bt Kurstaki overuse alone. Use pheromone traps for monitoring. Remove crop residues promptly. Apply Spinosad where registered. Encourage parasitic wasps"
        );

        d100 = DiseaseDoc(
            disease_id="BLACKROT_BRASSICA",
            disease_name="Black Rot of Brassica",
            description="Caused by Xanthomonas campestris pv. campestris. Major bacterial disease of kale, cabbage and other brassicas in Kenya. Seed-borne and spread by rain splash. Causes significant losses in wet seasons.",
            symptoms="Yellow V-shaped lesions at leaf margins pointing toward midrib, black veins visible inside the V-shaped lesion, leaves turn yellow and drop, blackening of head in cabbage",
            treatments="Use certified disease-free seeds. Apply copper bactericide at transplanting and when symptoms first seen. Avoid overhead irrigation. Remove and destroy infected plants. Practice 3-year rotation away from brassicas"
        );

        # ============================================================
        # BONUS DISEASES to ensure comprehensive coverage
        # ============================================================

        d101 = DiseaseDoc(
            disease_id="FALL_WEBWORM",
            disease_name="Cutworm",
            description="Agrotis species. Common soil pest affecting transplanted vegetables, maize and other crops in Kenya. Cuts seedlings at soil level at night. Found in all crop-growing areas.",
            symptoms="Seedlings cut at or below soil level at night, wilted or missing seedlings in the morning, fat smooth caterpillars found coiled in soil near damaged plant",
            treatments="Apply Chlorpyrifos bait granules or soil drench at planting. Till soil to expose and kill larvae. Plant dense and replace losses. Water seedlings adequately to reduce stress. Apply neem cake to soil"
        );

        d102 = DiseaseDoc(
            disease_id="LOCUST",
            disease_name="Desert Locust",
            description="Schistocerca gregaria. Periodic devastating pest of Kenya especially Northern, Eastern and Rift Valley. Major 2019-2021 outbreak affected 23 counties. Government and FAO manage response. KALRO provides technical guidance.",
            symptoms="Complete defoliation of crop fields, total stripping of crops and vegetation within hours, large swarms visible in sky, characteristic hopping bands of hoppers in early stage",
            treatments="Contact Ministry of Agriculture locust control unit immediately. Do not spray without government coordination. Apply Chlorpyrifos or Malathion by air if authorised. Report to nearest agricultural extension office. Plant replacement crops if season allows"
        );

        d103 = DiseaseDoc(
            disease_id="ARMY_WORM",
            disease_name="African Armyworm",
            description="Spodoptera exempta. Major migratory pest of cereals in Kenya especially during La Nina events. Outbreaks tracked by KALRO and Pest Control Products Board. Can destroy large areas in 24 hours.",
            symptoms="Large numbers of caterpillars moving through fields, complete defoliation starting from field edges, caterpillars with distinctive stripes on side, plants eaten down to stem",
            treatments="Apply Lambda-cyhalothrin or Emamectin benzoate immediately when outbreak reported. Dig trenches at field edges to stop marching bands. Report to extension officer for area-wide control. Apply Bt kurstaki for organic control on young caterpillars"
        );

        d104 = DiseaseDoc(
            disease_id="QUELEA_PROT",
            disease_name="Sorghum Shoot Fly",
            description="Atherigona soccata. Major pest of sorghum in Kenya ASAL regions. Attacks at seedling stage causing dead heart symptoms. Common in Machakos, Kitui, Tharaka Nithi and Makueni.",
            symptoms="Dead hearts in young sorghum plants with yellowing central shoot that pulls out easily, grubs at base of dead shoot, plants may tiller but are weakened",
            treatments="Plant early before peak fly population. Apply Carbofuran at planting. Use tolerant varieties with hairy or waxy leaves. Avoid late planting. Encourage parasitic fly populations"
        );

        d105 = DiseaseDoc(
            disease_id="MEALYBUG",
            disease_name="Cassava Mealybug",
            description="Phenacoccus manihoti. Introduced from South America. Present in coastal Kenya affecting cassava production. Biological control using parasitic wasp Apoanagyrus lopezi introduced by CABI/IITA.",
            symptoms="White cottony wax on growing tips, stunted shoots, crinkled distorted leaves at tips, yellowing of leaves",
            treatments="Biological control using Apoanagyrus lopezi wasp (CABI released). Apply Chlorpyrifos where infestation severe. Use clean cuttings from uninfected source. Check planting material before transport"
        );

        # Link all disease nodes to root
        root ++> d1; root ++> d2; root ++> d3; root ++> d4; root ++> d5;
        root ++> d6; root ++> d7; root ++> d8; root ++> d9; root ++> d10;
        root ++> d11; root ++> d12; root ++> d13; root ++> d14; root ++> d15;
        root ++> d16; root ++> d17; root ++> d18; root ++> d19; root ++> d20;
        root ++> d21; root ++> d22; root ++> d23; root ++> d24; root ++> d25;
        root ++> d26; root ++> d27; root ++> d28; root ++> d29; root ++> d30;
        root ++> d31; root ++> d32; root ++> d33; root ++> d34; root ++> d35;
        root ++> d36; root ++> d37; root ++> d38; root ++> d39; root ++> d40;
        root ++> d41; root ++> d42; root ++> d43; root ++> d44; root ++> d45;
        root ++> d46; root ++> d47; root ++> d48; root ++> d49; root ++> d50;
        root ++> d51; root ++> d52; root ++> d53; root ++> d54; root ++> d55;
        root ++> d56; root ++> d57; root ++> d58; root ++> d59; root ++> d60;
        root ++> d61; root ++> d62; root ++> d63; root ++> d64; root ++> d65;
        root ++> d66; root ++> d67; root ++> d68; root ++> d69; root ++> d70;
        root ++> d71; root ++> d72; root ++> d73; root ++> d74; root ++> d75;
        root ++> d76; root ++> d77; root ++> d78; root ++> d79; root ++> d80;
        root ++> d81; root ++> d82; root ++> d83; root ++> d84; root ++> d85;
        root ++> d86; root ++> d87; root ++> d88; root ++> d89; root ++> d90;
        root ++> d91; root ++> d92; root ++> d93; root ++> d94; root ++> d95;
        root ++> d96; root ++> d97; root ++> d98; root ++> d99; root ++> d100;
        root ++> d101; root ++> d102; root ++> d103; root ++> d104; root ++> d105;

        print("[SEED] Seeding case studies...");

        cs1 = CaseStudy(
            case_id="CS001",
            crop="maize",
            region="kiambu",
            problem="Farmer noticed progressive yellowing of maize leaves starting from lower leaves in March 2024 during long rains",
            diagnosis="Nitrogen Deficiency",
            outcome="Applied urea top-dressing at V6 stage. Plants recovered within 3 weeks. Yield improved by 40% compared to untreated plot"
        );

        cs2 = CaseStudy(
            case_id="CS002",
            crop="maize",
            region="nakuru",
            problem="White streaks along leaf veins observed on maize in April, plants severely stunted",
            diagnosis="Maize Streak Virus",
            outcome="Replaced with resistant variety H614 in the following season. Switched to certified seed. Yield improved significantly"
        );

        cs3 = CaseStudy(
            case_id="CS003",
            crop="maize",
            region="nyeri",
            problem="Long grey-brown lesions appearing on maize leaves after heavy rains in highland farm",
            diagnosis="Northern Corn Leaf Blight",
            outcome="Applied Mancozeb fungicide and improved spacing. Saved 65% of crop. Planted resistant variety following season"
        );

        cs4 = CaseStudy(
            case_id="CS004",
            crop="potato",
            region="nyandarua",
            problem="Entire field of Irish potato wilted within one week despite adequate rainfall in June",
            diagnosis="Potato Bacterial Wilt",
            outcome="No recovery possible. Destroyed infected crop. Farmer now uses KEPHIS certified seed tubers and practices 4-year rotation"
        );

        cs5 = CaseStudy(
            case_id="CS005",
            crop="potato",
            region="meru",
            problem="Water-soaked lesions on potato leaves rapidly spreading to whole field during long rains",
            diagnosis="Potato Late Blight",
            outcome="Applied Ridomil Gold preventively in subsequent seasons. Switched to resistant variety Shangi. Yield loss reduced from 80% to 10%"
        );

        cs6 = CaseStudy(
            case_id="CS006",
            crop="beans",
            region="western",
            problem="Angular brown spots on bean leaves with premature leaf drop reducing yield by over 50%",
            diagnosis="Angular Leaf Spot",
            outcome="Used resistant variety Lyamungu 85 in next season. Applied Mancozeb. Disease reduced significantly and yield doubled"
        );

        cs7 = CaseStudy(
            case_id="CS007",
            crop="maize",
            region="trans nzoia",
            problem="Fall armyworm damage observed in large outbreak affecting 20 acres in September 2022",
            diagnosis="Fall Armyworm",
            outcome="Applied Emamectin benzoate at first sign. Saved 70% of crop. Joined early warning scouting group coordinated by county agriculture office"
        );

        cs8 = CaseStudy(
            case_id="CS008",
            crop="tomato",
            region="kirinyaga",
            problem="Tomato crop wilting suddenly during warm afternoons, brown vascular tissue when stem cut",
            diagnosis="Tomato Bacterial Wilt",
            outcome="Crop destroyed. Next season grafted tomatoes onto resistant rootstock. No recurrence in 3 growing seasons"
        );

        cs9 = CaseStudy(
            case_id="CS009",
            crop="cassava",
            region="western",
            problem="Cassava roots showing brown corky patches inside making them inedible at harvest",
            diagnosis="Cassava Brown Streak Disease",
            outcome="Switched to CBSD-resistant variety Tajirika. Sourced certified virus-free cuttings. Production restored"
        );

        cs10 = CaseStudy(
            case_id="CS010",
            crop="maize",
            region="bungoma",
            problem="Striga witchweed covering over 60% of sorghum field in Western Kenya smallholder farm",
            diagnosis="Striga Witchweed",
            outcome="Adopted push-pull technology with Desmodium intercrop and Napier grass border. Striga reduced by 90% over 3 seasons. Fodder benefit also obtained"
        );

        root ++> cs1; root ++> cs2; root ++> cs3; root ++> cs4; root ++> cs5;
        root ++> cs6; root ++> cs7; root ++> cs8; root ++> cs9; root ++> cs10;

        print("[SEED] Running Graph-RAG seeding...");

        root spawn SeedGraphRAG();

        print("[SEED] ========================================");
        print("[SEED] SEEDING COMPLETE");
        print("[SEED]   DiseaseDoc nodes: 105");
        print("[SEED]   CaseStudy nodes: 10");
        print("[SEED]   Graph-RAG relationships seeded");
        print("[SEED] ========================================");
        print("[SEED] Sources: KALRO, KEPHIS, CABI, CIMMYT,");
        print("[SEED]          ICIPE, UoN, NPCK, CRI, TRFK");

        report {
            "status": "success",
            "diseases_seeded": 105,
            "case_studies_seeded": 10,
            "graph_rag_seeded": True
        };
    }
}
