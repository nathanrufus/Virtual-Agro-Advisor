cl import from "react-router-dom" { useParams, useNavigate }

cl {

    def CacheDetailPage() -> any {
        let [loading, setLoading] = useState(True);
        let [error, setError] = useState("");
        let [cache, setCache] = useState(None);

        let navigate = useNavigate();
        let params = useParams();

        let encodedKey = params.encodedKey or "";
        let cacheKey = "";

        if encodedKey {
            try {
                cacheKey = decodeURIComponent(encodedKey);
            } except exception as err {
                console.error("Failed to decode cache key:", err);
                cacheKey = encodedKey;
            }
        }

        useEffect(
            lambda -> None {
                async def fetchDetail() -> None {
                    setLoading(True);
                    setError("");
                    setCache(None);

                    if not cacheKey {
                        setError("Missing cache key in URL.");
                        setLoading(False);
                        return;
                    }

                    try {
                        let res = await root spawn GetAdviceCacheDetail(
                            cache_key=cacheKey
                        );
                        console.log("GetAdviceCacheDetail result:", res);

                        let detail = None;
                        if res and "reports" in res and res.reports.length > 0 {
                            detail = res.reports[res.reports.length - 1];
                        }

                        if detail and detail.ok {
                            setCache(detail);
                        } else {
                            let msg = "Failed to load cache detail.";
                            if detail and detail.error {
                                msg = detail.error;
                            }
                            setError(msg);
                        }
                    } except exception as err {
                        console.error("CacheDetailPage fetchDetail exception:", err);
                        setError("Failed to load cache detail.");
                    } finally {
                        setLoading(False);
                    }
                }

                fetchDetail();
            },
            [cacheKey]
        );

        def handleBackClick(e: any) -> None {
            e.preventDefault();
            navigate("/admin");
        }

        let titleKey = cacheKey;
        if not titleKey {
            titleKey = "(no key)";
        }

        # Prepare view pieces
        let parsed = {};
        let advice = {};
        let meta = {};
        let session = None;

        if cache {
            parsed = cache.parsed or {};
            advice = cache.advice or {};
            meta = cache.meta or {};
            session = cache.session or None;
        }

        let crop = parsed["crop"] or "";
        let region = parsed["location"] or parsed["region"] or "";
        let lang = parsed["lang"] or "";
        let problem = parsed["problem_preview"] or parsed["problem"] or "";

        let created_at = meta["created_at"] or "";
        let last_used_at = meta["last_used_at"] or "";
        let usage_count = meta["usage_count"] or 0;

        let session_id = "";
        let session_lang = "";
        let session_created = "";
        let session_last_active = "";
        let session_history = "";

        if session {
            session_id = session["session_id"] or "";
            session_lang = session["lang"] or "";
            session_created = session["created_at"] or "";
            session_last_active = session["last_active_at"] or "";
            session_history = session["history"] or "";
        }

        return <div className="space-y-4">
            <div className="flex items-center justify-between gap-3">
                <div>
                    <h1 className="text-xl font-semibold text-emerald-700">
                        Advice cache detail
                    </h1>
                    <p className="mt-1 text-slate-500">
                        Inspect a single advice cache entry, its session, and full plan.
                    </p>
                </div>

                <button
                    className=" rounded-full border border-emerald-200 px-4 py-1.5 font-medium text-emerald-700 hover:bg-emerald-50 hover:border-emerald-300 transition"
                    onClick={handleBackClick}
                >
                    ← Back to manage
                </button>
            </div>

            {loading and (
                <div className="rounded-2xl border border-slate-200 bg-white p-4 text-slate-500">
                    Loading cache details…
                </div>
            )}

            {not loading and error and (
                <div className="rounded-2xl border border-red-200 bg-red-50 p-4 text-red-700">
                    {error}
                </div>
            )}

            {not loading and not error and cache and (
                <div className="space-y-4">
                    # Top meta
                    <div className="rounded-2xl border border-emerald-100 bg-white p-4 text-slate-700 shadow-sm">
                        <div className="grid gap-3 md:grid-cols-2">
                            <div>
                                <p className="uppercase tracking-wide text-emerald-700">
                                    Crop
                                </p>
                                <p className="mt-1 font-medium text-slate-900">
                                    {crop or "—"}
                                </p>
                            </div>
                            <div>
                                <p className="uppercase tracking-wide text-emerald-700">
                                    Region
                                </p>
                                <p className="mt-1 font-medium text-slate-900">
                                    {region or "—"}
                                </p>
                            </div>
                            <div>
                                <p className="uppercase tracking-wide text-emerald-700">
                                    Language
                                </p>
                                <p className="mt-1 font-medium text-slate-900">
                                    {lang or "—"}
                                </p>
                            </div>
                        </div>

                        <div className="mt-3 flex flex-wrap gap-4 text-slate-600">
                            <span>
                                <span className="font-semibold text-emerald-700">Created:</span> {created_at or "—"}
                            </span>
                            <span>
                                <span className="font-semibold text-emerald-700">Last used:</span> {last_used_at or "—"}
                            </span>
                            <span>
                                <span className="font-semibold text-emerald-700">Usage count:</span> {usage_count}
                            </span>
                        </div>
                    </div>


                    # Advice content
                    <div className="flex flex-col gap-4 md:flex-row">
                        # Overview + steps card 
                        <div className="flex-1 rounded-2xl border border-emerald-100 bg-white p-4 text-slate-800 shadow-sm">
                            <div className="space-y-3">
                                <div>
                                    <p className="mb-1 font-semibold uppercase tracking-wide text-emerald-700">
                                        Overview
                                    </p>
                                    <p className="leading-relaxed">
                                        {advice.overview or "—"}
                                    </p>
                                </div>

                                {advice.steps && advice.steps.length > 0 and (
                                    <div>
                                        <p className="mb-1 font-semibold uppercase tracking-wide text-emerald-700">
                                            Steps
                                        </p>
                                        <ol className="space-y-1 pl-5">
                                            {advice.steps.map(
                                                lambda step: any, idx: any -> any {
                                                    return <li key={idx}>{step}</li>;
                                                }
                                            )}
                                        </ol>
                                    </div>
                                )}
                            </div>
                        </div>

                    #   Cautions card (separate) 
                        {advice.cautions && advice.cautions.length > 0 and (
                            <div className="flex-1 rounded-xl border border-amber-100 bg-amber-50 p-3">
                                <p className="mb-1 font-semibold uppercase tracking-wide text-amber-800">
                                    Cautions
                                </p>
                                <ul className="list-disc space-y-1 pl-5 text-amber-900">
                                    {advice.cautions.map(
                                        lambda c: any, idx: any -> any {
                                            return <li key={idx}>{c}</li>;
                                        }
                                    )}
                                </ul>
                            </div>
                        )}
                    </div>

                </div>
            )}
        </div>;
    }
}
