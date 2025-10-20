OLLAMA_MODEL="llama3.1:latest"
OLLAMA_HOST="${OLLAMA_HOST:-http://localhost:11434}"
AI_SEARCH_RESULTS="${AI_SEARCH_RESULTS:-3}"
AI_SEARCH_TIMEOUT="${AI_SEARCH_TIMEOUT:-6}"
AI_FETCH_TIMEOUT="${AI_FETCH_TIMEOUT:-6}"
AI_CONTEXT_CHARS="${AI_CONTEXT_CHARS:-3000}"
AI_UA="${AI_UA:-Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0 Safari/537.36}"
AI_DDG_HOST="${AI_DDG_HOST:-https://html.duckduckgo.com/html}"
SYSTEM_CONTEXT=$(awk -F= '/DISTRIB_ID|DISTRIB_RELEASE/{gsub(/"/,"",$2); printf "%s ", $2}' /etc/lsb-release | sed 's/ $//')

# URL encode a string (requires python3)
_urlencode() {
    python3 - << 'PY'
import sys, urllib.parse
print(urllib.parse.quote(sys.stdin.read().strip()))
PY
}

# URL decode a string (requires python3)
_urldecode() {
    python3 - << 'PY'
import sys, urllib.parse
print(urllib.parse.unquote(sys.stdin.read().strip()))
PY
}

# Fetch simplified text of a URL via Jina Reader
_fetch_readable() {
    local url="$1"
    # Jina Reader expects scheme inside the path: https://r.jina.ai/https://example.com
    local reader_url="https://r.jina.ai/$url"
    curl -sL --max-time "$AI_FETCH_TIMEOUT" "$reader_url" | head -c "$AI_CONTEXT_CHARS"
}

# Perform a simple web search and return compact text context
_web_search_context() {
    local query="$1"
    local ddg_url="$AI_DDG_HOST/?q=$(_urlencode <<< "$query")&kl=ru-ru&kp=1"
    local html=$(curl -sL --compressed --max-time "$AI_SEARCH_TIMEOUT" -H "User-Agent: $AI_UA" "$ddg_url")
    if [[ -z "$html" ]]; then
        # Fallback to main domain if html endpoint blocked
        ddg_url="https://duckduckgo.com/html/?q=$(_urlencode <<< "$query")&kl=ru-ru&kp=1"
        html=$(curl -sL --compressed --max-time "$AI_SEARCH_TIMEOUT" -H "User-Agent: $AI_UA" "$ddg_url")
    fi
    if [[ -z "$html" ]]; then
        echo ""
        return 0
    fi
    # Extract up to N result URLs by decoding the uddg param
    local urls=()
    while IFS= read -r enc; do
        [[ -z "$enc" ]] && continue
        local decoded=$(_urldecode <<< "$enc")
        # Keep only http/https links
        if [[ "$decoded" == http://* || "$decoded" == https://* ]]; then
            urls+=("$decoded")
        fi
        [[ ${#urls[@]} -ge $AI_SEARCH_RESULTS ]] && break
    done < <(echo "$html" | grep -o 'uddg=[^"&]*' | sed 's/^uddg=//' )

    if [[ -n "$AI_SEARCH_DEBUG" ]]; then
        echo "[debug] ddg_url=$ddg_url" 1>&2
        echo "[debug] html_len=${#html}" 1>&2
        echo "[debug] found_urls=${#urls[@]}" 1>&2
    fi

    if (( ${#urls[@]} == 0 )); then
        echo ""
        return 0
    fi

    local out=""
    local idx=1
    for u in "${urls[@]}"; do
        local excerpt=$(_fetch_readable "$u")
        if [[ -n "$excerpt" ]]; then
            local block=""
            block+=$'#['"$idx"$']\n'
            block+=$'URL: '"$u"$'\n'
            block+=$'Excerpt:\n'
            block+="$excerpt"$'\n''---''\n'
            out+="$block"
            ((idx++))
        fi
    done
    echo "$out"
}

# Chat with local Ollama, augmented with quick web search context
pplx() {
    if ! curl -s --max-time 1 "$OLLAMA_HOST" > /dev/null; then
        echo "❌ Ollama не доступна на $OLLAMA_HOST"
        return 1
    fi

    local query="$*"
    local system_prompt="You are a helpful terminal assistant. Be concise and practical. Focus on shell/command line solutions. When relevant, use the provided Web results and cite URLs inline."

    # Build web search context
    local web_ctx=$(_web_search_context "$query")

    # Build JSON payload safely with jq
    local payload=$(jq -n \
        --arg model "$OLLAMA_MODEL" \
        --arg sys_prompt "$system_prompt" \
        --arg sys_ctx "$SYSTEM_CONTEXT" \
        --arg web "$web_ctx" \
        --arg q "$query" \
        '{
            model: $model,
            stream: false,
            messages: [
                {role: "system", content: $sys_prompt},
                {role: "system", content: ("System: " + $sys_ctx)},
                ( if ($web | length) > 0 then {role: "system", content: ("Web results:\n" + $web)} else empty end ),
                {role: "user", content: $q}
            ]
        }')

    curl -s --request POST \
        --url "$OLLAMA_HOST/api/chat" \
        --header 'content-type: application/json' \
        --data "$payload" | jq -r '.message.content'
}

explain_error_widget() {
    local last_command=$(fc -ln -1)
    local query="The command '$last_command' failed. My system: $SYSTEM_CONTEXT. Explain why and suggest a fix. Be concise."
    echo "\n🔍 Error Analysis:"
    pplx "$query"
    zle reset-prompt
}
zle -N explain_error_widget
bindkey '^E' explain_error_widget

get_command_help_widget() {
    local current_word="${BUFFER%% *}"
    if [[ -n "$current_word" ]]; then
        echo "\n📚 Help for '$current_word':"
        pplx "Explain the '$current_word' command with common options and examples. Be concise."
    else
        echo "\n❌ No command to explain"
    fi
    zle reset-prompt
}
zle -N get_command_help_widget
bindkey '^H' get_command_help_widget

ai_autocomplete_widget() {
    if [[ -n "$BUFFER" ]]; then
        local original_buffer="$BUFFER"
        local old_buffer="$BUFFER"
        BUFFER="🤖 AI thinking..."
        zle redisplay

        local suggestion=$(pplx "Write down new shell command for: '$original_buffer'. My system: $SYSTEM_CONTEXT. Provide only the completed command, no explanation. No markdown markup. No code blocks.")

        if [[ -n "$suggestion" && "$suggestion" != "null" ]]; then
            BUFFER="$suggestion"
        else
            BUFFER="$original_buffer"
        fi
        zle end-of-line
    fi
}
zle -N ai_autocomplete_widget
bindkey '^ ' ai_autocomplete_widget  # Ctrl+Space

alias ai='pplx'


