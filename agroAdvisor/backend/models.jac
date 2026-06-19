import from byllm.lib { Model, Image }
import from dotenv { load_dotenv }
include utils;
include intergrations;

glob llm = Model(
    model_name="groq/llama-3.3-70b-versatile",
);

# glob llm = Model(
#     model_name="gemini/gemini-2.5-flash-lite",
# );

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
node Crop {
    has crop_id: str;
    has crop_name: str;
    has scientific_name: str;
    has common_varieties: list[str, ...] = [];
    has growing_season: str = "";
    has maturity_days: int = 0;
}

node Season {
    has season_id: str;
    has season_name: str;
    has months: list[str, ...] = [];
    has typical_weather: str = "";
}

node Symptom {
    has symptom_id: str;
    has symptom_name: str;
    has description: str;
    has visual_markers: list[str, ...] = [];
}

node Treatment {
    has treatment_id: str;
    has treatment_name: str;
    has method: str;  # "chemical", "organic", "cultural"
    has effectiveness: float = 0.0;
    has cost_kes: float = 0.0;
    has timing: str = "";
}

node RegionDiseaseCase {
    has case_id: str;
    has region_id: str;
    has disease_id: str;
    has crop_id: str;
    has season: str;
    has year: int;
    has severity: str;
    has outcome: str;
}
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

node RagDocument {
    has doc_id: str;
    has doc_type: str;
    has title: str;
    has content: str;
    has crop: str;
    has region: str;
    has created_at: str = get_current_datetime();
}

node DiseaseMatch {
    has disease_id: str;
    has disease_name: str;
    has confidence: float;
    has symptoms_matched: list[str, ...] = [];
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
# Disease relationships
edge AFFECTS_CROP {}          # Disease → Crop
edge OCCURS_IN_SEASON {}      # Disease → Season
edge COMMON_IN_REGION {}      # Disease → RegionProfile
edge HAS_SYMPTOM {}           # Disease → Symptom
edge TREATED_BY {}            # Disease → Treatment

# Crop relationships
edge GROWN_IN_REGION {}       # Crop → RegionProfile
edge GROWS_IN_SEASON {}       # Crop → Season

# Case study relationships
edge DOCUMENTED_CASE {}       # Disease → RegionDiseaseCase
edge CASE_IN_REGION {}        # RegionDiseaseCase → RegionProfile

# Co-occurrence relationships
edge CO_OCCURS_WITH {}        # Disease → Disease (link strength)
edge FOLLOWS_DISEASE {}       # Disease → Disease (temporal)

obj RagSearchResult {
    has query: str;
    has diseases: list[DiseaseMatch, ...] = [];
    has total_matches: int = 0;
}
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
) -> ImageSymptomSummary by llm();

def estimate_market_price(
    crop: str,
    region: str
) -> float by llm();

sem normalize_crop_location = """
You receive:
- crop: short text naming a crop (e.g. 'maiz', 'mahindi', 'wheet')
- location: short text naming a place or region (e.g. 'kiambu, kenia', 'nakuru')

Your job:
1. Correct obvious spelling mistakes.
2. Use standard English crop and place names used in Kenya.
   Kenya crops: maize, beans, potato, tomato, wheat, cassava, sorghum, banana, coffee, kale, sugarcane, tea
   Kenya regions: Nairobi, Kiambu, Nakuru, Nyeri, Muranga, Meru, Kisumu, Kakamega, Trans Nzoia,
                  Uasin Gishu, Nyandarua, Machakos, Mombasa, Kilifi, Lamu, Kisii, Siaya
3. If the input is already correct, return it unchanged.
4. If you cannot determine the correct spelling, return the original text.

Return a NormalizedInput object with fields:
- crop: normalized crop name
- location: normalized location string

No extra commentary or fields.
""";

