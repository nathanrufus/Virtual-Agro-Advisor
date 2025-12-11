import random;
include utils;
include intergrations;

#  Helper functions (pure logic, no LLM yet)


def generate_session_id() -> str {
    ts = get_current_datetime();
    # Clean the timestamp so it’s safe in IDs (no spaces/colons)
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



# SessionManager implementation


impl SessionManager.run {
    # 1. Ensure a single Memory node under root
    mem_list = [root --> (`?Memory)];
    if not mem_list {
        memory = Memory();
        root ++> memory;
    } else {
        memory = mem_list[0];
    }

    # 2. Find or create Session
    if not self.session_id {
        # New session
        new_id = generate_session_id();
        session = Session(
            session_id=new_id,
            lang=self.lang
        );
        memory +>: HAS_SESSION() :+> session;
        self.session_id = new_id;
    } else {
        # Look for an existing Session whose session_id field matches
        session = None;
        for s in [memory ->:HAS_SESSION:->] {
            if s.session_id == self.session_id {
                session = s;
                break;
            }
        }

        # If it doesn't exist, create and attach it
        if not session {
            session = Session(
                session_id=self.session_id,
                lang=self.lang
            );
            memory +>: HAS_SESSION() :+> session;
        } else {
            # keep language updated
            session.lang = self.lang;
        }
    }

    # 3. Update last active timestamp
    session.last_active_at = get_current_datetime();

    # 4. Report basic session info (useful for debugging / client)
    report {
        "session_id": session.session_id,
        "lang": session.lang,
        "created_at": session.created_at,
        "last_active_at": session.last_active_at
    };
}


#  WeatherAgent implementation (non-LLM, mock summary + caching)

impl WeatherAgent.run {
    session = here;
    loc_key = normalize_location(self.location);

    existing_snapshots = [];
    for snap in [session ->:HAS_WEATHER:->] {
        if snap.location_key == loc_key {
            existing_snapshots = existing_snapshots + [snap];
        }
    }

    snapshot = None;

    if existing_snapshots {
        snapshot = existing_snapshots[0];
    } else {
        # Call real API here
        raw = fetch_weather_raw(loc_key);
        summary_text = summarize_weather(raw, self.location);

        snapshot = WeatherSnapshot(
            location_key=loc_key,
            summary=summary_text,
            raw_source=raw
        );
        session +>: HAS_WEATHER() :+> snapshot;
    }

    weather_summary = WeatherSummary(
        summary_text=snapshot.summary
    );

    report weather_summary;
}

#  MarketAgent implementation (non-LLM, mock dataset + caching)

impl MarketAgent.run {
    let session = here;

    let crop_key = normalize_crop(self.crop);
    let region_key = normalize_region(self.region);

    # 1. Check cache first
    let existing_snapshots = [];
    for snap in [session ->:HAS_MARKET:->] {
        if snap.crop_key == crop_key and snap.region_key == region_key {
            existing_snapshots = existing_snapshots + [snap];
        }
    }

    let snapshot = None;

    if existing_snapshots {
        # Reuse cached FEWS NET snapshot
        snapshot = existing_snapshots[0];
    } else {
        # 2. No cache -> call FEWS NET API directly (no LLM)
        let region_for_api = self.region;
        if not region_for_api {
            region_for_api = "Kenya";
        }

        print(
            f"[MarketAgent] Fetching FEWS NET prices for crop='{self.crop}' in '{region_for_api}'."
        );

        let raw = fetch_market_price_raw(
            crop=self.crop,
            region=region_for_api
        );

        let summary_text = summarize_market(
            raw=raw,
            crop=self.crop,
            region=region_for_api
        );

        # 3. Store API-based snapshot with raw payload
        snapshot = MarketSnapshot(
            crop_key=crop_key,
            region_key=region_key,
            summary=summary_text,
            raw_source=raw
        );
        session +>: HAS_MARKET() :+> snapshot;
    }

    # 4. Return MarketSummary for the advisor / frontend
    let market_summary = MarketSummary(
        summary_text=snapshot.summary
    );

    report market_summary;
}

#  AuditAgent implementation

impl AuditAgent.run {
    # Entry node is a Memory
    memory = here;

    log = AuditLog(
        event=self.event,
        cache_hit=self.cache_hit,
        latency_ms=self.latency_ms,
        session_id=self.session_id
    );

    memory +>: HAS_AUDIT() :+> log;

    report {
        "event": log.event,
        "cache_hit": log.cache_hit,
        "latency_ms": log.latency_ms,
        "session_id": log.session_id,
        "created_at": log.created_at
    };
}


#  GetAllSessions implementation (admin / debug)

impl GetAllSessions.run {
    mem_list = [root --> (`?Memory)];
    if not mem_list {
        report "No Memory node found.";
        disengage;
    }

    memory = mem_list[0];
    sessions = [memory ->:HAS_SESSION:->];

    if not sessions {
        report "No sessions found.";
        disengage;
    }

    report [{
        "id": jid(session),
        "session_id": session.session_id,
        "lang": session.lang,
        "created_at": session.created_at,
        "last_active_at": session.last_active_at
    } for session in sessions];
}



#  GetAllAdviceCache implementation (admin / debug)

impl GetAllAdviceCache.run {
    mem_list = [root --> (`?Memory)];
    if not mem_list {
        report "No Memory node found.";
        disengage;
    }

    memory = mem_list[0];
    sessions = [memory ->:HAS_SESSION:->];

    all_cache_nodes = [];

    for sess in sessions {
        for ac in [sess ->:HAS_ADVICE:->] {
            all_cache_nodes = all_cache_nodes + [ac];
        }
    }

    if not all_cache_nodes {
        report "No advice cache entries found.";
        disengage;
    }

    report [{
        "session_id": cache.session_id if hasattr(cache, "session_id") else "",
        "cache_key": cache.cache_key,
        "created_at": cache.created_at,
        "last_used_at": cache.last_used_at,
        "usage_count": cache.usage_count
    } for cache in all_cache_nodes];
}

#  LLM-related helpers


def make_cache_key(
    crop: str,
    problem_text: str,
    location: str,
    lang: str,
    include_weather: bool,
    include_market: bool,
    include_image: bool    # NEW
) -> str {
    let norm_crop = normalize_crop(crop);
    let norm_loc = normalize_location(location);
    let trimmed_problem = problem_text.strip();
    if len(trimmed_problem) > 120 {
        trimmed_problem = trimmed_problem[:120];
    }
    return (
        f"{norm_crop}|{norm_loc}|{lang}"
        f"|w={include_weather}|m={include_market}|img={include_image}|{trimmed_problem}"
    );
}
def parse_cache_key(key: str) -> dict {
    # Defaults
    let crop = "";
    let location = "";
    let lang = "";
    let include_weather = False;
    let include_market = False;
    let include_image = False;
    let problem_preview = "";

    if key {
        let parts = key.split("|");

        if len(parts) >= 7 {
            crop = parts[0];
            location = parts[1];
            lang = parts[2];

            # include_weather
            if "w=True" in parts[3] or "w=true" in parts[3] {
                include_weather = True;
            }

            # include_market
            if "m=True" in parts[4] or "m=true" in parts[4] {
                include_market = True;
            }

            # include_image
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

    # Translate overview
    new_overview = translate_from_pivot(
        text=advice.overview,
        lang=target_lang
    );

    # Translate each step and caution
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
    # Default: English
    if not lang or lang == "en" {
        return {
            "advice_overview": "Overview",
            "advice_steps": "Recommended steps",
            "advice_cautions": "Cautions & safety notes",
            "weather_summary": "Weather summary",
            "market_summary": "Market summary"
        };
    }

    # Swahili example – adjust as you like
    if lang == "sw" {
        return {
            "advice_overview": "Muhtasari",
            "advice_steps": "Hatua zinazopendekezwa",
            "advice_cautions": "Tahadhari na usalama",
            "weather_summary": "Muhtasari wa hali ya hewa",
            "market_summary": "Muhtasari wa soko"
        };
    }

    # Fallback for other languages: use English for now
    return {
        "advice_overview": "Overview",
        "advice_steps": "Recommended steps",
        "advice_cautions": "Cautions & safety notes",
        "weather_summary": "Weather summary",
        "market_summary": "Market summary"
    };
}

#  AgroAdvisor implementation


impl AgroAdvisor.run {
    t_start = get_current_datetime();  # for logging; simple string stamp

    # 1. Ensure Memory root
    mem_list = [root --> (`?Memory)];
    if not mem_list {
        memory = Memory();
        root ++> memory;
    } else {
        memory = mem_list[0];
    }

    # 2. Get or create Session
    session = None;

    if not self.session_id {
        # New session
        let new_id = generate_session_id();
        session = Session(
            session_id=new_id,
            lang=self.language
        );
        memory +>: HAS_SESSION() :+> session;
        self.session_id = new_id;
    } else {
        # Look up existing Session by its session_id field
        for s in [memory ->:HAS_SESSION:->] {
            if s.session_id == self.session_id {
                session = s;
                break;
            }
        }

        if not session {
            # If it doesn't exist, create one with this ID
            session = Session(
                session_id=self.session_id,
                lang=self.language
            );
            memory +>: HAS_SESSION() :+> session;
        } else {
            # Keep language updated
            session.lang = self.language;
        }
    }

    session.last_active_at = get_current_datetime();
    
    # 2b. Let the LLM gently fix spelling in crop/location
    let norm = normalize_crop_location(
            crop=self.crop,
            location=self.location
        );

        if norm.crop {
            self.crop = norm.crop;
        }
        if norm.location {
            self.location = norm.location;
        }

    # 3. Cache lookup
    let cache_key = make_cache_key(
        crop=self.crop,
        problem_text=self.problem_text,
        location=self.location,
        lang=self.language,
        include_weather=self.include_weather,
        include_market=self.include_market,
        include_image=self.include_image
    );

    let existing_cache = None;
    for ac in [session ->:HAS_ADVICE:->] {
        if ac.cache_key == cache_key {
            existing_cache = ac;
            break;
        }
    }

    # We'll fill these regardless of cache hit/miss
    let weather_summary = WeatherSummary(
        summary_text="Weather data not requested."
    );
    let market_summary = MarketSummary(
        summary_text="Market data not requested."
    );

    # 3b. Always ensure weather/market snapshots exist, even on cache hit
    if self.include_weather {
        let loc_key = normalize_location(self.location);

        let existing_snapshots = [];
        for snap in [session ->:HAS_WEATHER:->] {
            if snap.location_key == loc_key {
                existing_snapshots = existing_snapshots + [snap];
            }
        }

        let snapshot_w = None;

        if existing_snapshots {
            snapshot_w = existing_snapshots[0];
        } else {
            # Call real API helpers from integrations/weather.jac
            let raw_weather = fetch_weather_raw(loc_key);
            let summary_text = summarize_weather(raw_weather, self.location);

            snapshot_w = WeatherSnapshot(
                location_key=loc_key,
                summary=summary_text,
                raw_source=raw_weather
            );
            session +>: HAS_WEATHER() :+> snapshot_w;
        }

        weather_summary = WeatherSummary(
            summary_text=snapshot_w.summary
        );
    }

    if self.include_market {
        let crop_key = normalize_crop(self.crop);
        let region_key = normalize_region(self.location);  # reuse location as region key

        # 1. Check if we already have a MarketSnapshot for this crop/region
        let existing_ms = [];
        for snap in [session ->:HAS_MARKET:->] {
            if snap.crop_key == crop_key and snap.region_key == region_key {
                existing_ms = existing_ms + [snap];
            }
        }

        # 2. If no snapshot, spawn MarketAgent on this Session node
        if not existing_ms {
            # Correct spawn syntax: node_reference spawn WalkerName(...)
            session spawn MarketAgent(
                crop=self.crop,
                region=self.location
            );

            # Re-scan snapshots after the walker runs
            for snap in [session ->:HAS_MARKET:->] {
                if snap.crop_key == crop_key and snap.region_key == region_key {
                    existing_ms = existing_ms + [snap];
                }
            }
        }

        # 3. If we now have at least one snapshot, build MarketSummary from it
        if existing_ms {
            let snapshot_m = existing_ms[0];

            market_summary = MarketSummary(
                summary_text=snapshot_m.summary
            );
        }
    }
        # 4. If cache hit: reuse advice, log, and return
        if existing_cache {
            existing_cache.touch();

            let log_hit = AuditLog(
                event="agro_advisor_cache_hit",
                cache_hit=True,
                latency_ms=0,
                session_id=session.session_id
            );
            memory +>: HAS_AUDIT() :+> log_hit;

            let advice_cached = existing_cache.advice;

            # Optionally re-translate advice if language changed
            let final_advice_cached = translate_advice_if_needed(
                advice=advice_cached,
                target_lang=self.language
            );

            # NEW: translate weather & market summary text if needed
            weather_summary.summary_text = translate_summary_text_if_needed(
                text=weather_summary.summary_text,
                target_lang=self.language
            );
            market_summary.summary_text = translate_summary_text_if_needed(
                text=market_summary.summary_text,
                target_lang=self.language
            );

            # NEW: localized UI titles for the frontend
            let ui_titles = get_ui_titles(self.language);

            report {
                "session_id": session.session_id,
                "advice_plan": final_advice_cached,
                "weather_summary": weather_summary,
                "market_summary": market_summary,
                "meta": {
                    "source": "cache",
                    "lang": self.language,
                    "titles": ui_titles
                }
            };
            disengage;
        }

    # 5. Cache miss: run full LLM pipeline

    # 5a. Optional: image-based symptom enrichment (like weather/market, but for images)
    let image_notes = "";
    if self.include_image and self.image_data {

        # Try to find existing image analysis for this image_data key
        let img_result = None;
        for img in [session ->:HAS_IMAGE_ANALYSIS:->] {
            if img.image_id == self.image_data {
                img_result = img;
                break;
            }
        }

        # If none, spawn ImageAnalysisAgent on this Session
        if not img_result {
            session spawn ImageAnalysisAgent(
                image_data=self.image_data,
                crop=self.crop,
                location=self.location
            );

            # Re-scan for the newly created node
            for img in [session ->:HAS_IMAGE_ANALYSIS:->] {
                if img.image_id == self.image_data {
                    img_result = img;
                    break;
                }
            }
        }

        if img_result {
            image_notes = (
                "Image analysis suggests these symptoms: "
                + ", ".join(img_result.labels)
                + ". "
                + img_result.notes
            );
        }
    }

    # Build context
    let history_text = session.get_history();
    let farmer_ctx = FarmerContext(
        region=self.location,
        lang=self.language
    );

    # Combine typed problem with image-derived notes
    let combined_problem = self.problem_text;
    if image_notes {
        if combined_problem {
            combined_problem = (
                combined_problem
                + "\n\nAdditional symptoms from image:\n"
                + image_notes
            );
        } else {
            combined_problem = image_notes;
        }
    }

    # 5.1 Analyze issue (LLM) – now using combined_problem
    let issue = analyze_issue(
        crop=self.crop,
        problem_text=combined_problem,
        location=self.location,
        history=history_text
    );

    # 5.2 Generate advice (LLM)
    let raw_advice = generate_advice(
        analysis=issue,
        weather=weather_summary,
        market=market_summary,
        context=farmer_ctx
    );

       # 5.3 Safety review (LLM)
    let safe_advice = safety_review(advice=raw_advice);

    # 5.4 Translation (if needed) – advice plan
    let final_advice = translate_advice_if_needed(
        advice=safe_advice,
        target_lang=self.language
    );

    # 6. Persistence: cache + history + audit
    let new_cache = AdviceCache(
        cache_key=cache_key,
        advice=safe_advice  # store base-language advice
    );
    session +>: HAS_ADVICE() :+> new_cache;

    let hist_entry = (
        "user: " + combined_problem + "\n" +
        "ai: " + final_advice.overview
    );
    session.add_history(hist_entry);

    let log_fresh = AuditLog(
        event="agro_advisor_fresh",
        cache_hit=False,
        latency_ms=0,
        session_id=session.session_id
    );
    memory +>: HAS_AUDIT() :+> log_fresh;

    # 6b. NEW: translate weather & market summaries
    weather_summary.summary_text = translate_summary_text_if_needed(
        text=weather_summary.summary_text,
        target_lang=self.language
    );
    market_summary.summary_text = translate_summary_text_if_needed(
        text=market_summary.summary_text,
        target_lang=self.language
    );

    # 6c. NEW: localized UI titles
    let ui_titles = get_ui_titles(self.language);

    # 7. Final response for frontend
    report {
        "session_id": session.session_id,
        "advice_plan": final_advice,
        "weather_summary": weather_summary,
        "market_summary": market_summary,
        "meta": {
            "source": "fresh",
            "lang": self.language,
            "titles": ui_titles
        }
    };
}



impl LLMAnalyzeDebug.run {
    # For debug, we don't care about session history yet
    history_text = "";

    # Optional: if language is not English, normalize input with translate_to_pivot
    problem_for_llm = self.problem_text;
    history_for_llm = history_text;

    if self.language != "en" and self.language != "" {
        problem_for_llm = translate_to_pivot(
            text=self.problem_text,
            lang=self.language
        );
        if history_text {
            history_for_llm = translate_to_pivot(
                text=history_text,
                lang=self.language
            );
        }
    }

    issue = analyze_issue(
        crop=self.crop,
        problem_text=problem_for_llm,
        location=self.location,
        history=history_for_llm
    );

    # Just return the raw IssueAnalysis object so you can see fields directly
    report issue;
}


impl LLMAdviceDebug.run {
    # 1. Prepare text for LLM (same pivot-language logic as AgroAdvisor)
    history_text = "";  # no history in this debug walker

    problem_for_llm = self.problem_text;
    history_for_llm = history_text;

    if self.language != "en" && self.language != "" {
        problem_for_llm = translate_to_pivot(
            text=self.problem_text,
            lang=self.language
        );
        if history_text {
            history_for_llm = translate_to_pivot(
                text=history_text,
                lang=self.language
            );
        }
    }

    # 2. Fake WeatherSummary / MarketSummary for now
    weather_summary = WeatherSummary(
        summary_text="(Debug) No real weather data. Assume typical conditions for the season."
    );
    if not self.include_weather {
        weather_summary.summary_text = "(Debug) Weather ignored for this run.";
    }

    market_summary = MarketSummary(
        summary_text="(Debug) No real market data. Assume normal local price range."
    );
    if not self.include_market {
        market_summary.summary_text = "(Debug) Market conditions ignored for this run.";
    }

    # 3. FarmerContext using provided location/lang
    farmer_ctx = FarmerContext(
        region=self.location,
        lang=self.language
    );

    # 4. Run the full LLM reasoning chain

    # 4.1 Analyze issue
    issue = analyze_issue(
        crop=self.crop,
        problem_text=problem_for_llm,
        location=self.location,
        history=history_for_llm
    );

    # 4.2 Generate advice
    raw_advice = generate_advice(
        analysis=issue,
        weather=weather_summary,
        market=market_summary,
        context=farmer_ctx
    );

    # 4.3 Safety review
    safe_advice = safety_review(advice=raw_advice);

    # 4.4 Translate back to target language if needed
    final_advice = translate_advice_if_needed(
        advice=safe_advice,
        target_lang=self.language
    );

    # 5. Report everything useful for debugging
    report {
        "issue_analysis": issue,
        "weather_summary": weather_summary,
        "market_summary": market_summary,
        "advice_plan": final_advice
    };
}
# CleanupOldSessions implementation
impl CleanupOldSessions.run {
    # Special mode: if cutoff is "ALL" (case-insensitive), delete ALL sessions
    let delete_all = False;
    if self.cutoff and self.cutoff.lower() == "all" {
        delete_all = True;
    }

    # For normal mode we still expect a real cutoff string
    if not self.cutoff {
        report {
            "deleted_count": 0,
            "message": "No cutoff provided; nothing deleted."
        };
        return;
    }

    let mem_list = [root --> (`?Memory)];
    if not mem_list {
        report {
            "deleted_count": 0,
            "message": "No Memory node found."
        };
        return;
    }
    let memory = mem_list[0];

    let deleted = 0;

    # Same traversal as GetAllSessions: Memory -> HAS_SESSION -> Session
    let sessions = [memory ->:HAS_SESSION:->];

    for sess in sessions {
        if not delete_all {
            # Normal mode: only delete if older than cutoff
            let ts = sess.last_active_at or sess.created_at or "";
            if not ts {
                continue;
            }
            # Compare lexicographically; both are "YYYY-MM-DD HH:MM:SS"
            if ts >= self.cutoff {
                continue;
            }
        }

        # Either delete_all == True OR ts < cutoff
        destroy([sess]);
        deleted = deleted + 1;
    }

    report {
        "deleted_count": deleted,
        "cutoff": self.cutoff,
        "mode": ( "all" if delete_all else "cutoff" )
    };
}


# ClearAdviceCache implementation

impl ClearAdviceCache.run {
    let mem_list = [root --> (`?Memory)];
    if not mem_list {
        report {
            "deleted_count": 0,
            "message": "No Memory node found."
        };
        return;
    }
    let memory = mem_list[0];

    let deleted = 0;

    # Use the SAME traversal as GetAllAdviceCache
    let sessions = [memory ->:HAS_SESSION:->];

    for sess in sessions {
        for ac in [sess ->:HAS_ADVICE:->] {
            del ac;
            deleted = deleted + 1;
        }
    }

    report {
        "deleted_count": deleted
    };
}
impl ImageAnalysisAgent.run {
    # Use the raw image_data as a simple key for now
    let img_key = self.image_data;

    # 1. Check cache: do we already have analysis for this image?
    let existing = None;
    for ia in [here ->:HAS_IMAGE_ANALYSIS:->] {
        if ia.image_id == img_key {
            existing = ia;
            break;
        }
    }

    if existing {
        report existing;
        disengage;
    }

    # 2. No cache → call the vision LLM
    let img = Image(self.image_data);  # byLLM Image wrapper :contentReference[oaicite:1]{index=1}

    let summary = analyze_crop_image(
        img=img,
        crop=self.crop,
        location=self.location
    );

    # 3. Create node in graph
    let node = ImageAnalysisResult(
        image_id=img_key,
        labels=summary.labels,
        confidences=summary.confidences,
        notes=summary.notes
    );
    here +>: HAS_IMAGE_ANALYSIS() :+> node;

    report node;
}
#  GetAdviceCacheDetail implementation (admin / debug)

impl GetAdviceCacheDetail.run {
    # 1. Find Memory root
    let mem_list = [root --> (`?Memory)];
    if not mem_list {
        report {
            "ok": False,
            "error": "No Memory node found.",
            "cache_key": self.cache_key
        };
        return;
    }
    let memory = mem_list[0];

    # 2. Traverse sessions and their advice cache nodes
    let sessions = [memory ->:HAS_SESSION:->];

    let found_cache = None;
    let owner_session = None;

    for sess in sessions {
        for ac in [sess ->:HAS_ADVICE:->] {
            if ac.cache_key == self.cache_key {
                found_cache = ac;
                owner_session = sess;
                break;
            }
        }
        if found_cache {
            break;
        }
    }

    # 3. Handle not found
    if not found_cache {
        report {
            "ok": False,
            "error": "Advice cache not found.",
            "cache_key": self.cache_key
        };
        return;
    }

    # 4. Parse cache key into human-readable info
    let parsed = parse_cache_key(found_cache.cache_key);

    # 5. Optional: get session history
    let history_snippet = "";
    if owner_session {
        history_snippet = owner_session.get_history();
    }

    # 6. Build session info dict (without ternary)
    let session_info = None;
    if owner_session {
        session_info = {
            "session_id": owner_session.session_id,
            "lang": owner_session.lang,
            "created_at": owner_session.created_at,
            "last_active_at": owner_session.last_active_at,
            "history": history_snippet
        };
    }

    # 7. Final detailed report
    report {
        "ok": True,
        "cache_key": found_cache.cache_key,
        "parsed": parsed,
        "session": session_info,
        "advice": {
            "overview": found_cache.advice.overview,
            "steps": found_cache.advice.steps,
            "cautions": found_cache.advice.cautions
        },
        "meta": {
            "created_at": found_cache.created_at,
            "last_used_at": found_cache.last_used_at,
            "usage_count": found_cache.usage_count
        }
    };
}
impl MarketDebug.run {
    print(
        f"[MarketDebug] Calling FEWS NET for crop='{self.crop}', region='{self.region}'."
    );

    let raw = fetch_market_price_raw(
        crop=self.crop,
        region=self.region
    );

    let summary = summarize_market(
        raw=raw,
        crop=self.crop,
        region=self.region
    );

    report {
        "crop": self.crop,
        "region": self.region,
        "raw_sample": raw[:500],   # first 500 chars just to inspect
        "summary": summary
    };
}
