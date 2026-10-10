#!/usr/bin/env bash
set -e

# @describe Perform a web search to get up-to-date information or additional context.
# Use this when you need current information or feel a search could provide a better answer.
# Powered by DuckDuckGo (no API key needed), goes through the local proxy.

# @option --query! The query to search for.

# @env LLM_OUTPUT=/dev/stdout The output path

main() {
    export https_proxy="${https_proxy:-http://127.0.0.1:8118}"
    export http_proxy="${http_proxy:-http://127.0.0.1:8118}"
    local res
    res="$(curl -sS -m 25 --compressed -A "Mozilla/5.0 (X11; Linux x86_64)" \
        -G "https://html.duckduckgo.com/html/" --data-urlencode "q=$argc_query" \
        | /usr/bin/python3 -c '
import re, sys, html, urllib.parse
s = sys.stdin.read()
items = re.findall(r"<a rel=\"nofollow\" class=\"result__a\" href=\"(.*?)\".*?>(.*?)</a>", s, re.S)
snips = re.findall(r"class=\"result__snippet\".*?>(.*?)</a>", s, re.S)
out = []
for i, (u, t) in enumerate(items[:8]):
    m = re.search(r"uddg=([^&]+)", u)
    url = urllib.parse.unquote(m.group(1)) if m else (u[2:] if u.startswith("//") else u)
    title = html.unescape(re.sub("<[^>]+>", "", t)).strip()
    snip = html.unescape(re.sub("<[^>]+>", "", snips[i])).strip()[:200] if i < len(snips) else ""
    out.append("%d. %s\n   %s\n   %s" % (i + 1, title, url, snip))
print("\n".join(out) if out else "No results found.")
')"
    printf '%s\n' "$res" >> "$LLM_OUTPUT"
}

eval "$(argc --argc-eval "$0" "$@")"
