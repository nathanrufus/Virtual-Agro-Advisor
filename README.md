# Virtual Agro‑Advisor

Virtual Agro‑Advisor is a graph‑based, LLM‑powered assistant that helps smallholder farmers get tailored crop management advice.  
It combines agronomy expertise, weather context, basic market signals, and a session‑aware memory into a single web app built on the **Jac** ecosystem.

The Jac app itself lives in the `agro-advisor/` folder of this repository. This README assumes the layout:

```text
Virtual-Agro-Advisor/
├── agro-advisor/        # Jac app (backend + frontend + deps)
│   ├── app.jac
│   ├── app.impl.jac
│   ├── app.cl/
│   ├── utils.jac
│   ├── intergrations.jac
│   ├── requirements.txt
│   ├── package.json
│   └── ...
└── (other top-level files, e.g. .git, docs, etc.)
```

The project is split into:

- **Backend graph & walkers** in `app.jac` and `app.impl.jac`
- **Frontend UI** in `app.cl/` using Jac’s React client and Tailwind CSS
- **LLM + integrations** wired through `byllm.llm` and helper modules in `utils.jac` and `intergrations.jac`
- **Per‑user auth** built on Jac’s built‑in `/user/create` and `/user/login` endpoints

---

## 1. High‑level features

-  **Personalized agronomy advice**
  - Farmers describe issues in free text (e.g., _“maize leaves turning yellow with brown spots”_).
  - Backend classifies the problem (pest, disease, nutrient, weather, management, other) and severity.
  - Returns a structured **Advice Plan** with overview, step‑by‑step actions, and safety cautions.

-  **Per‑user login with private sessions**
  - Uses Jac’s built‑in auth (`/user/create`, `/user/login`) to create and log in users.
  - Each authenticated user gets their **own graph** on the backend, so sessions, advice cache, and audit logs are isolated per user.
  - The UI shows **Login / Sign up / Logout** controls in the header, next to the main navigation.

-  **Weather‑aware recommendations**
  - Optionally fetches and summarizes live‑like weather data for the farmer’s location via `fetch_weather_raw` + `summarize_weather`.
  - Weather context is fed into the LLM so advice can consider rainfall, temperature, wind, etc.

-  **Market context (LLM price estimate, pluggable)**
  - Optionally adds a **non‑authoritative** KES/kg price estimate for the selected crop and region.
  - Clear disclaimer: this is _not_ live market data; farmers must still confirm with local buyers.
  - The design allows plugging in a real market price API in place of the LLM helper later.

-  **Per‑session memory & history**
  - Within each user graph, every browser session is mapped to a `Session` node.
  - A short history of user–AI turns is stored per session and used to provide continuity between queries.

-  **Caching & reuse**
  - Advice is cached in `AdviceCache` nodes by a deterministic key based on crop, problem, location, language, and flags (weather/market/image).
  - Weather and market results are cached per session to avoid repeated API/LLM calls.

-  **Manage (admin) & debug tooling**
  - **Manage** tab (previously “Admin”) shows an overview of sessions and advice cache entries using:
    - `GetAllSessions` walker — lists all sessions and their metadata for the logged‑in user.
    - `GetAllAdviceCache` walker — lists all cached advice entries with usage stats.
  - **Debug** tab is reserved for LLM tooling:
    - `LLMAnalyzeDebug` — inspect the raw `IssueAnalysis`.
    - `LLMAdviceDebug` — inspect the full chain `{ issue_analysis, weather_summary, market_summary, advice_plan }`.

---

## 2. Tech stack

**Core language & runtime**

- Jac for graph modeling, walkers, and the integrated client/server model.
- Jac API server (`jac serve app.jac`) for both backend APIs and the compiled frontend.

**Backend logic**

- `app.jac` – public graph schema and walker interfaces.
- `app.impl.jac` – implementation of nodes, edges, walkers, and LLM helpers.
- `byllm.llm` – LLM integration, configured with Groq’s `groq/llama-3.3-70b-versatile` model (configurable).
- Custom helpers in:
  - `utils.jac` – e.g., `get_current_datetime()`, HTTP helpers.
  - `intergrations.jac` – weather integration (`fetch_weather_raw`, `summarize_weather`) and other external calls.

