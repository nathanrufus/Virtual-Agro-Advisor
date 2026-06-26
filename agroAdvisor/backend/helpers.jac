include utils;
include intergrations;
include backend.models;

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

def strip_country_from_location(location: str) -> str {
    if not location {
        return "";
    }
    loc = location.lower();
    loc = loc.replace(", kenya", "");
    loc = loc.replace(" kenya", "");
    return loc.strip();
}

def normalize_region_to_id(location: str) -> str {
    if not location {
        return "";
    }
    loc = location.strip().lower();

    if "kiambu" in loc { return "ke-kiambu"; }
    elif "nairobi" in loc { return "ke-nairobi"; }
    elif "nakuru" in loc { return "ke-nakuru"; }
    elif "uasin gishu" in loc or "eldoret" in loc { return "ke-uasin-gishu"; }
    elif "kisumu" in loc { return "ke-kisumu"; }
    elif "meru" in loc { return "ke-meru"; }
    elif "machakos" in loc { return "ke-machakos"; }
    elif "mombasa" in loc or "kilifi" in loc or "kwale" in loc { return "ke-mombasa"; }
    elif "kakamega" in loc { return "ke-kakamega"; }
    elif "nyeri" in loc { return "ke-nyeri"; }
    elif "muranga" in loc { return "ke-muranga"; }
    elif "nyandarua" in loc { return "ke-nyandarua"; }
    elif "trans nzoia" in loc or "kitale" in loc { return "ke-transnzoia"; }
    elif "bungoma" in loc or "busia" in loc or "siaya" in loc or "vihiga" in loc { return "ke-western"; }
    elif "kitui" in loc or "makueni" in loc or "tharaka" in loc { return "ke-machakos"; }

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

def ensure_numbered_steps(advice: AdvicePlan) -> AdvicePlan {
    if not advice or not advice.steps {
        return advice;
    }
    fixed_steps = [];
    counter = 1;
    for step in advice.steps {
        step_str = str(step).strip();
        if not step_str {
            continue;
        }
        has_number = False;
        if len(step_str) > 2 {
            first_char = step_str[0];
            second_char = step_str[1];
            if first_char.isdigit() and (second_char == "." or second_char == ")") {
                has_number = True;
            }
        }
        if has_number {
            fixed_steps = fixed_steps + [step_str];
        } else {
            fixed_steps = fixed_steps + [str(counter) + ". " + step_str];
        }
        counter = counter + 1;
    }
    return AdvicePlan(
        overview=advice.overview,
        steps=fixed_steps,
        cautions=advice.cautions
    );
}

def translate_advice_if_needed(
    advice: AdvicePlan,
    target_lang: str
) -> AdvicePlan {
    if not target_lang or target_lang == "en" {
        return advice;
    }

    new_overview = translate_from_pivot(text=advice.overview, lang=target_lang);

    new_steps = [];
    for s in advice.steps {
        new_steps = new_steps + [translate_from_pivot(text=s, lang=target_lang)];
    }

    new_cautions = [];
    for c in advice.cautions {
        new_cautions = new_cautions + [translate_from_pivot(text=c, lang=target_lang)];
    }

    return AdvicePlan(overview=new_overview, steps=new_steps, cautions=new_cautions);
}

def translate_summary_text_if_needed(text: str, target_lang: str) -> str {
    if not target_lang or target_lang == "en" {
        return text;
    }
    if not text {
        return text;
    }
    return translate_from_pivot(text=text, lang=target_lang);
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

# ============================================================
# EMBEDDING SEARCH via Chroma
# Called first, results merged with graph traversal
# ============================================================

def search_chroma(problem: str, crop: str, region: str) -> list {
    region_clean = strip_country_from_location(region);
    crop_clean = normalize_crop(crop);
    
    # Call HTTP endpoint instead of subprocess
    url = f"http://127.0.0.1:8888/search?problem={problem}&crop={crop_clean}&region={region_clean}";
    
    raw = http_get(url);
    
    if not raw {
        print("[CHROMA] No response from server");
        return [];
    }

    try {
        matches = json.loads(raw);
        print(f"[CHROMA] Embedding search returned {len(matches)} candidates");
        return matches;
    } except Exception {
        print("[CHROMA] Failed to parse search response");
        return [];
    }
}

def build_disease_id_set(chroma_matches: list) -> dict {
    id_set = {};
    for m in chroma_matches {
        did = m.get("id", "");
        score = m.get("similarity", 0.0);
        if did {
            id_set[did] = float(score);
        }
    }
    return id_set;
}

# ============================================================
# MAIN RAG FUNCTION: 6-hop graph traversal + Chroma embedding
# ============================================================

def retrieve_relevant_diseases_graph(
    problem: str,
    crop: str,
    region: str,
    season: str = ""
) -> list {

    print("\n[GRAPH-RAG] ==========================================");
    print("[GRAPH-RAG] STARTING RETRIEVAL");
    print(f"[GRAPH-RAG] Crop:   {crop}");
    print(f"[GRAPH-RAG] Region: {region}");
    print("[GRAPH-RAG] ==========================================");

    # ── Step 0: Chroma embedding pre-search ──────────────────────────────
    # This runs first and gives us a map of disease_id → similarity score
    # The graph traversal then uses this to boost or surface results

    print("[GRAPH-RAG] Step 0: Chroma embedding search...");
    chroma_matches = search_chroma(problem, crop, region);
    chroma_scores = build_disease_id_set(chroma_matches);

    if chroma_scores {
        print(f"[GRAPH-RAG] Chroma found: {list(chroma_scores.keys())[:5]}");
    }

    # ── Scoring map: disease_id → {d: node, score: int, reasons: list} ──
    results = {};

    crop_lower = crop.lower();
    region_lower = strip_country_from_location(region).lower();
    problem_lower = problem.lower();
    problem_words = problem_lower.split();

    # ── HOP 1: Crop node → AFFECTS_CROP back-edges → DiseaseDoc ──────────
    # Only diseases that affect this crop are in the candidate pool

    print("[GRAPH-RAG] HOP 1: Crop → Disease edges...");
    crop_node_found = None;

    for crop_node in [root -->][?:Crop] {
        if crop_lower in crop_node.crop_name.lower() {
            crop_node_found = crop_node;
            print(f"[GRAPH-RAG]   Crop node: {crop_node.crop_name}");

            for disease in [crop_node <-:AFFECTS_CROP:<-] {
                did = disease.disease_id;
                if did not in results {
                    results[did] = {"d": disease, "score": 0, "reasons": []};
                }
                results[did]["score"] = results[did]["score"] + 4;
                results[did]["reasons"] = results[did]["reasons"] + [f"Affects {crop}"];
            }
        }
    }

    print(f"[GRAPH-RAG]   HOP 1 found {len(results)} crop-specific diseases");

    # If no crop node matched, fall through to all diseases
    if not results {
        print("[GRAPH-RAG]   No crop node found — using all DiseaseDoc nodes");
        for d in [root -->][?:DiseaseDoc] {
            results[d.disease_id] = {"d": d, "score": 1, "reasons": ["Global fallback"]};
        }
    }

    # ── HOP 2: Region node → COMMON_IN_REGION back-edges → DiseaseDoc ───
    # Diseases documented as prevalent in this county get a score boost

    print("[GRAPH-RAG] HOP 2: Region boost...");
    for region_node in [root -->][?:RegionProfile] {
        node_name = region_node.display_name.lower();
        node_county = region_node.county.lower();

        if region_lower in node_name or region_lower in node_county {
            print(f"[GRAPH-RAG]   Region: {region_node.display_name}");

            for disease in [region_node <-:COMMON_IN_REGION:<-] {
                did = disease.disease_id;
                if did in results {
                    results[did]["score"] = results[did]["score"] + 5;
                    results[did]["reasons"] = results[did]["reasons"] + [f"Common in {region_node.display_name}"];
                    print(f"[GRAPH-RAG]   +5 region match: {disease.disease_name}");
                }
            }
        }
    }

    # ── HOP 3: Season node → OCCURS_IN_SEASON back-edges → DiseaseDoc ───
    # Diseases active in current season get a boost

    if season {
        print(f"[GRAPH-RAG] HOP 3: Season boost ({season})...");
        season_lower = season.lower();

        for season_node in [root -->][?:Season] {
            if season_lower in season_node.season_name.lower() {
                for disease in [season_node <-:OCCURS_IN_SEASON:<-] {
                    did = disease.disease_id;
                    if did in results {
                        results[did]["score"] = results[did]["score"] + 2;
                        results[did]["reasons"] = results[did]["reasons"] + [f"Active in {season_node.season_name}"];
                    }
                }
            }
        }
    }

    # ── HOP 4a: Symptom keyword matching within graph node text ──────────
    # Keyword match on the problem text against disease symptoms/description
    # This uses the existing data in DiseaseDoc nodes

    print("[GRAPH-RAG] HOP 4a: Symptom keyword matching...");
    for did in results {
        disease = results[did]["d"];
        sym_lower = disease.symptoms.lower();
        desc_lower = disease.description.lower();

        # Full phrase match — highest score
        if problem_lower in sym_lower {
            results[did]["score"] = results[did]["score"] + 6;
            results[did]["reasons"] = results[did]["reasons"] + ["Full symptom phrase match"];
            print(f"[GRAPH-RAG]   +6 phrase match: {disease.disease_name}");
        }

        # Individual word matching
        for word in problem_words {
            if len(word) > 4 {
                if word in sym_lower {
                    results[did]["score"] = results[did]["score"] + 2;
                }
                if word in desc_lower {
                    results[did]["score"] = results[did]["score"] + 1;
                }
            }
        }

        # Disease name mentioned in query
        if disease.disease_name.lower() in problem_lower {
            results[did]["score"] = results[did]["score"] + 7;
            results[did]["reasons"] = results[did]["reasons"] + ["Disease name in query"];
        }
    }

    # ── HOP 4b: Chroma embedding score boost ─────────────────────────────
    # Merge the semantic similarity scores from ChromaDB
    # This catches cases where farmer uses different words for same disease

    print("[GRAPH-RAG] HOP 4b: Chroma embedding score boost...");
    for did in chroma_scores {
        similarity = chroma_scores[did];

        if did in results {
            # Convert similarity (0-100) to score points (max 8)
            boost = int((similarity / 100.0) * 8.0);
            results[did]["score"] = results[did]["score"] + boost;
            results[did]["reasons"] = results[did]["reasons"] + [f"Semantic match {similarity}%"];
            print(f"[GRAPH-RAG]   +{boost} semantic boost: {did} ({similarity}%)");
        } else {
            # Chroma found a disease that graph traversal missed
            # Look it up by ID and add it
            for d in [root -->][?:DiseaseDoc] {
                if d.disease_id == did {
                    boost = int((similarity / 100.0) * 5.0);
                    results[did] = {
                        "d": d,
                        "score": boost,
                        "reasons": [f"Semantic only {similarity}%"]
                    };
                    print(f"[GRAPH-RAG]   +{boost} semantic discovery: {did}");
                }
            }
        }
    }

    # ── HOP 5: Disease → CO_OCCURS_WITH → Disease ────────────────────────
    # Surface co-occurring diseases for the top scoring results

    print("[GRAPH-RAG] HOP 5: Co-occurrence expansion...");
    top_ids = [];
    for did in results {
        if results[did]["score"] >= 6 {
            top_ids = top_ids + [did];
        }
    }

    for did in top_ids {
        disease = results[did]["d"];
        for co_disease in [disease ->:CO_OCCURS_WITH:->] {
            co_did = co_disease.disease_id;
            if co_did not in results {
                results[co_did] = {
                    "d": co_disease,
                    "score": 2,
                    "reasons": [f"Co-occurs with {disease.disease_name}"]
                };
                print(f"[GRAPH-RAG]   +co-occur: {co_disease.disease_name}");
            }
        }
    }

    # ── HOP 6: Disease → DOCUMENTED_CASE → CaseStudy → Region ───────────
    # Boost diseases with documented cases in the farmer's region

    print("[GRAPH-RAG] HOP 6: Case study evidence...");
    for did in results {
        disease = results[did]["d"];
        for cs in [disease ->:DOCUMENTED_CASE:->] {
            for cs_region in [cs ->:CASE_IN_REGION:->] {
                if region_lower in cs_region.display_name.lower() or region_lower in cs_region.county.lower() {
                    results[did]["score"] = results[did]["score"] + 4;
                    results[did]["reasons"] = results[did]["reasons"] + [f"Documented case in {cs_region.display_name}"];
                    print(f"[GRAPH-RAG]   +4 local case: {disease.disease_name}");
                }
            }
        }
    }

    # ── Sort all results by score (descending) ────────────────────────────
    items = [];
    for did in results {
        items = items + [results[did]];
    }

    sorted_results = [];
    while len(items) > 0 {
        best = items[0];
        for item in items {
            if item["score"] > best["score"] {
                best = item;
            }
        }
        sorted_results = sorted_results + [best["d"]];
        items.remove(best);
    }

    print(f"\n[GRAPH-RAG] TOP RESULTS:");
    i = 0;
    for d in sorted_results {
        if i < 7 {
            item = results[d.disease_id];
            sc = item["score"];
            print(f"[GRAPH-RAG]   {i+1}. {d.disease_name} (score={sc})");
        }
        i = i + 1;
    }
    print("[GRAPH-RAG] ==========================================\n");

    return sorted_results;
}

# Keep backward compat — advisor.jac calls this directly
def retrieve_relevant_diseases(problem: str) -> list {
    return retrieve_relevant_diseases_graph(
        problem=problem,
        crop="",
        region=""
    );
}

# ============================================================
# CONTEXT FORMATTING — builds rich text block for the LLM
# ============================================================

def format_disease_context_graph(diseases: list) -> str {

    print(f"\n[GRAPH-RAG] Formatting context for LLM ({len(diseases)} diseases)...");

    context = "GRAPH-RETRIEVED KNOWLEDGE BASE:\n\n";

    for disease in diseases {
        context = context + "Disease/Problem: " + disease.disease_name + "\n";
        context = context + "Symptoms: " + disease.symptoms + "\n";
        context = context + "What to do: " + disease.treatments + "\n";

        # Crops affected (from graph edges)
        crop_nodes = [disease ->:AFFECTS_CROP:->];
        if len(crop_nodes) > 0 {
            crop_names = [];
            for c in crop_nodes {
                crop_names = crop_names + [c.crop_name];
            }
            context = context + "Affects crops: " + ", ".join(crop_names) + "\n";
        }

        # Seasons (from graph edges)
        season_nodes = [disease ->:OCCURS_IN_SEASON:->];
        if len(season_nodes) > 0 {
            season_names = [];
            for s in season_nodes {
                season_names = season_names + [s.season_name];
            }
            context = context + "Worst seasons: " + ", ".join(season_names) + "\n";
        }

        # Co-occurring diseases (from graph edges)
        co_nodes = [disease ->:CO_OCCURS_WITH:->];
        if len(co_nodes) > 0 {
            co_names = [];
            for cd in co_nodes {
                co_names = co_names + [cd.disease_name];
            }
            context = context + "Often co-occurs with: " + ", ".join(co_names) + "\n";
        }

        # Documented local case (from graph edges)
        case_nodes = [disease ->:DOCUMENTED_CASE:->];
        if len(case_nodes) > 0 {
            cs = case_nodes[0];
            context = context + "Real Kenya case: " + cs.outcome + "\n";
        }

        context = context + "\n";
    }

    print(f"[GRAPH-RAG] Context: {len(context)} chars");
    return context;
}

# Keep backward compat — advisor.jac calls format_disease_context
def format_disease_context(diseases: list) -> str {
    return format_disease_context_graph(diseases);
}
