cl import from "lucide-react" { Menu, X }

cl {
    def TopNav() -> any {
        let tabs = [
            {"id": "advisor", "label": "Advisor", "path": "/"},
            {"id": "admin", "label": "Manage", "path": "/admin"},
            {"id": "debug", "label": "Monitor", "path": "/debug"}
        ];

        let isLoggedIn = jacIsLoggedIn();
        let navigate = useNavigate();
        let [mobileOpen, setMobileOpen] = useState(False);

        def handleLogout(e: any) -> None {
            e.preventDefault();
            jacLogout();
            navigate("/login");
        }

        def toggleMobile(e: any) -> None {
            e.preventDefault();
            setMobileOpen(not mobileOpen);
        }

        return <header className="border-b border-lime-200 bg-lime-50 backdrop-blur fixed inset-x-0 top-0 z-50 ">
            <div className="mx-auto flex w-full  items-center justify-between px-6 py-3">
                # Brand 
                <div className="flex items-center gap-2">
                    <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-lime-500">
                        <span className="h-4 w-4 rounded-md bg-white/80" />
                    </div>
                    <span className="font-semibold text-slate-900">
                        Virtual Agro-Advisor
                    </span>
                </div>

                #  Desktop nav 
                <nav className="hidden md:flex items-center gap-3">
                    {isLoggedIn and tabs.map(lambda tab: any -> any {
                        return <Link
                            key={tab.id}
                            to={tab.path}
                            className="rounded-full px-4 py-1.5 font-medium text-slate-600 hover:bg-lime-50 transition"
                        >
                            {tab.label}
                        </Link>;
                    })}
                    <span className="h-5 w-px bg-slate-200" />

                    {isLoggedIn and (
                        <button
                            onClick={handleLogout}
                            className="rounded-full border border-emerald-600 bg-white px-3 py-1 font-medium text-slate-600 shadow-sm hover:bg-emerald-600 hover:text-white transition"
                        >
                            Logout
                        </button>
                    )}

                    {not isLoggedIn and (
                        <div className="flex items-center gap-2 ">
                            <Link
                                to="/login"
                                className="font-medium text-emerald-700 hover:text-emerald-900"
                            >
                                Login
                            </Link>
                            <span className="h-4 w-px bg-slate-300" />
                            <Link
                                to="/signup"
                                className="font-medium text-emerald-700 hover:text-emerald-900"
                            >
                                Sign up
                            </Link>
                        </div>
                    )}
                </nav>

                #  Mobile hamburger 
               <button
                    className="md:hidden inline-flex items-center justify-center rounded-full border border-slate-200 p-2 text-slate-700 hover:bg-slate-50 transition"
                    onClick={toggleMobile}
                    aria-label="Toggle navigation"
                >
                    { <X className="h-5 w-5" />
                        if mobileOpen else  <Menu className="h-5 w-5" />
                    }
                </button>

            </div>

            # Mobile menu dropdown
            {mobileOpen and (
                <div className="md:hidden border-t border-slate-200 bg-white">
                    <div className="mx-auto flex w-full max-w-6xl flex-col gap-2 px-4 py-3">
                        {isLoggedIn and (
                            <div className="flex flex-col gap-1">
                                {tabs.map(lambda tab: any -> any {
                                    return <Link
                                        key={tab.id}
                                        to={tab.path}
                                        className="rounded-full px-3 py-1.5 font-medium text-slate-600 hover:bg-lime-50 transition"
                                        onClick={lambda _e: any -> None { setMobileOpen(False); }}
                                    >
                                        {tab.label}
                                    </Link>;
                                })}
                            </div>
                        )}

                        {isLoggedIn and (
                            <button
                                onClick={handleLogout}
                                className="mt-1 rounded-full border border-emerald-600 bg-white px-3 py-1 font-medium text-slate-600 shadow-sm hover:bg-emerald-600 hover:text-white transition"
                            >
                                Logout
                            </button>
                        )}

                        {not isLoggedIn and (
                            <div className="mt-1 flex flex-col gap-1">
                                <Link
                                    to="/login"
                                    className="rounded-full px-3 py-1.5 font-medium text-emerald-700 hover:bg-emerald-50 hover:text-emerald-900 transition"
                                    onClick={lambda _e: any -> None { setMobileOpen(False); }}
                                >
                                    Login
                                </Link>
                                <Link
                                    to="/signup"
                                    className="rounded-full px-3 py-1.5 font-medium text-emerald-700 hover:bg-emerald-50 hover:text-emerald-900 transition"
                                    onClick={lambda _e: any -> None { setMobileOpen(False); }}
                                >
                                    Sign up
                                </Link>
                            </div>
                        )}
                    </div>
                </div>
            )}
        </header>;
    }
}
