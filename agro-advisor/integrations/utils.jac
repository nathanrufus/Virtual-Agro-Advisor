import from python.requests { get as py_get }

# Basic HTTP GET with headers using python-requests
def http_get_with_header(url: str, header_name: str, header_value: str) -> str {
    try {
        headers = {header_name: header_value};
        response = py_get(url, headers=headers);

        if response.status_code != 200 {
            return f"ERROR: HTTP {response.status_code}";
        }

        # Return response body as string
        return response.text;

    } catch e {
        return f"ERROR: {e}";
    }
}
