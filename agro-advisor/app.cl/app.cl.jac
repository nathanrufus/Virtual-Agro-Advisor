cl import "../global.css";
cl import from "@jac-client/utils" {
    Router,
    Routes,
    Route
}

cl {

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
