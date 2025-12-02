import {__jacJsx, __jacSpawn} from "@jac-client/utils";
import { useState } from "react";
function app() {
  let [crop, setCrop] = useState("maize");
  let [location, setLocation] = useState("Kiambu, Kenya");
  let [problemText, setProblemText] = useState("");
  let [sessionId, setSessionId] = useState("");
  let [output, setOutput] = useState(null);
  let [loading, setLoading] = useState(false);
  let [error, setError] = useState("");
  async function callAgroAdvisor() {
    setLoading(true);
    setError("");
    try {
      let result = await __jacSpawn("AgroAdvisor", "", {"crop": crop, "problem_text": problemText, "location": location, "session_id": sessionId, "language": "en", "include_weather": true, "include_market": true});
      console.log("AgroAdvisor result object:", result);
      let reports = result.reports;
      if (reports.length === 0) {
        setError("No reports from AgroAdvisor.");
        setOutput(null);
        setLoading(false);
        return;
      }
      let data = reports[reports.length - 1];
      console.log("AgroAdvisor chosen report:", data);
      if (data && "session_id" in data && data["session_id"] !== sessionId) {
        setSessionId(data["session_id"]);
      }
      setOutput(data);
    } catch {
      console.log("Error calling AgroAdvisor:", e);
      setError("Failed to call AgroAdvisor.");
      setOutput(null);
    }
    setLoading(false);
  }
  let buttonLabel = "Test AgroAdvisor";
  if (loading) {
    buttonLabel = "Calling AgroAdvisor...";
  }
  let errorNode = null;
  if (error) {
    errorNode = __jacJsx("p", {"style": {"color": "red"}}, [error]);
  }
  let sessionNode = null;
  if (sessionId) {
    sessionNode = __jacJsx("p", {}, [__jacJsx("strong", {}, ["session_id:"]), " ", sessionId]);
  }
  let outputNode = null;
  if (output) {
    let src = output["meta"] && output["meta"]["source"] || "";
    let overview = output["advice_plan"] && output["advice_plan"]["overview"] || "";
    outputNode = __jacJsx("div", {"style": {"marginTop": "16px"}}, [__jacJsx("h2", {}, ["Response summary"]), __jacJsx("p", {}, [__jacJsx("strong", {}, ["Source:"]), " ", src]), __jacJsx("p", {}, [__jacJsx("strong", {}, ["Advice overview:"]), " ", overview])]);
  }
  return __jacJsx("div", {"style": {"padding": "24px", "fontFamily": "sans-serif", "maxWidth": "600px", "margin": "0 auto"}}, [__jacJsx("h1", {}, ["AgroAdvisor backend smoke test"]), __jacJsx("div", {"style": {"marginBottom": "12px"}}, [__jacJsx("label", {}, ["Crop"]), __jacJsx("br", {}, []), __jacJsx("input", {"value": crop, "onChange": e => {
    setCrop(e.target.value);
  }, "style": {"width": "100%", "padding": "8px"}}, [])]), __jacJsx("div", {"style": {"marginBottom": "12px"}}, [__jacJsx("label", {}, ["Location"]), __jacJsx("br", {}, []), __jacJsx("input", {"value": location, "onChange": e => {
    setLocation(e.target.value);
  }, "style": {"width": "100%", "padding": "8px"}}, [])]), __jacJsx("div", {"style": {"marginBottom": "12px"}}, [__jacJsx("label", {}, ["Problem description"]), __jacJsx("br", {}, []), __jacJsx("textarea", {"value": problemText, "onChange": e => {
    setProblemText(e.target.value);
  }, "style": {"width": "100%", "minHeight": "80px", "padding": "8px"}}, [])]), __jacJsx("button", {"onClick": e => {
    callAgroAdvisor();
  }, "style": {"padding": "10px 16px", "marginTop": "8px"}}, [buttonLabel]), errorNode, sessionNode, outputNode]);
}
export { app };
