include utils;
include intergrations;
include backend.models;
include backend.helpers;



walker:pub LLMAnalyzeDebug {
    has crop: str;
    has problem_text: str;
    has location: str;
    has language: str = "en";

    can run with Root entry {
        history_text = "";

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

        if not issue {
            report {
                "error": "analyze_issue returned None",
                "stage": "analyze_issue",
                "crop": self.crop,
                "location": self.location,
                "problem_text": self.problem_text
            };
            disengage;
        }

        report {
            "issue_analysis": issue
        };
    }
}

walker:pub LLMAdviceDebug {
    has crop: str;
    has problem_text: str;
    has location: str;
    has language: str = "en";
    has include_weather: bool = True;
    has include_market: bool = True;

    can run with Root entry {
        history_text = "";

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

        farmer_ctx = FarmerContext(
            region=self.location,
            lang=self.language
        );

        issue = analyze_issue(
            crop=self.crop,
            problem_text=problem_for_llm,
            location=self.location,
            history=history_for_llm
        );

        if not issue {
            report {
                "error": "analyze_issue returned None",
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
                "error": "generate_advice returned None",
                "stage": "generate_advice",
                "issue_analysis": issue
            };
            disengage;
        }

        reviewed = safety_review(advice=raw_advice);
        if not reviewed {
            report {
                "error": "safety_review returned None",
                "stage": "safety_review",
                "raw_advice": raw_advice
            };
            disengage;
        }

        safe_advice = ensure_numbered_steps(reviewed);

        final_advice = translate_advice_if_needed(
            advice=safe_advice,
            target_lang=self.language
        );

        if not final_advice {
            report {
                "error": "translate_advice_if_needed returned None",
                "stage": "translate_advice_if_needed",
                "safe_advice": safe_advice
            };
            disengage;
        }

        report {
            "issue_analysis": issue,
            "weather_summary": weather_summary,
            "market_summary": market_summary,
            "advice_plan": final_advice
        };
    }
}

walker:pub MarketDebug {
    has crop: str;
    has region: str;

    obj __specs__ {
        static has methods: list = ["get", "post"];
        static has auth: bool = False;
        static has as_query: list = ["crop", "region"];
    }

    can run with Root entry {
        raw = fetch_market_price_raw(
            crop=self.crop,
            region=self.region
        );

        summary = summarize_market(
            raw=raw,
            crop=self.crop,
            region=self.region
        );

        report {
            "crop": self.crop,
            "region": self.region,
            "raw_sample": raw[:500],
            "summary": summary
        };
    }
}