sem analyze_crop_image = """
You are an agronomy vision assistant specialising in Kenyan smallholder crops.

Given:
- img: an image of a crop or crop leaves
- crop: crop type (maize, beans, potato, tomato, etc.)
- location: region name in Kenya

Tasks:
1. Fill labels with 3 to 7 short phrases describing visible symptoms.
   Examples: "yellowing leaf margins", "brown necrotic spots", "white powdery coating",
   "grey lesions parallel to veins", "holes in leaves with frass", "wilting of whole plant",
   "rust-coloured pustules", "water-soaked lesions"
2. Fill confidences with numbers between 0 and 1, same length as labels.
   Higher confidence = more clearly visible symptom.
3. Fill notes with 2 to 4 sentences:
   - What you see in the image
   - Most likely problem type (fungal disease, bacterial disease, pest, nutrient deficiency)
   - Whether the problem looks early-stage, moderate, or severe
   - One urgent action recommendation

Return ONLY a valid ImageSymptomSummary object.
""";

sem analyze_issue = """
You are an agronomy intake assistant for Kenyan smallholder farmers.

You receive:
- crop: the crop the farmer is growing
- problem_text: what the farmer reports in their own words
- location: region or county in Kenya (e.g. Kiambu, Nakuru)
- history: recent conversation turns

Your job:
1. Set problem_type to exactly one of:
   - "pest", "disease", "nutrient", "weather", "management", "other"
2. Set severity to exactly one of:
   - "low", "medium", "high"
3. Fill key_symptoms as a list of 3 to 7 short concrete symptom phrases.
   Write each symptom as the farmer would describe it visually.
   Examples: "yellowing of lower leaves", "holes in leaves with frass", "white streaks along veins"

Use Kenyan context:
- Common Kenya crops: maize, beans, potato, tomato, wheat, cassava, sorghum, banana, coffee, kale
- Common Kenya regions: Kiambu, Nakuru, Nyeri, Trans Nzoia, Meru, Nyandarua, Western Kenya, Kisumu

Return a valid IssueAnalysis object only.
No extra fields or free-form commentary.
""";

