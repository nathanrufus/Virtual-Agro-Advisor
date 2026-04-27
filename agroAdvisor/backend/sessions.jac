# sv import from backend.models {
#     Memory,
#     Session,
#     WeatherSnapshot,
#     MarketSnapshot,
#     AuditLog,
#     WeatherSummary,
#     MarketSummary,
#     HAS_SESSION,
#     HAS_WEATHER,
#     HAS_MARKET,
#     HAS_AUDIT
# }
include backend.models;
sv import from backend.helpers {
    generate_session_id,
    normalize_location,
    normalize_crop,
    normalize_region
}
import from intergrations {
    fetch_weather_raw,
    fetch_market_price_raw,
    summarize_weather,
    summarize_market
}
include utils;
sv {
    walker SessionManager {
        has session_id: str = "";
        has lang: str = "en";

        can run with Root entry {
            mem_list = [root -->][?:Memory];
            if not mem_list {
                memory = Memory();
                root ++> memory;
            } else {
                memory = mem_list[0];
            }

            if not self.session_id {
                new_id = generate_session_id();
                session = Session(
                    session_id=new_id,
                    lang=self.lang
                );
                memory +>: HAS_SESSION() :+> session;
                self.session_id = new_id;
            } else {
                session = None;
                for s in [memory ->:HAS_SESSION:->] {
                    if s.session_id == self.session_id {
                        session = s;
                        break;
                    }
                }

                if not session {
                    session = Session(
                        session_id=self.session_id,
                        lang=self.lang
                    );
                    memory +>: HAS_SESSION() :+> session;
                } else {
                    session.lang = self.lang;
                }
            }

            session.last_active_at = get_current_datetime();

            report {
                "session_id": session.session_id,
                "lang": session.lang,
                "created_at": session.created_at,
                "last_active_at": session.last_active_at
            };
        }
    }

    walker WeatherAgent {
        has location: str;

        can run with Session entry {
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
                raw = fetch_weather_raw(loc_key);
                summary_text = summarize_weather(raw, self.location);

                snapshot = WeatherSnapshot(
                    location_key=loc_key,
                    summary=summary_text,
                    raw_source=raw
                );
                session +>: HAS_WEATHER() :+> snapshot;
            }

            report WeatherSummary(
                summary_text=snapshot.summary
            );
        }
    }

    walker MarketAgent {
        has crop: str;
        has region: str;

        can run with Session entry {
            session = here;

            crop_key = normalize_crop(self.crop);
            region_key = normalize_region(self.region);

            existing_snapshots = [];
            for snap in [session ->:HAS_MARKET:->] {
                if snap.crop_key == crop_key and snap.region_key == region_key {
                    existing_snapshots = existing_snapshots + [snap];
                }
            }

            snapshot = None;

            if existing_snapshots {
                snapshot = existing_snapshots[0];
            } else {
                region_for_api = self.region;
                if not region_for_api {
                    region_for_api = "Kenya";
                }

                raw = fetch_market_price_raw(
                    crop=self.crop,
                    region=region_for_api
                );

                summary_text = summarize_market(
                    raw=raw,
                    crop=self.crop,
                    region=region_for_api
                );

                snapshot = MarketSnapshot(
                    crop_key=crop_key,
                    region_key=region_key,
                    summary=summary_text,
                    raw_source=raw
                );
                session +>: HAS_MARKET() :+> snapshot;
            }

            report MarketSummary(
                summary_text=snapshot.summary
            );
        }
    }

    walker AuditAgent {
        has event: str;
        has cache_hit: bool = False;
        has latency_ms: int = 0;
        has session_id: str = "";

        can run with Memory entry {
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
    }

    walker:pub GetAllSessions {
        can create with Root entry {
            mem_list = [root -->][?:Memory];
            if not mem_list {
                report [];
                disengage;
            }

            memory = mem_list[0];
            sessions = [memory ->:HAS_SESSION:->];

            report [{
                "session_id": sess.session_id,
                "lang": sess.lang,
                "created_at": sess.created_at,
                "last_active_at": sess.last_active_at
            } for sess in sessions];
        }
    }

    walker:pub CleanupOldSessions {
        has cutoff: str = "";

        can create with Root entry {
            mem_list = [root -->][?:Memory];
            if not mem_list {
                report {
                    "deleted_count": 0,
                    "message": "No Memory node found."
                };
                disengage;
            }

            delete_all = False;
            if self.cutoff and self.cutoff.upper() == "ALL" {
                delete_all = True;
            }

            memory = mem_list[0];
            sessions = [memory ->:HAS_SESSION:->];
            deleted = 0;

            for sess in sessions {
                ts = sess.last_active_at or sess.created_at or "";
                if delete_all or (self.cutoff and ts and ts < self.cutoff) {
                    del sess;
                    deleted = deleted + 1;
                }
            }

            report {
                "deleted_count": deleted
            };
        }
    }
}