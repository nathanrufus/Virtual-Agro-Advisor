include utils;
include intergrations;
sv import from byllm.lib { Image }

sv import from backend.models {
    Memory,
    Session,
    AdviceCache,
    WeatherSnapshot,
    MarketSnapshot,
    ImageAnalysisResult,
    AuditLog,
    HAS_SESSION,
    HAS_WEATHER,
    HAS_MARKET,
    HAS_ADVICE,
    HAS_IMAGE_ANALYSIS,
    HAS_AUDIT,
    FarmerContext,
    WeatherSummary,
    MarketSummary
}

sv import from backend.helpers {
    generate_session_id,
    normalize_location,
    normalize_crop,
    normalize_region,
    make_cache_key,
    translate_advice_if_needed,
    translate_summary_text_if_needed,
    get_ui_titles,
    ensure_numbered_steps
}


sv import from backend.models {
    normalize_crop_location,
    analyze_issue,
    generate_advice,
    safety_review,
    analyze_crop_image
}

sv import from backend.sessions {
    MarketAgent
}

walker ImageAnalysisAgent {
    has image_data: str;
    has crop: str;
    has location: str;

    can run with Session entry {
        img_key = self.image_data;

        existing = None;
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

        img = Image(self.image_data);

        summary = analyze_crop_image(
            img=img,
            crop=self.crop,
            location=self.location
        );

        analysis_node = ImageAnalysisResult(
            image_id=img_key,
            labels=summary.labels,
            confidences=summary.confidences,
            notes=summary.notes
        );
        here +>: HAS_IMAGE_ANALYSIS() :+> analysis_node;

        report analysis_node;
    }
}

walker:pub AgroAdvisor {
    has crop: str;
    has problem_text: str;
    has location: str;
    has session_id: str = "";
    has language: str = "en";
    has include_weather: bool = True;
    has include_market: bool = True;
    has include_image: bool = False;
    has image_data: str = "";

    can run with Root entry {
        mem_list = [root -->][?:Memory];
        if not mem_list {
            memory = Memory();
            root ++> memory;
        } else {
            memory = mem_list[0];
        }

        session = None;

        if not self.session_id {
            new_id = generate_session_id();
            session = Session(
                session_id=new_id,
                lang=self.language
            );
            memory +>: HAS_SESSION() :+> session;
            self.session_id = new_id;
        } else {
            for s in [memory ->:HAS_SESSION:->] {
                if s.session_id == self.session_id {
                    session = s;
                    break;
                }
            }

            if not session {
                session = Session(
                    session_id=self.session_id,
                    lang=self.language
                );
                memory +>: HAS_SESSION() :+> session;
            } else {
                session.lang = self.language;
            }
        }

        session.last_active_at = get_current_datetime();

        norm = normalize_crop_location(
            crop=self.crop,
            location=self.location
        );

        if norm.crop {
            self.crop = norm.crop;
        }
        if norm.location {
            self.location = norm.location;
        }

        cache_key = make_cache_key(
            crop=self.crop,
            problem_text=self.problem_text,
            location=self.location,
            lang=self.language,
            include_weather=self.include_weather,
            include_market=self.include_market,
            include_image=self.include_image
        );

        existing_cache = None;
        for ac in [session ->:HAS_ADVICE:->] {
            if ac.cache_key == cache_key {
                existing_cache = ac;
                break;
            }
        }

        weather_summary = WeatherSummary(
            summary_text="Weather data not requested."
        );
        market_summary = MarketSummary(
            summary_text="Market data not requested."
        );

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
            region_key = normalize_region(self.location);

            existing_ms = [];
            for snap in [session ->:HAS_MARKET:->] {
                if snap.crop_key == crop_key and snap.region_key == region_key {
                    existing_ms = existing_ms + [snap];
                }
            }

            if not existing_ms {
                session spawn MarketAgent(
                    crop=self.crop,
                    region=self.location
                );

                for snap in [session ->:HAS_MARKET:->] {
                    if snap.crop_key == crop_key and snap.region_key == region_key {
                        existing_ms = existing_ms + [snap];
                    }
                }
            }

            if existing_ms {
                snapshot_m = existing_ms[0];
                market_summary = MarketSummary(
                    summary_text=snapshot_m.summary
                );
            }
        }

        if existing_cache {
            existing_cache.touch();

            log_hit = AuditLog(
                event="agro_advisor_cache_hit",
                cache_hit=True,
                latency_ms=0,
                session_id=session.session_id
            );
            memory +>: HAS_AUDIT() :+> log_hit;

            advice_cached = existing_cache.advice;

            final_advice_cached = translate_advice_if_needed(
                advice=advice_cached,
                target_lang=self.language
            );
            final_advice_cached = ensure_numbered_steps(final_advice_cached);

            weather_summary.summary_text = translate_summary_text_if_needed(
                text=weather_summary.summary_text,
                target_lang=self.language
            );
            market_summary.summary_text = translate_summary_text_if_needed(
                text=market_summary.summary_text,
                target_lang=self.language
            );

            ui_titles = get_ui_titles(self.language);

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

        image_notes = "";
        if self.include_image and self.image_data {
            img_result = None;
            for img in [session ->:HAS_IMAGE_ANALYSIS:->] {
                if img.image_id == self.image_data {
                    img_result = img;
                    break;
                }
            }

            if not img_result {
                session spawn ImageAnalysisAgent(
                    image_data=self.image_data,
                    crop=self.crop,
                    location=self.location
                );

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

        history_text = session.get_history();
        farmer_ctx = FarmerContext(
            region=self.location,
            lang=self.language
        );

        combined_problem = self.problem_text;
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

        issue = analyze_issue(
            crop=self.crop,
            problem_text=combined_problem,
            location=self.location,
            history=history_text
        );

        if not issue {
            report {
                "error": "analyze_issue returned null",
                "stage": "analyze_issue"
            };
            disengage;
        }

        raw_advice = generate_advice(
            analysis=issue,
            weather=weather_summary,
            market=market_summary,
            context=farmer_ctx
        );

        if not raw_advice {
            report {
                "error": "generate_advice returned null",
                "stage": "generate_advice",
                "issue_analysis": issue
            };
            disengage;
        }

        safe_advice = safety_review(advice=raw_advice);

        if not safe_advice {
            report {
                "error": "safety_review returned null",
                "stage": "safety_review",
                "raw_advice": raw_advice
            };
            disengage;
        }

        safe_advice = ensure_numbered_steps(safe_advice);

        final_advice = translate_advice_if_needed(
            advice=safe_advice,
            target_lang=self.language
        );

        if not final_advice {
            report {
                "error": "translate_advice_if_needed returned null",
                "stage": "translate_advice_if_needed",
                "safe_advice": safe_advice
            };
            disengage;
        }

        new_cache = AdviceCache(
            cache_key=cache_key,
            advice=safe_advice
        );
        session +>: HAS_ADVICE() :+> new_cache;

        hist_entry = (
            "user: " + combined_problem + "\n" +
            "ai: " + final_advice.overview
        );
        session.add_history(hist_entry);

        log_fresh = AuditLog(
            event="agro_advisor_fresh",
            cache_hit=False,
            latency_ms=0,
            session_id=session.session_id
        );
        memory +>: HAS_AUDIT() :+> log_fresh;

        weather_summary.summary_text = translate_summary_text_if_needed(
            text=weather_summary.summary_text,
            target_lang=self.language
        );
        market_summary.summary_text = translate_summary_text_if_needed(
            text=market_summary.summary_text,
            target_lang=self.language
        );

        ui_titles = get_ui_titles(self.language);

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
}