include utils;
include intergrations;

sv import from backend.models {
    AdvicePlan,
    DiseaseDoc,
    Crop
}

sv import from backend.models {
    translate_from_pivot
}

def generate_session_id() -> str {
    ts = get_current_datetime();
    clean = ts.replace(" ", "_").replace(":", "-");
    return f"sess-{clean}";
}

def normalize_location(loc: str) -> str {
    if not loc {
        return "unknown";
    }
    return loc.strip().lower();
}

def normalize_crop(crop: str) -> str {
    if not crop {
        return "unknown";
    }
    return crop.strip().lower();
}

def normalize_region(region: str) -> str {
    if not region {
        return "unknown";
    }
    return region.strip().lower();
}

def normalize_region_to_id(location: str) -> str {
    if not location {
        return "";
    }

    loc = location.strip().lower();

    if "kiambu" in loc {
        return "ke-kiambu";
    } elif "nairobi" in loc {
        return "ke-nairobi";
    } elif "nakuru" in loc {
        return "ke-nakuru";
    } elif "uasin gishu" in loc or "eldoret" in loc {
        return "ke-uasin-gishu";
    } elif "kisumu" in loc {
        return "ke-kisumu";
    } elif "meru" in loc {
        return "ke-meru";
    } elif "machakos" in loc {
        return "ke-machakos";
    } elif "mombasa" in loc {
        return "ke-mombasa";
    } elif "kakamega" in loc {
        return "ke-kakamega";
    } elif "nyeri" in loc {
        return "ke-nyeri";
    }

    return "";
}

def make_cache_key(
    crop: str,
    problem_text: str,
    location: str,
    lang: str,
    include_weather: bool,
    include_market: bool,
    include_image: bool
) -> str {
    norm_crop = normalize_crop(crop);
    norm_loc = normalize_location(location);
    trimmed_problem = problem_text.strip();
    if len(trimmed_problem) > 120 {
        trimmed_problem = trimmed_problem[:120];
    }
    return (
        f"{norm_crop}|{norm_loc}|{lang}"
        f"|w={include_weather}|m={include_market}|img={include_image}|{trimmed_problem}"
    );
}

def parse_cache_key(key: str) -> dict {
    crop = "";
    location = "";
    lang = "";
    include_weather = False;
    include_market = False;
    include_image = False;
    problem_preview = "";

    if key {
        parts = key.split("|");

        if len(parts) >= 7 {
            crop = parts[0];
            location = parts[1];
            lang = parts[2];

            if "w=True" in parts[3] or "w=true" in parts[3] {
                include_weather = True;
            }

            if "m=True" in parts[4] or "m=true" in parts[4] {
                include_market = True;
            }

            if "img=True" in parts[5] or "img=true" in parts[5] {
                include_image = True;
            }

            problem_preview = parts[6];
        }
    }

    return {
        "raw": key,
        "crop": crop,
        "location": location,
        "lang": lang,
        "include_weather": include_weather,
        "include_market": include_market,
        "include_image": include_image,
        "problem_preview": problem_preview
    };
}

def translate_advice_if_needed(
    advice: AdvicePlan,
    target_lang: str
) -> AdvicePlan {
    if not target_lang or target_lang == "en" {
        return advice;
    }

    new_overview = translate_from_pivot(
        text=advice.overview,
        lang=target_lang
    );

    new_steps = [];
    for s in advice.steps {
        new_steps = new_steps + [
            translate_from_pivot(text=s, lang=target_lang)
        ];
    }

    new_cautions = [];
    for c in advice.cautions {
        new_cautions = new_cautions + [
            translate_from_pivot(text=c, lang=target_lang)
        ];
    }

    return AdvicePlan(
        overview=new_overview,
        steps=new_steps,
        cautions=new_cautions
    );
}

def translate_summary_text_if_needed(
    text: str,
    target_lang: str
) -> str {
    if not target_lang or target_lang == "en" {
        return text;
    }
    if not text {
        return text;
    }

    return translate_from_pivot(
        text=text,
        lang=target_lang
    );
}