**Frontend**

- Jac client React bindings from `@jac-client/utils`.
- Tailwind CSS for styling (configured in `global.css` and the JS toolchain).
- Single‑page app, entry: `app.cl/app.cl.jac`.

**Auth**

- Uses Jac’s built‑in user system:
  - `/user/create` — sign up.
  - `/user/login` — log in and get an auth token.
- Frontend helpers from `@jac-client/utils`:
  - `jacIsLoggedIn`, `jacLogout`, plus `jacLogin`/`jacSignup` used in the auth pages.
- Per‑user graph isolation is handled by Jac, so data is scoped to the logged‑in user automatically.

Other tools:

- Vite (under the hood) for bundling the frontend.
- Python virtual environment + `requirements.txt` (inside `agro-advisor/`) for supporting tooling.

---

## 3. Project structure

Key layout (inside the `Virtual-Agro-Advisor/` repo):

```text
Virtual-Agro-Advisor/
├── agro-advisor/
│   ├── app.jac                  # Graph schema + walker declarations + cl entry
│   ├── app.impl.jac             # Walker implementations + nodes/edges/LLM helpers
│   ├── utils.jac                # Utilities (time, HTTP, logging helpers, etc.)
│   ├── intergrations.jac        # Weather + other integration helpers
│   ├── app.cl/
│   │   ├── app.cl.jac           # Frontend entry: router + protected routes
│   │   ├── TopNav.cl.jac        # Top navigation bar (Advisor / Manage / Debug + auth)
│   │   ├── PageShell.cl.jac     # Shared layout wrapper (full-width on large screens)
│   │   ├── AdvisorPage.cl.jac   # Main advisor screen
│   │   ├── AdvisorForm.cl.jac   # Left‑hand input form
│   │   ├── AdvicePlanPanel.cl.jac
│   │   ├── WeatherSummaryPanel.cl.jac
│   │   ├── MarketSummaryPanel.cl.jac
│   │   ├── AdminPage.cl.jac     # “Manage” dashboard (sessions + advice cache)
│   │   ├── CacheDetail.cl.jac   # Detail page for a single cache entry
│   │   ├── DebugPage.cl.jac     # Debug tools shell
│   │   └── AuthPages.cl.jac     # LoginPage + SignupPage
│   ├── global.css               # Tailwind + global styles
│   ├── package.json             # Frontend dependencies
│   ├── vite.config.js           # Vite config used by jac-client
│   ├── requirements.txt         # Python deps (lives here, NOT in repo root)
│   └── README.md                # (optional per-folder readme)
└── README.md                    # Main project README (this file)
```

> Jac currently does not support importing `.cl.jac` files from nested subdirectories, so most frontend components live directly inside `app.cl/` and are imported with e.g. `cl import from .TopNav { TopNav }`.

---

## 4. Backend architecture

### 4.1 Per‑user graphs

Jac’s auth model gives each authenticated user their own “root” object and underlying graph. That means:

- `Memory`, `Session`, `AdviceCache`, `WeatherSnapshot`, `MarketSnapshot`, and `AuditLog` nodes are **per user**.
- When user A logs in, their advisor history and cache are completely separate from user B’s.
- Logging out and logging in as a different user effectively switches to a different graph.

All walkers described below run **within the logged‑in user’s graph**.

### 4.2 Graph schema

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
  - Placeholder for future computer‑vision integrations.
- `AuditLog`
  - `event: str`, `cache_hit: bool`, `latency_ms: int`, `session_id: str`, `created_at`

**Edges**

- `HAS_SESSION`        (Memory → Session)
- `HAS_PROFILE`        (Memory → FarmerProfile or Session → FarmerProfile)
- `HAS_WEATHER`        (Session → WeatherSnapshot)
- `HAS_MARKET`         (Session → MarketSnapshot)
- `HAS_ADVICE`         (Session → AdviceCache)
- `HAS_IMAGE_ANALYSIS` (Session → ImageAnalysisResult)
- `HAS_AUDIT`          (Memory → AuditLog)

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

### 4.3 LLM helpers

