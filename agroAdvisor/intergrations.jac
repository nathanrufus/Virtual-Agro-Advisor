import from dotenv { load_dotenv }
import os;
import json;
include utils;
# sv import from utils { system_call } 


# WEATHER INTEGRATION (WeatherAPI Forecast)

def fetch_weather_raw(location_key: str) -> str {
    api_key = os.getenv("WEATHER_API_KEY");
    if not api_key {
        print("[Weather] Missing WEATHER_API_KEY env var.");
        return "";
    }

    url = f"https://api.weatherapi.com/v1/forecast.json?key={api_key}&q={location_key}&days=1&aqi=no&alerts=no";
    print(f"[Weather] Requesting: {url}");

    response_text = http_get(url);

    if not response_text {
        print("[Weather] Empty or error response from WeatherAPI.");
    } else {
        print(f"[Weather] Raw length = {len(response_text)}");
    }

    return response_text;
}

def summarize_weather(raw: str, location: str) -> str {
    if not raw {
        return f"No live weather data available for '{location}'.";
    }

    try {
        data = json.loads(raw);
    } except Exception {
        print("[Weather] Failed to parse JSON.");
        return f"Could not parse live weather data for '{location}'.";
    }

    current = data.get("current", {});
    forecast = data.get("forecast", {});
    forecastday = forecast.get("forecastday", []);

    temp_c = current.get("temp_c", None);
    cond_obj = current.get("condition", {});
    cond_text = cond_obj.get("text", "typical conditions");
    humidity = current.get("humidity", None);
    wind_kph = current.get("wind_kph", None);

    min_temp = None;
    max_temp = None;
    total_precip = None;

    if forecastday and len(forecastday) > 0 {
        day = forecastday[0].get("day", {});
        min_temp = day.get("mintemp_c", None);
        max_temp = day.get("maxtemp_c", None);
        total_precip = day.get("totalprecip_mm", None);
    }

    if temp_c is None {
        return f"Live weather data for '{location}' is incomplete.";
    }

    parts = [f"it is currently about {temp_c}°C with {cond_text.lower()}"];

    if humidity is not None {
        parts = parts + [f"humidity is around {humidity}%"];
    }

    if wind_kph is not None {
        parts = parts + [f"winds are near {wind_kph} km/h"];
    }

    if min_temp is not None and max_temp is not None {
        parts = parts + [f"today ranges roughly from {min_temp}°C to {max_temp}°C"];
    }

    if total_precip is not None {
        parts = parts + [f"expected rainfall today is about {total_precip} mm"];
    }

    return f"In {location}, " + ". ".join(parts) + ".";
}