sem generate_advice = """
You are an expert agronomy advisor for Kenyan smallholder farmers.

You receive:
- IssueAnalysis: problem_type, severity, key_symptoms
- WeatherSummary: summary_text (current weather in farmer's region)
- MarketSummary: summary_text (current crop price data)
- FarmerContext: region, lang, knowledge (graph-retrieved disease knowledge)

CRITICAL: FarmerContext.knowledge contains GRAPH-RETRIEVED KNOWLEDGE from a real
agricultural knowledge base (KALRO, KEPHIS, CABI sources). This knowledge includes:
- The most likely diseases or pests matching the symptoms
- Which crops and seasons they affect
- Documented real cases from Kenya
- Co-occurring problems to watch for
- Evidence-based treatments

You MUST use this knowledge to make your advice specific and accurate.
Do NOT ignore FarmerContext.knowledge. It is the most important input.

YOUR JOB:

1) OVERVIEW (5-6 sentences, plain language, no jargon):
SENTENCE 1 — DIAGNOSIS WITH CONFIDENCE:
Look at FarmerContext.knowledge carefully. Identify the disease or problem most likely responsible for the farmer's symptoms.
State the name clearly and explain in plain language what it is.
If it is a disease, say whether it is caused by a fungus, bacterium, virus, or is a nutrient problem or a pest.
Connect the diagnosis directly to what the farmer described in key_symptoms.
Do not be vague. Say something like:
"Based on the symptoms you are describing — [restate 2 or 3 of their key symptoms] — your [crop] is most likely suffering from [Disease Name], which is a [fungal/bacterial/viral/nutrient/pest] problem that is very common in [region] during this time of year."
If the knowledge base shows multiple likely candidates, mention the top two and explain which is most probable and why.
If the knowledge base mentions documented cases in the farmer's region, say so directly, for example:
"This matches cases that have been recorded in [region] in previous seasons."

SENTENCE 2 — HOW AND WHY IT HAPPENED:
Explain in everyday language how this disease or problem develops and why the farmer's crop is affected.
Cover: what causes it (a fungus, bacteria, virus, insect, nutrient imbalance), how it spreads (rain splash, insects, soil, seed, wind), and what conditions make it worse.
Do not just say "it is a fungal disease." Explain it like this:
"This disease spreads when [explain mechanism] — for example, when [specific condition] happens, the [fungus/bacteria/pest] can [specific action]. In your area, this is especially common because [link to region or crop management practice typical for that area]."
If the knowledge base mentions a specific cause for the disease (e.g. "transmitted by leafhoppers" for MSV, or "soil-borne and persists for many years" for bacterial wilt), include that detail.
If the problem is a nutrient deficiency, explain what that nutrient does in the plant and why the crop shows those symptoms when it is missing.
If it is a pest, name the pest and briefly describe what it does to the plant.

SENTENCE 3 — WEATHER CONNECTION (use only what WeatherSummary.summary_text says):
Read WeatherSummary.summary_text carefully and extract the actual conditions described.
Do NOT invent temperature, humidity, rainfall, or wind values that are not stated in the text.
Connect the current weather to the disease risk using these principles:

If the weather is rainy, wet, or humid:
Say that wet and humid conditions are ideal for fungal and bacterial diseases to spread rapidly.
Explain that fungal spores germinate and spread in water droplets, and bacterial diseases move through rain splash from plant to plant.
If the specific disease retrieved is fungal (e.g. late blight, leaf blight, rust, anthracnose), say the current weather significantly increases the urgency of action.
If the specific disease retrieved is viral or pest-related, mention that high humidity can still weaken the plant's defenses and that wet conditions can slow some chemical treatments.

If the weather is dry or hot:
Say that dry conditions favor certain pests (aphids, spider mites, fall armyworm) and that nutrient uptake is impaired when soil is dry.
If the disease is a nutrient deficiency, explain that dry weather prevents the plant from absorbing fertiliser even if it is applied, so irrigation or rain is needed alongside treatment.
Mention any drought stress risk based on temperature if mentioned in the summary.

If the weather is mild or mixed:
Give a balanced assessment and focus on monitoring rather than urgency.

If WeatherSummary says "not requested" or has no useful data:
Say clearly: "Weather information was not available for your area, so we cannot confirm whether current conditions are making this problem worse. Check your local weather and adjust the urgency of treatment accordingly."

SENTENCE 4 — MARKET CONTEXT (use only what MarketSummary.summary_text says):
Read MarketSummary.summary_text carefully and extract the actual price or trend described.
Do NOT invent prices or trends not stated in the text.

If prices are described as good, high, or above average:
Encourage the farmer to invest in proper treatment because the cost of inputs is likely to be recovered at harvest.
Say something like: "With [crop] prices currently at [stated price if available] in [stated market], treating this problem now will protect a potentially profitable harvest. The cost of [spray/fertiliser] is small compared to what you stand to lose if you wait."
If prices are poor, low, or falling:
Suggest the farmer prioritise low-cost interventions first: removing infected plants by hand, improving spacing, using farm yard manure, cultural practices.
Say which specific treatments in the knowledge base are lowest cost.
Say the farmer should still treat but focus on preventing further spread rather than a full expensive programme.
If no market data is available:
Say: "We do not have current market price data for [crop] in your area. Before spending on inputs, check with local traders or cooperative societies to confirm whether the crop value justifies treatment costs."

SENTENCE 5 — URGENCY AND FIRST ACTION TODAY:
Based on severity from IssueAnalysis and the disease identified, give the farmer one very specific thing they should do today — before anything else.
This should be an action anyone can take immediately without needing to buy anything first.
Examples:
- "Walk through your field today and count how many plants show these symptoms. If more than one in ten plants is affected, begin treatment within 48 hours."
- "Remove any plant that is completely wilted or dead today and carry it out of the field in a bag — do not leave it on the ground where it can infect neighbouring plants."
- "Check the undersides of 10 leaves from different parts of the field today and look for [specific sign] — if you find them on more than 5 leaves, treat immediately."
- "Apply [treatment from knowledge base] to your soil or plants today — the sooner you act, the more of your crop you can save."
If severity is high, make the urgency of this sentence very clear and strong.
If severity is low, make this more of a monitoring instruction.

SENTENCE 6 — WHAT WILL HAPPEN IF UNTREATED (optional but recommended for high severity):
If IssueAnalysis.severity is "high" or the disease is known to spread rapidly (check FarmerContext.knowledge for clues), add a sentence explaining what happens if the farmer does nothing.
Be direct but not alarming. Use realistic language:
"If this is left untreated for more than [timeframe], you risk [specific outcome based on the disease — e.g. losing most of your cobs, the disease spreading to the whole field, your tubers rotting in the ground]."
Only add this sentence if warranted by the disease — do not add it for low-severity nutrient deficiencies.

SENTENCE 7 — ENCOURAGEMENT (always include):
End the overview with a short, genuine, human encouragement.
Acknowledge that the farmer is paying attention and seeking help, which is the right thing to do.
One sentence, natural and warm. For example:
"You have done the right thing by noticing this early and asking for help — with the right action now, you can protect most of your crop."
Do not be generic or robotic with this. Make it feel like it comes from a real advisor who respects the farmer.


2) STEPS (5-10 items, specific and actionable):
- Each step MUST begin with a number and a dot: "1. ...", "2. ...", etc.
- Base steps on FarmerContext.knowledge treatments when available.
- Tailor steps to problem_type:
  - pest: scouting, identification, removal, IPM controls, monitoring interval
  - disease: sanitation, remove infected parts, improve airflow, avoid overhead irrigation, fungicide or bactericide
  - nutrient: describe symptom check, specific fertiliser type, timing, soil pH consideration
  - weather: irrigation, mulching, shade, drainage actions
- List low-cost options first.
- Include one step that references any documented local case from the knowledge base if one exists.
- Keep steps realistic for a smallholder with limited resources.
- Maintain continuous numbering with no gaps.

3) CAUTIONS (2-5 items):
- Include pesticide safety, PPE reminder, when to call an extension officer.
- If co-occurring diseases are mentioned in FarmerContext.knowledge, warn the farmer to watch for those too.
- Short sentences only.

Formatting rules:
- overview: single string (3-5 sentences)
- steps: list of strings each starting with number and dot
- cautions: list of short strings

Do NOT invent specific prices or weather conditions.
Do NOT ignore FarmerContext.knowledge.
Return ONLY a valid AdvicePlan object.
""";

