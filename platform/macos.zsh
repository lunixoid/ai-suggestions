# macOS platform: read OS name and version via sw_vers
SYSTEM_CONTEXT="$(sw_vers -productName) $(sw_vers -productVersion)"

# macOS User-Agent for web requests
AI_UA="${AI_UA:-Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0 Safari/537.36}"
