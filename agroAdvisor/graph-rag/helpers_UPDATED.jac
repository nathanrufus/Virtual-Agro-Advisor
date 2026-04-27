include utils;
include intergrations;
include backend.graph_rag;

sv import from backend.models {
    AdvicePlan,
    DiseaseDoc
}

sv import from backend.models {
    translate_from_pivot
}

sv import from backend.graph_models {
    Disease
}

sv import from backend.graph_rag {
    graph_query_disease_context,
    graph_query_diseases_for_crop,
    graph_query_diseases_for_crop_in_region,
    graph_query_treatments_for_disease,
    graph_query_treatment_success_in_region
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

# ============================================
# GRAPH-RAG ENHANCED RAG FUNCTIONS
# ============================================

def retrieve_relevant_diseases(crop: str, problem: str, region: str) -> list {
    """
    UPDATED: Now uses Graph-RAG for intelligent disease retrieval.
    
    Graph queries used:
    - Crop --[AFFECTED_BY]--> Disease --[OCCURS_IN]--> Region
    - Retrieves diseases with regional prevalence and treatment data
    
    Falls back to legacy string matching if graph has no data.
    """
    
    print("\n[RAG] ========================================");
    print("[RAG] GRAPH-RAG QUERY INITIATED");
    print(f"[RAG] Crop: {crop}");
    print(f"[RAG] Region: {region}");
    
    preview = problem;
    if len(problem) > 100 {
        preview = problem[0:100];
    }
    print(f"[RAG] Problem: {preview}...");
    print("[RAG] ========================================");
    
    results = [];
    
    # Try graph-based retrieval first
    if region and crop {
        print("[RAG] Attempting GRAPH QUERY...");
        
        # Query: Crop --[AFFECTED_BY]--> Disease --[OCCURS_IN]--> Region
        regional_diseases = graph_query_diseases_for_crop_in_region(crop, region);
        
        if regional_diseases {
            print(f"[RAG] ✓ Found {len(regional_diseases)} diseases via GRAPH");
            
            # Convert graph results to DiseaseDoc format for compatibility
            for rd in regional_diseases {
                # Find the actual Disease node
                all_diseases = [root -->][?:Disease];
                for d_node in all_diseases {
                    if d_node.disease_name == rd.disease_name {
                        # Create DiseaseDoc with enriched graph data
                        treatments_str = "";
                        if rd.recommended_treatments {
                            treatments_str = ", ".join(rd.recommended_treatments);
                        }
                        
                        # Enrich description with regional info
                        enriched_desc = d_node.description;
                        enriched_desc += f"\n\nREGIONAL DATA ({region}):";
                        enriched_desc += f"\n- Prevalence: {rd.prevalence_pct}%";
                        enriched_desc += f"\n- Reported cases: {rd.cases_reported}";
                        enriched_desc += f"\n- Risk level: {rd.risk_level}";
                        
                        disease_doc = DiseaseDoc(
                            disease_id=d_node.disease_id,
                            disease_name=d_node.disease_name,
                            description=enriched_desc,
                            symptoms=d_node.symptoms,
                            treatments=treatments_str
                        );
                        results.append(disease_doc);
                        
                        print(f"[RAG]   ✓ {d_node.disease_name}");
                        print(f"[RAG]     Prevalence: {rd.prevalence_pct}%, Risk: {rd.risk_level}");
                        break;
                    }
                }
            }
            
            print(f"[RAG] ✓ Converted {len(results)} graph results");
        } else {
            print("[RAG] ⚠ Graph query returned no results");
        }
    } else {
        print("[RAG] ⚠ Insufficient data for graph query (need crop AND region)");
    }
    
    # Fallback to legacy string matching if graph query fails
    if len(results) == 0 {
        print("[RAG] → Falling back to LEGACY STRING MATCHING...");
        
        problem_lower = problem.lower();
        all_diseases_old = [root -->][?:DiseaseDoc];
        
        print(f"[RAG] Scanning {len(all_diseases_old)} DiseaseDoc nodes...");
        
        temp_results = [];
        
        for d in all_diseases_old {
            score = 0;
            
            if problem_lower in d.symptoms.lower() {
                score = score + 2;
                print(f"[RAG]   ✓ Symptom match in: {d.disease_name}");
            }
            
            if problem_lower in d.description.lower() {
                score = score + 1;
                print(f"[RAG]   ✓ Description match in: {d.disease_name}");
            }
            
            if problem_lower in d.disease_name.lower() {
                score = score + 3;
                print(f"[RAG]   ✓ Name match in: {d.disease_name}");
            }
            
            if score > 0 {
                temp_results.append({"d": d, "score": score});
                print(f"[RAG]   → {d.disease_name}: score = {score}");
            }
        }
        
        # Sort by score (bubble sort for simplicity)
        sorted_results = [];
        while len(temp_results) > 0 {
            best = temp_results[0];
            for r in temp_results {
                if r["score"] > best["score"] {
                    best = r;
                }
            }
            sorted_results.append(best["d"]);
            temp_results.remove(best);
        }
        
        results = sorted_results;
        print(f"[RAG] ✓ Legacy search found {len(results)} diseases");
    }
    
    print("\n[RAG] ========================================");
    print(f"[RAG] FINAL RESULTS: {len(results)} DISEASES");
    
    i = 0;
    for d in results {
        if i < 5 {
            print(f"[RAG]   {i + 1}. {d.disease_name}");
        }
        i = i + 1;
    }
    
    print("[RAG] ========================================\n");
    
    return results;
}

def format_disease_context(diseases: list) -> str {
    """
    Formats disease information for LLM context.
    Works with both legacy DiseaseDoc and graph-enriched DiseaseDoc.
    """
    
    context = "";

    print("\n[RAG] ========================================");
    print("[RAG] FORMATTING CONTEXT FOR LLM");
    print(f"[RAG] Number of diseases: {len(diseases)}");
    print("[RAG] ========================================");

    for d in diseases {
        context += "Disease: " + d.disease_name + "\n";
        context += "Symptoms: " + d.symptoms + "\n";
        context += "Treatment: " + d.treatments + "\n";
        
        # Include enriched description if available (from graph)
        if d.description and len(d.description) > 0 {
            context += "Additional Info: " + d.description + "\n";
        }
        
        context += "\n";

        print(f"[RAG] Added to context: {d.disease_name}");
    }

    print(f"[RAG] Total context length: {len(context)} characters");
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
