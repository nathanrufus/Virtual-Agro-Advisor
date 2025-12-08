# Virtual Agro‑Advisor

Virtual Agro‑Advisor is a graph‑based, LLM‑powered assistant that helps smallholder farmers get tailored crop management advice.  
It combines agronomy expertise, weather context, basic market signals, and a session‑aware memory into a single web app built on the **Jac** ecosystem.

The project is split into:

- **Backend graph & walkers** in `app.jac` and `app.impl.jac`
- **Frontend UI** in `app.cl/` using Jac’s React client and Tailwind CSS
- **LLM + integrations** wired through `byllm.llm` and helper modules in `utils.jac` and `integrations.jac`

---

## 1. High‑level features

- 🌱 **Personalized agronomy advice**
  - Farmers describe issues in free text (e.g., *“maize leaves turning yellow with brown spots”*).
  - Backend classifies the problem (pest, disease, nutrient, weather, management, other) and severity.
  - Returns a structured **Advice Plan** with overview, step‑by‑step actions, and safety cautions.

- ☁️ **Weather‑aware recommendations**
  - Optionally fetches and summarizes live‑like weather data for the farmer’s location.
  - Weather context is fed into the LLM so advice can consider rainfall, temperature, wind, etc.

- 💹 **Market context (LLM price estimate)**
  - Optionally adds a **non‑authoritative** KES/kg price estimate for the selected crop and region.
  - Clear disclaimer: this is *not* live market data; farmers must still confirm with local buyers.

- 🧠 **Per‑session memory & history**
  - Each browser session is mapped to a `Session` node in the graph.
  - Short history of user–AI turns is stored per session and used to provide continuity between queries.

- ⚡ **Caching & reuse**
  - Advice is cached in `AdviceCache` nodes by a deterministic key based on crop, problem, location, language, and flags (weather/market).
  - Weather and market results are cached per session to avoid repeated API/LLM calls.

- 🛠️ **Admin & debug tooling (UI + walkers)**
  - `GetAllSessions` walker lists all sessions and their metadata.
  - `GetAllAdviceCache` walker lists all cached advice entries.
  - `LLMAnalyzeDebug` and `LLMAdviceDebug` walkers let you inspect the raw LLM reasoning chain.

---

## 2. Tech stack

**Core language & runtime**