def get_ui_titles(lang: str) -> dict {
    if not lang or lang == "en" {
        return {
            "advice_overview": "Overview",
            "advice_steps": "Recommended steps",
            "advice_cautions": "Cautions & safety notes",
            "weather_summary": "Weather summary",
            "market_summary": "Market summary"
        };
    }

    if lang == "sw" {
        return {
            "advice_overview": "Muhtasari",
            "advice_steps": "Hatua zinazopendekezwa",
            "advice_cautions": "Tahadhari na usalama",
            "weather_summary": "Muhtasari wa hali ya hewa",
            "market_summary": "Muhtasari wa soko"
        };
    }

    return {
        "advice_overview": "Overview",
        "advice_steps": "Recommended steps",
        "advice_cautions": "Cautions & safety notes",
        "weather_summary": "Weather summary",
        "market_summary": "Market summary"
    };
}

def parse_datetime_safe(dt_str: str) -> any {
    try {
        return datetime.fromisoformat(dt_str);
    } except Exception {
        try {
            return datetime.strptime(dt_str, "%Y-%m-%d %H:%M:%S.%f");
        } except Exception {
            try {
                return datetime.strptime(dt_str, "%Y-%m-%d %H:%M:%S");
            } except Exception {
                return None;
            }
        }
    }
}


