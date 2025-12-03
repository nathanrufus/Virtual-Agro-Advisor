cl import from react { useState }

# cl import from .AdvisorForm { AdvisorForm }
# cl import from .AdvicePlanPanel { AdvicePlanPanel }
# cl import from .WeatherSummaryPanel { WeatherSummaryPanel }
# cl import from .MarketSummaryPanel { MarketSummaryPanel }
   
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
                let result = await root spawn AgroAdvisor(
                    crop=crop,
                    problem_text=problemText,
                    location=location,
                    session_id=sessionId,
                    language=language,
                    include_weather=includeWeather,
                    include_market=includeMarket
                );

                console.log("AgroAdvisor result object:", result);

                let payload = result;
                if (result && result.report) {
                    payload = result.report;
                }

                if (payload.session_id) {
                    setSessionId(payload.session_id);
                }

                setAdvicePlan(payload.advice_plan);
                setWeatherSummary(payload.weather_summary);
                setMarketSummary(payload.market_summary);
                setMeta(payload.meta);
            } except (err) {
                console.error("AgroAdvisor error:", err);
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
