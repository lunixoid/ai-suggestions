#!/usr/bin/env zsh

# Oh My Zsh plugin entrypoint.
# Select backend via AI_BACKEND: perplexity | ollama

local plugin_dir="${0:A:h}"

case "${AI_BACKEND:-}" in
  perplexity)
    source "${plugin_dir}/ai-perplexity.zsh"
    ;;
  ollama)
    source "${plugin_dir}/ai-ollama.zsh"
    ;;
  "")
    print -u2 "ai-suggestions: AI_BACKEND is not set. Set AI_BACKEND=perplexity or AI_BACKEND=ollama before loading the plugin."
    return 1
    ;;
  *)
    print -u2 "ai-suggestions: unknown AI_BACKEND='${AI_BACKEND}'. Use 'perplexity' or 'ollama'."
    return 1
    ;;
esac

unset plugin_dir
