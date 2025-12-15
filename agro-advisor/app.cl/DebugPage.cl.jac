cl {

    def extractAnalysis(res: any) -> any {
        if not res {
            return None;
        }

        # Case 1: already a plain IssueAnalysis object
        if ("problem_type" in res) or ("severity" in res) {
            return res;
        }

        # Case 2: walker reports list
        if ("reports" in res and res["reports"]) {
            let first = res["reports"][0];

            if ("analysis" in first) {
                return first["analysis"];
            }

            if ("problem_type" in first) or ("severity" in first) {
                return first;
            }
        }

        # Case 3: nested under "result"
        if ("result" in res) {
            let r = res["result"];
            if ("analysis" in r) {
                return r["analysis"];
            }
            if ("problem_type" in r) or ("severity" in r) {
                return r;
            }
        }

        return None;
    }

    def extractAdvice(res: any) -> any {
        if not res {
            return None;
        }

        # Case 1: already a plain AdvicePlan object
        if ("overview" in res) or ("steps" in res) or ("cautions" in res) {
            return res;
        }

        # Case 2: walker reports list → look for advice_plan/advice inside reports[0]
        if ("reports" in res and res["reports"] and res["reports"].length > 0) {
            let first = res["reports"][0];

            if ("advice_plan" in first) {
                return first["advice_plan"];
            }

            if ("advice" in first) {
                return first["advice"];
            }

            if ("overview" in first) or ("steps" in first) or ("cautions" in first) {
                return first;
            }
        }

        # Case 3: nested under result
        if ("result" in res) {
            let r = res["result"];

            if ("advice_plan" in r) {
                return r["advice_plan"];
            }

            if ("advice" in r) {
                return r["advice"];
            }

            if ("overview" in r) or ("steps" in r) or ("cautions" in r) {
                return r;
            }
        }

        return None;
    }



    def DebugPage() -> any {
        let [crop, setCrop] = useState("maize");
        let [location, setLocation] = useState("Kiambu, Kenya");
        let [problemText, setProblemText] = useState("");

        let [analysisResult, setAnalysisResult] = useState(None);
        let [adviceResult, setAdviceResult] = useState(None);

        let [loadingAnalysis, setLoadingAnalysis] = useState(False);
        let [loadingAdvice, setLoadingAdvice] = useState(False);
        let [error, setError] = useState("");

        async def runAnalyzeDebug() -> None {
            # Make problem description compulsory
            if (not problemText) or (problemText.trim() == "") {
                window.alert("Please enter a problem description before running LLMAnalyzeDebug.");
                return;
            }

            setLoadingAnalysis(True);
            setError("");
            setAnalysisResult(None);

            try {
                let res = await root spawn LLMAnalyzeDebug(
                    crop=crop,
                    problem_text=problemText,
                    location=location,
                    language="en"
                );
                console.log("LLMAnalyzeDebug result:", res);

                if ("error" in res) {
                    console.error("LLMAnalyzeDebug error:", res.error);
                    setError("LLMAnalyzeDebug failed: " + res.error);
                } else {
                    setAnalysisResult(res);
                }
            } except exception as err {
                console.error("LLMAnalyzeDebug exception:", err);
                setError("Unexpected error in LLMAnalyzeDebug.");
            } finally {
                setLoadingAnalysis(False);
            }
        }

        async def runAdviceDebug() -> None {
            # Make problem description compulsory
            if (not problemText) or (problemText.trim() == "") {
                window.alert("Please enter a problem description before running LLMAdviceDebug.");
                return;
            }

            setLoadingAdvice(True);
            setError("");
            setAdviceResult(None);

            try {
                let res = await root spawn LLMAdviceDebug(
                    crop=crop,
                    problem_text=problemText,
                    location=location,
                    language="en",
                    include_weather=True,
                    include_market=True
                );
                console.log("LLMAdviceDebug result:", res);

                if ("error" in res) {
                    console.error("LLMAdviceDebug error:", res.error);
                    setError("LLMAdviceDebug failed: " + res.error);
                } else {
                    setAdviceResult(res);
                }
            } except exception as err {
                console.error("LLMAdviceDebug exception:", err);
                setError("Unexpected error in LLMAdviceDebug.");
            } finally {
                setLoadingAdvice(False);
            }
        }

        # Derived objects for nicer UI
        let analysis = extractAnalysis(analysisResult);
        let advice = extractAdvice(adviceResult);

        let severity = "";
        let problemType = "";

        if analysis {
            if ("severity" in analysis and analysis["severity"]) {
                severity = analysis["severity"];
            }
            if ("problem_type" in analysis and analysis["problem_type"]) {
                problemType = analysis["problem_type"];
            }
        }

        let severityClass = "inline-flex items-center rounded-full border border-slate-200 bg-slate-50 px-2 py-0.5 font-medium text-slate-700";
        if severity == "low" {
            severityClass = "inline-flex items-center rounded-full border border-emerald-200 bg-emerald-50 px-2 py-0.5 font-medium text-emerald-800";
        } elif severity == "high" {
            severityClass = "inline-flex items-center rounded-full border border-rose-200 bg-rose-50 px-2 py-0.5 font-medium text-rose-800";
        }

        return <div className="space-y-6">
            <div>
                <h1 className="text-xl font-semibold text-slate-900">
                    Debug tools
                </h1>
                <p className="mt-1 text-slate-500">
                    Run the LLM analysis and advice walkers directly with test inputs.
                </p>
            </div>

            {error and (
                <div className="rounded-2xl border border-red-200 bg-red-50 p-4 text-red-700">
                    {error}
                </div>
            )}

            <div className="rounded-2xl border border-slate-200 bg-white p-4 text-slate-700 space-y-4">
                <div className="grid gap-3 sm:grid-cols-2">
                    <div className="space-y-1">
                        <label className=" font-medium text-slate-700">
                            Crop
                        </label>
                        <input
                            className="w-full rounded-lg border border-slate-200 px-3 py-2 outline-none focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500"
                            value={crop}
                            onChange={lambda e: any -> None { setCrop(e.target.value); }}
                            placeholder="maize"
                        />
                    </div>

                    <div className="space-y-1">
                        <label className="font-medium text-slate-700">
                            Location
                        </label>
                        <input
                            className="w-full rounded-lg border border-slate-200 px-3 py-2 outline-none focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500"
                            value={location}
                            onChange={lambda e: any -> None { setLocation(e.target.value); }}
                            placeholder="Kiambu, Kenya"
                        />
                    </div>
                </div>

                <div className="space-y-1">
                    <label className="font-medium text-slate-700">
                        Problem description
                    </label>
                    <textarea
                        className="h-28 w-full rounded-lg border border-slate-200 px-3 py-2 outline-none focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500"
                        value={problemText}
                        onChange={lambda e: any -> None { setProblemText(e.target.value); }}
                        placeholder="Describe the farmer&#39;s issue here (e.g. leaves are curling and turning yellow)…"
                        required
                    />
                </div>

                <div className="flex flex-wrap gap-2">
                    <button
                        className="rounded-lg border border-slate-300 px-3 py-1.5 font-medium hover:bg-slate-50 disabled:opacity-60" disabled={loadingAnalysis}
                        onClick={lambda e: any -> None { runAnalyzeDebug(); }}
                    >
                        { "Running LLMAnalyzeDebug…" if loadingAnalysis else "Run LLMAnalyzeDebug" }
                    </button>

                    <button
                        className="rounded-lg bg-emerald-600 px-3 py-1.5 font-medium text-white hover:bg-emerald-700 disabled:opacity-60"
                        disabled={loadingAdvice}
                        onClick={lambda e: any -> None { runAdviceDebug(); }}
                    >
                        { "Running LLMAdviceDebug…" if loadingAdvice else "Run LLMAdviceDebug" }
                    </button>
                </div>
            </div>

            <div className="grid gap-4 lg:grid-cols-2">
                # -------- IssueAnalysis card --------
                <div className="flex h-[320px] flex-col rounded-2xl border border-slate-200 bg-white p-4 text-slate-700">
                    <div className="mb-2 flex items-center justify-between">
                        <h2 className="font-semibold text-slate-800">
                            IssueAnalysis
                        </h2>
                        <span className="uppercase tracking-wide text-slate-400">
                            LLMAnalyzeDebug
                        </span>
                    </div>

                    <div className="mt-1 flex-1 overflow-y-auto">
                        {(
                            <div className="space-y-3">
                                <div className="flex flex-wrap items-center gap-2">
                                    <span className=" uppercase tracking-wide text-slate-400">
                                        Problem type
                                    </span>
                                    <span className="inline-flex items-center rounded-full bg-slate-50 px-2 py-0.5  font-medium text-slate-800">
                                        {problemType or "—"}
                                    </span>

                                    <span className="ml-3  uppercase tracking-wide text-slate-400">
                                        Severity
                                    </span>
                                    <span className={severityClass}>
                                        {severity or "—"}
                                    </span>
                                </div>

                                <div>
                                    <p className="mb-1 font-medium text-slate-500">
                                        Key symptoms
                                    </p>

                                    {(
                                        <ul className="list-disc space-y-1 pl-5 ">
                                            {analysis["key_symptoms"].map(
                                                lambda s: any, idx: any -> any {
                                                    return <li key={idx}>
                                                        {s}
                                                    </li>;
                                                }
                                            )}
                                        </ul>
                                    ) if ("key_symptoms" in analysis and analysis["key_symptoms"] and analysis["key_symptoms"].length > 0) else (
                                        <p className="text-slate-400">
                                            No key symptoms returned.
                                        </p>
                                    )}
                                </div>
                            </div>
                        ) if analysis else (
                            <p className="text-slate-500">
                                Run LLMAnalyzeDebug to see structured IssueAnalysis here.
                            </p>
                        )}
                    </div>
                </div>

                # -------- AdvicePlan card --------
                <div className="flex h-[320px] flex-col rounded-2xl border border-slate-200 bg-white p-4 text-slate-700">
                    <div className="mb-2 flex items-center justify-between">
                        <h2 className="font-semibold text-slate-800">
                            AdvicePlan
                        </h2>
                    <span className=" uppercase tracking-wide text-slate-400">
                            LLMAdviceDebug
                        </span>
                    </div>

                    <div className="mt-1 flex-1 overflow-y-auto">
                        {(
                            <div className="space-y-4">
                                <div>
                                    <p className="mb-1  font-medium text-slate-500">
                                        Overview
                                    </p>
                                    <p className="leading-relaxed text-slate-700">
                                        {advice["overview"] or "No overview returned."}
                                    </p>
                                </div>

                                <div>
                                    <p className="mb-1  font-medium text-slate-500">
                                        Recommended steps
                                    </p>
                                    {(
                                      <ol className=" space-y-2 pl-5">
                                            {advice["steps"].map(
                                                lambda step: any, idx: any -> any {
                                                return <li key={idx} className="text-slate-700">
                                                    {step}
                                                </li>;
                                                }
                                            )}
                                            </ol>

                                    ) if ("steps" in advice and advice["steps"] and advice["steps"].length > 0) else (
                                        <p className="text-slate-400">
                                            No steps returned.
                                        </p>
                                    )}
                                </div>

                                <div>
                                    <p className="mb-1 font-medium text-slate-500">
                                        Cautions
                                    </p>
                                    {(
                                        <ul className="list-disc space-y-1 pl-5  text-slate-700">
                                            {advice["cautions"].map(
                                                lambda c: any, idx: any -> any {
                                                    return <li key={idx}>
                                                        {c}
                                                    </li>;
                                                }
                                            )}
                                        </ul>
                                    ) if ("cautions" in advice and advice["cautions"] and advice["cautions"].length > 0) else (
                                        <p className="text-slate-400">
                                            No cautions returned.
                                        </p>
                                    )}
                                </div>
                            </div>
                        ) if advice else (
                            <p className=" text-slate-500">
                                Run LLMAdviceDebug to see the generated AdvicePlan here.
                            </p>
                        )}
                    </div>
                </div>
            </div>

        </div>;
    }
}