def build_weather_snapshot_data(raw: str, location_key: str) -> dict {
    out = {
        "summary": summarize_weather(raw, location_key),
        "temperature_c": 0.0,
        "humidity_pct": 0.0,
        "precipitation_mm": 0.0,
        "wind_kph": 0.0,
        "forecast_temp_min_c": 0.0,
        "forecast_temp_max_c": 0.0,
        "forecast_precipitation_mm": 0.0,
        "disease_risk_score": 0,
        "disease_risk_level": "UNKNOWN",
        "disease_risk_reason": ""
    };

    if not raw {
        return out;
    }

    try {
        data = json.loads(raw);
    } except Exception {
        return out;
    }

    current = data.get("current", {});
    forecast = data.get("forecast", {});
    forecastday = forecast.get("forecastday", []);

    temp_c = current.get("temp_c", 0.0) or 0.0;
    humidity = current.get("humidity", 0.0) or 0.0;
    wind_kph = current.get("wind_kph", 0.0) or 0.0;
    precip_mm = current.get("precip_mm", 0.0) or 0.0;

    min_temp = temp_c;
    max_temp = temp_c;
    total_precip = precip_mm;

    if forecastday and len(forecastday) > 0 {
        day = forecastday[0].get("day", {});
        min_temp = day.get("mintemp_c", temp_c) or temp_c;
        max_temp = day.get("maxtemp_c", temp_c) or temp_c;
        total_precip = day.get("totalprecip_mm", precip_mm) or precip_mm;
    }

    risk_score = 0;
    risk_reasons = [];

    if humidity >= 85 {
        risk_score = risk_score + 35;
        risk_reasons = risk_reasons + ["high humidity"];
    } elif humidity >= 70 {
        risk_score = risk_score + 20;
        risk_reasons = risk_reasons + ["moderately high humidity"];
    }

    if total_precip >= 10 {
        risk_score = risk_score + 20;
        risk_reasons = risk_reasons + ["meaningful rainfall expected"];
    } elif total_precip > 0 {
        risk_score = risk_score + 10;
        risk_reasons = risk_reasons + ["some rainfall expected"];
    }

    if max_temp >= 28 and humidity >= 70 {
        risk_score = risk_score + 10;
        risk_reasons = risk_reasons + ["warm and humid conditions"];
    }

    risk_level = "LOW";
    if risk_score >= 70 {
        risk_level = "HIGH";
    } elif risk_score >= 40 {
        risk_level = "MEDIUM";
    }

    out["temperature_c"] = float(temp_c);
    out["humidity_pct"] = float(humidity);
    out["precipitation_mm"] = float(precip_mm);
    out["wind_kph"] = float(wind_kph);
    out["forecast_temp_min_c"] = float(min_temp);
    out["forecast_temp_max_c"] = float(max_temp);
    out["forecast_precipitation_mm"] = float(total_precip);
    out["disease_risk_score"] = int(risk_score);
    out["disease_risk_level"] = risk_level;
    out["disease_risk_reason"] = ", ".join(risk_reasons) if risk_reasons else "No major moisture-driven disease signal detected.";

    return out;
}

def fetch_regional_weather(region_id: str) -> str {
    return fetch_weather_raw(region_id);
}

def summarize_regional_weather(raw: str, region_id: str) -> dict {
    return {
        "ok": bool(raw),
        "summary": summarize_weather(raw, region_id)
    };
}


# MARKET INTEGRATION (FEWS NET Staple Food Price Data)

def normalize_crop_for_fews(crop: str) -> str {
    if not crop {
        return "";
    }

    c = crop.strip().lower();

    if c == "maize" or c == "corn" {
        return "Maize";
    }

    if c == "beans" or c == "bean" {
        return "Beans";
    }

    return c.title();
}

def fetch_market_price_raw(crop: str, region: str) -> str {
    base_url = "https://fdw.fews.net/api/marketpricefacts/";
    commodity = normalize_crop_for_fews(crop);

    url = (
        base_url
        + "?dataset=FEWS_NET_Staple_Food_Price_Data"
        + "&country=KE"
        + "&format=json"
        + "&fields=simple"
    );

    if commodity {
        url = url + f"&product_name={commodity}";
    }

    print(f"[Market] Requesting FEWS NET: {url}");

    response_text = http_get(url);

    if not response_text {
        print("[Market] Empty or error response from FEWS NET.");
    } else {
        print(f"[Market] Raw length = {len(response_text)}");
    }

    return response_text;
}

