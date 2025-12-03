cl {
    def AdvisorForm(props: any) -> any {
        def handleSubmit(e: any) -> None {
            e.preventDefault();
            props.onSubmit();
        }

        return <form
            onSubmit={handleSubmit}
            className="space-y-5 rounded-2xl border border-lime-100 bg-white p-5 shadow-sm"
        >
            <div className="space-y-1">
                <h1 className="text-2xl font-semibold text-slate-900">
                    Get Personalized Agricultural Advice
                </h1>
                <p className="text-sm text-slate-500">
                    Fill in the details below to receive a tailored plan for your crops.
                </p>
            </div>

            <div className="space-y-4">
                <div className="space-y-1">
                    <label className="text-xs font-medium text-slate-700">
                        Select Crop
                    </label>
                    <input
                        type="text"
                        placeholder="e.g., Maize, Wheat, Soybeans"
                        value={props.crop}
                        onChange={lambda e: any -> None {
                            props.onCropChange(e.target.value);
                        }}
                        className="w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm outline-none focus:border-lime-500 focus:bg-white focus:ring-1 focus:ring-lime-500"
                    />
                </div>

                <div className="space-y-1">
                    <label className="text-xs font-medium text-slate-700">
                        Enter Location
                    </label>
                    <input
                        type="text"
                        placeholder="e.g., Kisumu, Kenya"
                        value={props.location}
                        onChange={lambda e: any -> None {
                            props.onLocationChange(e.target.value);
                        }}
                        className="w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm outline-none focus:border-lime-500 focus:bg-white focus:ring-1 focus:ring-lime-500"
                    />
                </div>

                <div className="space-y-1">
                    <label className="text-xs font-medium text-slate-700">
                        Describe Your Problem
                    </label>
                    <textarea
                        rows={4}
                        placeholder="Describe the issue you are facing in detail..."
                        value={props.problemText}
                        onChange={lambda e: any -> None {
                            props.onProblemTextChange(e.target.value);
                        }}
                        className="w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm outline-none focus:border-lime-500 focus:bg-white focus:ring-1 focus:ring-lime-500"
                    />
                </div>

                <div className="space-y-2">
                    <label className="text-xs font-medium text-slate-700">
                        Select Language
                    </label>
                    <div className="inline-flex gap-1 rounded-full bg-slate-100 p-1">
                        <button
                            type="button"
                            className={
                                "rounded-full px-4 py-1 text-xs font-medium " +
                                (
                                    "bg-lime-500 text-white shadow-sm"
                                    if props.language == "en"
                                    else "text-slate-600")
                            }
                            onClick={lambda e: any -> None {
                                props.onLanguageChange("en");
                            }}
                        >
                            English
                        </button>
                        <button
                            type="button"
                            className={
                                "rounded-full px-4 py-1 text-xs font-medium " +
                                (
                                    "bg-lime-500 text-white shadow-sm"
                                    if props.language == "sw"
                                    else "text-slate-600")
                            }
                            onClick={lambda e: any -> None {
                                props.onLanguageChange("sw");
                            }}
                        >
                            Swahili
                        </button>
                    </div>
                </div>

                <div className="flex flex-wrap gap-4">
                    <label className="flex items-center gap-2 text-xs text-slate-700">
                        <input
                            type="checkbox"
                            checked={props.includeWeather}
                            onChange={lambda e: any -> None {
                                props.onIncludeWeatherChange(e.target.checked);
                            }}
                            className="h-4 w-4 rounded border-slate-300 text-lime-500 focus:ring-lime-500"
                        />
                        Include Weather Forecast
                    </label>

                    <label className="flex items-center gap-2 text-xs text-slate-700">
                        <input
                            type="checkbox"
                            checked={props.includeMarket}
                            onChange={lambda e: any -> None {
                                props.onIncludeMarketChange(e.target.checked);
                            }}
                            className="h-4 w-4 rounded border-slate-300 text-lime-500 focus:ring-lime-500"
                        />
                        Include Market Prices
                    </label>
                </div>

                <div>
                    <button
                        type="submit"
                        disabled={props.loading}
                        className={
                            "mt-1 inline-flex w-full items-center justify-center rounded-xl bg-lime-500 px-4 py-2 text-sm font-semibold text-white shadow-sm transition " +
                            ( "opacity-80" if props.loading   else  "hover:bg-lime-600")
                        }
                    >
                        {"Getting advice..." if props.loading   else "Get Advice"}
                    </button>
                </div>
            </div>
        </form>;
    }
}
