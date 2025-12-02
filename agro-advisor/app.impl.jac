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
    session = here;

    crop_key = normalize_crop(self.crop);
    region_key = normalize_region(self.region);

    # 1. Check cache first
    existing_snapshots = [];
    for snap in [session ->:HAS_MARKET:->] {
        if snap.crop_key == crop_key and snap.region_key == region_key {
            existing_snapshots = existing_snapshots + [snap];
        }
    }

    snapshot = None;

    if existing_snapshots {
        # Reuse cached LLM-based snapshot
        snapshot = existing_snapshots[0];
    } else {
        # 2. No cache -> use byLLM to estimate price

        let region_for_llm = self.region if self.region else "Kenya";

        print(
            f"[MarketLLM] Using pure LLM estimate for {self.crop} "
            f"in {region_for_llm}."
        );

        let est_price = 0.0;
        try {
            est_price = estimate_market_price(
                crop=self.crop,
                region=region_for_llm
            );
        } except Exception {
            print("[MarketLLM] estimate_market_price LLM call failed.");
            est_price = 0.0;
        }

        let summary_text = "";
        if est_price > 0.0 {
            summary_text = (
                f"An AI-based estimate suggests the current price for {self.crop} "
                f"in {region_for_llm} is around {est_price} KES/kg. "
                f"This is NOT live market data; always confirm with local buyers, "
                f"cooperatives, or nearby markets before making financial decisions."
            );
        } else {
            summary_text = (
                f"Market price estimates for {self.crop} in {region_for_llm} "
                f"are currently unavailable. Please check with local buyers, "
                f"cooperatives, or nearby markets for current prices."
            );
        }

        # 3. Store LLM-only snapshot (no external raw_source)
        snapshot = MarketSnapshot(
            crop_key=crop_key,
            region_key=region_key,
            summary=summary_text,
            raw_source=""  # no API payload
        );
        session +>: HAS_MARKET() :+> snapshot;
    }

    # 4. Return MarketSummary for the advisor / frontend
    market_summary = MarketSummary(
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
    include_market: bool
) -> str {
    # Very simple deterministic cache key; you can improve later if needed.
    norm_crop = normalize_crop(crop);
    norm_loc = normalize_location(location);
    trimmed_problem = problem_text.strip();
    # Avoid super-long keys by truncating the problem text
    if len(trimmed_problem) > 120 {
        trimmed_problem = trimmed_problem[:120];
    }
    return f"{norm_crop}|{norm_loc}|{lang}|w={include_weather}|m={include_market}|{trimmed_problem}";
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
        new_id = generate_session_id();
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

    # 3. Cache lookup
    cache_key = make_cache_key(
        crop=self.crop,
        problem_text=self.problem_text,
        location=self.location,
        lang=self.language,
        include_weather=self.include_weather,
        include_market=self.include_market
    );

    existing_cache = None;
    for ac in [session ->:HAS_ADVICE:->] {
        if ac.cache_key == cache_key {
            existing_cache = ac;
            break;
        }
    }

    # We'll fill these regardless of cache hit/miss
    weather_summary = WeatherSummary(
        summary_text="Weather data not requested."
    );
    market_summary = MarketSummary(
        summary_text="Market data not requested."
    );

    # 3b. Always ensure weather/market snapshots exist, even on cache hit
    if self.include_weather {
        loc_key = normalize_location(self.location);

        existing_snapshots = [];
        for snap in [session ->:HAS_WEATHER:->] {
            if snap.location_key == loc_key {
                existing_snapshots = existing_snapshots + [snap];
            }
        }

        snapshot_w = None;

        if existing_snapshots {
            snapshot_w = existing_snapshots[0];
        } else {
            # Call real API helpers from integrations/weather.jac
            raw_weather = fetch_weather_raw(loc_key);
            summary_text = summarize_weather(raw_weather, self.location);

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
        crop_key = normalize_crop(self.crop);
        region_key = normalize_region(self.location);  # reuse location as region key

        # 1. Check if we already have a MarketSnapshot for this crop/region
        existing_ms = [];
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
            snapshot_m = existing_ms[0];

            market_summary = MarketSummary(
                summary_text=snapshot_m.summary
            );
        }
    }

    # 4. If cache hit: reuse advice, log, and return
    if existing_cache {
        existing_cache.touch();

        log_hit = AuditLog(
            event="agro_advisor_cache_hit",
            cache_hit=True,
            latency_ms=0,  # TODO: compute if you add real timing
            session_id=session.session_id
        );
        memory +>: HAS_AUDIT() :+> log_hit;

        advice_cached = existing_cache.advice;

        # Optionally re-translate if language changed
        final_advice_cached = translate_advice_if_needed(
            advice=advice_cached,
            target_lang=self.language
        );

        report {
            "session_id": session.session_id,
            "advice_plan": final_advice_cached,
            "weather_summary": weather_summary,
            "market_summary": market_summary,
            "meta": {
                "source": "cache",
                "lang": self.language
            }
        };
        disengage;
    }

    # 5. Cache miss: run full LLM pipeline

    # Build context
    history_text = session.get_history();
    farmer_ctx = FarmerContext(
        region=self.location,
        lang=self.language
    );

    # 5.1 Analyze issue (LLM)
    issue = analyze_issue(
        crop=self.crop,
        problem_text=self.problem_text,
        location=self.location,
        history=history_text
    );

    # 5.2 Generate advice (LLM)
    raw_advice = generate_advice(
        analysis=issue,
        weather=weather_summary,
        market=market_summary,
        context=farmer_ctx
    );

    # 5.3 Safety review (LLM)
    safe_advice = safety_review(advice=raw_advice);

    # 5.4 Translation (if needed)
    final_advice = translate_advice_if_needed(
        advice=safe_advice,
        target_lang=self.language
    );

    # 6. Persistence: cache + history + audit
    new_cache = AdviceCache(
        cache_key=cache_key,
        advice=safe_advice  # store the pivot-language or base advice
    );
    session +>: HAS_ADVICE() :+> new_cache;

    # Append brief interaction to session history
    hist_entry = (
        "user: " + self.problem_text + "\n" +
        "ai: " + final_advice.overview
    );
    session.add_history(hist_entry);

    # Audit log
    log_fresh = AuditLog(
        event="agro_advisor_fresh",
        cache_hit=False,
        latency_ms=0,
        session_id=session.session_id
    );
    memory +>: HAS_AUDIT() :+> log_fresh;

    # 7. Final response for frontend
    report {
        "session_id": session.session_id,
        "advice_plan": final_advice,
        "weather_summary": weather_summary,
        "market_summary": market_summary,
        "meta": {
            "source": "fresh",
            "lang": self.language
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
