

cl {
    def TopNav() -> any {
        let tabs = [
            {"id": "advisor", "label": "Advisor", "path": "/"},
            {"id": "admin", "label": "Manage", "path": "/admin"},
            {"id": "debug", "label": "Debug", "path": "/debug"}
        ];

        let isLoggedIn = jacIsLoggedIn();
        let navigate = useNavigate();

        def handleLogout(e: any) -> None {
            e.preventDefault();
            jacLogout();
            navigate("/login");
        }

        return <header className="border-b border-slate-200 bg-white/80 backdrop-blur">
            <div className="mx-auto flex max-w-6xl items-center justify-between px-4 py-3">
                <div className="flex items-center gap-2">
                    <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-lime-500">
                        <span className="h-4 w-4 rounded-md bg-white/80" />
                    </div>
                    <span className="text-sm font-semibold text-slate-900">
                        Virtual Agro-Advisor
                    </span>
                </div>

                <nav className="flex items-center gap-3 text-sm">
                    {isLoggedIn and tabs.map(lambda tab: any -> any {
                        return <Link
                            key={tab.id}
                            to={tab.path}
                            className="rounded-full px-4 py-1.5 text-xs font-medium text-slate-600 hover:bg-lime-50 transition"
                        >
                            {tab.label}
                        </Link>;
                    })}
                    <span className="h-5 w-px bg-slate-200" />

                    {isLoggedIn and (
                        <button
                            onClick={handleLogout}
                            className="rounded-full border border-emerald-600 bg-white px-3 py-1 text-xs font-medium text-slate-600 shadow-sm hover:bg-emerald-600 hover:text-white transition"
                        >
                            Logout
                        </button>
                    )}

                    {not isLoggedIn and (
                        <div className="flex items-center gap-2 text-xs">
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
            </div>
        </header>;
    }
}
