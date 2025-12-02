cl import from react { useState }

cl {

    def app() -> any {
        let [crop, setCrop] = useState("maize");
        let [location, setLocation] = useState("Kiambu, Kenya");
        let [problemText, setProblemText] = useState("");
        let [sessionId, setSessionId] = useState("");
        let [output, setOutput] = useState(null);
        let [loading, setLoading] = useState(False);
        let [error, setError] = useState("");

        # --- call AgroAdvisor using values from frontend ---

        async def callAgroAdvisor() -> None {
            setLoading(True);
            setError("");

            try {
                # Call walker using the same pattern as:
                # result = await root spawn create_todo(text=input.trim());
                let result = await root spawn AgroAdvisor(
                    crop=crop,
                    problem_text=problemText,
                    location=location,
                    session_id=sessionId,
                    language="en",
                    include_weather=True,
                    include_market=True
                );

                console.log("AgroAdvisor result object:", result);

                let reports = result.reports;

                # No reports at all
                if reports.length == 0 {
                    setError("No reports from AgroAdvisor.");
                    setOutput(null);
                    setLoading(False);
                    return;
                }

                # Choose the report that actually contains the full AgroAdvisor payload
                # Fallback is the last report; we override if we find one with `advice_plan`
                let data = reports[reports.length - 1];

                for  i = 0 to i < reports.length by i = i + 1 {
                    let r = reports[i];

                    if r and "advice_plan" in r {
                        data = r;
                        break;
                    }
                }

                console.log("AgroAdvisor chosen report:", data);

                # Update sessionId from backend if it changed / was created
                if data and "session_id" in data and data["session_id"] != sessionId {
                    setSessionId(data["session_id"]);
                }

                setOutput(data);
            } except e {
                console.log("Error calling AgroAdvisor:", e);
                setError("Failed to call AgroAdvisor.");
                setOutput(null);
            }

            setLoading(False);
        }

        # --- simple vars for button label / conditional pieces ---

        let buttonLabel = "Test AgroAdvisor";
        if loading {
            buttonLabel = "Calling AgroAdvisor...";
        }

        let errorNode = null;
        if error {
            errorNode = <p style={{"color": "red"}}>{error}</p>;
        }

        let sessionNode = null;
        if sessionId {
            sessionNode = <p><strong>session_id:</strong> {sessionId}</p>;
        }

        let outputNode = null;
        if output {
            let src = output["meta"] and output["meta"]["source"] or "";
            let overview = output["advice_plan"] and output["advice_plan"]["overview"] or "";

            outputNode = <div style={{"marginTop": "16px"}}>
                <h2>Response summary</h2>
                <p><strong>Source:</strong> {src}</p>
                <p><strong>Advice overview:</strong> {overview}</p>
            </div>;
        }

        # --- UI using lambda like in docs ---

        return <div style={{"padding": "24px", "fontFamily": "sans-serif", "maxWidth": "600px", "margin": "0 auto"}}>
            <h1>AgroAdvisor backend smoke test</h1>

            <div style={{"marginBottom": "12px"}}>
                <label>Crop</label><br />
                <input
                    value={crop}
                    onChange={lambda e: any -> None { setCrop(e.target.value); }}
                    style={{"width": "100%", "padding": "8px"}}
                />
            </div>

            <div style={{"marginBottom": "12px"}}>
                <label>Location</label><br />
                <input
                    value={location}
                    onChange={lambda e: any -> None { setLocation(e.target.value); }}
                    style={{"width": "100%", "padding": "8px"}}
                />
            </div>

            <div style={{"marginBottom": "12px"}}>
                <label>Problem description</label><br />
                <textarea
                    value={problemText}
                    onChange={lambda e: any -> None { setProblemText(e.target.value); }}
                    style={{"width": "100%", "minHeight": "80px", "padding": "8px"}}
                />
            </div>

            <button
                onClick={lambda e: any -> None { callAgroAdvisor(); }}
                style={{"padding": "10px 16px", "marginTop": "8px"}}
            >
                {buttonLabel}
            </button>

            {errorNode}
            {sessionNode}
            {outputNode}
        </div>;
    }
}
