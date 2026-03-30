# Linux platform: read OS name and version from /etc/lsb-release
SYSTEM_CONTEXT=$(awk -F= '/DISTRIB_ID|DISTRIB_RELEASE/{gsub(/"/,"",$2); printf "%s ", $2}' /etc/lsb-release | sed 's/ $//')

# Linux User-Agent for web requests
AI_UA="${AI_UA:-Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0 Safari/537.36}"