- [Jac](https://jaseci.org/) for graph modeling, walkers, and the integrated client/server model.
- Jac API server (`jac serve app.jac`) for both backend APIs and the compiled frontend.

**Backend logic**

- `app.jac` – public graph schema and walker interfaces.
- `app.impl.jac` – implementation of nodes, edges, walkers, and LLM helpers.
- `byllm.llm` – LLM integration, configured with Groq’s `llama-3.3-70b-versatile` model (configurable).
- Custom helpers in:
  - `utils.jac` – e.g., `get_current_datetime()`
  - `integrations.jac` – weather integration (`fetch_weather_raw`, `summarize_weather`) and other external calls.

**Frontend**

- Jac client React bindings from `@jac-client/utils`.
- Tailwind CSS for styling (configured in `global.css` and the JS toolchain).
- Single‑page app, entry: `app.cl/app.cl.jac`.

Other tools:

- Vite (under the hood) for bundling the frontend.
- Python virtual environment + `requirements.txt` for supporting tooling.

---

## 3. Project structure

The important bits of this repo look like:

```text
agro-advisor/
├── app.jac              # Graph schema + walker declarations + cl entry
├── app.impl.jac         # Walker implementations + nodes/edges/LLM helpers
├── utils.jac            # Utilities (time, logging helpers, etc.)
├── intergrations.jac    # Weather + other integration helpers
├── app.cl/
│   ├── app.cl.jac       # Frontend entry: router + layout + pages
│   ├── TopNav.cl.jac    # Top navigation bar with router links
│   ├── PageShell.cl.jac # Shared layout wrapper
│   ├── AdvisorPage.cl.jac
│   ├── AdvisorForm.cl.jac
│   ├── AdvicePlanPanel.cl.jac
│   ├── WeatherSummaryPanel.cl.jac
│   ├── MarketSummaryPanel.cl.jac
│   └── (future) Admin + Debug pages
├── global.css           # Tailwind + global styles
├── package.json         # Frontend dependencies
├── vite.config.js       # Vite config used by jac-client
├── requirements.txt     # Python deps (if used)
└── README.md            # This file
```

> Note: Jac currently does not support importing `.cl.jac` files from nested subdirectories, so most frontend components live directly inside `app.cl/` and are imported with `cl import from .ComponentName { ComponentName }`.

---

## 4. Backend architecture

### 4.1 Graph schema

**Nodes**

- `Memory`
  - Singleton node that hangs off the Jac `root` object.
  - Acts as the root for sessions, profiles, cache, weather, market, and audit logs.
- `Session`
  - `session_id: str`
  - `lang: str = "en"`
  - `history: list[str]`
  - `created_at`, `last_active_at`
  - `add_history(entry: str)` – appends a short text entry and updates `last_active_at`.
  - `get_history() -> str` – returns the last 10 history entries joined as newline‑separated text.
- `FarmerProfile`
  - Optional profile data (farmer id, name, region, primary crops, preferred language).
- `AdviceCache`
  - `cache_key: str`
  - `advice: AdvicePlan`
  - `created_at`, `last_used_at`, `usage_count`
  - `touch()` increments `usage_count` and updates `last_used_at`.
- `WeatherSnapshot`
  - `location_key: str`
  - `summary: str`
  - `raw_source: str` (JSON / raw API text)
  - `created_at`
- `MarketSnapshot`
  - `crop_key: str`
  - `region_key: str`
  - `summary: str`
  - `raw_source: str` (LLM or future API payload)
  - `created_at`
- `ImageAnalysisResult`
  - Placeholder for future computer‐vision integrations.
- `AuditLog`
  - `event: str`, `cache_hit: bool`, `latency_ms: int`, `session_id: str`, `created_at`

**Edges**

- `HAS_SESSION`  (Memory → Session)
- `HAS_PROFILE`  (Memory → FarmerProfile or Session → FarmerProfile)
- `HAS_WEATHER`  (Session → WeatherSnapshot)
- `HAS_MARKET`   (Session → MarketSnapshot)
- `HAS_ADVICE`   (Session → AdviceCache)
- `HAS_IMAGE_ANALYSIS` (Session → ImageAnalysisResult)
- `HAS_AUDIT`    (Memory → AuditLog)

**Structured objects (Jac `obj`)**

- `IssueAnalysis`
  - `problem_type: "pest" | "disease" | "nutrient" | "weather" | "management" | "other"`
  - `severity: "low" | "medium" | "high"`
  - `key_symptoms: list[str]`
- `FarmerContext`
  - `region: str`
  - `lang: str`
- `WeatherSummary`
  - `summary_text: str`
- `MarketSummary`
  - `summary_text: str`
- `AdvicePlan`
  - `overview: str`
  - `steps: list[str]`
  - `cautions: list[str]`

### 4.2 LLM helpers

LLM helpers are declared in Jac and backed by a global `llm` (from `byllm.llm`), with detailed semantic constraints (`sem` blocks) that define how the model should behave.

Core helpers:

- `analyze_issue(crop, problem_text, location, history) -> IssueAnalysis`
- `generate_advice(analysis, weather, market, context) -> AdvicePlan`
- `safety_review(advice: AdvicePlan) -> AdvicePlan`
- `translate_to_pivot(text, lang) -> str`
- `translate_from_pivot(text, lang) -> str`
- `estimate_market_price(crop, region) -> float` (KES/kg number only)

Each helper is constrained to return **only structured data**, no extra commentary, which keeps the pipeline predictable and safe.

### 4.3 Walkers (backend APIs)

#### `SessionManager`

- **Entry:** `root`
- **Use:** Ensure the existence of a `Memory` node and a `Session` matching a given `session_id` (or create one).
- **Output:** JSON with session metadata (id, lang, created/last active).

#### `WeatherAgent`

- **Entry:** `Session`
- **Use:** Fetch or reuse a cached `WeatherSnapshot` for a normalized location key.
- **Output:** `WeatherSummary` object.

#### `MarketAgent`

- **Entry:** `Session`
- **Use:** Estimate market price with `estimate_market_price`, cache it in `MarketSnapshot`, and return a `MarketSummary` object.
- **Note:** Pure LLM‑based at the moment; no live market API.

#### `AgroAdvisor` (main advisor API)

- **Entry:** `root`
- **Inputs:**

  ```text
  crop: str
  problem_text: str
  location: str
  session_id: str (optional)
  language: str = "en"
  include_weather: bool = True
  include_market: bool = True
  ```

- **Pipeline (cache‑miss):**

  1. Ensure `Memory` and `Session` for the given `session_id` (creating new if needed).
  2. Generate a **cache key** from normalized crop, problem text, location, language, and flags.
  3. If `include_weather`:
     - Fetch or reuse `WeatherSnapshot` for this session/location and create `WeatherSummary`.
  4. If `include_market`:
     - Fetch or reuse `MarketSnapshot` for this session/crop/region and create `MarketSummary`.
  5. Load recent session history (`Session.get_history()`).
  6. Call `analyze_issue()` to produce `IssueAnalysis`.
  7. Call `generate_advice()` with issue, weather, market, and `FarmerContext`.
  8. Call `safety_review()` to clean up unsafe or unrealistic advice.
  9. Translate advice if `language != "en"` using pivot‑language helpers.
  10. Cache the **safe** advice in `AdviceCache` for future reuse.
  11. Append a short “user/ai” pair to the session history.
  12. Write an `AuditLog` indicating a **fresh** result.
  13. `report { session_id, advice_plan, weather_summary, market_summary, meta }`

- **Pipeline (cache‑hit):**

  1. Retrieve cached `AdviceCache` by cache key.
  2. Update usage stats via `touch()`.
  3. Ensure weather/market snapshots are still present as above.
  4. Optionally re‑translate advice if language changed.
  5. Write an `AuditLog` indicating a **cache hit**.
  6. `report { session_id, advice_plan, weather_summary, market_summary, meta }`

#### Debug walkers

- `GetAllSessions` – returns an array of all sessions (IDs, language, timestamps).
- `GetAllAdviceCache` – returns all advice cache entries across sessions.
- `LLMAnalyzeDebug` – returns raw `IssueAnalysis` for a given prompt.
- `LLMAdviceDebug` – returns `IssueAnalysis`, `WeatherSummary`, `MarketSummary`, and `AdvicePlan` without touching cache or history.

---

## 5. Frontend architecture

The frontend is written in Jac’s client‑side React flavor.

### 5.1 Entry & routing

- **Entry file**: `app.cl/app.cl.jac`
- Uses `Router`, `Routes`, and `Route` from `@jac-client/utils`:

  - `/` → `AdvisorPage` (default view)
  - `/admin` → `AdminPage` (placeholder for now)
  - `/debug` → `DebugPage` (placeholder for LLM debug tools)

- `TopNav.cl.jac` uses `Link` from `@jac-client/utils` to render the **Advisor / Admin / Debug** navigation tabs.

### 5.2 Advisor page and components

**`AdvisorPage.cl.jac`**

- Local React state via `useState` for:
  - `crop`, `location`, `problemText`, `language`
  - `includeWeather`, `includeMarket`
  - `sessionId`, `loading`, `error`
  - `advicePlan`, `weatherSummary`, `marketSummary`, `meta`
- `handleGetAdvice()`:
  - Validates input.
  - Calls the backend via:

    ```jac
    result = root spawn AgroAdvisor(...);
    ```

  - Examines `result.reports` and selects the **last** report as the main payload.
  - Updates session ID and output states.
- Layout:
  - Left: `AdvisorForm` (input form).
  - Right: `AdvicePlanPanel`, `WeatherSummaryPanel`, `MarketSummaryPanel`.

**`AdvisorForm.cl.jac`**

- Controlled inputs for crop, location, and problem description.
- Language toggle (English / Swahili) implemented as pill buttons.
- Checkboxes for including weather forecast and market prices.
- “Get Advice” button that triggers `onSubmit()`.

**`AdvicePlanPanel.cl.jac`**

- Shows a placeholder message until `advicePlan` is populated.
- Once advice is available:
  - Renders `overview` text.
  - Renders numbered steps as a list.
  - Renders cautions in a highlighted warning box.
- Shows a small badge (`Source: fresh` or `Source: cache`) based on `meta.source`.

**`WeatherSummaryPanel.cl.jac` and `MarketSummaryPanel.cl.jac`**

- Show placeholder text when no data is available.
- Once data is present, display `summary.summary_text` in a styled card.

### 5.3 Styling

- Tailwind CSS utilities are used throughout (`global.css` is imported at the top of `app.cl.jac`).
- General design language:
  - Light green/neutral background.
  - White cards with rounded corners and soft borders.
  - Primary actions in bright green.
  - Responsive grid layout for main advisor view.

---

## 6. Getting started

### 6.1 Prerequisites

- Python 3.10+
- Node.js + npm (for the JS toolchain)
- Jac CLI (`pip install jaseci` or your chosen installation method)
- Access tokens / API keys for:
  - Groq (or other LLM provider) – used via `byllm.llm`
  - Weather API (if `fetch_weather_raw` depends on one)

### 6.2 Setup

1. **Clone the repository**

   ```bash
   git clone <your-repo-url> virtual-agro-advisor
   cd virtual-agro-advisor/agro-advisor
   ```

2. **Python environment** (optional but recommended)

   ```bash
   python -m venv venv
   source venv/bin/activate  # Linux/macOS
   # .env\Scriptsctivate  # Windows PowerShell

   pip install -r requirements.txt
   ```

3. **Node dependencies**

   ```bash
   npm install
   ```

4. **Environment variables**

   Copy `.env.example` to `.env` (if present) or create `.env` and add at minimum:

   ```bash
   GROQ_API_KEY=your_groq_api_key_here
   WEATHER_API_KEY=your_weather_api_key_here  # if needed by integrations
   ```

   The Jac entry file includes a startup hook:

   ```jac
   with entry {
       load_dotenv();
   }
   ```

   so these values are loaded automatically.

### 6.3 Running the app

From the project root (where `app.jac` lives):

```bash
jac serve app.jac
```

This will:

- Start the Jac API server (default at `http://0.0.0.0:8000`).
- Build the frontend using Vite.
- Serve the SPA and backend walkers on a single port.

Visit:

- **Advisor UI** – `http://localhost:8000/page/app`
- Admin / Debug tabs are accessible from the top navigation once the app loads.

---

## 7. Using the advisor

1. Open the **Advisor** tab (default).
2. Fill the form:
   - Crop (e.g., `maize`)
   - Location (e.g., `Kiambu, Kenya`)
   - Describe problem (e.g., `yellow leaves with brown edges`)
   - Choose language (English or Swahili)
   - Enable/disable weather and market checkboxes.
3. Click **Get Advice**.
4. The right‑hand side will populate with:
   - **Advice Plan** – overview, enumerated steps, and cautions.
   - **Weather Summary** – short text describing current conditions.
   - **Market Summary** – short text with a price estimate and warning.

If you submit the *same* crop/problem/location/language with the same flags, the response should be served from the **cache** (meta.source = `cache`) and will be much faster.

---

## 8. Development & debugging tips

- **Console logs (frontend)**  
  `AdvisorPage` logs outgoing payloads and the raw Walker responses to help you inspect `result.reports` and `payload`.

- **Jac server logs (backend)**  
  Print statements in `AgroAdvisor`, `WeatherAgent`, and `MarketAgent` (e.g. `[Weather] Raw length = ...`, `[MarketLLM] Using pure LLM estimate for ...`) show which branches are being executed and when cache is hit.

- **Debug walkers**  
  You can call the following from the Jac shell or future Debug UI:
  - `root spawn GetAllSessions()` – inspect all sessions.
  - `root spawn GetAllAdviceCache()` – inspect cache keys and usage.
  - `root spawn LLMAnalyzeDebug(...)` – see only the `IssueAnalysis`.
  - `root spawn LLMAdviceDebug(...)` – see the full chain without impacting user history/cache.

- **Common gotchas**  
  - Jac client currently does **not** support nested imports for `.cl.jac` files; keep components inside `app.cl/` and import via `cl import from .Component { Component }`.
  - `root spawn` results need to be read from `result.reports`. In this project, `AgroAdvisor`’s own `report { ... }` is the **last** element of that array.
  - Use strict equality/inequality (`==`, `!=`) and Jac’s Python‑like truthiness rules in conditions, not JavaScript’s `===` inside Jac code.

---

## 9. Roadmap / future improvements

Some ideas for evolving the project:

- **Real market data integration**
  - Replace or complement the LLM‑based `estimate_market_price` with live APIs (e.g., FEWS NET, national market boards).

- **Offline / low‑connectivity mode**
  - Pre‑load generic best‑practice advice for common crops and problems when the LLM or weather APIs are not reachable.

- **Farmer profiles & multi‑device sessions**
  - Persist `FarmerProfile` nodes more fully, with secure authentication linking multiple sessions to the same farmer.

- **Richer admin dashboards**
  - Flesh out the Admin UI to fully consume `GetAllSessions` and `GetAllAdviceCache`, including filters and inspection views as per the design mocks.

- **Image analysis**
  - Implement `ImageAnalysisResult` with a CV model to classify leaf diseases/pests from photos and feed that into the `IssueAnalysis` stage.

---

## 10. License

Add your preferred license here (e.g., MIT, Apache‑2.0) or keep the project private if it is coursework or internal work.

---

## 11. Acknowledgements

- Jac language and ecosystem for providing the graph‑native, LLM‑integrated runtime.
- Groq (or your chosen LLM provider) for the underlying model powering the agronomy reasoning.
- Any agronomy references or local extension services you consulted while shaping the prompt semantics.