#!/usr/bin/env python3
import json
import os
import sys


def deep_merge(dst, src):
    """Recursively merge src dict into dst dict."""
    for key, value in src.items():
        if key in dst and isinstance(dst[key], dict) and isinstance(value, dict):
            deep_merge(dst[key], value)
        else:
            dst[key] = value
    return dst


def main():
    """Merge Infisical path lookup results from INFISICAL_RESULTS into nested and dotted JSON maps."""
    raw = os.environ.get("INFISICAL_RESULTS", "[]")
    try:
        results = json.loads(raw)
    except json.JSONDecodeError as exc:
        print(f"Invalid JSON input: {exc}", file=sys.stderr)
        sys.exit(1)

    final = {}

    for entry in results:
        path = (entry.get("item") or "/").strip("/")
        secrets = entry.get("secrets") or {}

        # Promote root ('/') keys directly to top-level `secrets.<KEY>`
        if not path:
            deep_merge(final, secrets)
            continue

        parts = [part for part in path.split("/") if part]
        cursor = final
        for part in parts:
            if part not in cursor:
                cursor[part] = {}
            cursor = cursor[part]
        deep_merge(cursor, secrets)

        # Also emit dotted keys (e.g. secrets['ansible.mail']) alongside nested dicts for backward compatibility
        dotted_key = ".".join(parts)
        if dotted_key not in final:
            final[dotted_key] = {}
        deep_merge(final[dotted_key], secrets)

    print(json.dumps(final, sort_keys=True))


if __name__ == "__main__":
    main()
