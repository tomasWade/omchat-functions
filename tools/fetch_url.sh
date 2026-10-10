#!/usr/bin/env bash
set -e

# @describe Fetch a URL and return its readable text content.
# Use this when you need to read the content of a web page or document by URL.

# @option --url! The URL to fetch.

# @env LLM_OUTPUT=/dev/stdout The output path

main() {
    export https_proxy="${https_proxy:-http://127.0.0.1:8118}"
    export http_proxy="${http_proxy:-http://127.0.0.1:8118}"
    local res
    res="$(curl -sSL -m 30 --compressed -A "Mozilla/5.0 (X11; Linux x86_64)" "$argc_url" \
        | /usr/bin/python3 -c '
import re, sys, html
s = sys.stdin.read()
s = re.sub(r"(?is)<(script|style|noscript|svg|head)[^>]*>.*?</\1>", " ", s)
s = re.sub(r"(?is)<br\s*/?>|</p>|</div>|</li>|</h[1-6]>", "\n", s)
t = html.unescape(re.sub(r"(?s)<[^>]+>", " ", s))
t = re.sub(r"[ \t\r\f\v]+", " ", t)
t = re.sub(r"\n\s*\n\s*\n+", "\n\n", t).strip()
print(t[:12000])
')"
    printf '%s\n' "$res" >> "$LLM_OUTPUT"
}

eval "$(argc --argc-eval "$0" "$@")"
