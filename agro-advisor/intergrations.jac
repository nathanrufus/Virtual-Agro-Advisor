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

    # Expected WeatherAPI structure:
    # {
    #   "location": {...},
    #   "current": {
    #       "temp_c": 22.1,
    #       "condition": {"text": "Partly cloudy"},
    #       "humidity": 46,
    #       "wind_kph": 20.9,
    #       ...
    #   }
    # }
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

with entry {
    load_dotenv();
}
