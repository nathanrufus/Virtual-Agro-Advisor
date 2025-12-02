import from datetime { datetime }
import from requests { get as py_get }
import json;


def json_get(raw: str, path: str) -> any {
    # Parse JSON safely
    try {
        data = json.loads(raw);
    } except Exception {
        return None;
    }

    # Support simple "[0].field" pattern
    if path.startswith("[") and "]." in path {
        closing = path.find("]");
        idx_str = path[1:closing];
        key = path[closing + 2:];  # skip "]."

        try {
            idx = int(idx_str);
        } except Exception {
            return None;
        }

        if not isinstance(data, list) or idx < 0 or idx >= len(data) {
            return None;
        }

        item = data[idx];

        if isinstance(item, dict) and key in item {
            return item[key];
        }

        return None;
    }

    # Otherwise, treat as a top-level key
    if isinstance(data, dict) and path in data {
        return data[path];
    }

    return None;
}


# Basic HTTP GET with headers using python-requests
def http_get_with_header(url: str, header_name: str, header_value: str) -> str {
    try {
        headers = {header_name: header_value};
        response = py_get(url, headers=headers, timeout=10);

        if response.status_code != 200 {
            # Return empty string so callers can fall back gracefully
            return "";
        }

        # Return response body as string
        return response.text;

    } except Exception as e {
        # Swallow network errors and let callers detect empty string
        return "";
    }
}


# Basic HTTP GET without headers (for weather, etc.)
def http_get(url: str) -> str {
    try {
        let response = py_get(url, timeout=15);

        print(f"[HTTP] GET {url} -> {response.status_code}");

        if response.status_code != 200 {
            # Print a small preview of the error body so we can see what FEWS NET says
            let text = response.text;
            if text and len(text) > 200 {
                text = text[:200];
            }
            print(f"[HTTP] Error body preview: {text}");
            return "";
        }

        return response.text;

    } except Exception as e {
        print(f"[HTTP] Exception calling {url}: {e}");
        return "";
    }
}



def get_current_datetime() -> str {
    return str(datetime.now());
}
