import from byllm.lib { Model, Image }
import from dotenv { load_dotenv }
include utils;
include intergrations;

glob llm = Model(
    model_name="groq/llama-3.3-70b-versatile",
);

glob llm_vision = Model(
    model_name="gemini/gemini-2.0-flash",
);

node Memory {
    has id: str = "memory_root";
}

node Session {
    has session_id: str;
    has lang: str = "en";
    has history: list[str, ...] = [];
    has created_at: str = get_current_datetime();
    has last_active_at: str = get_current_datetime();

    def add_history(history_entry: str) {
        self.history = self.history + [history_entry];
        self.last_active_at = get_current_datetime();
    }

    def get_history -> str {
        return "\n".join(self.history[-10:]);
    }
}

node FarmerProfile {
    has farmer_id: str;
    has name: str = "";
    has region: str = "";
    has primary_crops: list[str, ...] = [];
    has preferred_lang: str = "en";
}

# -----------------------------------------
# NEW: explicit region profile
# -----------------------------------------
node RegionProfile {
    has region_id: str;
    has display_name: str = "";
    has county: str = "";
    has sub_county: str = "";
    has lat: float = 0.0;
    has lon: float = 0.0;
    has agro_ecological_zone: str = "";
    has dominant_crops: list[str, ...] = [];
    has created_at: str = get_current_datetime();
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
    has location_key: str;
    has summary: str;
    has region_id: str = "";
    has region_name: str = "";
    has temperature_c: float = 0.0;
    has humidity_pct: float = 0.0;
    has precipitation_mm: float = 0.0;
    has wind_kph: float = 0.0;
    has forecast_temp_min_c: float = 0.0;
    has forecast_temp_max_c: float = 0.0;
    has forecast_precipitation_mm: float = 0.0;
    has disease_risk_score: int = 0;
    has disease_risk_level: str = "UNKNOWN";
    has disease_risk_reason: str = "";
    has raw_source: str = "";
    has created_at: str = get_current_datetime();
}

node MarketSnapshot {
    has crop_key: str;
    has region_key: str;
    has summary: str;
    has region_id: str = "";
    has region_name: str = "";
    has market_name: str = "";
    has admin1: str = "";
    has price: float = 0.0;
    has currency: str = "KES";
    has unit: str = "kg";
    has observed_date: str = "";
    has raw_source: str = "";
    has created_at: str = get_current_datetime();
}


node ImageAnalysisResult {
    has image_id: str;
    has labels: list[str, ...] = [];
    has confidences: list[float, ...] = [];
    has notes: str = "";
    has created_at: str = get_current_datetime();
}

node AuditLog {
    has event: str;
    has created_at: str = get_current_datetime();
    has cache_hit: bool = False;
    has latency_ms: int = 0;
    has session_id: str = "";
}

edge HAS_SESSION {}
edge HAS_PROFILE {}
edge HAS_REGION {}
edge HAS_WEATHER {}
edge HAS_MARKET {}
edge HAS_ADVICE {}
edge HAS_IMAGE_ANALYSIS {}
edge HAS_AUDIT {}
edge AFFECTS {}
edge OCCURS_IN {}
edge RELATED_TO_DISEASE {}
edge REPORTED_IN {}

obj IssueAnalysis {
    has problem_type: str;
    has severity: str;
    has key_symptoms: list[str, ...] = [];
}

obj FarmerContext {
    has region: str;
    has lang: str = "en";
    has knowledge: str = "";
}

obj WeatherSummary {
    has summary_text: str;
}

obj MarketSummary {
    has summary_text: str;
}

obj AdvicePlan {
    has overview: str;
    has steps: list[str, ...] = [];
    has cautions: list[str, ...] = [];
}

obj ImageSymptomSummary {
    has labels: list[str, ...] = [];
    has confidences: list[float, ...] = [];
    has notes: str = "";
}

obj NormalizedInput {
    has crop: str;
    has location: str;
}

def normalize_crop_location(
    crop: str,
    location: str
) -> NormalizedInput by llm();

def analyze_issue(
    crop: str,
    problem_text: str,
    location: str,
    history: str
) -> IssueAnalysis by llm();

def generate_advice(
    analysis: IssueAnalysis,
    weather: WeatherSummary,
    market: MarketSummary,
    context: FarmerContext
) -> AdvicePlan by llm();

def safety_review(
    advice: AdvicePlan
) -> AdvicePlan by llm();

def translate_to_pivot(
    text: str,
    lang: str
) -> str by llm();

def translate_from_pivot(
    text: str,
    lang: str
) -> str by llm();

def analyze_crop_image(
    img: Image,
    crop: str,
    location: str
) -> ImageSymptomSummary by llm_vision();

def estimate_market_price(
    crop: str,
    region: str
) -> float by llm();

