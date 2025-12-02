
import from byllm.llm { Model }
import from dotenv { load_dotenv }
include utils; 

# Global LLM model using Groq (change model_name if you want another Groq model)
glob llm = Model(
    model_name="groq/llama-3.3-70b-versatile",
    verbose=False
);
# glob llm = Model(
#     model_name="gemini/gemini-2.0-flash",
#     verbose=False
# );
# Core graph schema: nodes

node Memory {
    has id: str = "memory_root";
    # You can add more global configuration fields later if needed.
}

node Session {
    has session_id: str;
    has lang: str = "en";
    has history: list[str,...] = [];          # list of short text history entries
    has created_at: str = get_current_datetime();
    has last_active_at: str = get_current_datetime();

    def add_history(entry: str) {
        self.history = self.history + [entry];
        self.last_active_at = get_current_datetime();
    }

    def get_history -> str {
        # Return last 10 turns as a single string, newest last.
        return "\n".join(self.history[-10:]);
    }
}

node FarmerProfile {
    has farmer_id: str;
    has name: str = "";
    has region: str = "";        # e.g. "Kiambu, Kenya"
    has primary_crops: list [str, ...]= [];# e.g. ["maize", "beans"]
    has preferred_lang: str = "en";
}

node AdviceCache {
    has cache_key: str;
    has advice: AdvicePlan;
    has created_at: str = get_current_datetime();
    has last_used_at: str = get_current_datetime();
    has usage_count: int = 0;

    def touch() {
        self.usage_count = self.usage_count + 1;
        self.last_used_at = get_current_datetime();
    }
}

node WeatherSnapshot {
    has location_key: str;       # normalized location identifier
    has summary: str;           # human-readable weather summary
    has raw_source: str = "";   # optional JSON/string from API
    has created_at: str = get_current_datetime();
}

node MarketSnapshot {
    has crop_key: str;          # normalized crop name
    has region_key: str;        # normalized region identifier
    has summary: str;           # human-readable market summary
    has raw_source: str = "";   # optional JSON/string from API or dataset
    has created_at: str = get_current_datetime();
}

node ImageAnalysisResult {
    has image_id: str;          # reference to stored image
    has labels: list [str, ...]= [];      # e.g. ["leaf blight", "yellowing"]
    has confidences: list[float, ...]  = []; # parallel list of confidence scores
    has notes: str = "";
    has created_at: str = get_current_datetime();
}

node AuditLog {
    has event: str;             # free-text description or JSON
    has created_at: str = get_current_datetime();
    has cache_hit: bool = False;
    has latency_ms: int = 0;
    has session_id: str = "";
}


#  Edges: how nodes relate in the graph

edge HAS_SESSION {}

edge HAS_PROFILE {}

edge HAS_WEATHER {}

edge HAS_MARKET {}

edge HAS_ADVICE {}

edge HAS_IMAGE_ANALYSIS {}

edge HAS_AUDIT {}


# Structured objects (used by LLM + walkers)

obj IssueAnalysis {
    has problem_type: str;      # e.g. "pest", "disease", "nutrient", "weather", "management"
    has severity: str;          # e.g. "low", "medium", "high"
    has key_symptoms: list [str, ...]= [];# list of important symptom strings
}

obj FarmerContext {
    has region: str;
    has lang: str = "en";
}

obj WeatherSummary {
    has summary_text: str;      # short text for the LLM / UI
}

obj MarketSummary {
    has summary_text: str;      # short text for the LLM / UI
}

obj AdvicePlan {
    has overview: str;          # 3–5 sentence summary of the situation
    has steps: list [str, ...]= [];       # ordered list of recommended actions
    has cautions: list[str, ...] = [];    # safety notes / warnings
}



# LLM-powered helper functions (byLLM) - declarations only

"""Analyze the farmer's problem into structured issue fields."""
def analyze_issue(
    crop: str,
    problem_text: str,
    location: str,
    history: str
) -> IssueAnalysis by llm();

"""Generate a structured agronomy advice plan."""
def generate_advice(
    analysis: IssueAnalysis,
    weather: WeatherSummary,
    market: MarketSummary,
    context: FarmerContext
) -> AdvicePlan by llm();

"""Review the advice plan for safety and realism."""
def safety_review(
    advice: AdvicePlan
) -> AdvicePlan by llm();

""" translate text into a pivot language for reasoning."""
def translate_to_pivot(
    text: str,
    lang: str
) -> str by llm();

"""translate text from pivot language to user's language."""
def translate_from_pivot(
    text: str,
    lang: str
) -> str by llm();


