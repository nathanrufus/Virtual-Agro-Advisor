cl import from react { useState }
cl import from .AdvisorForm { AdvisorForm }
cl import from .AdvicePlanPanel { AdvicePlanPanel }
cl import from .WeatherSummaryPanel { WeatherSummaryPanel }
cl import from .MarketSummaryPanel { MarketSummaryPanel }
cl import from .FarmerMap { FarmerMap }

sv import from ..main { AgroAdvisor }

cl {
    def:pub AdvisorPage() -> any {
        [crop, setCrop] = useState("maize");
        [location, setLocation] = useState("Kiambu, Kenya");
        [problemText, setProblemText] = useState("");
        [language, setLanguage] = useState("en");
        [includeWeather, setIncludeWeather] = useState(True);
        [includeMarket, setIncludeMarket] = useState(True);
        [sessionId, setSessionId] = useState("");
        [loading, setLoading] = useState(False);
        [error, setError] = useState("");
        [advicePlan, setAdvicePlan] = useState(None);
        [weatherSummary, setWeatherSummary] = useState(None);
        [marketSummary, setMarketSummary] = useState(None);
        [meta, setMeta] = useState(None);
        [imagePreviewUrl, setImagePreviewUrl] = useState("");
        [activeTab, setActiveTab] = useState("advice");

       async def handleGetAdvice() -> None {
            if not problemText or not problemText.trim() {
                setError("Please describe the problem you are facing.");
                return;
            }

            setLoading(True);
            setError("");
            setAdvicePlan(None);
            setWeatherSummary(None);
            setMarketSummary(None);
            setMeta(None);

            try {
                result = await root spawn AgroAdvisor(
                    crop=crop,
                    problem_text=problemText,
                    location=location,
                    session_id=sessionId,
                    language=language,
                    include_weather=includeWeather,
                    include_market=includeMarket,
                    include_image=False,
                    image_data=""
                );

                payload = None;

                if result and result.reports and result.reports.length > 0 {
                    payload = result.reports[result.reports.length - 1];
                } else {
                    console.warn("[AdvisorPage] No reports returned from AgroAdvisor", result);
                    setError("No advice returned from AgroAdvisor.");
                    return;
                }

                if payload.error {
                    console.error("[AdvisorPage] AgroAdvisor reported error:", payload);
                    setError(payload.error);
                    return;
                }

                if payload.session_id {
                    setSessionId(payload.session_id);
                }

                if not payload.advice_plan {
                    console.warn("[AdvisorPage] advice_plan missing from payload", payload);
                    setError("Advice was not generated.");
                    return;
                }

                setAdvicePlan(payload.advice_plan);
                setWeatherSummary(payload.weather_summary or None);
                setMarketSummary(payload.market_summary or None);
                setMeta(payload.meta or None);
                setActiveTab("advice");
            } except exception as err {
                console.error("[AdvisorPage] AgroAdvisor error:", err);
                setError("Something went wrong while fetching advice. Please try again.");
            } finally {
                setLoading(False);
            }
        }

        tabActiveClass = "border-b-2 border-green-600 text-green-700 font-semibold";
        tabInactiveClass = "text-slate-500 hover:text-slate-700";

        return <div className="space-y-4">

            <div className="flex gap-6 border-b border-slate-200 pb-0">
                <button
                    className={tabActiveClass if activeTab == "advice" else tabInactiveClass}
                    onClick={lambda e: any -> None { setActiveTab("advice"); }}
                >
                    Advice
                </button>
                <button
                    className={tabActiveClass if activeTab == "map" else tabInactiveClass}
                    onClick={lambda e: any -> None { setActiveTab("map"); }}
                >
                    Farm Map
                </button>
            </div>

            {(
                <div className="grid gap-6 md:grid-cols-[minmax(0,1.2fr)_minmax(0,1fr)]">
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
                        imagePreviewUrl={imagePreviewUrl}
                        onImageChange={setImagePreviewUrl}
                    />
                    <div className="space-y-4">
                        <AdvicePlanPanel
                            advicePlan={advicePlan}
                            meta={meta}
                            loading={loading}
                            error={error}
                        />
                        <WeatherSummaryPanel summary={weatherSummary} meta={meta} />
                        <MarketSummaryPanel summary={marketSummary} meta={meta} />
                    </div>
                </div>
            ) if activeTab == "advice" else (
                <div className="w-full">
                    <div className="mb-3 rounded-xl bg-white border border-slate-200 p-4">
                        <p className="text-sm text-slate-600">
                            Showing data for: <span className="font-semibold text-slate-800">{location}</span>
                            — Crop: <span className="font-semibold text-slate-800 capitalize">{crop}</span>
                        </p>
                        <p className="text-xs text-slate-400 mt-1">
                            Map updates after you get advice. Weather and market data shown for regions you have queried.
                        </p>
                    </div>
                    <FarmerMap crop={crop} userLocation={None} />
                </div>
            )}

        </div>;
    }
}
