cl import "../global.css";

cl import from "@jac-client/utils" {
    Router,
    Routes,
    Link,
    Route,
    Navigate,
    jacIsLoggedIn,
    jacLogin,
    jacLogout,
    jacSignup
}

cl {

    # Wrapper to guard routes that require login
    def ProtectedRoute(props: any) -> any {
        let isLoggedIn = jacIsLoggedIn();
        if isLoggedIn {
            return props.element;
        }
        return <Navigate to="/login" replace={True} />;
    }

    def app() -> any {
        return <Router>
            <div className="min-h-screen bg-[#F3F7F2] text-slate-900">
                <TopNav />

                <PageShell>
                    <Routes>
                        # Public auth routes
                        <Route
                            path="/login"
                            element={<LoginPage />}
                        />
                        <Route
                            path="/signup"
                            element={<SignupPage />}
                        />

                        # DEFAULT HOME → AdvisorPage (protected)
                        <Route
                            path="/"
                            element={<ProtectedRoute element={<AdvisorPage />} />}
                        />

                        # Admin route (protected)
                        <Route
                            path="/admin"
                            element={<ProtectedRoute element={<AdminPage />} />}
                        />

                        # Debug route (protected)
                        <Route
                            path="/debug"
                            element={<ProtectedRoute element={<DebugPage />} />}
                        />

                        # Cache detail route (protected)
                        <Route
                            path="/admin/cache/:encodedKey"
                            element={<ProtectedRoute element={<CacheDetailPage />} />}
                        />
                    </Routes>
                </PageShell>
            </div>
        </Router>;
    }
}