LLM helpers are declared in Jac and backed by a global `llm` (from `byllm.llm`), with semantic constraints (`sem` blocks) that define how the model should behave.

Core helpers:

- `analyze_issue(crop, problem_text, location, history) -> IssueAnalysis`
- `generate_advice(analysis, weather, market, context) -> AdvicePlan`
- `safety_review(advice: AdvicePlan) -> AdvicePlan`
- `translate_to_pivot(text, lang) -> str`
- `translate_from_pivot(text, lang) -> str`
- `estimate_market_price(crop, region) -> float` (KES/kg number only)

Each helper is constrained to return **only structured data**, no extra commentary, which keeps the pipeline predictable and safe.

### 4.4 Walkers (backend APIs)

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
  include_image: bool = False  # reserved for future image analysis
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
  4. Re‑translate advice, weather, and market summaries if language changed.
  5. Write an `AuditLog` indicating a **cache hit**.
  6. `report { session_id, advice_plan, weather_summary, market_summary, meta }`

#### Debug & management walkers

- `GetAllSessions` – returns an array of all sessions (IDs, language, timestamps) for the current user.
- `GetAllAdviceCache` – returns all advice cache entries across this user’s sessions.
- `LLMAnalyzeDebug` – returns raw `IssueAnalysis` for a given prompt.
- `LLMAdviceDebug` – returns the full chain without impacting user history/cache.
- `CleanupOldSessions` – delete sessions older than a cutoff (or all).
- `ClearAdviceCache` – delete all `AdviceCache` nodes under the user’s `Memory`.

---

## 5. Frontend architecture

The frontend is written in Jac’s client‑side React flavor.

### 5.1 Entry & routing

**Entry file**: `app.cl/app.cl.jac`

- Uses `Router`, `Routes`, and `Route` from `@jac-client/utils`.
- Routes:

  - `/login` → `LoginPage` (public)
  - `/signup` → `SignupPage` (public)
  - `/` → `AdvisorPage` (protected)
  - `/admin` → `AdminPage` (protected, shown as **Manage** in the nav)
  - `/debug` → `DebugPage` (protected)
  - `/admin/cache/:encodedKey` → `CacheDetailPage` (protected detail view for a single cache entry)

- A small `ProtectedRoute` component wraps protected routes, using `jacIsLoggedIn()` to decide whether to render the element or redirect to `/login`.

### 5.2 Top navigation

**`TopNav.cl.jac`**

- Shows:

  - Logo + title (“Virtual Agro‑Advisor”).
  - Tabs: **Advisor**, **Manage**, **Debug** (using `Link` from `@jac-client/utils`).
  - Auth controls on the right:
    - If logged **out** (`!jacIsLoggedIn()`): `Login` and `Sign up` links.
    - If logged **in**: a green‑outlined **Logout** button, wired to `jacLogout()` and `useNavigate()` to send the user back to `/login`.

### 5.3 Layout & styling

**`PageShell.cl.jac`**

- Wraps all pages in a full‑width container:

  - Uses `w-full` instead of `max-w-6xl`, so on large screens the content can stretch wide.
  - Horizontal padding (`px-4 sm:px-6 lg:px-10`) keeps content away from the very edges.

**Styling highlights**

- Tailwind CSS utilities throughout (`global.css` is imported at the top of `app.cl.jac`).
- General design language:
  - Light green/neutral page background (`bg-[#F3F7F2]`).
  - White cards with rounded corners and soft borders.
  - Primary actions in bright greens (`bg-green-500`, `border-emerald-600`).
  - Responsive grid layout for the main advisor view: form on the left, results on the right.

### 5.4 Advisor page and components

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
    result = root spawn AgroAdvisor(
        crop=crop,
        problem_text=problemText,
        location=location,
        session_id=sessionId,
        language=language,
        include_weather=includeWeather,
        include_market=includeMarket
    );
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
- Optional image upload placeholder (front‑end only for now).
- “Get Advice” button that triggers `onSubmit()`.

**`AdvicePlanPanel.cl.jac`**

- Shows a placeholder message until `advicePlan` is populated.
- Once advice is available:
  - Renders `overview` text with a localized title (e.g., “Overview” / “Muhtasari”).
  - Renders **numbered** steps as an ordered list.
  - Renders cautions in a highlighted warning box with a localized title.