def summarize_market(raw: str, crop: str, region: str) -> str {
    if not raw {
        return f"No live market price data available for {crop} in {region}.";
    }

    try {
        data = json.loads(raw);
    } except Exception {
        print("[Market] Failed to parse FEWS NET JSON.");
        return f"Could not parse live market price data for {crop} in {region}.";
    }

    rows = [];

    if isinstance(data, list) {
        rows = data;
    } else {
        maybe_results = data.get("results", None);
        if maybe_results and isinstance(maybe_results, list) {
            rows = maybe_results;
        }
    }

    if not rows {
        return f"No recent FEWS NET price points for {crop} in Kenya.";
    }

    crop_norm = "";
    region_norm = "";

    if crop {
        crop_norm = crop.strip().lower();
    }
    if region {
        region_norm = region.strip().lower();
    }

    filtered = [];

    for row in rows {
        product_name = row.get("product_name", "") or row.get("commodity", "");
        market_name = row.get("market", "");
        admin1 = row.get("admin_1", "") or row.get("admin1", "");
        combined_loc = (market_name + " " + admin1).lower();

        product_l = "";
        if product_name {
            product_l = product_name.lower();
        }

        matches_crop = False;
        if crop_norm and product_l {
            if crop_norm in product_l {
                matches_crop = True;
            }
        } else {
            matches_crop = True;
        }

        matches_region = False;
        if region_norm {
            if region_norm in combined_loc {
                matches_region = True;
            }
        } else {
            matches_region = True;
        }

        if matches_crop and matches_region {
            filtered = filtered + [row];
        }
    }

    if not filtered {
        filtered = rows;
    }

    latest_row = filtered[0];
    latest_date = latest_row.get("period_date", "") or "";

    if not latest_date {
        year = latest_row.get("mp_year", "");
        month = latest_row.get("mp_month", "");
        if year and month {
            latest_date = f"{year}-{month}-01";
        }
    }

    for row in filtered {
        d = row.get("period_date", "") or "";
        if not d {
            y = row.get("mp_year", "");
            m = row.get("mp_month", "");
            if y and m {
                d = f"{y}-{m}-01";
            }
        }

        if d and (not latest_date or d > latest_date) {
            latest_row = row;
            latest_date = d;
        }
    }

    price_val = latest_row.get("price", None) or latest_row.get("value", None);
    unit = latest_row.get("unit", "kg");
    currency = latest_row.get("currency", "KES");
    market_name = latest_row.get("market", "");
    admin1 = latest_row.get("admin_1", "") or latest_row.get("admin1", "");

    if not price_val {
        return f"FEWS NET data found for {crop} in Kenya, but price values are missing or marked as not collected.";
    }

    loc_phrase = region;
    if not loc_phrase {
        loc_phrase = "Kenya";
    }

    if market_name {
        loc_phrase = market_name;
        if admin1 {
            loc_phrase = f"{market_name}, {admin1}";
        }
    }

    date_phrase = latest_date;
    if not date_phrase {
        date_phrase = "recent months";
    }

    return (
        "Recent FEWS NET data suggests typical prices for "
        + crop
        + " around "
        + str(price_val)
        + " "
        + currency
        + "/"
        + unit
        + " in "
        + loc_phrase
        + " as of "
        + date_phrase
        + ". These are reference values; always confirm with local buyers, cooperatives, or nearby markets before making financial decisions."
    );
}

def build_market_snapshot_data(raw: str, crop: str, region: str) -> dict {
    out = {
        "summary": summarize_market(raw, crop, region),
        "region_id": "",
        "region_name": region,
        "market_name": "",
        "admin1": "",
        "price": 0.0,
        "currency": "KES",
        "unit": "kg",
        "observed_date": ""
    };

    if not raw {
        return out;
    }

    try {
        data = json.loads(raw);
    } except Exception {
        return out;
    }

    rows = [];
    if isinstance(data, list) {
        rows = data;
    } else {
        maybe_results = data.get("results", None);
        if maybe_results and isinstance(maybe_results, list) {
            rows = maybe_results;
        }
    }

    if not rows {
        return out;
    }

    latest_row = rows[0];
    latest_date = latest_row.get("period_date", "") or "";

    for row in rows {
        d = row.get("period_date", "") or "";
        if d and (not latest_date or d > latest_date) {
            latest_row = row;
            latest_date = d;
        }
    }

    price_val = latest_row.get("price", None) or latest_row.get("value", None) or 0.0;

    out["market_name"] = latest_row.get("market", "");
    out["admin1"] = latest_row.get("admin_1", "") or latest_row.get("admin1", "");
    out["price"] = float(price_val);
    out["currency"] = latest_row.get("currency", "KES");
    out["unit"] = latest_row.get("unit", "kg");
    out["observed_date"] = latest_date;

    return out;
}

def fetch_regional_market(crop: str, region_id: str) -> str {
    return fetch_market_price_raw(crop, region_id);
}

