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
        useEffect(lambda -> None {
            # ----- Page title -----
            document.title = "Virtual Agro-Advisor";

            # ----- Favicon -----
            link = document.querySelector("link[rel='icon']");
            if not link {
                link = document.createElement("link");
                link.rel = "icon";
                document.head.appendChild(link);
            }
            # Point this to your logo in /assets
            link.href = "/static/assets/agro-logo.png";

            # ----- Mobile viewport meta -----
            meta = document.querySelector("meta[name='viewport']");
            if not meta {
                meta = document.createElement("meta");
                meta.name = "viewport";
                meta.content = "width=device-width, initial-scale=1.0";
                document.head.appendChild(meta);
            } else {
                meta.setAttribute("content", "width=device-width, initial-scale=1.0");
            }
        }, []);

        return <Router>
            <div className="min-h-screen bg-[#F3F7F2] text-slate-900 text-sm sm:text-base md:text-lg">
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