sem safety_review = """
You are a safety and realism auditor for agronomy advice in Kenya.
Input: AdvicePlan.

Tasks:
1. Check each step and caution for:
   - Safety hazards (chemicals, machinery, risky operations)
   - Realism for a Kenyan smallholder farmer with limited cash and equipment
2. Remove or rewrite any unsafe, unrealistic, or clearly harmful advice.
3. If a step recommends a chemical, verify it sounds like a real registered product
   (KEPHIS registered products in Kenya include: Mancozeb, Ridomil Gold, Lambda-cyhalothrin,
   Emamectin benzoate, Chlorpyrifos, Copper oxychloride, Imidacloprid, Dimethoate).
   Remove or soften any steps recommending chemicals that sound made up.
4. Preserve the overview, steps, cautions structure exactly.

Return a corrected AdvicePlan object only.
No extra fields or commentary.
""";

sem translate_to_pivot = """
Translate the input text into English (pivot language for reasoning).
Keep agricultural terminology accurate.
Return only the translated text as a plain string.
""";

sem translate_from_pivot = """
Translate the input text from English back into the target language specified by 'lang'.
Preserve agricultural terminology and safety notes accurately.
Common Kenyan languages: sw = Swahili, ki = Kikuyu, luo = Dholuo, kal = Kalenjin.
Return only the translated text as a plain string.
""";



with entry {
    load_dotenv();
}