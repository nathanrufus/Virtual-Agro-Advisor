import from dotenv { load_dotenv }
import os;
import json;
include utils;  # http_get, json_get, get_current_datetime, etc.


# WEATHER INTEGRATION (WeatherAPI)

def fetch_weather_raw(location_key: str) -> str {
    api_key = os.getenv("WEATHER_API_KEY");
    if not api_key {
        print("[Weather] Missing WEATHER_API_KEY env var.");
        return "";
    }

    let url = f"https://api.weatherapi.com/v1/current.json?key={api_key}&q={location_key}";
    print(f"[Weather] Requesting: {url}");

    let response_text = http_get(url);

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

    # Parse JSON safely
    try {
        let data = json.loads(raw);
    } except Exception {
        print("[Weather] Failed to parse JSON.");
        return f"Could not parse live weather data for '{location}'.";
    }

    let current = data.get("current", {});
    let temp_c = current.get("temp_c", None);
    let cond_obj = current.get("condition", {});
    let cond_text = cond_obj.get("text", "typical conditions");
    let humidity = current.get("humidity", None);
    let wind_kph = current.get("wind_kph", None);

    if temp_c is None {
        return f"Live weather data for '{location}' is incomplete.";
    }

    # Build human-friendly description
    let details = f"about {temp_c}°C with {cond_text.lower()}";

    if humidity is not None {
        details = f"{details}, humidity around {humidity}%.";
    } else {
        details = f"{details}.";
    }

    if wind_kph is not None {
        details = f"{details} Winds near {wind_kph} km/h.";
    }

    return f"In {location}, it is currently {details}";
}


# MARKET INTEGRATION (FEWS NET Staple Food Price Data)
# Uses public FEWS NET FDW endpoint:
# https://fdw.fews.net/api/marketpricefacts/?dataset=FEWS_NET_Staple_Food_Price_Data&country=KE&format=json&fields=simple 

def normalize_crop_for_fews(crop: str) -> str {
    if not crop {
        return "";
    }

    let c = crop.strip().lower();

    if c == "maize" or c == "corn" {
        return "Maize";
    }

    if c == "beans" or c == "bean" {
        return "Beans";
    }

    # Fallback: title-case whatever we got
    return c.title();
}

def fetch_market_price_raw(crop: str, region: str) -> str {
    # FEWS NET uses ISO country codes; KE = Kenya
    let base_url = "https://fdw.fews.net/api/marketpricefacts/";
    let commodity = normalize_crop_for_fews(crop);

    let url = (
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

    let response_text = http_get(url);

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
        let data = json.loads(raw);
    } except Exception {
        print("[Market] Failed to parse FEWS NET JSON.");
        return f"Could not parse live market price data for {crop} in {region}.";
    }

    # FEWS NET API sometimes returns:
    #  - a list of rows, or
    #  - an object with a 'results' list.
    let rows = [];

    if isinstance(data, list) {
        rows = data;
    } else {
        let maybe_results = data.get("results", None);
        if maybe_results and isinstance(maybe_results, list) {
            rows = maybe_results;
        }
    }

    if not rows {
        return f"No recent FEWS NET price points for {crop} in Kenya.";
    }

    let crop_norm = "";
    let region_norm = "";

    if crop {
        crop_norm = crop.strip().lower();
    }
    if region {
        region_norm = region.strip().lower();
    }

    let filtered = [];

    for row in rows {
        let product_name = row.get("product_name", "") or row.get("commodity", "");
        let market_name = row.get("market", "");
        let admin1 = row.get("admin_1", "") or row.get("admin1", "");
        let combined_loc = (market_name + " " + admin1).lower();

        let product_l = "";
        if product_name {
            product_l = product_name.lower();
        }

        let matches_crop = False;
        if crop_norm and product_l {
            if crop_norm in product_l {
                matches_crop = True;
            }
        } else {
            matches_crop = True;
        }

        let matches_region = False;
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

    # Pick the latest point by period_date (YYYY-MM-DD) or mp_year/mp_month
    let latest_row = filtered[0];
    let latest_date = latest_row.get("period_date", "") or "";

    if not latest_date {
        let year = latest_row.get("mp_year", "");
        let month = latest_row.get("mp_month", "");
        if year and month {
            latest_date = f"{year}-{month}-01";
        }
    }

    for row in filtered {
        let d = row.get("period_date", "") or "";
        if not d {
            let y = row.get("mp_year", "");
            let m = row.get("mp_month", "");
            if y and m {
                d = f"{y}-{m}-01";
            }
        }

        if d and (not latest_date or d > latest_date) {
            latest_row = row;
            latest_date = d;
        }
    }

    let price_val = latest_row.get("price", None) or latest_row.get("value", None);
    let unit = latest_row.get("unit", "kg");
    let currency = latest_row.get("currency", "KES");
    let market_name = latest_row.get("market", "");
    let admin1 = latest_row.get("admin_1", "") or latest_row.get("admin1", "");

    if not price_val {
        return f"FEWS NET data found for {crop} in Kenya, but price values are missing or marked as not collected.";
    }

    let loc_phrase = region;
    if not loc_phrase {
        loc_phrase = "Kenya";
    }

    if market_name {
        loc_phrase = market_name;
        if admin1 {
            loc_phrase = f"{market_name}, {admin1}";
        }
    }

    let date_phrase = latest_date;
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


with entry {
    load_dotenv();
}