def summarize_regional_market(raw: str, crop: str, region_id: str) -> dict {
    return {
        "ok": bool(raw),
        "summary": summarize_market(raw, crop, region_id)
    };
}

# ============================================
# KAMIS MARKET INTEGRATION
# ============================================
def fetch_kamis_raw(crop: str, market: str) -> str {

    if crop == "" or market == "" {
        print("[KAMIS] Missing parameters");
        return "";
    }

    args = [
        "python",
        "scripts/kamis_search_downloader.py",
        "--crop",
        crop,
        "--market",
        market,   # 🔥 now safe even if "kiambu, kenya"
        "--days",
        "30"
    ];

    print("[KAMIS] Fetching:", crop, "in", market);

    try {
        response_text = system_call(args);

        if response_text == null or response_text.strip() == "" {
            print("[KAMIS] Empty response from script");
            return "";
        }

        print("[KAMIS] Response received:", len(response_text));
        return response_text;

    } except Exception {
        print("[KAMIS] Error calling system");
        return "";
    }
}

def summarize_kamis(raw: str, crop: str, market: str) -> str {

    if not raw {
        return "KAMIS market data not available for " + crop + " in " + market + ".";
    }

    try {
        data = json.loads(raw);
    } except Exception {
        print("[KAMIS] Invalid JSON received:", raw[:200]);
        return "Could not parse KAMIS response for " + crop + " in " + market + ".";
    }

    if not data or len(data) == 0 {
        return "No KAMIS price records found for " + crop + " in " + market + ".";
    }

    latest = data[0];

    price = latest.get("price", None);
    if price is None {
        return "KAMIS data missing price for " + crop + " in " + market + ".";
    }

    date = latest.get("date", "recent date");
    currency = latest.get("currency", "KES");
    unit = latest.get("unit", "kg");
    market_name = latest.get("market", market);

    return (
        "KAMIS market data: In " + market_name +
        ", " + crop + " is trading at " +
        str(price) + " " + currency + "/" + unit +
        " (as of " + date + ")."
    );
}

def fetch_best_kamis_price(crop: str, region: str) -> dict {

    if not crop or not region {
        return {
            "success": False,
            "error": "Crop and region required"
        };
    }

    region_to_markets = {
        "nairobi": ["nairobi"],
        "kiambu": ["thika"],
        "kisumu": ["kisumu"],
        "nakuru": ["nakuru"],
        "mombasa": ["mombasa"],
        "eldoret": ["eldoret"],
        "kericho": ["kericho"],
        "nyeri": ["nyeri"],
        "muranga": ["muranga"],
        "machakos": ["machakos"]
    };

    region_lower = region.strip().lower();
    markets = region_to_markets.get(region_lower, []);

    if not markets {
        markets = [region_lower];
    }

    best_price = 0.0;
    best_market = "";
    best_date = "";
    best_currency = "KES";

    all_prices = [];

    for market in markets {

        raw = fetch_kamis_raw(crop, market);

        if not raw {
            continue;
        }

        try {
            data = json.loads(raw);

            if data and len(data) > 0 {

                latest = data[0];
                price = latest["price"];

                if price != null and price > 0 {

                    all_prices = all_prices + [{
                        "market": latest["market"],
                        "price": price,
                        "date": latest["date"],
                        "currency": latest["currency"]
                    }];

                    if price > best_price {
                        best_price = price;
                        best_market = latest["market"];
                        best_date = latest["date"];
                        best_currency = latest["currency"];
                    }
                }
            }

        } except Exception {
            print("[KAMIS] Error parsing market " + market);
            continue;
        }
    }

    if best_price > 0 {
        return {
            "success": True,
            "best_market": best_market,
            "best_price": best_price,
            "crop": crop,
            "region": region,
            "date": best_date,
            "currency": best_currency,
            "all_prices": all_prices
        };
    } else {
        return {
            "success": False,
            "error": "No price data found for " + crop + " in " + region,
            "all_prices": all_prices
        };
    }
}

with entry {
    load_dotenv();
}