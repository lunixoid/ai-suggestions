PERPLEXITY_MODEL="sonar-pro"
SYSTEM_CONTEXT=$(awk -F= '/DISTRIB_ID|DISTRIB_RELEASE/{gsub(/"/,"",$2); printf "%s ", $2}' /etc/lsb-release | sed 's/ $//')

# Call Perplexity API
pplx() {
    if [[ -z "$PERPLEXITY_API_KEY" ]]; then
        echo "❌ PERPLEXITY_API_KEY not set"
        return 1
    fi
    
    local query="$*"
    local system_prompt="You are a helpful terminal assistant. Be concise and practical. Focus on shell/command line solutions."
    
    curl -s --request POST \
        --url https://api.perplexity.ai/chat/completions \
        --header "authorization: Bearer $PERPLEXITY_API_KEY" \
        --header 'content-type: application/json' \
        --data "{
            \"model\": \"$PERPLEXITY_MODEL\",
            \"messages\": [
                {\"role\": \"system\", \"content\": \"$system_prompt\"},
                {\"role\": \"user\", \"content\": \"$query\"}
            ],
            \"stream\": false
        }" | jq -r '.choices[0].message.content'
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

