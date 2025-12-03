import {__jacJsx, __jacSpawn} from "@jac-client/utils";
import { useState } from "react";
import "..//global.css";
import { Router, Routes, Route } from "@jac-client/utils";
import { Link } from "@jac-client/utils";
function AdvisorPage() {
  let [crop, setCrop] = useState("maize");
  let [location, setLocation] = useState("Kiambu, Kenya");
  let [problemText, setProblemText] = useState("");
  let [language, setLanguage] = useState("en");
  let [includeWeather, setIncludeWeather] = useState(true);
  let [includeMarket, setIncludeMarket] = useState(true);
  let [sessionId, setSessionId] = useState("");
  let [loading, setLoading] = useState(false);
  let [error, setError] = useState("");
  let [advicePlan, setAdvicePlan] = useState(null);
  let [weatherSummary, setWeatherSummary] = useState(null);
  let [marketSummary, setMarketSummary] = useState(null);
  let [meta, setMeta] = useState(null);
  async function handleGetAdvice() {
    if (!problemText || !problemText.trim()) {
      setError("Please describe the problem you are facing.");
      return;
    }
    setLoading(true);
    setError("");
    try {
      let result = await __jacSpawn("AgroAdvisor", "", {"crop": crop, "problem_text": problemText, "location": location, "session_id": sessionId, "language": language, "include_weather": includeWeather, "include_market": includeMarket});
      console.log("AgroAdvisor result object:", result);
      let payload = result;
      if (result && result.report) {
        payload = result.report;
      }
      if (payload.session_id) {
        setSessionId(payload.session_id);
      }
      setAdvicePlan(payload.advice_plan);
      setWeatherSummary(payload.weather_summary);
      setMarketSummary(payload.market_summary);
      setMeta(payload.meta);
    } catch {
      console.error("AgroAdvisor error:", err);
      setError("Something went wrong while fetching advice. Please try again.");
    } finally {
      setLoading(false);
    }
  }
  return __jacJsx("div", {"className": "grid gap-6 md:grid-cols-[minmax(0,1.2fr)_minmax(0,1fr)]"}, [__jacJsx(AdvisorForm, {"crop": crop, "onCropChange": setCrop, "location": location, "onLocationChange": setLocation, "problemText": problemText, "onProblemTextChange": setProblemText, "language": language, "onLanguageChange": setLanguage, "includeWeather": includeWeather, "onIncludeWeatherChange": setIncludeWeather, "includeMarket": includeMarket, "onIncludeMarketChange": setIncludeMarket, "loading": loading, "onSubmit": handleGetAdvice}, []), __jacJsx("div", {"className": "space-y-4"}, [__jacJsx(AdvicePlanPanel, {"advicePlan": advicePlan, "meta": meta, "loading": loading, "error": error}, []), __jacJsx(WeatherSummaryPanel, {"summary": weatherSummary}, []), __jacJsx(MarketSummaryPanel, {"summary": marketSummary}, [])])]);
}
function AdvisorForm(props) {
  function handleSubmit(e) {
    e.preventDefault();
    props.onSubmit();
  }
  return __jacJsx("form", {"onSubmit": handleSubmit, "className": "space-y-5 rounded-2xl border border-lime-100 bg-white p-5 shadow-sm"}, [__jacJsx("div", {"className": "space-y-1"}, [__jacJsx("h1", {"className": "text-2xl font-semibold text-slate-900"}, ["Get Personalized Agricultural Advice"]), __jacJsx("p", {"className": "text-sm text-slate-500"}, ["Fill in the details below to receive a tailored plan for your crops."])]), __jacJsx("div", {"className": "space-y-4"}, [__jacJsx("div", {"className": "space-y-1"}, [__jacJsx("label", {"className": "text-xs font-medium text-slate-700"}, ["Select Crop"]), __jacJsx("input", {"type": "text", "placeholder": "e.g., Maize, Wheat, Soybeans", "value": props.crop, "onChange": e => {
    props.onCropChange(e.target.value);
  }, "className": "w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm outline-none focus:border-lime-500 focus:bg-white focus:ring-1 focus:ring-lime-500"}, [])]), __jacJsx("div", {"className": "space-y-1"}, [__jacJsx("label", {"className": "text-xs font-medium text-slate-700"}, ["Enter Location"]), __jacJsx("input", {"type": "text", "placeholder": "e.g., Kisumu, Kenya", "value": props.location, "onChange": e => {
    props.onLocationChange(e.target.value);
  }, "className": "w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm outline-none focus:border-lime-500 focus:bg-white focus:ring-1 focus:ring-lime-500"}, [])]), __jacJsx("div", {"className": "space-y-1"}, [__jacJsx("label", {"className": "text-xs font-medium text-slate-700"}, ["Describe Your Problem"]), __jacJsx("textarea", {"rows": 4, "placeholder": "Describe the issue you are facing in detail...", "value": props.problemText, "onChange": e => {
    props.onProblemTextChange(e.target.value);
  }, "className": "w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm outline-none focus:border-lime-500 focus:bg-white focus:ring-1 focus:ring-lime-500"}, [])]), __jacJsx("div", {"className": "space-y-2"}, [__jacJsx("label", {"className": "text-xs font-medium text-slate-700"}, ["Select Language"]), __jacJsx("div", {"className": "inline-flex gap-1 rounded-full bg-slate-100 p-1"}, [__jacJsx("button", {"type": "button", "className": "rounded-full px-4 py-1 text-xs font-medium " + props.language === "en" ? "bg-lime-500 text-white shadow-sm" : "text-slate-600", "onClick": e => {
    props.onLanguageChange("en");
  }}, ["English"]), __jacJsx("button", {"type": "button", "className": "rounded-full px-4 py-1 text-xs font-medium " + props.language === "sw" ? "bg-lime-500 text-white shadow-sm" : "text-slate-600", "onClick": e => {
    props.onLanguageChange("sw");
  }}, ["Swahili"])])]), __jacJsx("div", {"className": "flex flex-wrap gap-4"}, [__jacJsx("label", {"className": "flex items-center gap-2 text-xs text-slate-700"}, [__jacJsx("input", {"type": "checkbox", "checked": props.includeWeather, "onChange": e => {
    props.onIncludeWeatherChange(e.target.checked);
  }, "className": "h-4 w-4 rounded border-slate-300 text-lime-500 focus:ring-lime-500"}, []), "Include Weather Forecast"]), __jacJsx("label", {"className": "flex items-center gap-2 text-xs text-slate-700"}, [__jacJsx("input", {"type": "checkbox", "checked": props.includeMarket, "onChange": e => {
    props.onIncludeMarketChange(e.target.checked);
  }, "className": "h-4 w-4 rounded border-slate-300 text-lime-500 focus:ring-lime-500"}, []), "Include Market Prices"])]), __jacJsx("div", {}, [__jacJsx("button", {"type": "submit", "disabled": props.loading, "className": "mt-1 inline-flex w-full items-center justify-center rounded-xl bg-lime-500 px-4 py-2 text-sm font-semibold text-white shadow-sm transition " + props.loading ? "opacity-80" : "hover:bg-lime-600"}, [props.loading ? "Getting advice..." : "Get Advice"])])])]);
}
function AdminPage() {
  return __jacJsx("div", {"className": "rounded-2xl border border-slate-200 bg-white p-6 text-sm text-slate-500"}, ["Admin screens coming soon…"]);
}
function DebugPage() {
  return __jacJsx("div", {"className": "rounded-2xl border border-slate-200 bg-white p-6 text-sm text-slate-500"}, ["Debug tools coming soon…"]);
}
function app() {
  return __jacJsx(Router, {}, [__jacJsx("div", {"className": "min-h-screen bg-[#F3F7F2] text-slate-900"}, [__jacJsx(TopNav, {}, []), __jacJsx(PageShell, {}, [__jacJsx(Routes, {}, [__jacJsx(Route, {"path": "/", "element": __jacJsx(AdvisorPage, {}, [])}, []), __jacJsx(Route, {"path": "/admin", "element": __jacJsx(AdminPage, {}, [])}, []), __jacJsx(Route, {"path": "/debug", "element": __jacJsx(DebugPage, {}, [])}, [])])])])]);
}
function MarketSummaryPanel(props) {
  if (!props.summary) {
    return __jacJsx("div", {"className": "rounded-2xl border border-slate-200 bg-white p-4 text-sm text-slate-500"}, ["Market summary will appear here when you request it."]);
  }
  return __jacJsx("div", {"className": "rounded-2xl border border-slate-200 bg-white p-4"}, [__jacJsx("div", {"className": "mb-2 flex items-center justify-between"}, [__jacJsx("h3", {"className": "text-sm font-semibold text-slate-900"}, ["Market Summary"])]), __jacJsx("p", {"className": "text-sm text-slate-700"}, [props.summary.summary_text])]);
}
function AdvicePlanPanel(props) {
  let sourceLabel = "";
  let sourceColor = "";
  if (props.meta && props.meta.source) {
    if (props.meta.source === "fresh") {
      sourceLabel = "Source: fresh";
      sourceColor = "bg-emerald-50 text-emerald-700";
    } else {
      sourceLabel = "Source: cache";
      sourceColor = "bg-slate-100 text-slate-700";
    }
  }
  return __jacJsx("div", {"className": "rounded-2xl border border-lime-100 bg-white p-5 shadow-sm"}, [__jacJsx("div", {"className": "mb-3 flex items-center justify-between gap-2"}, [__jacJsx("h2", {"className": "text-base font-semibold text-slate-900"}, ["Advice Plan"]), sourceLabel && __jacJsx("span", {"className": "inline-flex items-center gap-1 rounded-full px-3 py-1 text-[11px] font-medium " + sourceColor}, [__jacJsx("span", {"className": "h-1.5 w-1.5 rounded-full bg-current"}, []), sourceLabel])]), props.error && __jacJsx("p", {"className": "text-sm text-red-600"}, [props.error]), !props.error && props.loading && __jacJsx("p", {"className": "text-sm text-slate-500"}, ["Generating advice…"]), !props.error && !props.loading && !props.advicePlan && __jacJsx("p", {"className": "text-sm text-slate-500"}, ["Fill in the form on the left and click", " ", __jacJsx("span", {"className": "font-semibold"}, ["Get Advice"]), " to see your plan here."]), !props.error && !props.loading && props.advicePlan && __jacJsx("div", {"className": "space-y-3 text-sm text-slate-800"}, [__jacJsx("div", {}, [__jacJsx("p", {"className": "mb-1 font-semibold"}, ["Overview"]), __jacJsx("p", {"className": "leading-relaxed"}, [props.advicePlan.overview])]), props.advicePlan.steps && props.advicePlan.steps.length > 0 && __jacJsx("div", {}, [__jacJsx("p", {"className": "mb-1 font-semibold"}, ["Step-by-Step Guide"]), __jacJsx("ol", {"className": "list-decimal space-y-1 pl-5"}, [props.advicePlan.steps.map(step => {
    return __jacJsx("li", {}, [step]);
  })])]), props.advicePlan.cautions && props.advicePlan.cautions.length > 0 && __jacJsx("div", {"className": "rounded-xl bg-amber-50 p-3"}, [__jacJsx("p", {"className": "mb-1 text-sm font-semibold text-amber-800"}, ["Cautions"]), __jacJsx("ul", {"className": "list-disc space-y-1 pl-5 text-xs text-amber-900"}, [props.advicePlan.cautions.map(c => {
    return __jacJsx("li", {}, [c]);
  })])])])]);
}
function TopNav() {
  let tabs = [{"id": "advisor", "label": "Advisor", "path": "/"}, {"id": "admin", "label": "Admin", "path": "/admin"}, {"id": "debug", "label": "Debug", "path": "/debug"}];
  return __jacJsx("header", {"className": "border-b border-slate-200 bg-white/80 backdrop-blur"}, [__jacJsx("div", {"className": "mx-auto flex max-w-6xl items-center justify-between px-4 py-3"}, [__jacJsx("div", {"className": "flex items-center gap-2"}, [__jacJsx("div", {"className": "flex h-8 w-8 items-center justify-center rounded-xl bg-lime-500"}, [__jacJsx("span", {"className": "h-4 w-4 rounded-md bg-white/80"}, [])]), __jacJsx("span", {"className": "text-sm font-semibold text-slate-900"}, ["Virtual Agro-Advisor"])]), __jacJsx("nav", {"className": "flex items-center gap-2 text-sm"}, [tabs.map(tab => {
    return __jacJsx(Link, {"key": tab.id, "to": tab.path, "className": "rounded-full px-4 py-1.5 text-xs font-medium text-slate-600 hover:bg-lime-50 transition"}, [tab.label]);
  })])])]);
}
function WeatherSummaryPanel(props) {
  if (!props.summary) {
    return __jacJsx("div", {"className": "rounded-2xl border border-slate-200 bg-white p-4 text-sm text-slate-500"}, ["Weather summary will appear here when you request it."]);
  }
  return __jacJsx("div", {"className": "rounded-2xl border border-slate-200 bg-white p-4"}, [__jacJsx("div", {"className": "mb-2 flex items-center justify-between"}, [__jacJsx("h3", {"className": "text-sm font-semibold text-slate-900"}, ["Weather Summary"])]), __jacJsx("p", {"className": "text-sm text-slate-700"}, [props.summary.summary_text])]);
}
function PageShell(props) {
  return __jacJsx("main", {"className": "mx-auto max-w-6xl px-4 py-6"}, [props.children]);
}
export { AdminPage, AdvicePlanPanel, AdvisorForm, AdvisorPage, DebugPage, MarketSummaryPanel, PageShell, TopNav, WeatherSummaryPanel, app };
