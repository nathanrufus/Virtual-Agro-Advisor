cl import from "@jac-client/utils" { Link }

cl {
    def TopNav() -> any {
        let tabs = [
            {"id": "advisor", "label": "Advisor", "path": "/"},
            {"id": "admin", "label": "Admin", "path": "/admin"},
            {"id": "debug", "label": "Debug", "path": "/debug"}
        ];

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

                <nav className="flex items-center gap-2 text-sm">
                    {tabs.map(lambda tab: any -> any {
                        return <Link
                            key={tab.id}
                            to={tab.path}
                            className="rounded-full px-4 py-1.5 text-xs font-medium text-slate-600 hover:bg-lime-50 transition"
                        >
                            {tab.label}
                        </Link>;
                    })}
                </nav>
            </div>
        </header>;
    }
}
