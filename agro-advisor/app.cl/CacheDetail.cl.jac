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
                    <h1 className="text-xl font-semibold text-slate-900">
                        Advice cache detail
                    </h1>
                    <p className="mt-1 text-xs text-slate-500">
                        Inspect a single advice cache entry, its session, and full plan.
                    </p>
                </div>

                <button
                    className="rounded-full border border-slate-300 px-4 py-1.5 text-xs font-medium text-slate-700 hover:bg-slate-50"
                    onClick={handleBackClick}
                >
                    ← Back to manage
                </button>
            </div>

            <div className="rounded-2xl border border-slate-200 bg-white p-4 text-[11px] text-slate-600">
                <p className="mb-1 font-semibold text-slate-800">
                    Cache key
                </p>
                <p className="font-mono break-all">
                    {titleKey}
                </p>
            </div>

            {loading and (
                <div className="rounded-2xl border border-slate-200 bg-white p-4 text-sm text-slate-500">
                    Loading cache details…
                </div>
            )}

            {not loading and error and (
                <div className="rounded-2xl border border-red-200 bg-red-50 p-4 text-xs text-red-700">
                    {error}
                </div>
            )}

            {not loading and not error and cache and (
                <div className="space-y-4">
                    # Top meta
                    <div className="rounded-2xl border border-slate-200 bg-white p-4 text-xs text-slate-700">
                        <div className="grid gap-3 md:grid-cols-2">
                            <div>
                                <p className="text-[10px] uppercase tracking-wide text-slate-400">
                                    Crop
                                </p>
                                <p className="mt-1 text-sm font-medium text-slate-900">
                                    {crop or "—"}
                                </p>
                            </div>
                            <div>
                                <p className="text-[10px] uppercase tracking-wide text-slate-400">
                                    Region
                                </p>
                                <p className="mt-1 text-sm font-medium text-slate-900">
                                    {region or "—"}
                                </p>
                            </div>
                            <div>
                                <p className="text-[10px] uppercase tracking-wide text-slate-400">
                                    Language
                                </p>
                                <p className="mt-1 text-sm font-medium text-slate-900">
                                    {lang or "—"}
                                </p>
                            </div>
                            <div>
                                <p className="text-[10px] uppercase tracking-wide text-slate-400">
                                    Problem (preview)
                                </p>
                                <p className="mt-1 text-sm font-medium text-slate-900 line-clamp-3">
                                    {problem or "—"}
                                </p>
                            </div>
                        </div>

                        <div className="mt-3 flex flex-wrap gap-4 text-[11px] text-slate-600">
                            <span>
                                <span className="font-semibold">Created:</span> {created_at or "—"}
                            </span>
                            <span>
                                <span className="font-semibold">Last used:</span> {last_used_at or "—"}
                            </span>
                            <span>
                                <span className="font-semibold">Usage count:</span> {usage_count}
                            </span>
                        </div>
                    </div>

                    # Session info
                    {session and (
                        <div className="rounded-2xl border border-slate-200 bg-slate-50 p-4 text-xs text-slate-700">
                            <p className="mb-2 text-[11px] font-semibold uppercase tracking-wide text-slate-600">
                                Owning session
                            </p>
                            <div className="grid gap-2 md:grid-cols-2">
                                <div>
                                    <p className="text-[10px] uppercase tracking-wide text-slate-400">
                                        Session ID
                                    </p>
                                    <p className="mt-1 font-mono text-[11px]">
                                        {session_id or "—"}
                                    </p>
                                </div>
                                <div>
                                    <p className="text-[10px] uppercase tracking-wide text-slate-400">
                                        Lang
                                    </p>
                                    <p className="mt-1">
                                        {session_lang or "—"}
                                    </p>
                                </div>
                                <div>
                                    <p className="text-[10px] uppercase tracking-wide text-slate-400">
                                        Created
                                    </p>
                                    <p className="mt-1">
                                        {session_created or "—"}
                                    </p>
                                </div>
                                <div>
                                    <p className="text-[10px] uppercase tracking-wide text-slate-400">
                                        Last active
                                    </p>
                                    <p className="mt-1">
                                        {session_last_active or "—"}
                                    </p>
                                </div>
                            </div>

                            {session_history and (
                                <div className="mt-3">
                                    <p className="mb-1 text-[10px] font-semibold uppercase tracking-wide text-slate-500">
                                        Recent history
                                    </p>
                                    <pre className="max-h-40 overflow-y-auto whitespace-pre-wrap rounded-lg bg-white px-2 py-1 text-[10px] text-slate-700">
                                        {session_history}
                                    </pre>
                                </div>
                            )}
                        </div>
                    )}

                    # Advice content
                    <div className="rounded-2xl border border-slate-200 bg-white p-4 text-sm text-slate-800">
                        <div className="space-y-3">
                            <div>
                                <p className="mb-1 text-xs font-semibold uppercase tracking-wide text-slate-500">
                                    Overview
                                </p>
                                <p className="leading-relaxed">
                                    {advice.overview or "—"}
                                </p>
                            </div>

                            {advice.steps && advice.steps.length > 0 and (
                                <div>
                                    <p className="mb-1 text-xs font-semibold uppercase tracking-wide text-slate-500">
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

                            {advice.cautions && advice.cautions.length > 0 and (
                                <div className="rounded-xl border border-amber-100 bg-amber-50 p-3">
                                    <p className="mb-1 text-xs font-semibold uppercase tracking-wide text-amber-800">
                                        Cautions
                                    </p>
                                    <ul className="list-disc space-y-1 pl-5 text-[11px] text-amber-900">
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
                </div>
            )}
        </div>;
    }
}
