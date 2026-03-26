sv import from backend.models {
    Memory,
    HAS_SESSION,
    HAS_ADVICE
}

sv import from backend.helpers {
    parse_cache_key
}

sv {
    walker:pub GetAllAdviceCache {
        can create with Root entry {
            mem_list = [root -->][?:Memory];
            if not mem_list {
                report [];
                disengage;
            }

            memory = mem_list[0];
            sessions = [memory ->:HAS_SESSION:->];

            rows = [];
            for sess in sessions {
                for ac in [sess ->:HAS_ADVICE:->] {
                    rows = rows + [{
                        "cache_key": ac.cache_key,
                        "created_at": ac.created_at,
                        "last_used_at": ac.last_used_at,
                        "usage_count": ac.usage_count
                    }];
                }
            }

            report rows;
        }
    }

    walker:pub ClearAdviceCache {
        can create with Root entry {
            mem_list = [root -->][?:Memory];
            if not mem_list {
                report {
                    "deleted_count": 0
                };
                disengage;
            }

            memory = mem_list[0];
            sessions = [memory ->:HAS_SESSION:->];

            deleted = 0;
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
    }

    walker:pub GetAdviceCacheDetail {
        has cache_key: str;

        can create with Root entry {
            mem_list = [root -->][?:Memory];
            if not mem_list {
                report {
                    "ok": False,
                    "error": "No Memory node found.",
                    "cache_key": self.cache_key
                };
                disengage;
            }

            memory = mem_list[0];
            sessions = [memory ->:HAS_SESSION:->];

            found_cache = None;
            owner_session = None;

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

            if not found_cache {
                report {
                    "ok": False,
                    "error": "Advice cache not found.",
                    "cache_key": self.cache_key
                };
                disengage;
            }

            parsed = parse_cache_key(found_cache.cache_key);

            report {
                "ok": True,
                "cache_key": found_cache.cache_key,
                "parsed": parsed,
                "session": {
                    "session_id": owner_session.session_id,
                    "lang": owner_session.lang,
                    "created_at": owner_session.created_at,
                    "last_active_at": owner_session.last_active_at
                },
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
    }
}