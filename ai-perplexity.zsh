PERPLEXITY_MODEL="sonar-pro"

# Detect platform and set SYSTEM_CONTEXT
source "${0:A:h}/platform/detect.zsh"

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

source "${0:A:h}/widgets.zsh"