sem normalize_crop_location = """
You receive:
- crop: short text naming a crop (e.g. 'maiz', 'maize', 'wheet')
- location: short text naming a place or region (e.g. 'kiambu, kenia')

Your job:
1. Correct obvious spelling mistakes.
2. Use standard English crop and place names used in Kenya.
3. If the input is already correct, return it unchanged.
4. If you cannot guess, return the original text.

Return a NormalizedInput object with fields:
- crop: normalized crop name (e.g. 'maize')
- location: normalized location string (e.g. 'Kiambu, Kenya')

Do not add extra commentary or fields.
""";

sem analyze_crop_image = """
You are an agronomy vision assistant.

Given:
- img: an image of a crop or leaves
- crop: crop type
- location: region name

Tasks:
1. Fill labels with 3–7 short phrases describing visible symptoms
   (e.g. "yellowing leaf margins", "brown necrotic spots").
2. Fill confidences with numbers between 0 and 1, same length as labels.
3. Fill notes with 2–4 sentences summarizing what is visible and
   the most likely types of problems (pest, disease, nutrient, other).

Return ONLY a valid ImageSymptomSummary object.
""";

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

CRITICAL GOAL:
Return an AdvicePlan that is practical for a smallholder farmer and clearly ties:
(1) the likely problem,
(2) whether CURRENT weather conditions could be a contributing factor,
(3) whether CURRENT market conditions look favorable for selling (based on MarketSummary).

Your job:

1) OVERVIEW (3–5 sentences, plain language, no jargon):
- Sentence 1: Restate the likely problem using IssueAnalysis fields (problem_type, severity, symptoms).
- Sentence 2: Explain the most likely cause(s) given the symptoms.
- Sentence 3: Use WeatherSummary.summary_text to say whether current weather could be contributing:
  * If WeatherSummary says hot/dry → mention drought stress, pests, wilting risk, nutrient uptake issues.
  * If rainy/humid → mention disease pressure (fungal/bacterial), waterlogging, spread risk.
  * If WeatherSummary indicates "not requested"/no data → say weather influence cannot be confirmed.
  Do NOT invent weather details beyond summary_text.
- Sentence 4: Use MarketSummary.summary_text to give a simple market signal:
  * If it indicates strong/high/rising/good demand → "market looks favorable".
  * If weak/low/falling/oversupply → "market looks less favorable".
  * If MarketSummary indicates "not requested"/no data → say market outlook cannot be confirmed.
  Do NOT invent prices.
- Sentence 5 (optional): A short encouragement + immediate priority (“start with inspection today…”).

2) STEPS (4–10 items, MUST be specific and doable):
- Each step MUST begin with an explicit number and a dot: "1. ...", "2. ...", etc.
- Steps must be tailored to IssueAnalysis.problem_type and the key_symptoms:
  * pest: scouting + identification, mechanical removal, sanitation, safe controls (IPM), monitoring.
  * disease: sanitation, remove infected parts, spacing/airflow, avoid overhead watering, suitable controls, monitoring.
  * nutrient: soil/leaf symptom checks, balanced fertilizer/manure guidance, pH/drainage considerations, correct application timing.
  * weather: irrigation/drainage, mulching, shade/windbreaks, timing of field operations.
  * management: spacing, weeding, rotation, residue management, planting practices.
- Avoid generic “do better management” steps; make each step an action with a clear purpose.
- Keep steps realistic: low-cost options first; if recommending inputs, give safe general guidance (no exact doses unless provided).
- Maintain continuous numbering (1..N) with no gaps.

3) CAUTIONS (2–5 items, short safety/risk notes):
- Include: pesticide safety (read label, PPE), avoid mixing chemicals without guidance, keep children/livestock away,
  and when to consult an extension officer (rapid spread, severe damage, unknown pest/disease).
- No numbering required.

Formatting requirements for the AdvicePlan:
- overview: single string (3–5 sentences).
- steps: list of strings; each string MUST begin with "<number>. ".
- cautions: list of strings (short sentences).

Do NOT invent specific prices or weather conditions.
Use only what is stated in WeatherSummary.summary_text and MarketSummary.summary_text.
Return ONLY a valid AdvicePlan object and nothing else.
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

sem estimate_market_price = """
You are an agricultural market analyst.

Task:
- Estimate the current typical market price in KENYA for the given crop.
- The unit MUST be Kenyan shillings per kilogram (KES/kg).

Rules:
- Use recent, realistic values based on your knowledge.
- If a specific region is given, prefer that region.
- If you are unsure, give a reasonable nationwide average.

CRITICAL OUTPUT FORMAT:
- Respond with ONLY a single positive number.
- No words, no units, no commas, no explanations.

Return a float representing KES per kg.
""";


#  KNOWLEDGE LAYER START


node DiseaseDoc {
    has disease_id: str;
    has disease_name: str;
    has description: str;
    has symptoms: str;
    has treatments: str;
}

node CaseStudy {
    has case_id: str;
    has crop: str;
    has region: str;
    has problem: str;
    has diagnosis: str;
    has outcome: str;
}


with entry {
    load_dotenv();
}