- Shows a small badge (`Source: fresh` or `Source: cache`) based on `meta.source`.

**`WeatherSummaryPanel.cl.jac` and `MarketSummaryPanel.cl.jac`**

- Show placeholder text when no data is available.
- Once data is present, display `summary.summary_text` in a styled card with localized section titles (“Weather Summary”, “Market Summary”, or their Swahili equivalents).

### 5.5 Manage (admin) dashboard

**`AdminPage.cl.jac`** (labelled **Manage** in the nav):

- Fetches data using:

  - `root spawn GetAllSessions()`
  - `root spawn GetAllAdviceCache()`

- Shows:

  - Summary cards (total sessions, advice cache entries, latest activity).
  - Sessions table (session id, language, created, last active).
  - Advice cache table (parsed from `cache_key`: crop, region, problem, plus usage count and last used).

- Clicking an advice cache row navigates to:

  - `/admin/cache/:encodedKey` → `CacheDetailPage`

**`CacheDetail.cl.jac`**

- Decodes the `encodedKey` from the URL.
- Shows a detailed view of the parsed cache key plus any available metadata (usage count, timestamps, etc.).
- Designed as a debugging/inspection tool to see what was cached for a given crop/problem/location/lang combination.

### 5.6 Auth pages

**`AuthPages.cl.jac`** defines:

- `LoginPage`
  - Centered card with email/password inputs.
  - Calls `jacLogin(email, password)` under the hood (via `@jac-client/utils` helper or a small wrapper) and redirects to `/` on success.
- `SignupPage`
  - Similar card with email/password confirmation.
  - Calls `jacSignup` (or `/user/create`) and then logs the user in or redirects to login.

Both pages use the same green/neutral color palette as the rest of the app.

---

## 6. Getting started

### 6.1 Prerequisites

- Python 3.10+
- Node.js + npm
- Jac CLI
- API keys as needed:
  - Groq (or other LLM provider) for `byllm.llm`.
  - Gemini for image analysis
  - Weather API key used by `fetch_weather_raw`.

### 6.2 Setup

1. **Clone the repository**

   ```bash
   git clone https://github.com/nathanrufus/Virtual-Agro-Advisor.git
   cd Virtual-Agro-Advisor/agro-advisor
   ```

2. **Python environment**

   ```bash
   python -m venv venv
   source venv/bin/activate        # Linux/macOS
   # .\venv\Scripts\activate       # Windows

   pip install -r requirements.txt
   ```

3. **Node dependencies**

   ```bash
   npm install
   ```

4. **Environment variables**

   Create `.env` inside `agro-advisor/` and add at minimum:

   ```bash
   GROQ_API_KEY=your_groq_api_key_here
   WEATHER_API_KEY=your_weather_api_key_here  
   ```

   These are loaded at startup via:

   ```jac
   with entry {
       load_dotenv();
   }
   ```

### 6.3 Running the app (local dev)

From `Virtual-Agro-Advisor/agro-advisor`:

```bash
jac serve app.jac
```

The server will:

- Start the Jac API + auth endpoints.
- Build and serve the frontend SPA.

Open:

- `http://localhost:8000/page/app#/login` — login screen (or signup).
- After logging in, you’ll be redirected to the main **Advisor** view.

---
 ### 6.4 Running the app with Docker

You can run the Jac server and frontend entirely in a Docker container using Docker Compose.  
There is:

- `Dockerfile` is inside `Virtual-Agro-Advisor/agro-advisor/`
- `requirements.txt`, `package.json`, `app.jac`, etc. are all in the same `agro-advisor/` folder
- You have a `.env` file inside `agro-advisor/` with your keys:

  ```bash
  GROQ_API_KEY=your_groq_api_key_here
  WEATHER_API_KEY=your_weather_api_key_here
  ```

From the project root (`Virtual-Agro-Advisor/`), build and start the app:

```bash
cd Virtual-Agro-Advisor
docker compose up --build
```

Once it is running, open:

```text
http://localhost:8000
```

(or the port defined in `docker-compose.yml`) in your browser.

