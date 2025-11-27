import from dotenv { load_dotenv }
include utils;  # for http_get_with_header, json_get, etc.

def map_crop_to_api_name(crop_key: str) -> str {
    # Basic mapping from your internal crop keys to API Ninjas commodity names
    if crop_key == "maize" or crop_key == "corn"{
        return "corn";
   } elif crop_key == "wheat" {
        return "wheat";
    }elif crop_key == "coffee"{
        return "coffee";
    }elif crop_key == "rice"{
        return "rice";
        }
    # Fallback: just use the same
   else{return crop_key;} 
}

def fetch_market_raw(crop_key: str, region_key: str) -> str {
    api_key = getenv("API_NINJAS_API_KEY");
    base_url = getenv("API_NINJAS_BASE_URL");

    if not api_key or not base_url {
        return "";
    }

    name = map_crop_to_api_name(crop_key);
    url = f"{base_url}/commodityprice?name={name}";

    # You implement this helper in backend.utils (simple GET with header)
    raw = http_get_with_header(url, "X-Api-Key", api_key);
    return raw;
}

def summarize_market(raw: str, crop: str, region: str) -> str {
    if not raw {
        return f"No live market data available for '{crop}' in '{region}'.";
    }

    # Example API Ninjas response is typically a JSON array like:
    # [ { "name": "corn", "price": 4.87, "unit": "USD/bu", "exchange": "CBOT" }, ... ]
    #
    # json_get is a tiny helper you define to pull fields from JSON.
    price = json_get(raw, "[0].price");
    unit = json_get(raw, "[0].unit");
    exchange = json_get(raw, "[0].exchange");

    return (
        f"Recent global price for {crop} is about {price} {unit} on {exchange}. "
        f"For farmers in {region}, this indicates the international reference price; "
        f"local farmgate prices may be lower due to transport, intermediaries, and quality."
    );
}
with entry {
    load_dotenv();
}