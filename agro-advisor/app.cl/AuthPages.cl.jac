

cl {

    def LoginPage() -> any {
        let [email, setEmail] = useState("");
        let [password, setPassword] = useState("");
        let [error, setError] = useState("");
        let [loading, setLoading] = useState(False);

        let navigate = useNavigate();

        async def handleLogin(e: any) -> None {
            e.preventDefault();
            setError("");

            if not email or not password {
                setError("Please fill in all fields.");
                return;
            }

            setLoading(True);
            try {
                let ok = await jacLogin(email, password);
                if ok {
                    navigate("/");
                } else {
                    setError("Invalid email or password.");
                }
            } except exception as err {
                console.error("[LoginPage] Login error:", err);
                setError("Login failed. Please try again.");
            } finally {
                setLoading(False);
            }
        }

        let buttonLabel = "Login";
        if loading {
            buttonLabel = "Logging in…";
        }

        return <div className="min-h-screen bg-[#F3F7F2] flex items-center justify-center px-4">
            <div className="w-full max-w-md rounded-2xl border border-lime-100 bg-white p-6 shadow-sm">
                <h1 className="text-2xl font-semibold text-slate-900">
                    Welcome back
                </h1>
                <p className="mt-1 text-slate-500">
                    Log in to use the Virtual Agro-Advisor and see your past advice sessions.
                </p>

                {error and (
                    <div className="mt-4 rounded-lg border border-red-200 bg-red-50 px-3 py-2 text-red-700">
                        {error}
                    </div>
                )}

                <form onSubmit={handleLogin} className="mt-4 space-y-4">
                    <div className="space-y-1">
                        <label className="font-medium text-slate-700">
                            Email
                        </label>
                        <input
                            type="email"
                            value={email}
                            onChange={lambda e: any -> None { setEmail(e.target.value); }}
                            placeholder="you@example.com"
                            className="w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 outline-none placeholder:text-slate-400 focus:border-emerald-600 focus:bg-white focus:ring-1 focus:ring-emerald-600"
                        />
                    </div>

                    <div className="space-y-1">
                        <label className="font-medium text-slate-700">
                            Password
                        </label>
                        <input
                            type="password"
                            value={password}
                            onChange={lambda e: any -> None { setPassword(e.target.value); }}
                            placeholder="••••••••"
                            className="w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 outline-none placeholder:text-slate-400 focus:border-emerald-600 focus:bg-white focus:ring-1 focus:ring-emerald-600"
                        />
                    </div>

                    <button
                        type="submit"
                        disabled={loading}
                        className="mt-2 inline-flex w-full items-center justify-center rounded-full bg-green-500 px-4 py-2.5 font-semibold text-white shadow-md hover:bg-emerald-800 disabled:opacity-60 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:ring-offset-1"
                    >
                        {buttonLabel}
                    </button>
                </form>

                <p className="mt-4 text-center text-slate-500">
                    Need an account?{" "}
                    <Link
                        to="/signup"
                        className="font-semibold text-emerald-700 hover:text-emerald-900"
                    >
                        Sign up
                    </Link>
                </p>
            </div>
        </div>;
    }


    def SignupPage() -> any {
        let [email, setEmail] = useState("");
        let [password, setPassword] = useState("");
        let [confirmPassword, setConfirmPassword] = useState("");
        let [error, setError] = useState("");
        let [loading, setLoading] = useState(False);

        let navigate = useNavigate();

        # If already logged in, no need to sign up again
        if jacIsLoggedIn() {
            return <Navigate to="/" replace={True} />;
        }

        async def handleSignup(e: any) -> None {
            e.preventDefault();
            setError("");

            if not email or not password or not confirmPassword {
                setError("Please fill in all fields.");
                return;
            }

            if password != confirmPassword {
                setError("Passwords do not match.");
                return;
            }

            setLoading(True);
            try {
                let result = await jacSignup(email, password);
                if result and result["success"] {
                    # After successful signup, go to login so user can log in
                    navigate("/login");
                } else {
                    let errMsg = "Signup failed. Please try again.";
                    if result and "error" in result and result["error"] {
                        errMsg = result["error"];
                    }
                    setError(errMsg);
                }
            } except exception as err {
                console.error("[SignupPage] Signup error:", err);
                setError("Signup failed. Please try again.");
            } finally {
                setLoading(False);
            }
        }

        let buttonLabel = "Create account";
        if loading {
            buttonLabel = "Creating account…";
        }

        return <div className="min-h-screen bg-[#F3F7F2] flex items-center justify-center px-4">
            <div className="w-full max-w-md rounded-2xl border border-lime-100 bg-white p-6 shadow-sm">
                <h1 className="text-2xl font-semibold text-slate-900">
                    Create your account
                </h1>
                <p className="mt-1 text-slate-500">
                    Sign up once, and your sessions and advice history will be saved under your login.
                </p>

                {error and (
                    <div className="mt-4 rounded-lg border border-red-200 bg-red-50 px-3 py-2 text-red-700">
                        {error}
                    </div>
                )}

                <form onSubmit={handleSignup} className="mt-4 space-y-4">
                    <div className="space-y-1">
                        <label className="font-medium text-slate-700">
                            Email
                        </label>
                        <input
                            type="email"
                            value={email}
                            onChange={lambda e: any -> None { setEmail(e.target.value); }}
                            placeholder="you@example.com"
                            className="w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 outline-none placeholder:text-slate-400 focus:border-emerald-600 focus:bg-white focus:ring-1 focus:ring-emerald-600"
                        />
                    </div>

                    <div className="space-y-1">
                        <label className="font-medium text-slate-700">
                            Password
                        </label>
                        <input
                            type="password"
                            value={password}
                            onChange={lambda e: any -> None { setPassword(e.target.value); }}
                            placeholder="Choose a strong password"
                            className="w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 outline-none placeholder:text-slate-400 focus:border-emerald-600 focus:bg-white focus:ring-1 focus:ring-emerald-600"
                        />
                    </div>

                    <div className="space-y-1">
                        <label className="font-medium text-slate-700">
                            Confirm password
                        </label>
                        <input
                            type="password"
                            value={confirmPassword}
                            onChange={lambda e: any -> None { setConfirmPassword(e.target.value); }}
                            placeholder="Repeat your password"
                            className="w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 outline-none placeholder:text-slate-400 focus:border-emerald-600 focus:bg-white focus:ring-1 focus:ring-emerald-600"
                        />
                    </div>

                    <button
                        type="submit"
                        disabled={loading}
                        className="mt-2 inline-flex w-full items-center justify-center rounded-full bg-green-500 px-4 py-2.5 font-semibold text-white shadow-md hover:bg-emerald-800 disabled:opacity-60 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:ring-offset-1">
                        {buttonLabel}
                    </button>
                </form>

                <p className="mt-4 text-center text-slate-500">
                    Already have an account?{" "}
                    <Link
                        to="/login"
                        className="font-semibold text-emerald-700 hover:text-emerald-900"
                    >
                        Log in
                    </Link>
                </p>
            </div>
        </div>;
    }
}
