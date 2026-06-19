import from datetime { datetime }
import from requests { get as py_get }
import json;
import subprocess;
import os;
import from scripts.executor {py_run}

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

def system_call(args: list) -> str {
   
    # Execute subprocess command with CORRECT JAC syntax and directory handling.
    
    # FIX: Proper JAC for-loop syntax (not Python syntax)
   
    
    try {
        # Only go up ONE directory from utils.jac location
        base_dir = os.path.dirname(os.path.abspath(__file__));

        print(f"[system_call] CWD: {base_dir}");
        print(f"[system_call] ARGS: {args}");

        # Convert relative script paths to absolute paths
        # Using JAC-style loop (no unpacking)
        fixed_args = [];
        i = 0;
        
        for arg in args {
            if i == 0 {
                # Keep 'python' as-is
                fixed_args.append(arg);
            }
            # elif i == 1 and arg.startswith("scripts/") {
            #     # Convert relative path to absolute
            #     abs_script_path = os.path.join(base_dir, arg);
            #     print(f"[system_call] Script path: {arg} -> {abs_script_path}");
            #     fixed_args.append(abs_script_path);
            # }
            else {
                fixed_args.append(arg);
            }
            
            i = i + 1;
        }

        print(f"[system_call] Fixed ARGS: {fixed_args}");
        cmd_parts = [];
        for arg in fixed_args {
            # Quote arguments with spaces
            if " " in arg {
                cmd_parts.append(f'"{arg}"');
            }
            else {
                cmd_parts.append(arg);
            }
        }

        cmd = " ".join(cmd_parts);

  
        result = subprocess.run(
            cmd,
            shell=True,
            cwd=base_dir,        
            capture_output=True,
            text=True,
            timeout=30
        );

        print(f"[system_call] RETURN CODE: {result.returncode}");

        stdout = result.stdout.strip() if result.stdout else "";
        stderr = result.stderr.strip() if result.stderr else "";

        if stdout {
            print(f"[system_call] STDOUT: {stdout[:500]}");
        }

        if stderr {
            print(f"[system_call] STDERR: {stderr[:500]}");
        }

        # Return stdout only on success
        if result.returncode == 0 {
            return stdout;
        } else {
            if stderr {
                print(f"[system_call] Command failed: {stderr}");
            }
            return "";
        }

    } except subprocess.TimeoutExpired {
        print("[system_call] TIMEOUT: Command exceeded 30 seconds");
        return "";
    } except Exception as e {
        print(f"[system_call] EXCEPTION: {type(e).__name__}: {str(e)}");
        return "";
    }
}
