cl import "../global.css";
cl import from "@jac-client/utils" {
    Router,
    Routes,
    Route
}

# cl import from .TopNav { TopNav }
# cl import from .PageShell { PageShell }

# cl import from .AdvisorPage { AdvisorPage }
cl {
    # Simple placeholders for now – you can replace with real pages later
    def AdminPage() -> any {
        return <div className="rounded-2xl border border-slate-200 bg-white p-6 text-sm text-slate-500">
            Admin screens coming soon…
        </div>;
    }

    def DebugPage() -> any {
        return <div className="rounded-2xl border border-slate-200 bg-white p-6 text-sm text-slate-500">
            Debug tools coming soon…
        </div>;
    }

    def app() -> any {
        return <Router>
            <div className="min-h-screen bg-[#F3F7F2] text-slate-900">
                <TopNav />
                <PageShell>
                    <Routes>
                        #  DEFAULT HOME → AdvisorPage 
                        <Route
                            path="/"
                            element={<AdvisorPage />}
                        />

                        #  Admin route 
                        <Route
                            path="/admin"
                            element={<AdminPage />}
                        />

                        #  Debug route 
                        <Route
                            path="/debug"
                            element={<DebugPage />}
                        />
                    </Routes>
                </PageShell>
            </div>
        </Router>;
    }
}
