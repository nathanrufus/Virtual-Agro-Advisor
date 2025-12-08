cl import from react { useState }

cl {
    def AdvisorPage() -> any {
        let [crop, setCrop] = useState("maize");
        let [location, setLocation] = useState("Kiambu, Kenya");
        let [problemText, setProblemText] = useState("");
        let [language, setLanguage] = useState("en");
        let [includeWeather, setIncludeWeather] = useState(True);
        let [includeMarket, setIncludeMarket] = useState(True);
        let [sessionId, setSessionId] = useState("");
        let [loading, setLoading] = useState(False);
        let [error, setError] = useState("");
        let [advicePlan, setAdvicePlan] = useState(None);
        let [weatherSummary, setWeatherSummary] = useState(None);
        let [marketSummary, setMarketSummary] = useState(None);
        let [meta, setMeta] = useState(None);

        async def handleGetAdvice() -> None {
            if not problemText or not problemText.trim() {
                setError("Please describe the problem you are facing.");
                return;
            }

            setLoading(True);
            setError("");

            try {
                console.log("[AdvisorPage] Sending request with:", {
                    "crop": crop,
                    "location": location,
                    "problemText": problemText,
                    "language": language,
                    "includeWeather": includeWeather,
                    "includeMarket": includeMarket,
                    "sessionId": sessionId
                });

                result = root spawn AgroAdvisor(
                    crop=crop,
                    problem_text=problemText,
                    location=location,
                    session_id=sessionId,
                    language=language,
                    include_weather=includeWeather,
                    include_market=includeMarket
                );

                console.log("[AdvisorPage] Raw AgroAdvisor result:", result);
                console.log("[AdvisorPage] result.reports:", result && result.reports);

                let payload = None;

                # IMPORTANT: AgroAdvisor's own report is the LAST item
                if result and result.reports and result.reports.length > 0 {
                    payload = result.reports[result.reports.length - 1];
                } else {
                    console.warn("[AdvisorPage] No reports returned from AgroAdvisor");
                    setError("No advice returned from AgroAdvisor.");
                    return;
                }

                console.log("[AdvisorPage] Selected payload:", payload);
                console.log("[AdvisorPage] payload.advice_plan:", payload.advice_plan);

                if payload.session_id {
                    setSessionId(payload.session_id);
                } else {
                    console.warn("[AdvisorPage] payload.session_id missing");
                }

                setAdvicePlan(payload.advice_plan);
                setWeatherSummary(payload.weather_summary);
                setMarketSummary(payload.market_summary);
                setMeta(payload.meta);

                console.log("[AdvisorPage] advicePlan state after set:", payload.advice_plan);
            } except (err) {
                console.error("[AdvisorPage] AgroAdvisor error:", err);
                setError("Something went wrong while fetching advice. Please try again.");
            } finally {
                setLoading(False);
            }
        }

        return <div className="grid gap-6 md:grid-cols-[minmax(0,1.2fr)_minmax(0,1fr)]">
            <AdvisorForm
                crop={crop}
                onCropChange={setCrop}
                location={location}
                onLocationChange={setLocation}
                problemText={problemText}
                onProblemTextChange={setProblemText}
                language={language}
                onLanguageChange={setLanguage}
                includeWeather={includeWeather}
                onIncludeWeatherChange={setIncludeWeather}
                includeMarket={includeMarket}
                onIncludeMarketChange={setIncludeMarket}
                loading={loading}
                onSubmit={handleGetAdvice}
            />
            <div className="space-y-4">
                <AdvicePlanPanel
                    advicePlan={advicePlan}
                    meta={meta}
                    loading={loading}
                    error={error}
                />
                <WeatherSummaryPanel summary={weatherSummary} />
                <MarketSummaryPanel summary={marketSummary} />
            </div>
        </div>;
    }
}
