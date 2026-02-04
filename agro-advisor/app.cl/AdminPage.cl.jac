cl import from react {  useEffect }
cl import from "date-fns" { subDays, format }

cl {

    def extractReports(res: any) -> list[any, ...] {
        if not res {
            return [];
        }
        if not ("reports" in res) or not res["reports"] {
            return [];
        }

        let reports = res["reports"];

        # Case 1: walker reported a single list, so reports[0] is the real list
        if reports.length == 1 and Array.isArray(reports[0]) {
            return reports[0];
        }

        # Case 2: reports already contains plain items
        return reports;
    }


    def computeStats(
        sessionsList: list[any, ...],
        adviceList: list[any, ...]
    ) -> any {
        let stats = {
            "totalSessions": sessionsList.length,
            "adviceEntries": adviceList.length,
            "latestSessionTime": ""
        };

        for i = 0 to i < sessionsList.length by i = i + 1 {
            let sess = sessionsList[i];
            let t = sess["last_active_at"] or sess["created_at"] or "";
            if not t {
                continue;
            }
            if not stats["latestSessionTime"] or t > stats["latestSessionTime"] {
                stats["latestSessionTime"] = t;
            }
        }

        return stats;
    }

    def formatShortDatetime(dt: str) -> str {
        if not dt {
            return "";
        }
        # Show just "YYYY-MM-DD HH:MM"
        if dt.length >= 16 {
            return dt.slice(0, 16);
        }
        return dt;
    }

    def parseCacheKey(cache_key: str) -> any {
        if not cache_key {
            return {
                "crop": "",
                "region": "",
                "lang": "",
                "problem": ""
            };
        }

        let parts = cache_key.split("|");
        let crop = parts[0] if parts.length > 0 else "";
        let region = parts[1] if parts.length > 1 else "";
        let lang = parts[2] if parts.length > 2 else "";
        let problem = parts[parts.length - 1] if parts.length > 0 else "";

        return {
            "crop": crop,
            "region": region,
            "lang": lang,
            "problem": problem
        };
    }

    def makeCutoffString(days: int) -> str {
        let nowMs = Date.now();                 # current time in ms
        let cutoffDate = subDays(nowMs, days);  # now - N days
        let cutoffStr = format(
            cutoffDate,
            "yyyy-MM-dd HH:mm:ss"
        );

        return cutoffStr;
    }



    def AdminPage() -> any {
        let [loading, setLoading] = useState(False);
        let [error, setError] = useState("");
        let [flash, setFlash] = useState("");

        let [sessionRows, setSessionRows] = useState([]);
        let [adviceRows, setAdviceRows] = useState([]);
        let [stats, setStats] = useState({
            "totalSessions": 0,
            "adviceEntries": 0,
            "latestSessionTime": ""
        });

        let [cleaningSessions, setCleaningSessions] = useState(False);
        let [clearingCache, setClearingCache] = useState(False);

        let navigate = useNavigate();

        async def loadAdminData() -> None {
            setLoading(True);
            setError("");
            setFlash("");

            try {
                let sessionsRes = await root spawn GetAllSessions();
                let adviceRes = await root spawn GetAllAdviceCache();

                let sessionsList = extractReports(sessionsRes);
                let adviceList = extractReports(adviceRes);

                setSessionRows(sessionsList);
                setAdviceRows(adviceList);
                setStats(computeStats(sessionsList, adviceList));
            } except exception as err {
                console.error("AdminPage loadAdminData exception:", err);
                setError("Failed to load admin data.");
            } finally {
                setLoading(False);
            }
        }

        async def handleCleanupSessions() -> None {
            let days = 7;
            if not window.confirm(
                "Delete sessions  This cannot be undone."
            ) {
                return;
            }

            setCleaningSessions(True);
            setError("");
            setFlash("");

            try {
                let cutoff = makeCutoffString(days);
                let res = await root spawn CleanupOldSessions(
                    cutoff="ALL"
                );
                let deleted = 0;
                if res and "reports" in res and res.reports.length > 0 {
                    let r0 = res.reports[0];
                    if "deleted_count" in r0 {
                        deleted = r0.deleted_count;
                    }
                }

                let suffix = "";
                if deleted != 1 {
                    suffix = "s";
                }

                setFlash(
                    "Removed " + deleted + " session" + suffix +
                    " older than " + days + " days."
                );

                await loadAdminData();
            } except exception as err {
                console.error("handleCleanupSessions exception:", err);
                setError("Failed to cleanup sessions.");
            } finally {
                setCleaningSessions(False);
            }
        }

        async def handleClearCache() -> None {
            if not window.confirm(
                "Clear all advice cache entries? This cannot be undone."
            ) {
                return;
            }

            setClearingCache(True);
            setError("");
            setFlash("");

            try {
                let res = await root spawn ClearAdviceCache();

                let deleted = 0;
                if res and "reports" in res and res.reports.length > 0 {
                    let r0 = res.reports[0];
                    if "deleted_count" in r0 {
                        deleted = r0.deleted_count;
                    }
                }

                let suffix = "ies";
                if deleted == 1 {
                    suffix = "y";
                }

                setFlash(
                    "Cleared " + deleted + " advice cache entr" + suffix + "."
                );

                await loadAdminData();
            } except exception as err {
                console.error("handleClearCache exception:", err);
                setError("Failed to clear advice cache.");
            } finally {
                setClearingCache(False);
            }
        }

        def handleAdviceRowClick(entry: any) -> None {
            let key = entry["cache_key"] or "";
            if not key {
                return;
            }

            let encoded = encodeURIComponent(key);
            navigate("/admin/cache/" + encoded);
        }

        # Load once on mount
        useEffect(
            lambda -> None {
                loadAdminData();
            },
            []
        );

        return <div className="space-y-6">
            <div className="flex flex-wrap items-center justify-between gap-3">
                <div>
                    <h1 className="text-xl font-semibold text-slate-900">
                        Manage dashboard
                    </h1>
                    <p className="mt-1 text-slate-500">
                        Inspect sessions and advice cache, and run maintenance tasks.
                    </p>
                </div>

                <div className="flex flex-wrap gap-2">
                    <button
                        className="rounded-lg border border-slate-300 px-3 py-1 font-medium hover:bg-slate-50 disabled:opacity-60"
                        disabled={loading}
                        onClick={lambda e: any -> None { loadAdminData(); }}
                    >
                        {"Refreshing…" if loading else "Refresh"}
                    </button>

                    <button
                        className="rounded-lg border border-amber-300 bg-amber-50 px-3 py-1 font-medium text-amber-900 hover:bg-amber-100 disabled:opacity-60"
                        disabled={cleaningSessions}
                        onClick={lambda e: any -> None { handleCleanupSessions(); }}
                    >
                        {"Cleaning sessions…" if cleaningSessions else "Cleanup old sessions"}
                    </button>

                    <button
                        className="rounded-lg border border-rose-300 bg-rose-50 px-3 py-1 font-medium text-rose-900 hover:bg-rose-100 disabled:opacity-60"
                        disabled={clearingCache}
                        onClick={lambda e: any -> None { handleClearCache(); }}
                    >
                        {"clear advice cache" if clearingCache else "clear advice cache"}
                    </button>
                </div>
            </div>

            {flash and (
                <div className="rounded-2xl border border-emerald-200 bg-emerald-50 px-4 py-2 text-emerald-800">
                    {flash}
                </div>
            )}

            {error and (
                <div className="rounded-2xl border border-red-200 bg-red-50 px-4 py-2 text-red-700">
                    {error}
                </div>
            )}

            <div className="grid gap-4 md:grid-cols-3">
                <div className="rounded-2xl border border-slate-200 bg-white p-4">
                    <p className="text-slate-500">
                        Total sessions
                    </p>
                    <p className="mt-1 text-xl font-semibold text-slate-900">
                        {stats["totalSessions"]}
                    </p>
                </div>

                <div className="rounded-2xl border border-slate-200 bg-white p-4">
                    <p className="text-slate-500">
                        Advice cache entries
                    </p>
                    <p className="mt-1 text-xl font-semibold text-slate-900">
                        {stats["adviceEntries"]}
                    </p>
                </div>

                # <div className="rounded-2xl border border-slate-200 bg-white p-4">
                #     <p className="text-slate-500">
                #         Latest session activity
                #     </p>
                #     <p className="mt-1 font-medium text-slate-900">
                #         {formatShortDatetime(stats["latestSessionTime"]) if stats["latestSessionTime"] else "_"}
                #     </p>
                # </div>
            </div>

            <div className="grid gap-4 lg:grid-cols-2">
                # Sessions table 
                <div className="rounded-2xl border border-slate-200 bg-white p-4 text-slate-700">
                    <div className="mb-3 flex items-center justify-between">
                        <h2 className="font-semibold text-slate-800">
                            Sessions
                        </h2>
                        <span className="text-[10px] uppercase tracking-wide text-slate-400">
                            GetAllSessions
                        </span>
                    </div>
                    {( 
                        <div className="overflow-x-auto">
                            <table className="min-w-full text-left ">
                                <thead className="border-b border-slate-100 text-[10px] uppercase tracking-wide text-slate-400">
                                    <tr>
                                        <th className="py-1 pr-3">Session ID</th>
                                        <th className="py-1 pr-3">Lang</th>
                                        <th className="py-1 pr-3">Created</th>
                                        <th className="py-1">Last active</th>
                                    </tr>
                                </thead>
                                <tbody className="">
                                    {sessionRows.map(
                                        lambda sess: any, idx: any -> any {
                                            return <tr
                                                key={idx}
                                                className="border-b border-slate-50 last:border-0"
                                            >
                                                <td className="py-1 pr-3 font-mono">
                                                    {sess["session_id"] or "—"}
                                                </td>
                                                <td className="py-1 pr-3">
                                                    {sess["lang"] or "—"}
                                                </td>
                                                <td className="py-1 pr-3">
                                                    {formatShortDatetime(sess["created_at"] or "")}
                                                </td>
                                                <td className="py-1">
                                                    {formatShortDatetime(sess["last_active_at"] or "")}
                                                </td>
                                            </tr>;
                                        }
                                    )}
                                </tbody>

                            </table>
                            {sessionRows.length > 10 and (
                                <p className="mt-2 text-[10px] text-slate-400">
                                    Showing first 10 sessions.
                                </p>
                            )}
                        </div>
                    ) if sessionRows and sessionRows.length > 0 else (
                        <p className="text-slate-500">
                            No sessions yet.
                        </p>
                    )}
                </div>

                # Advice cache table 
                <div className="rounded-2xl border border-slate-200 bg-white p-4 text-slate-700">
                    <div className="mb-3 flex items-center justify-between">
                        <h2 className="font-semibold text-slate-800">
                            Advice cache
                        </h2>
                        <span className="text-[10px] uppercase tracking-wide text-slate-400">
                            GetAllAdviceCache
                        </span>
                    </div>
                    {( 
                        <div className="overflow-x-auto">
                            <table className="min-w-full text-left ">
                                <thead className="border-b border-slate-100 text-[10px] uppercase tracking-wide text-slate-400">
                                    <tr>
                                        <th className="py-1 pr-3">Crop</th>
                                        <th className="py-1 pr-3">Region</th>
                                        <th className="py-1 pr-3">Usage</th>
                                        <th className="py-1">Last used</th>
                                    </tr>
                                </thead>
                                <tbody className="">
                                    {adviceRows.map(
                                        lambda entry: any, idx: any -> any {
                                            let meta = parseCacheKey(entry["cache_key"] or "");
                                            return <tr
                                                key={idx}
                                                className="cursor-pointer border-b border-slate-50 last:border-0 hover:bg-slate-50"
                                                onClick={lambda e: any -> None { handleAdviceRowClick(entry); }}
                                            >
                                                <td className="py-1 pr-3">
                                                    {meta["crop"] or "—"}
                                                </td>
                                                <td className="py-1 pr-3">
                                                    {meta["region"] or "—"}
                                                </td>
                                                <td className="py-1 pr-3">
                                                    {entry["usage_count"] or 0}
                                                </td>
                                                <td className="py-1">
                                                    {formatShortDatetime(entry["last_used_at"] or "")}
                                                </td>
                                            </tr>;
                                        }
                                    )}
                                </tbody>

                            </table>
                            {adviceRows.length > 10 and (
                                <p className="mt-2 text-[10px] text-slate-400">
                                    Showing first 10 advice cache entries.
                                </p>
                            )}
                        </div>
                    ) if adviceRows and adviceRows.length > 0 else (
                        <p className="text-slate-500">
                            No advice cache entries yet.
                        </p>
                    )}
                </div>
            </div>
        </div>;
    }
}