# RAG FUNCTIONS
def retrieve_relevant_diseases(problem: str) -> list {

    print("\n[RAG] ========================================");
    print("[RAG] SEARCHING KNOWLEDGE BASE");

    preview = problem;
    if len(problem) > 100 {
        preview = problem[0:100];
    }

    print("[RAG] Query: " + preview + "...");
    print("[RAG] ========================================");

    results = [];
    problem_lower = problem.lower();

    all_diseases = [root -->][?:DiseaseDoc];
    print("[RAG] Total diseases in knowledge base: " + str(len(all_diseases)));

    for d in all_diseases {

        score = 0;

        if problem_lower in d.symptoms.lower() {
            score = score + 2;
            print("[RAG]   ✓ Symptom match in: " + d.disease_name);
        }

        if problem_lower in d.description.lower() {
            score = score + 1;
            print("[RAG]   ✓ Description match in: " + d.disease_name);
        }

        if problem_lower in d.disease_name.lower() {
            score = score + 3;
            print("[RAG]   ✓ Name match in: " + d.disease_name);
        }

        if score > 0 {
            results.append({"d": d, "score": score});
            print("[RAG]   → " + d.disease_name + ": score = " + str(score));
        }
    }

    sorted_results = [];

    while len(results) > 0 {

        best = results[0];

        for r in results {
            if r["score"] > best["score"] {
                best = r;
            }
        }

        sorted_results.append(best["d"]);
        results.remove(best);
    }

    print("\n[RAG] FOUND " + str(len(sorted_results)) + " RELEVANT DISEASES");

    i = 0;
    for d in sorted_results {

        if i < 5 {
            print("[RAG]   " + str(i + 1) + ". " + d.disease_name);
        }

        i = i + 1;
    }

    print("[RAG] ========================================\n");

    return sorted_results;
}
def format_disease_context(diseases: list) -> str {
    # Format disease information for LLM context
    # WITH LOGGING to show what's being sent to LLM

    context = "";

    print("\n[RAG] ========================================");
    print("[RAG] FORMATTING CONTEXT FOR LLM");
    print("[RAG] Number of diseases: " + str(len(diseases)));
    print("[RAG] ========================================");

    for d in diseases {
        context += "Disease: " + d.disease_name + "\n";
        context += "Symptoms: " + d.symptoms + "\n";
        context += "Treatment: " + d.treatments + "\n\n";

        print("[RAG] Added to context: " + d.disease_name);
    }

    print("[RAG] Total context length: " + str(len(context)) + " characters");
    print("[RAG] ========================================\n");

    return context;
}
def strip_country_from_location(location: str) -> str {

    if not location {
        return "";
    }

    loc = location.lower();

    # remove country suffixes
    loc = loc.replace(", kenya", "");
    loc = loc.replace(" kenya", "");

    return loc.strip();
}
def retrieve_relevant_diseases_graph(
    problem: str,
    crop: str,
    region: str,
    season: str = ""
) -> list {
   
    # Graph-RAG search: Find diseases using graph relationships
    
    
    print("\n[GRAPH-RAG] ========================================");
    print(f"[GRAPH-RAG] SEARCHING WITH GRAPH CONTEXT");
    print(f"[GRAPH-RAG] Problem: {problem[:80]}...");
    print(f"[GRAPH-RAG] Crop: {crop}");
    print(f"[GRAPH-RAG] Region: {region}");
    print("[GRAPH-RAG] ========================================");
    
    results = [];
    problem_lower = problem.lower();
    crop_lower = crop.lower();
    
    # STEP 1: Find diseases that affect this crop
    crop_diseases = [];
    
    for crop_node in [root -->][?:Crop] {
        if crop_lower in crop_node.crop_name.lower() {
            print(f"[GRAPH-RAG] Found crop: {crop_node.crop_name}");
            
            # Get all diseases affecting this crop
            for disease in [crop_node <-:AFFECTS_CROP:<-] {
                crop_diseases = crop_diseases + [disease];
                print(f"[GRAPH-RAG]   → Affects: {disease.disease_name}");
            }
        }
    }
    
    # STEP 2: Score diseases by symptom match + graph context
    for disease in crop_diseases {
        score = 0;
        
        # Symptom matching (as before)
        if problem_lower in disease.symptoms.lower() {
            score += 3;
        }
        
        if problem_lower in disease.description.lower() {
            score += 1;
        }
        
        #  BONUS: Disease is for this crop
        score += 2;
        
        #  BONUS: Check if disease common in this region
        for region_profile in [root -->][?:RegionProfile] {
            if region.lower() in region_profile.display_name.lower() {
                for common_disease in [region_profile <-:COMMON_IN_REGION:<-] {
                    if common_disease.disease_id == disease.disease_id {
                        score += 3;
                        print(f"[GRAPH-RAG]   ✓ Common in {region}: +3 score");
                    }
                }
            }
        }
        
        if score > 0 {
            results = results + [{"d": disease, "score": score}];
            print(f"[GRAPH-RAG]   {disease.disease_name}: score = {score}");
        }
    }
    
    # STEP 3: Add co-occurring diseases
    for result in results {
        disease = result["d"];
        
        for co_disease in [disease ->:CO_OCCURS_WITH:->] {
            # Add co-occurring disease if not already in results
            found = False;
            for r in results {
                if r["d"].disease_id == co_disease.disease_id {
                    found = True;
                }
            }
            
            if not found {
                results = results + [{"d": co_disease, "score": 1}];
                print(f"[GRAPH-RAG]   + Co-occurs: {co_disease.disease_name}");
            }
        }
    }
    
    #  STEP 4: Sort by score
    sorted_results = [];
    while results {
        best = results[0];
        for r in results {
            if r["score"] > best["score"] {
                best = r;
            }
        }
        sorted_results = sorted_results + [best["d"]];
        results.remove(best);
    }
    
    print(f"\n[GRAPH-RAG] FOUND {len(sorted_results)} DISEASES");
    print("[GRAPH-RAG] ========================================\n");
    
    return sorted_results;
}
def format_disease_context_graph(diseases: list) -> str {
    
    # Format disease information WITH GRAPH CONTEXT for LLM
    
    
    context = "KNOWLEDGE BASE (Graph-Enhanced):\n\n";

    for disease in diseases {
        context += "Disease: " + disease.disease_name + "\n";
        context += "Symptoms: " + disease.symptoms + "\n";
        context += "Treatment: " + disease.treatments + "\n";
        
        # Add graph-derived information
        
        # Which crops affected
        crops = [disease ->:AFFECTS_CROP:->];
        if crops {
            crop_names = [];
            for c in crops {
                crop_names = crop_names + [c.crop_name];
            }
            context += "Affects crops: " + ", ".join(crop_names) + "\n";
        }
        
        # Which seasons
        seasons = [disease ->:OCCURS_IN_SEASON:->];
        if seasons {
            season_names = [];
            for s in seasons {
                season_names = season_names + [s.season_name];
            }
            context += "Common in seasons: " + ", ".join(season_names) + "\n";
        }
        
        # Co-occurring diseases
        co_diseases = [disease ->:CO_OCCURS_WITH:->];
        if co_diseases {
            co_names = [];
            for cd in co_diseases {
                co_names = co_names + [cd.disease_name];
            }
            context += "Often co-occurs with: " + ", ".join(co_names) + "\n";
        }
        
        context += "\n";
    }

    return context;
}