# sem stubs: behavior constraints for the LLM helpers


sem analyze_issue = """
You are an agronomy intake assistant.
Given:
- crop (str)
- problem_text (farmer's free text)
- location (region or place)
- history (recent conversation turns)

Your job:
1. Set problem_type to one of:
   - "pest", "disease", "nutrient", "weather", "management", "other".
2. Set severity to one of:
   - "low", "medium", "high".
3. Fill key_symptoms as a list of 3–7 short, concrete symptom phrases.

Return a valid IssueAnalysis object.
Do not include any extra fields or free-form commentary.
""";

sem generate_advice = """
You are an agronomy advisor for smallholder farmers.
You receive:
- IssueAnalysis (problem_type, severity, key_symptoms)
- WeatherSummary (summary_text)
- MarketSummary (summary_text)
- FarmerContext (region, lang)

Your job:
1. Fill overview with a 3–5 sentence explanation of:
   - What is likely happening.
   - How weather/market factors may affect the situation (if relevant).
2. Fill steps as an ordered list of 4–10 short, concrete, numbered actions.
   - Each step should be simple and doable with limited resources.
3. Fill cautions with 2–5 short safety or risk notes:
   - What to avoid.
   - When to seek expert help or local extension services.

Do NOT invent specific prices or weather conditions.
Use only high-level statements unless precise facts are supplied via WeatherSummary or MarketSummary.
Return a valid AdvicePlan object and nothing else.
""";

sem safety_review = """
You are a safety and realism auditor for agronomy advice.
Input: AdvicePlan.

Tasks:
1. Check each step and caution for:
   - Safety (chemicals, machinery, risky operations).
   - Realism for smallholder farmers with limited resources.
2. Remove or rewrite any unsafe, unrealistic, or clearly harmful advice.
3. Preserve the structure: overview, steps, cautions.

Return a corrected AdvicePlan object only.
Do not add new fields or extra commentary outside the object.
""";

sem translate_to_pivot = """
Translate the input text into a suitable pivot language for reasoning (e.g. English).
Keep meaning and technical details accurate.
Return only the translated text as a plain string.
""";

sem translate_from_pivot = """
Translate the input text from the pivot language back into the target language 'lang'.
Preserve agricultural terminology and safety notes accurately.
Return only the translated text as a plain string.
""";

"""Estimate a reference market price in Kenyan shillings per kilogram for a given crop and region."""
def estimate_market_price(
    crop: str,
    region: str
) -> float by llm();
sem estimate_market_price = """
You are an agricultural market analyst.

Task:
- Estimate the current typical market price in KENYA for the given crop.
- The unit MUST be Kenyan shillings per kilogram (KES/kg).

Rules:
- Use recent, realistic values based on your knowledge.
- If a specific region is given (e.g. 'Kiambu, Kenya'), prefer that region.
- If you are unsure, give a reasonable nationwide average.

CRITICAL OUTPUT FORMAT:
- Respond with ONLY a single positive number.
- No words, no units, no commas, no explanations.
- Example of valid output: 45.5
- Examples of INVALID output: '45 KES/kg', 'about 45', 'Price is 45.5'

Return a float representing KES per kg.
""";


#  Walker interfaces 
# Implementation in app.impl.jac 

walker SessionManager {
    has session_id: str = "";
    has lang: str = "en";

    can run with `root entry;
}

walker WeatherAgent {
    has location: str;

    can run with Session entry;
}

walker MarketAgent {
    has crop: str;
    has region: str;

    can run with Session entry;
}

walker AuditAgent {
    has event: str;
    has cache_hit: bool = False;
    has latency_ms: int = 0;
    has session_id: str = "";

    can run with Memory entry;
}

walker GetAllSessions {
    can run with `root entry;
}

walker GetAllAdviceCache {
    can run with `root entry;
}

walker AgroAdvisor {
    has crop: str;
    has problem_text: str;
    has location: str;
    has session_id: str = "";
    has language: str = "en";
    has include_weather: bool = True;
    has include_market: bool = True;

    can run with `root entry;
}


walker LLMAnalyzeDebug {
    has crop: str;
    has problem_text: str;
    has location: str;
    has language: str = "en";

    can run with `root entry;
}

walker LLMAdviceDebug {
    has crop: str;
    has problem_text: str;
    has location: str;
    has language: str = "en";
    has include_weather: bool = True;
    has include_market: bool = True;

    can run with `root entry;
}

# Startup hook: load environment variables (for Groq, APIs)

with entry {
    load_dotenv();
}