To run the app in the background:

```bash
docker compose up --build -d
```

To stop and remove the containers:

```bash
docker compose down
```
## 7. Using the app

1. **Sign up**

   - Click **Sign up** in the header.
   - Create a new account (email/password).
   - Either get auto‑logged in or go back to **Login**.

2. **Log in**

   - Enter your credentials on the **Login** page.
   - On success, you’ll be redirected to the **Advisor** tab.

3. **Get advice**

   - Fill the form with crop, location, and problem description.
   - Choose language (EN / SW).
   - Toggle weather and market context on/off as needed.
   - Click **Get Advice**.

   The right‑hand side shows:

   - **Advice Plan** – overview, numbered steps, and cautions.
   - **Weather Summary** – plain English/Swahili description of current conditions.
   - **Market Summary** – short description and LLM‑estimated price with a disclaimer.

4. **Inspect sessions & cache (Manage tab)**

   - Click **Manage** in the top nav.
   - View:
     - Summary cards (total sessions, total advice cache entries, latest activity).
     - Sessions table.
     - Advice cache table.
   - Click a cache entry (depending on your implementation) to see more details on the `CacheDetail` page.

5. **Debug (Debug tab)**

   - Reserved for running debug walkers and showing raw LLM chains.
   - Helpful during development when tuning prompts or diagnosing issues.

6. **Logout**

   - Click **Logout** in the top nav to clear your auth token and return to the login view.

---

## 8. Development & debugging tips

- **Frontend console**

  - `AdvisorPage` logs outgoing parameters and the raw Walker responses (`result`, `result.reports`, and the selected `payload`) to the browser console.

- **Backend logs**

  - Print statements in `AgroAdvisor`, `WeatherAgent`, and `MarketAgent` include tags like `[Weather]` and `[MarketLLM]` so you can see what’s happening server‑side.

- **Direct walker calls**

  - You can call walkers with `curl` while the server is running, for example:

    ```bash
    curl -X POST "http://localhost:8000/walker/AgroAdvisor" \
      -H "Content-Type: application/json" \
      -d '{
        "ctx": "root",
        "crop": "maize",
        "problem_text": "yellowing leaves with brown tips",
        "location": "Kiambu, Kenya",
        "language": "en",
        "include_weather": true,
        "include_market": true
      }'
    ```

  - For debug walkers:

    ```bash
    curl -X POST "http://localhost:8000/walker/GetAllSessions" \
      -H "Content-Type: application/json" \
      -d '{"ctx": "root"}'
    ```

    (Make sure you include valid auth headers or run from an authenticated Jac shell if required.)

- **Common pitfalls**

  - Forgetting to pass `ctx: "root"` when calling walkers over HTTP.
  - Not reading from `result.reports` on the frontend; `AgroAdvisor`’s report is the last item.
  - Using ternary operators in Jac where a simple `if`/`else` is safer and clearer.

---

## 9. Roadmap / future improvements

- **Real market data integration**

  - Replace the LLM‑based `estimate_market_price` with live APIs (e.g., FEWS NET or national market boards).
  - Store API payloads in `MarketSnapshot.raw_source` and reflect them more explicitly in `MarketSummary`.

- **Offline / low‑connectivity mode**

  - Pre‑load generic best‑practice advice for common crops and problems when the LLM or weather APIs are not reachable.

- **Richer farmer profiles**

  - Expand `FarmerProfile` with more structured info (farm size, soil type, typical pests/diseases) and surface it in the advisor prompts.

- **Full image analysis pipeline**

  - Implement `ImageAnalysisAgent` wired to a multimodal model (e.g., Gemini Vision).
  - Let farmers upload leaf photos and blend image‑derived symptoms into `IssueAnalysis`.

- **Per‑user analytics**

  - Add more management views (within the **Manage** tab) to show how often a user asks about each crop/problem type, without ever exposing another user’s data.

---

## 10. Acknowledgements

- Jac language and ecosystem for providing the graph‑native, LLM‑integrated runtime.
- Groq (or your chosen LLM provider) for the underlying model powering the agronomy reasoning.
- Any agronomy references or local extension services consulted while shaping the prompt semantics and safety checks.
