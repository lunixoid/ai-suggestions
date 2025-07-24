# AI Configuration for ZSH
PERPLEXITY_MODEL="sonar"

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

# ZLE widgets for interactive use
# Error analysis (Ctrl+E)
explain_error_widget() {
    local last_command=$(fc -ln -1)
    local query="The command '$last_command' failed. Explain why and suggest a fix. Be concise."
    
    echo "\n🔍 Error Analysis:"
    pplx "$query"
    zle reset-prompt
}
zle -N explain_error_widget
bindkey '^E' explain_error_widget

# Help for current command (Ctrl+H)
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

# AI autocomplete (Ctrl+Space)
ai_autocomplete_widget() {
    if [[ -n "$BUFFER" ]]; then
        local original_buffer="$BUFFER"
        
        # Show progress
        local old_buffer="$BUFFER"
        BUFFER="🤖 AI thinking..."
        zle redisplay
        
        local suggestion=$(pplx "Complete this shell command: '$original_buffer'. Provide only the completed command, no explanation. No markdown markup. No code blocks.")
        
        if [[ -n "$suggestion" && "$suggestion" != "null" ]]; then
            # Replace with suggestion
            BUFFER="$suggestion"
        else
            # Return original command
            BUFFER="$original_buffer"
        fi
        
        zle end-of-line
    fi
}
zle -N ai_autocomplete_widget
bindkey '^ ' ai_autocomplete_widget  # Ctrl+Space

alias ai='pplx'
