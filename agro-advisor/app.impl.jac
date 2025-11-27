import random;
include utils;  # expects get_current_datetime() to exist

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
        memory +>: HAS_SESSION :+> session;
        self.session_id = new_id;
    } else {
        # Try to reference an existing session by ID
        session = &(self.session_id);
        if not session {
            # If it doesn't exist, create and attach it
            session = Session(
                session_id=self.session_id,
                lang=self.lang
            );
            memory +>: HAS_SESSION :+> session;
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
    # Entry node is a Session
    session = here;

    # 1. Normalize location into a key
    loc_key = normalize_location(self.location);

    # 2. Look for an existing WeatherSnapshot for this location
    existing_snapshots = [];
    for snap in [->:HAS_WEATHER:->] {
        if snap.location_key == loc_key {
            existing_snapshots = existing_snapshots + [snap];
        }
    }

    snapshot = null;

    if existing_snapshots {
        # Reuse first existing snapshot for now
        snapshot = existing_snapshots[0];
    } else {
        # 3. Create a new snapshot (mock / placeholder data for Phase 2)
        summary_text = (
            f"Current weather information for '{self.location}' "
            f"as of {get_current_datetime()}. (Mock summary for now.)"
        );
        snapshot = WeatherSnapshot(
            location_key=loc_key,
            summary=summary_text,
            raw_source=""  # fill in later once you integrate a real API
        );
        session +>: HAS_WEATHER:+> snapshot;
    }

    # 4. Build a WeatherSummary object for downstream use
    weather_summary = WeatherSummary(
        summary_text=snapshot.summary
    );

    report weather_summary;
}



#  MarketAgent implementation (non-LLM, mock dataset + caching)


impl MarketAgent.run {
    # Entry node is a Session
    session = here;

    crop_key = normalize_crop(self.crop);
    region_key = normalize_region(self.region);

    # 1. Look for existing MarketSnapshot for this crop+region
    existing_snapshots = [];
    for snap in [->:HAS_MARKET:->] {
        if snap.crop_key == crop_key and snap.region_key == region_key {
            existing_snapshots = existing_snapshots + [snap];
        }
    }

    snapshot = null;

    if existing_snapshots {
        snapshot = existing_snapshots[0];
    } else {
        # 2. Mock price/trend summary for now
        #    Later, replace with real data or a small JSON dataset.
        summary_text = (
            f"Market info for crop '{self.crop}' in region '{self.region}'. "
            "Prices and trends are currently mocked for development."
        );
        snapshot = MarketSnapshot(
            crop_key=crop_key,
            region_key=region_key,
            summary=summary_text,
            raw_source=""
        );
        session +>: HAS_MARKET :+> snapshot;
    }

    # 3. Build a MarketSummary object
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

    memory +>: HAS_AUDIT :+> log;

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
