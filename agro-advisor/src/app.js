import {__jacJsx, __jacSpawn} from "@jac-client/utils";
import { useState } from "react";
import "..//global.css";
import { Router, Routes, Route } from "@jac-client/utils";
import { useEffect } from "react";
import { subDays, format } from "date-fns";
import { useParams, useNavigate } from "react-router-dom";
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
  let [imagePreviewUrl, setImagePreviewUrl] = useState("");
  async function handleGetAdvice() {
    if (!problemText || !problemText.trim()) {
      setError("Please describe the problem you are facing.");
      return;
    }
    setLoading(true);
    setError("");
    try {
      console.log("[AdvisorPage] Sending request with:", {"crop": crop, "location": location, "problemText": problemText, "language": language, "includeWeather": includeWeather, "includeMarket": includeMarket, "sessionId": sessionId, "imagePreviewUrl": imagePreviewUrl});
      let result = await __jacSpawn("AgroAdvisor", "", {"crop": crop, "problem_text": problemText, "location": location, "session_id": sessionId, "language": language, "include_weather": includeWeather, "include_market": includeMarket});
      console.log("[AdvisorPage] Raw AgroAdvisor result:", result);
      console.log("[AdvisorPage] result.reports:", result && result.reports);
      let payload = null;
      if (result && result.reports && result.reports.length > 0) {
        payload = result.reports[result.reports.length - 1];
      } else {
        console.warn("[AdvisorPage] No reports returned from AgroAdvisor");
        setError("No advice returned from AgroAdvisor.");
        return;
      }
      console.log("[AdvisorPage] Selected payload:", payload);
      console.log("[AdvisorPage] payload.advice_plan:", payload.advice_plan);
      if (payload.session_id) {
        setSessionId(payload.session_id);
      } else {
        console.warn("[AdvisorPage] payload.session_id missing");
      }
      setAdvicePlan(payload.advice_plan);
      setWeatherSummary(payload.weather_summary);
      setMarketSummary(payload.market_summary);
      setMeta(payload.meta);
      console.log("[AdvisorPage] advicePlan state after set:", payload.advice_plan);
    } catch {
      console.error("[AdvisorPage] AgroAdvisor error:", err);
      setError("Something went wrong while fetching advice. Please try again.");
    } finally {
      setLoading(false);
    }
  }
  return __jacJsx("div", {"className": "grid gap-6 md:grid-cols-[minmax(0,1.2fr)_minmax(0,1fr)]"}, [__jacJsx(AdvisorForm, {"crop": crop, "onCropChange": setCrop, "location": location, "onLocationChange": setLocation, "problemText": problemText, "onProblemTextChange": setProblemText, "language": language, "onLanguageChange": setLanguage, "includeWeather": includeWeather, "onIncludeWeatherChange": setIncludeWeather, "includeMarket": includeMarket, "onIncludeMarketChange": setIncludeMarket, "loading": loading, "onSubmit": handleGetAdvice, "imagePreviewUrl": imagePreviewUrl, "onImageChange": setImagePreviewUrl}, []), __jacJsx("div", {"className": "space-y-4"}, [__jacJsx(AdvicePlanPanel, {"advicePlan": advicePlan, "meta": meta, "loading": loading, "error": error}, []), __jacJsx(WeatherSummaryPanel, {"summary": weatherSummary, "meta": meta}, []), __jacJsx(MarketSummaryPanel, {"summary": marketSummary, "meta": meta}, [])])]);
}
function AdvisorForm(props) {
  function handleSubmit(e) {
    e.preventDefault();
    props.onSubmit();
  }
  let handleImageChange = e => {
    let files = e.target.files;
    if (!files || files.length === 0) {
      if (props.onImageChange) {
        props.onImageChange("");
      }
      return;
    }
    let file = files[0];
    let previewUrl = URL.createObjectURL(file);
    if (props.onImageChange) {
      props.onImageChange(previewUrl);
    }
  };
  return __jacJsx("form", {"onSubmit": handleSubmit, "className": "flex h-full min-h-[520px] flex-col rounded-2xl border border-lime-100 bg-white p-6 shadow-sm"}, [__jacJsx("div", {"className": "space-y-1"}, [__jacJsx("h1", {"className": "text-2xl font-semibold text-slate-900"}, ["Get Personalized Agricultural Advice"]), __jacJsx("p", {"className": "text-sm text-slate-500"}, ["Fill in the details below to receive a tailored plan for your crops."])]), __jacJsx("div", {"className": "mt-4 flex-1 space-y-4 overflow-y-auto pr-1"}, [__jacJsx("div", {"className": "space-y-1"}, [__jacJsx("label", {"className": "text-sm font-medium text-slate-800"}, ["Give Crop"]), __jacJsx("input", {"type": "text", "placeholder": "e.g., Maize, Wheat, Soybeans", "value": props.crop, "onChange": e => {
    props.onCropChange(e.target.value);
  }, "className": "w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-sm outline-none placeholder:text-lime-500/70 focus:border-emerald-600 focus:bg-white focus:ring-1 focus:ring-emerald-600"}, [])]), __jacJsx("div", {"className": "space-y-1"}, [__jacJsx("label", {"className": "text-sm font-medium text-slate-800"}, ["Enter Location"]), __jacJsx("input", {"type": "text", "placeholder": "e.g., Kisumu, Kenya", "value": props.location, "onChange": e => {
    props.onLocationChange(e.target.value);
  }, "className": "w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-sm outline-none placeholder:text-lime-500/70 focus:border-emerald-600 focus:bg-white focus:ring-1 focus:ring-emerald-600"}, [])]), __jacJsx("div", {"className": "space-y-2"}, [__jacJsx("label", {"className": "text-sm font-medium text-slate-800"}, ["Upload Image (optional)"]), __jacJsx("input", {"type": "file", "accept": "image/*", "onChange": handleImageChange, "className": "block w-full text-sm text-slate-700 file:mr-4 file:rounded-full file:border-0 file:bg-green-50 file:px-4 file:py-2 file:text-sm file:font-semibold file:text-green-700 hover:file:bg-green-100"}, []), props.imagePreviewUrl && props.imagePreviewUrl !== "" ? __jacJsx("div", {"className": "mt-2 overflow-hidden rounded-xl border border-slate-200 bg-slate-50"}, [__jacJsx("img", {"src": props.imagePreviewUrl, "alt": "Problem preview", "className": "h-40 w-full object-cover"}, [])]) : __jacJsx("div", {"className": "mt-2 flex h-24 items-center justify-center rounded-xl border border-dashed border-slate-300 bg-slate-50 text-xs text-slate-400"}, ["No image selected – you can upload a clear photo of the affected plant."])]), __jacJsx("div", {"className": "space-y-1"}, [__jacJsx("label", {"className": "text-sm font-medium text-slate-800"}, ["Describe Your Problem"]), __jacJsx("textarea", {"rows": 4, "placeholder": "Describe the issue you are facing in detail...", "value": props.problemText, "onChange": e => {
    props.onProblemTextChange(e.target.value);
  }, "className": "w-full min-h-[120px] rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-sm outline-none placeholder:text-lime-500/70 focus:border-emerald-600 focus:bg-white focus:ring-1 focus:ring-emerald-600 resize-y"}, [])]), __jacJsx("div", {"className": "space-y-2 pt-1"}, [__jacJsx("label", {"className": "text-sm font-medium text-slate-800"}, ["Select Language"]), __jacJsx("div", {"className": "flex gap-2"}, [__jacJsx("label", {"className": "flex-1"}, [__jacJsx("input", {"type": "radio", "name": "advisor-language", "value": "en", "checked": props.language === "en", "onChange": e => {
    props.onLanguageChange("en");
  }, "className": "peer sr-only"}, []), __jacJsx("div", {"className": "w-full rounded-md border border-green-600 bg-white px-4 py-2 text-sm font-semibold text-green-700 transition peer-checked:bg-green-600 peer-checked:text-white"}, ["EN - English"])]), __jacJsx("label", {"className": "flex-1"}, [__jacJsx("input", {"type": "radio", "name": "advisor-language", "value": "sw", "checked": props.language === "sw", "onChange": e => {
    props.onLanguageChange("sw");
  }, "className": "peer sr-only"}, []), __jacJsx("div", {"className": " w-full rounded-md border border-green-600 bg-white px-4 py-2 text-sm font-semibold text-green-700 transition peer-checked:bg-green-600 peer-checked:text-white"}, ["SW - Swahili"])])])]), __jacJsx("div", {"className": "border-t border-slate-200 pt-3"}, []), __jacJsx("div", {"className": "space-y-3 text-sm text-slate-800"}, [__jacJsx("label", {"className": "flex items-center gap-3"}, [__jacJsx("span", {"className": "relative inline-flex h-6 w-11 items-center"}, [__jacJsx("input", {"type": "checkbox", "checked": props.includeWeather, "onChange": e => {
    props.onIncludeWeatherChange(e.target.checked);
  }, "className": "peer sr-only"}, []), __jacJsx("span", {"className": "absolute inset-0 rounded-full bg-slate-300 transition peer-checked:bg-green-600"}, []), __jacJsx("span", {"className": "absolute h-5 w-5 rounded-full bg-white shadow translate-x-1 transition peer-checked:translate-x-5"}, [])]), __jacJsx("span", {}, ["Include Weather"])]), __jacJsx("label", {"className": "flex items-center gap-3"}, [__jacJsx("span", {"className": "relative inline-flex h-6 w-11 items-center"}, [__jacJsx("input", {"type": "checkbox", "checked": props.includeMarket, "onChange": e => {
    props.onIncludeMarketChange(e.target.checked);
  }, "className": "peer sr-only"}, []), __jacJsx("span", {"className": " absolute inset-0 rounded-full bg-slate-300 transition peer-checked:bg-green-600"}, []), __jacJsx("span", {"className": " absolute h-5 w-5 rounded-full bg-white shadow translate-x-1 transition peer-checked:translate-x-5"}, [])]), __jacJsx("span", {}, ["Include Market"])])])]), __jacJsx("div", {"className": "mt-4"}, [__jacJsx("button", {"type": "submit", "className": "inline-flex w-full items-center justify-center rounded-full bg-green-500 px-4 py-3 text-base font-semibold text-white shadow-md hover:bg-emerald-800 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:ring-offset-1"}, ["Get Advice"])])]);
}
function app() {
  return __jacJsx(Router, {}, [__jacJsx("div", {"className": "min-h-screen bg-[#F3F7F2] text-slate-900"}, [__jacJsx(TopNav, {}, []), __jacJsx(PageShell, {}, [__jacJsx(Routes, {}, [__jacJsx(Route, {"path": "/", "element": __jacJsx(AdvisorPage, {}, [])}, []), __jacJsx(Route, {"path": "/admin", "element": __jacJsx(AdminPage, {}, [])}, []), __jacJsx(Route, {"path": "/debug", "element": __jacJsx(DebugPage, {}, [])}, []), __jacJsx(Route, {"path": "/admin/cache/:encodedKey", "element": __jacJsx(CacheDetailPage, {}, [])}, [])])])])]);
}
function MarketSummaryPanel(props) {
  if (!props.summary) {
    return __jacJsx("div", {"className": "h-[150px] rounded-2xl border border-lime-100 bg-white p-4 text-sm text-slate-500"}, ["Market summary will appear here when you request it."]);
  }
  let heading = "Market Summary";
  if (props.meta && props.meta.titles && props.meta.titles.market_summary) {
    heading = props.meta.titles.market_summary;
  }
  return __jacJsx("div", {"className": "h-[150px] rounded-2xl border border-lime-100 bg-white p-4"}, [__jacJsx("div", {"className": "mb-2 flex items-center justify-between"}, [__jacJsx("h3", {"className": "text-sm font-semibold text-slate-900"}, [heading])]), __jacJsx("div", {"className": "h-full overflow-y-auto"}, [__jacJsx("p", {"className": "text-sm text-slate-700 leading-relaxed"}, [props.summary.summary_text])])]);
}
function extractReports(res) {
  if (!res) {
    return [];
  }
  if (!"reports" in res || !res["reports"]) {
    return [];
  }
  let reports = res["reports"];
  if (reports.length === 1 && Array.isArray(reports[0])) {
    return reports[0];
  }
  return reports;
}
function computeStats(sessionsList, adviceList) {
  let stats = {"totalSessions": sessionsList.length, "adviceEntries": adviceList.length, "latestSessionTime": ""};
  return stats;
}
function formatShortDatetime(dt) {
  if (!dt) {
    return "";
  }
  if (dt.length >= 16) {
    return dt.slice(0, 16);
  }
  return dt;
}
function parseCacheKey(cache_key) {
  if (!cache_key) {
    return {"crop": "", "region": "", "lang": "", "problem": ""};
  }
  let parts = cache_key.split("|");
  let crop = parts.length > 0 ? parts[0] : "";
  let region = parts.length > 1 ? parts[1] : "";
  let lang = parts.length > 2 ? parts[2] : "";
  let problem = parts.length > 0 ? parts[parts.length - 1] : "";
  return {"crop": crop, "region": region, "lang": lang, "problem": problem};
}
function makeCutoffString(days) {
  let nowMs = Date.now();
  let cutoffDate = subDays(nowMs, days);
  let cutoffStr = format(cutoffDate, "yyyy-MM-dd HH:mm:ss");
  return cutoffStr;
}
function AdminPage() {
  let [loading, setLoading] = useState(false);
  let [error, setError] = useState("");
  let [flash, setFlash] = useState("");
  let [sessionRows, setSessionRows] = useState([]);
  let [adviceRows, setAdviceRows] = useState([]);
  let [stats, setStats] = useState({"totalSessions": 0, "adviceEntries": 0, "latestSessionTime": ""});
  let [cleaningSessions, setCleaningSessions] = useState(false);
  let [clearingCache, setClearingCache] = useState(false);
  let navigate = useNavigate();
  async function loadAdminData() {
    setLoading(true);
    setError("");
    setFlash("");
    try {
      let sessionsRes = await __jacSpawn("GetAllSessions", "", {});
      let adviceRes = await __jacSpawn("GetAllAdviceCache", "", {});
      console.log("GetAllSessions result:", sessionsRes);
      console.log("GetAllAdviceCache result:", adviceRes);
      let sessionsList = extractReports(sessionsRes);
      let adviceList = extractReports(adviceRes);
      setSessionRows(sessionsList);
      setAdviceRows(adviceList);
      setStats(computeStats(sessionsList, adviceList));
    } catch (err) {
      console.error("AdminPage loadAdminData exception:", err);
      setError("Failed to load admin data.");
    } finally {
      setLoading(false);
    }
  }
  async function handleCleanupSessions() {
    let days = 7;
    if (!window.confirm("Delete sessions  This cannot be undone.")) {
      return;
    }
    setCleaningSessions(true);
    setError("");
    setFlash("");
    try {
      let cutoff = makeCutoffString(days);
      let res = await __jacSpawn("CleanupOldSessions", "", {"cutoff": "ALL"});
      console.log("CleanupOldSessions result:", res);
      let deleted = 0;
      if (res && "reports" in res && res.reports.length > 0) {
        let r0 = res.reports[0];
        if ("deleted_count" in r0) {
          deleted = r0.deleted_count;
        }
      }
      let suffix = "";
      if (deleted !== 1) {
        suffix = "s";
      }
      setFlash("Removed " + deleted + " session" + suffix + " older than " + days + " days.");
      await loadAdminData();
    } catch (err) {
      console.error("handleCleanupSessions exception:", err);
      setError("Failed to cleanup sessions.");
    } finally {
      setCleaningSessions(false);
    }
  }
  async function handleClearCache() {
    if (!window.confirm("Clear all advice cache entries? This cannot be undone.")) {
      return;
    }
    setClearingCache(true);
    setError("");
    setFlash("");
    try {
      let res = await __jacSpawn("ClearAdviceCache", "", {});
      console.log("ClearAdviceCache result:", res);
      let deleted = 0;
      if (res && "reports" in res && res.reports.length > 0) {
        let r0 = res.reports[0];
        if ("deleted_count" in r0) {
          deleted = r0.deleted_count;
        }
      }
      let suffix = "ies";
      if (deleted === 1) {
        suffix = "y";
      }
      setFlash("Cleared " + deleted + " advice cache entr" + suffix + ".");
      await loadAdminData();
    } catch (err) {
      console.error("handleClearCache exception:", err);
      setError("Failed to clear advice cache.");
    } finally {
      setClearingCache(false);
    }
  }
  function handleAdviceRowClick(entry) {
    let key = entry["cache_key"] || "";
    if (!key) {
      return;
    }
    let encoded = encodeURIComponent(key);
    navigate("/admin/cache/" + encoded);
  }
  useEffect(() => {
    loadAdminData();
  }, []);
  return __jacJsx("div", {"className": "space-y-6"}, [__jacJsx("div", {"className": "flex flex-wrap items-center justify-between gap-3"}, [__jacJsx("div", {}, [__jacJsx("h1", {"className": "text-xl font-semibold text-slate-900"}, ["Admin dashboard"]), __jacJsx("p", {"className": "mt-1 text-xs text-slate-500"}, ["Inspect sessions and advice cache, and run maintenance tasks."])]), __jacJsx("div", {"className": "flex flex-wrap gap-2"}, [__jacJsx("button", {"className": "rounded-lg border border-slate-300 px-3 py-1 text-xs font-medium hover:bg-slate-50 disabled:opacity-60", "disabled": loading, "onClick": e => {
    loadAdminData();
  }}, [loading ? "Refreshing\u2026" : "Refresh"]), __jacJsx("button", {"className": "rounded-lg border border-amber-300 bg-amber-50 px-3 py-1 text-xs font-medium text-amber-900 hover:bg-amber-100 disabled:opacity-60", "disabled": cleaningSessions, "onClick": e => {
    handleCleanupSessions();
  }}, [cleaningSessions ? "Cleaning sessions\u2026" : "Cleanup old sessions"]), __jacJsx("button", {"className": "rounded-lg border border-rose-300 bg-rose-50 px-3 py-1 text-xs font-medium text-rose-900 hover:bg-rose-100 disabled:opacity-60", "disabled": clearingCache, "onClick": e => {
    handleClearCache();
  }}, [clearingCache ? "clear advice cache" : "clear advice cache"])])]), flash && __jacJsx("div", {"className": "rounded-2xl border border-emerald-200 bg-emerald-50 px-4 py-2 text-xs text-emerald-800"}, [flash]), error && __jacJsx("div", {"className": "rounded-2xl border border-red-200 bg-red-50 px-4 py-2 text-xs text-red-700"}, [error]), __jacJsx("div", {"className": "grid gap-4 md:grid-cols-3"}, [__jacJsx("div", {"className": "rounded-2xl border border-slate-200 bg-white p-4"}, [__jacJsx("p", {"className": "text-[11px] text-slate-500"}, ["Total sessions"]), __jacJsx("p", {"className": "mt-1 text-xl font-semibold text-slate-900"}, [stats["totalSessions"]])]), __jacJsx("div", {"className": "rounded-2xl border border-slate-200 bg-white p-4"}, [__jacJsx("p", {"className": "text-[11px] text-slate-500"}, ["Advice cache entries"]), __jacJsx("p", {"className": "mt-1 text-xl font-semibold text-slate-900"}, [stats["adviceEntries"]])]), __jacJsx("div", {"className": "rounded-2xl border border-slate-200 bg-white p-4"}, [__jacJsx("p", {"className": "text-[11px] text-slate-500"}, ["Latest session activity"]), __jacJsx("p", {"className": "mt-1 text-sm font-medium text-slate-900"}, [stats["latestSessionTime"] ? formatShortDatetime(stats["latestSessionTime"]) : "_"])])]), __jacJsx("div", {"className": "grid gap-4 lg:grid-cols-2"}, [__jacJsx("div", {"className": "rounded-2xl border border-slate-200 bg-white p-4 text-sm text-slate-700"}, [__jacJsx("div", {"className": "mb-3 flex items-center justify-between"}, [__jacJsx("h2", {"className": "text-sm font-semibold text-slate-800"}, ["Sessions"]), __jacJsx("span", {"className": "text-[10px] uppercase tracking-wide text-slate-400"}, ["GetAllSessions"])]), sessionRows && sessionRows.length > 0 ? __jacJsx("div", {"className": "overflow-x-auto"}, [__jacJsx("table", {"className": "min-w-full text-left text-[11px]"}, [__jacJsx("thead", {"className": "border-b border-slate-100 text-[10px] uppercase tracking-wide text-slate-400"}, [__jacJsx("tr", {}, [__jacJsx("th", {"className": "py-1 pr-3"}, ["Session ID"]), __jacJsx("th", {"className": "py-1 pr-3"}, ["Lang"]), __jacJsx("th", {"className": "py-1 pr-3"}, ["Created"]), __jacJsx("th", {"className": "py-1"}, ["Last active"])])]), __jacJsx("tbody", {"className": "text-xs"}, [sessionRows.map((sess, idx) => {
    return __jacJsx("tr", {"key": idx, "className": "border-b border-slate-50 last:border-0"}, [__jacJsx("td", {"className": "py-1 pr-3 font-mono"}, [sess["session_id"] || "\u2014"]), __jacJsx("td", {"className": "py-1 pr-3"}, [sess["lang"] || "\u2014"]), __jacJsx("td", {"className": "py-1 pr-3"}, [formatShortDatetime(sess["created_at"] || "")]), __jacJsx("td", {"className": "py-1"}, [formatShortDatetime(sess["last_active_at"] || "")])]);
  })])]), sessionRows.length > 10 && __jacJsx("p", {"className": "mt-2 text-[10px] text-slate-400"}, ["Showing first 10 sessions."])]) : __jacJsx("p", {"className": "text-[11px] text-slate-500"}, ["No sessions yet."])]), __jacJsx("div", {"className": "rounded-2xl border border-slate-200 bg-white p-4 text-sm text-slate-700"}, [__jacJsx("div", {"className": "mb-3 flex items-center justify-between"}, [__jacJsx("h2", {"className": "text-sm font-semibold text-slate-800"}, ["Advice cache"]), __jacJsx("span", {"className": "text-[10px] uppercase tracking-wide text-slate-400"}, ["GetAllAdviceCache"])]), adviceRows && adviceRows.length > 0 ? __jacJsx("div", {"className": "overflow-x-auto"}, [__jacJsx("table", {"className": "min-w-full text-left text-[11px]"}, [__jacJsx("thead", {"className": "border-b border-slate-100 text-[10px] uppercase tracking-wide text-slate-400"}, [__jacJsx("tr", {}, [__jacJsx("th", {"className": "py-1 pr-3"}, ["Crop"]), __jacJsx("th", {"className": "py-1 pr-3"}, ["Region"]), __jacJsx("th", {"className": "py-1 pr-3"}, ["Problem"]), __jacJsx("th", {"className": "py-1 pr-3"}, ["Usage"]), __jacJsx("th", {"className": "py-1"}, ["Last used"])])]), __jacJsx("tbody", {"className": "text-xs"}, [adviceRows.map((entry, idx) => {
    let meta = parseCacheKey(entry["cache_key"] || "");
    return __jacJsx("tr", {"key": idx, "className": "cursor-pointer border-b border-slate-50 last:border-0 hover:bg-slate-50", "onClick": e => {
      handleAdviceRowClick(entry);
    }}, [__jacJsx("td", {"className": "py-1 pr-3"}, [meta["crop"] || "\u2014"]), __jacJsx("td", {"className": "py-1 pr-3"}, [meta["region"] || "\u2014"]), __jacJsx("td", {"className": "py-1 pr-3"}, [meta["problem"] || "\u2014"]), __jacJsx("td", {"className": "py-1 pr-3"}, [entry["usage_count"] || 0]), __jacJsx("td", {"className": "py-1"}, [formatShortDatetime(entry["last_used_at"] || "")])]);
  })])]), adviceRows.length > 10 && __jacJsx("p", {"className": "mt-2 text-[10px] text-slate-400"}, ["Showing first 10 advice cache entries."])]) : __jacJsx("p", {"className": "text-[11px] text-slate-500"}, ["No advice cache entries yet."])])])]);
}
function extractAnalysis(res) {
  if (!res) {
    return null;
  }
  if ("problem_type" in res || "severity" in res) {
    return res;
  }
  if ("reports" in res && res["reports"]) {
    let first = res["reports"][0];
    if ("analysis" in first) {
      return first["analysis"];
    }
    if ("problem_type" in first || "severity" in first) {
      return first;
    }
  }
  if ("result" in res) {
    let r = res["result"];
    if ("analysis" in r) {
      return r["analysis"];
    }
    if ("problem_type" in r || "severity" in r) {
      return r;
    }
  }
  return null;
}
function extractAdvice(res) {
  if (!res) {
    return null;
  }
  if ("overview" in res || "steps" in res || "cautions" in res) {
    return res;
  }
  if ("reports" in res && res["reports"] && res["reports"].length > 0) {
    let first = res["reports"][0];
    if ("advice_plan" in first) {
      return first["advice_plan"];
    }
    if ("advice" in first) {
      return first["advice"];
    }
    if ("overview" in first || "steps" in first || "cautions" in first) {
      return first;
    }
  }
  if ("result" in res) {
    let r = res["result"];
    if ("advice_plan" in r) {
      return r["advice_plan"];
    }
    if ("advice" in r) {
      return r["advice"];
    }
    if ("overview" in r || "steps" in r || "cautions" in r) {
      return r;
    }
  }
  return null;
}
function DebugPage() {
  let [crop, setCrop] = useState("maize");
  let [location, setLocation] = useState("Kiambu, Kenya");
  let [problemText, setProblemText] = useState("");
  let [analysisResult, setAnalysisResult] = useState(null);
  let [adviceResult, setAdviceResult] = useState(null);
  let [loadingAnalysis, setLoadingAnalysis] = useState(false);
  let [loadingAdvice, setLoadingAdvice] = useState(false);
  let [error, setError] = useState("");
  async function runAnalyzeDebug() {
    if (!problemText || problemText.trim() === "") {
      window.alert("Please enter a problem description before running LLMAnalyzeDebug.");
      return;
    }
    setLoadingAnalysis(true);
    setError("");
    setAnalysisResult(null);
    try {
      let res = await __jacSpawn("LLMAnalyzeDebug", "", {"crop": crop, "problem_text": problemText, "location": location, "language": "en"});
      console.log("LLMAnalyzeDebug result:", res);
      if ("error" in res) {
        console.error("LLMAnalyzeDebug error:", res.error);
        setError("LLMAnalyzeDebug failed: " + res.error);
      } else {
        setAnalysisResult(res);
      }
    } catch (err) {
      console.error("LLMAnalyzeDebug exception:", err);
      setError("Unexpected error in LLMAnalyzeDebug.");
    } finally {
      setLoadingAnalysis(false);
    }
  }
  async function runAdviceDebug() {
    if (!problemText || problemText.trim() === "") {
      window.alert("Please enter a problem description before running LLMAdviceDebug.");
      return;
    }
    setLoadingAdvice(true);
    setError("");
    setAdviceResult(null);
    try {
      let res = await __jacSpawn("LLMAdviceDebug", "", {"crop": crop, "problem_text": problemText, "location": location, "language": "en", "include_weather": true, "include_market": true});
      console.log("LLMAdviceDebug result:", res);
      if ("error" in res) {
        console.error("LLMAdviceDebug error:", res.error);
        setError("LLMAdviceDebug failed: " + res.error);
      } else {
        setAdviceResult(res);
      }
    } catch (err) {
      console.error("LLMAdviceDebug exception:", err);
      setError("Unexpected error in LLMAdviceDebug.");
    } finally {
      setLoadingAdvice(false);
    }
  }
  let analysis = extractAnalysis(analysisResult);
  let advice = extractAdvice(adviceResult);
  let severity = "";
  let problemType = "";
  if (analysis) {
    if ("severity" in analysis && analysis["severity"]) {
      severity = analysis["severity"];
    }
    if ("problem_type" in analysis && analysis["problem_type"]) {
      problemType = analysis["problem_type"];
    }
  }
  let severityClass = "inline-flex items-center rounded-full border border-slate-200 bg-slate-50 px-2 py-0.5 text-[10px] font-medium text-slate-700";
  if (severity === "low") {
    severityClass = "inline-flex items-center rounded-full border border-emerald-200 bg-emerald-50 px-2 py-0.5 text-[10px] font-medium text-emerald-800";
  } else if (severity === "high") {
    severityClass = "inline-flex items-center rounded-full border border-rose-200 bg-rose-50 px-2 py-0.5 text-[10px] font-medium text-rose-800";
  }
  return __jacJsx("div", {"className": "space-y-6"}, [__jacJsx("div", {}, [__jacJsx("h1", {"className": "text-xl font-semibold text-slate-900"}, ["Debug tools"]), __jacJsx("p", {"className": "mt-1 text-xs text-slate-500"}, ["Run the LLM analysis and advice walkers directly with test inputs."])]), error && __jacJsx("div", {"className": "rounded-2xl border border-red-200 bg-red-50 p-4 text-sm text-red-700"}, [error]), __jacJsx("div", {"className": "rounded-2xl border border-slate-200 bg-white p-4 text-sm text-slate-700 space-y-4"}, [__jacJsx("div", {"className": "grid gap-3 sm:grid-cols-2"}, [__jacJsx("div", {"className": "space-y-1"}, [__jacJsx("label", {"className": "text-[11px] font-medium text-slate-700"}, ["Crop"]), __jacJsx("input", {"className": "w-full rounded-lg border border-slate-200 px-3 py-2 text-sm outline-none focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500", "value": crop, "onChange": e => {
    setCrop(e.target.value);
  }, "placeholder": "maize"}, [])]), __jacJsx("div", {"className": "space-y-1"}, [__jacJsx("label", {"className": "text-[11px] font-medium text-slate-700"}, ["Location"]), __jacJsx("input", {"className": "w-full rounded-lg border border-slate-200 px-3 py-2 text-sm outline-none focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500", "value": location, "onChange": e => {
    setLocation(e.target.value);
  }, "placeholder": "Kiambu, Kenya"}, [])])]), __jacJsx("div", {"className": "space-y-1"}, [__jacJsx("label", {"className": "text-[11px] font-medium text-slate-700"}, ["Problem description"]), __jacJsx("textarea", {"className": "h-28 w-full rounded-lg border border-slate-200 px-3 py-2 text-sm outline-none focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500", "value": problemText, "onChange": e => {
    setProblemText(e.target.value);
  }, "placeholder": "Describe the farmer&#39;s issue here (e.g. leaves are curling and turning yellow)…", "required": true}, [])]), __jacJsx("div", {"className": "flex flex-wrap gap-2"}, [__jacJsx("button", {"className": "rounded-lg border border-slate-300 px-3 py-1.5 text-xs font-medium hover:bg-slate-50 disabled:opacity-60", "disabled": loadingAnalysis, "onClick": e => {
    runAnalyzeDebug();
  }}, [loadingAnalysis ? "Running LLMAnalyzeDebug\u2026" : "Run LLMAnalyzeDebug"]), __jacJsx("button", {"className": "rounded-lg bg-emerald-600 px-3 py-1.5 text-xs font-medium text-white hover:bg-emerald-700 disabled:opacity-60", "disabled": loadingAdvice, "onClick": e => {
    runAdviceDebug();
  }}, [loadingAdvice ? "Running LLMAdviceDebug\u2026" : "Run LLMAdviceDebug"])])]), __jacJsx("div", {"className": "grid gap-4 lg:grid-cols-2"}, [__jacJsx("div", {"className": "flex h-[320px] flex-col rounded-2xl border border-slate-200 bg-white p-4 text-sm text-slate-700"}, [__jacJsx("div", {"className": "mb-2 flex items-center justify-between"}, [__jacJsx("h2", {"className": "text-sm font-semibold text-slate-800"}, ["IssueAnalysis"]), __jacJsx("span", {"className": "text-[10px] uppercase tracking-wide text-slate-400"}, ["LLMAnalyzeDebug"])]), __jacJsx("div", {"className": "mt-1 flex-1 overflow-y-auto"}, [analysis ? __jacJsx("div", {"className": "space-y-3"}, [__jacJsx("div", {"className": "flex flex-wrap items-center gap-2"}, [__jacJsx("span", {"className": "text-[11px] uppercase tracking-wide text-slate-400"}, ["Problem type"]), __jacJsx("span", {"className": "inline-flex items-center rounded-full bg-slate-50 px-2 py-0.5 text-[11px] font-medium text-slate-800"}, [problemType || "\u2014"]), __jacJsx("span", {"className": "ml-3 text-[11px] uppercase tracking-wide text-slate-400"}, ["Severity"]), __jacJsx("span", {"className": severityClass}, [severity || "\u2014"])]), __jacJsx("div", {}, [__jacJsx("p", {"className": "mb-1 text-[11px] font-medium text-slate-500"}, ["Key symptoms"]), "key_symptoms" in analysis && analysis["key_symptoms"] && analysis["key_symptoms"].length > 0 ? __jacJsx("ul", {"className": "list-disc space-y-1 pl-5 text-[11px]"}, [analysis["key_symptoms"].map((s, idx) => {
    return __jacJsx("li", {"key": idx}, [s]);
  })]) : __jacJsx("p", {"className": "text-[11px] text-slate-400"}, ["No key symptoms returned."])])]) : __jacJsx("p", {"className": "text-[11px] text-slate-500"}, ["Run LLMAnalyzeDebug to see structured IssueAnalysis here."])])]), __jacJsx("div", {"className": "flex h-[320px] flex-col rounded-2xl border border-slate-200 bg-white p-4 text-sm text-slate-700"}, [__jacJsx("div", {"className": "mb-2 flex items-center justify-between"}, [__jacJsx("h2", {"className": "text-sm font-semibold text-slate-800"}, ["AdvicePlan"]), __jacJsx("span", {"className": "text-[10px] uppercase tracking-wide text-slate-400"}, ["LLMAdviceDebug"])]), __jacJsx("div", {"className": "mt-1 flex-1 overflow-y-auto"}, [advice ? __jacJsx("div", {"className": "space-y-4"}, [__jacJsx("div", {}, [__jacJsx("p", {"className": "mb-1 text-[11px] font-medium text-slate-500"}, ["Overview"]), __jacJsx("p", {"className": "text-[11px] leading-relaxed text-slate-700"}, [advice["overview"] || "No overview returned."])]), __jacJsx("div", {}, [__jacJsx("p", {"className": "mb-1 text-[11px] font-medium text-slate-500"}, ["Recommended steps"]), "steps" in advice && advice["steps"] && advice["steps"].length > 0 ? __jacJsx("ol", {"className": "space-y-2 text-[11px]"}, [advice["steps"].map((step, idx) => {
    return __jacJsx("li", {"key": idx, "className": "flex gap-2"}, [__jacJsx("span", {"className": "mt-0.5 inline-flex h-5 w-5 items-center justify-center rounded-full bg-emerald-50 text-[10px] font-semibold text-emerald-800"}, [idx + 1]), __jacJsx("span", {"className": "text-slate-700"}, [step])]);
  })]) : __jacJsx("p", {"className": "text-[11px] text-slate-400"}, ["No steps returned."])]), __jacJsx("div", {}, [__jacJsx("p", {"className": "mb-1 text-[11px] font-medium text-slate-500"}, ["Cautions"]), "cautions" in advice && advice["cautions"] && advice["cautions"].length > 0 ? __jacJsx("ul", {"className": "list-disc space-y-1 pl-5 text-[11px] text-slate-700"}, [advice["cautions"].map((c, idx) => {
    return __jacJsx("li", {"key": idx}, [c]);
  })]) : __jacJsx("p", {"className": "text-[11px] text-slate-400"}, ["No cautions returned."])])]) : __jacJsx("p", {"className": "text-[11px] text-slate-500"}, ["Run LLMAdviceDebug to see the generated AdvicePlan here."])])])])]);
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
  let overviewTitle = "Overview";
  let stepsTitle = "Step-by-Step Guide";
  let cautionsTitle = "Cautions";
  if (props.meta && props.meta.titles) {
    let titles = props.meta.titles;
    if (titles.advice_overview) {
      overviewTitle = titles.advice_overview;
    }
    if (titles.advice_steps) {
      stepsTitle = titles.advice_steps;
    }
    if (titles.advice_cautions) {
      cautionsTitle = titles.advice_cautions;
    }
  }
  return __jacJsx("div", {"className": "flex h-[520px] flex-col rounded-2xl border border-lime-100 bg-white p-5 md:p-6 shadow-sm"}, [__jacJsx("div", {"className": "mb-2 flex items-center justify-between gap-2"}, [__jacJsx("h2", {"className": "text-base font-semibold text-slate-900"}, ["Advice Plan"]), sourceLabel && __jacJsx("span", {"className": "inline-flex items-center gap-1 rounded-full px-3 py-1 text-[11px] font-medium " + sourceColor}, [__jacJsx("span", {"className": "h-1.5 w-1.5 rounded-full bg-current"}, []), sourceLabel])]), __jacJsx("div", {"className": "mt-1 flex-1 overflow-y-auto rounded-xl bg-slate-50/70 px-3 py-2"}, [props.error && __jacJsx("p", {"className": "text-sm text-red-600"}, [props.error]), !props.error && props.loading && __jacJsx("p", {"className": "text-sm text-slate-500"}, ["Generating advice…"]), !props.error && !props.loading && !props.advicePlan && __jacJsx("p", {"className": "text-sm text-slate-500"}, ["Fill in the form on the left and click", " ", __jacJsx("span", {"className": "font-semibold"}, ["Get Advice"]), " to see your plan here."]), !props.error && !props.loading && props.advicePlan && __jacJsx("div", {"className": "space-y-3 text-sm text-slate-800"}, [__jacJsx("div", {}, [__jacJsx("p", {"className": "mb-1 font-semibold"}, [overviewTitle]), __jacJsx("p", {"className": "leading-relaxed"}, [props.advicePlan.overview])]), props.advicePlan.steps && props.advicePlan.steps.length > 0 && __jacJsx("div", {}, [__jacJsx("p", {"className": "mb-1 font-semibold"}, [stepsTitle]), __jacJsx("ol", {"className": "list-decimal space-y-1 pl-5"}, [props.advicePlan.steps.map(step => {
    return __jacJsx("li", {}, [step]);
  })])]), props.advicePlan.cautions && props.advicePlan.cautions.length > 0 && __jacJsx("div", {"className": "rounded-xl border border-amber-100 bg-amber-50 p-3"}, [__jacJsx("p", {"className": "mb-1 text-sm font-semibold text-amber-800"}, [cautionsTitle]), __jacJsx("ul", {"className": "list-disc space-y-1 pl-5 text-xs text-amber-900"}, [props.advicePlan.cautions.map(c => {
    return __jacJsx("li", {}, [c]);
  })])])])])]);
}
function CacheDetailPage() {
  let [loading, setLoading] = useState(true);
  let [error, setError] = useState("");
  let [cache, setCache] = useState(null);
  let navigate = useNavigate();
  let params = useParams();
  let encodedKey = params.encodedKey || "";
  let cacheKey = "";
  if (encodedKey) {
    try {
      cacheKey = decodeURIComponent(encodedKey);
    } catch (err) {
      console.error("Failed to decode cache key:", err);
      cacheKey = encodedKey;
    }
  }
  useEffect(() => {
    async function fetchDetail() {
      setLoading(true);
      setError("");
      setCache(null);
      if (!cacheKey) {
        setError("Missing cache key in URL.");
        setLoading(false);
        return;
      }
      try {
        let res = await __jacSpawn("GetAdviceCacheDetail", "", {"cache_key": cacheKey});
        console.log("GetAdviceCacheDetail result:", res);
        let detail = null;
        if (res && "reports" in res && res.reports.length > 0) {
          detail = res.reports[res.reports.length - 1];
        }
        if (detail && detail.ok) {
          setCache(detail);
        } else {
          let msg = "Failed to load cache detail.";
          if (detail && detail.error) {
            msg = detail.error;
          }
          setError(msg);
        }
      } catch (err) {
        console.error("CacheDetailPage fetchDetail exception:", err);
        setError("Failed to load cache detail.");
      } finally {
        setLoading(false);
      }
    }
    fetchDetail();
  }, [cacheKey]);
  function handleBackClick(e) {
    e.preventDefault();
    navigate("/admin");
  }
  let titleKey = cacheKey;
  if (!titleKey) {
    titleKey = "(no key)";
  }
  let parsed = {};
  let advice = {};
  let meta = {};
  let session = null;
  if (cache) {
    parsed = cache.parsed || {};
    advice = cache.advice || {};
    meta = cache.meta || {};
    session = cache.session || null;
  }
  let crop = parsed["crop"] || "";
  let region = parsed["location"] || parsed["region"] || "";
  let lang = parsed["lang"] || "";
  let problem = parsed["problem_preview"] || parsed["problem"] || "";
  let created_at = meta["created_at"] || "";
  let last_used_at = meta["last_used_at"] || "";
  let usage_count = meta["usage_count"] || 0;
  let session_id = "";
  let session_lang = "";
  let session_created = "";
  let session_last_active = "";
  let session_history = "";
  if (session) {
    session_id = session["session_id"] || "";
    session_lang = session["lang"] || "";
    session_created = session["created_at"] || "";
    session_last_active = session["last_active_at"] || "";
    session_history = session["history"] || "";
  }
  return __jacJsx("div", {"className": "space-y-4"}, [__jacJsx("div", {"className": "flex items-center justify-between gap-3"}, [__jacJsx("div", {}, [__jacJsx("h1", {"className": "text-xl font-semibold text-slate-900"}, ["Advice cache detail"]), __jacJsx("p", {"className": "mt-1 text-xs text-slate-500"}, ["Inspect a single advice cache entry, its session, and full plan."])]), __jacJsx("button", {"className": "rounded-full border border-slate-300 px-4 py-1.5 text-xs font-medium text-slate-700 hover:bg-slate-50", "onClick": handleBackClick}, ["← Back to admin"])]), __jacJsx("div", {"className": "rounded-2xl border border-slate-200 bg-white p-4 text-[11px] text-slate-600"}, [__jacJsx("p", {"className": "mb-1 font-semibold text-slate-800"}, ["Cache key"]), __jacJsx("p", {"className": "font-mono break-all"}, [titleKey])]), loading && __jacJsx("div", {"className": "rounded-2xl border border-slate-200 bg-white p-4 text-sm text-slate-500"}, ["Loading cache details…"]), !loading && error && __jacJsx("div", {"className": "rounded-2xl border border-red-200 bg-red-50 p-4 text-xs text-red-700"}, [error]), !loading && !error && cache && __jacJsx("div", {"className": "space-y-4"}, [__jacJsx("div", {"className": "rounded-2xl border border-slate-200 bg-white p-4 text-xs text-slate-700"}, [__jacJsx("div", {"className": "grid gap-3 md:grid-cols-2"}, [__jacJsx("div", {}, [__jacJsx("p", {"className": "text-[10px] uppercase tracking-wide text-slate-400"}, ["Crop"]), __jacJsx("p", {"className": "mt-1 text-sm font-medium text-slate-900"}, [crop || "\u2014"])]), __jacJsx("div", {}, [__jacJsx("p", {"className": "text-[10px] uppercase tracking-wide text-slate-400"}, ["Region"]), __jacJsx("p", {"className": "mt-1 text-sm font-medium text-slate-900"}, [region || "\u2014"])]), __jacJsx("div", {}, [__jacJsx("p", {"className": "text-[10px] uppercase tracking-wide text-slate-400"}, ["Language"]), __jacJsx("p", {"className": "mt-1 text-sm font-medium text-slate-900"}, [lang || "\u2014"])]), __jacJsx("div", {}, [__jacJsx("p", {"className": "text-[10px] uppercase tracking-wide text-slate-400"}, ["Problem (preview)"]), __jacJsx("p", {"className": "mt-1 text-sm font-medium text-slate-900 line-clamp-3"}, [problem || "\u2014"])])]), __jacJsx("div", {"className": "mt-3 flex flex-wrap gap-4 text-[11px] text-slate-600"}, [__jacJsx("span", {}, [__jacJsx("span", {"className": "font-semibold"}, ["Created:"]), " ", created_at || "\u2014"]), __jacJsx("span", {}, [__jacJsx("span", {"className": "font-semibold"}, ["Last used:"]), " ", last_used_at || "\u2014"]), __jacJsx("span", {}, [__jacJsx("span", {"className": "font-semibold"}, ["Usage count:"]), " ", usage_count])])]), session && __jacJsx("div", {"className": "rounded-2xl border border-slate-200 bg-slate-50 p-4 text-xs text-slate-700"}, [__jacJsx("p", {"className": "mb-2 text-[11px] font-semibold uppercase tracking-wide text-slate-600"}, ["Owning session"]), __jacJsx("div", {"className": "grid gap-2 md:grid-cols-2"}, [__jacJsx("div", {}, [__jacJsx("p", {"className": "text-[10px] uppercase tracking-wide text-slate-400"}, ["Session ID"]), __jacJsx("p", {"className": "mt-1 font-mono text-[11px]"}, [session_id || "\u2014"])]), __jacJsx("div", {}, [__jacJsx("p", {"className": "text-[10px] uppercase tracking-wide text-slate-400"}, ["Lang"]), __jacJsx("p", {"className": "mt-1"}, [session_lang || "\u2014"])]), __jacJsx("div", {}, [__jacJsx("p", {"className": "text-[10px] uppercase tracking-wide text-slate-400"}, ["Created"]), __jacJsx("p", {"className": "mt-1"}, [session_created || "\u2014"])]), __jacJsx("div", {}, [__jacJsx("p", {"className": "text-[10px] uppercase tracking-wide text-slate-400"}, ["Last active"]), __jacJsx("p", {"className": "mt-1"}, [session_last_active || "\u2014"])])]), session_history && __jacJsx("div", {"className": "mt-3"}, [__jacJsx("p", {"className": "mb-1 text-[10px] font-semibold uppercase tracking-wide text-slate-500"}, ["Recent history"]), __jacJsx("pre", {"className": "max-h-40 overflow-y-auto whitespace-pre-wrap rounded-lg bg-white px-2 py-1 text-[10px] text-slate-700"}, [session_history])])]), __jacJsx("div", {"className": "rounded-2xl border border-slate-200 bg-white p-4 text-sm text-slate-800"}, [__jacJsx("div", {"className": "space-y-3"}, [__jacJsx("div", {}, [__jacJsx("p", {"className": "mb-1 text-xs font-semibold uppercase tracking-wide text-slate-500"}, ["Overview"]), __jacJsx("p", {"className": "leading-relaxed"}, [advice.overview || "\u2014"])]), advice.steps && advice.steps.length > 0 && __jacJsx("div", {}, [__jacJsx("p", {"className": "mb-1 text-xs font-semibold uppercase tracking-wide text-slate-500"}, ["Steps"]), __jacJsx("ol", {"className": "list-decimal space-y-1 pl-5"}, [advice.steps.map((step, idx) => {
    return __jacJsx("li", {"key": idx}, [step]);
  })])]), advice.cautions && advice.cautions.length > 0 && __jacJsx("div", {"className": "rounded-xl border border-amber-100 bg-amber-50 p-3"}, [__jacJsx("p", {"className": "mb-1 text-xs font-semibold uppercase tracking-wide text-amber-800"}, ["Cautions"]), __jacJsx("ul", {"className": "list-disc space-y-1 pl-5 text-[11px] text-amber-900"}, [advice.cautions.map((c, idx) => {
    return __jacJsx("li", {"key": idx}, [c]);
  })])])])])])]);
}
function TopNav() {
  let tabs = [{"id": "advisor", "label": "Advisor", "path": "/"}, {"id": "admin", "label": "Admin", "path": "/admin"}, {"id": "debug", "label": "Debug", "path": "/debug"}];
  return __jacJsx("header", {"className": "border-b border-slate-200 bg-white/80 backdrop-blur"}, [__jacJsx("div", {"className": "mx-auto flex max-w-6xl items-center justify-between px-4 py-3"}, [__jacJsx("div", {"className": "flex items-center gap-2"}, [__jacJsx("div", {"className": "flex h-8 w-8 items-center justify-center rounded-xl bg-lime-500"}, [__jacJsx("span", {"className": "h-4 w-4 rounded-md bg-white/80"}, [])]), __jacJsx("span", {"className": "text-sm font-semibold text-slate-900"}, ["Virtual Agro-Advisor"])]), __jacJsx("nav", {"className": "flex items-center gap-2 text-sm"}, [tabs.map(tab => {
    return __jacJsx(Link, {"key": tab.id, "to": tab.path, "className": "rounded-full px-4 py-1.5 text-xs font-medium text-slate-600 hover:bg-lime-50 transition"}, [tab.label]);
  })])])]);
}
function WeatherSummaryPanel(props) {
  if (!props.summary) {
    return __jacJsx("div", {"className": "h-[150px] rounded-2xl border border-lime-100 bg-white p-4 text-sm text-slate-500"}, ["Weather summary will appear here when you request it."]);
  }
  let heading = "Weather Summary";
  if (props.meta && props.meta.titles && props.meta.titles.weather_summary) {
    heading = props.meta.titles.weather_summary;
  }
  return __jacJsx("div", {"className": "h-[150px] rounded-2xl border border-lime-100 bg-white p-4"}, [__jacJsx("div", {"className": "mb-2 flex items-center justify-between"}, [__jacJsx("h3", {"className": "text-sm font-semibold text-slate-900"}, [heading])]), __jacJsx("div", {"className": "h-full overflow-y-auto"}, [__jacJsx("p", {"className": "text-sm text-slate-700 leading-relaxed"}, [props.summary.summary_text])])]);
}
function PageShell(props) {
  return __jacJsx("main", {"className": "mx-auto max-w-6xl px-4 py-6"}, [props.children]);
}
export { AdminPage, AdvicePlanPanel, AdvisorForm, AdvisorPage, CacheDetailPage, DebugPage, MarketSummaryPanel, PageShell, TopNav, WeatherSummaryPanel, app, computeStats, extractAdvice, extractAnalysis, extractReports, formatShortDatetime, makeCutoffString, parseCacheKey };
