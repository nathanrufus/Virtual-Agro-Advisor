"""Main entry point for agroAdvisor."""

include backend.models;
include intergrations;
include backend.helpers;
include backend.sessions;
include backend.cache;
include backend.debug;
include backend.advisor;

cl import "./global.css";
cl import from react { useEffect }
cl import from "@jac/runtime" {
    Router,
    Routes,
    Route,
    Navigate,
    jacIsLoggedIn,
    jacLogin,
    jacLogout,
    jacSignup
}
cl import from .components.TopNav { TopNav }
cl import from .components.PageShell { PageShell }
cl import from .components.AdvisorPage { AdvisorPage }
cl import from .components.AdminPage { AdminPage }
cl import from .components.DebugPage { DebugPage }
cl import from .components.CacheDetail { CacheDetailPage }
cl import from .components.AuthPages { LoginPage, SignupPage }

cl {
    def ProtectedRoute(props: any) -> any {
        isLoggedIn = jacIsLoggedIn();
        if isLoggedIn {
            return props.element;
        }
        return <Navigate to="/login" replace={True} />;
    }

    def:pub app() -> any {
        useEffect(lambda -> None {
            document.title = "Virtual Agro-Advisor";

            link = document.querySelector("link[rel='icon']");
            if not link {
                link = document.createElement("link");
                link.rel = "icon";
                document.head.appendChild(link);
            }
            link.href = "/static/assets/agro-logo.png";

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
                        <Route path="/login" element={<LoginPage />} />
                        <Route path="/signup" element={<SignupPage />} />
                        <Route path="/" element={<ProtectedRoute element={<AdvisorPage />} />} />
                        <Route path="/admin" element={<ProtectedRoute element={<AdminPage />} />} />
                        <Route path="/debug" element={<ProtectedRoute element={<DebugPage />} />} />
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