import from datetime { datetime }
import from requests { get as py_get }
import json;
# include app;


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
            return "";
        }

        return response.text;

    } except Exception {
        return "";
    }
}


# Basic HTTP GET without headers
def http_get(url: str) -> str {
    try {
        response = py_get(url, timeout=15);

        print(f"[HTTP] GET {url} -> {response.status_code}");

        if response.status_code != 200 {
            text = response.text;
            if text and len(text) > 200 {
                text = text[:200];
            }
            print(f"[HTTP] Error body preview: {text}");
            return "";
        }

        return response.text;

    } except Exception {
    print(f"[HTTP] Exception calling {url}");
    return "";
}
}

def strip_step_prefix(s: str) -> str {
    if not s {
        return "";
    }

    t = s.strip();

    if t.startswith("- ") {
        t = t[2:].strip();
    }
    if t.startswith("* ") {
        t = t[2:].strip();
    }
    if t.startswith("• ") {
        t = t[2:].strip();
    }

    i = 0;
    while i < len(t) and t[i].isdigit() {
        i = i + 1;
    }

    if i > 0 and i < len(t) and (t[i] == "." or t[i] == ")") {
        j = i + 1;
        while j < len(t) and t[j] == " " {
            j = j + 1;
        }
        t = t[j:].strip();
    }

    return t;
}

def ensure_numbered_steps(advice: any) -> any {
    if not advice {
        return advice;
    }

    cleaned = [];
    n = 1;

    steps = [];
    if hasattr(advice, "steps") {
        steps = advice.steps;
    } elif ("steps" in advice) {
        steps = advice["steps"];
    }

    for s in steps {
        base = strip_step_prefix(s);
        if base {
            cleaned = cleaned + [f"{n}. {base}"];
            n = n + 1;
        }
    }

    if hasattr(advice, "steps") {
        advice.steps = cleaned;
    } else {
        advice["steps"] = cleaned;
    }

    return advice;
}

def clean_steps_for_ui(advice: any) -> any {
    if not advice {
        return advice;
    }

    cleaned = [];

    steps = [];
    if hasattr(advice, "steps") {
        steps = advice.steps;
    } elif ("steps" in advice) {
        steps = advice["steps"];
    }

    for s in steps {
        base = strip_step_prefix(s);
        if base {
            cleaned = cleaned + [base];
        }
    }

    if hasattr(advice, "steps") {
        advice.steps = cleaned;
    } else {
        advice["steps"] = cleaned;
    }

    return advice;
}

def normalize_advice_for_ui(advice: any) -> any {
    return clean_steps_for_ui(advice);
}

def get_current_datetime() -> str {
    return str(datetime.now());
}

def parse_datetime_safe(dt_str: str) -> any {
    try {
        return datetime.fromisoformat(dt_str);
    } except Exception {
        try {
            return datetime.strptime(dt_str, "%Y-%m-%d %H:%M:%S.%f");
        } except Exception {
            try {
                return datetime.strptime(dt_str, "%Y-%m-%d %H:%M:%S");
            } except Exception {
                return None;
            }
        }
    }
}

def hours_since(dt_str: str) -> float {
    dt = parse_datetime_safe(dt_str);

    if not dt {
        return 10000.0;
    }

    try {
        delta = datetime.now() - dt;
        return delta.total_seconds() / 3600.0;
    } except Exception {
        return 10000.0;
    }
}