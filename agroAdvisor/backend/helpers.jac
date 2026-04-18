include utils;
include intergrations;

sv import from backend.models {
    AdvicePlan
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

# RAG FUNCTIONS


def retrieve_relevant_diseases(problem: str) -> list {
    results = [];
    problem_lower = problem.lower();

    for d in [root -->][?:DiseaseDoc] {

        score = 0;

        if problem_lower in d.symptoms.lower() {
            score += 2;
        }

        if problem_lower in d.description.lower() {
            score += 1;
        }

        if problem_lower in d.disease_name.lower() {
            score += 3;
        }

        if score > 0 {
            results = results + [{"d": d, "score": score}];
        }
    }

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

    return sorted_results;
}

def format_disease_context(diseases: list) -> str {
    context = "";

    for d in diseases {
        context += "Disease: " + d.disease_name + "\n";
        context += "Symptoms: " + d.symptoms + "\n";
        context += "Treatment: " + d.treatments + "\n\n";
    }

    return context;
}