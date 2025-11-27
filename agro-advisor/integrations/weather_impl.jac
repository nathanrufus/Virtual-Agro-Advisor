import from dotenv { load_dotenv }
import os;


def fetch_weather_raw(location_key: str) -> str {
   
    api_key = getenv("WEATHER_API_KEY");
    if not api_key {
        return "";
    }

    # Example URL building – replace with your actual provider
    url = f"https://api.weatherapi.com/v1/current.json?key={api_key}&q={location_key}";

    # Assuming you have some helper to do HTTP GET and return string/JSON
    response_text = http_get(url);   # <-- you'll implement http_get somewhere
    return response_text;
}

def summarize_weather(raw: str, location: str) -> str {
    if not raw {
        return f"No live weather data available for '{location}'.";
    }
    # For Phase 1 you can just embed the raw, later you parse it properly:
    # parse raw JSON, pick temp/conditions, then build a human summary.
    return f"Current weather for '{location}' from live API data (raw length={len(raw)}).";
}
with entry {
    load_dotenv();
}