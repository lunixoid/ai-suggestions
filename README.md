# AI Terminal Assistant for ZSH

This project provides an AI-powered assistant for your ZSH terminal with two backends:

- Perplexity API (cloud)
- Local Ollama + web search context (DuckDuckGo + Jina Reader)

## Features

- **AI Command Completion**: Get shell command suggestions and autocompletions with <kbd>Ctrl+Space</kbd>.
- **Error Analysis**: Instantly analyze and get fixes for failed commands with <kbd>Ctrl+E</kbd>.
- **Command Help**: Get concise help and examples for any command with <kbd>Ctrl+H</kbd>.
- **Direct AI Query**: Use the `ai` alias to ask the AI anything related to the terminal.

## Installation

Choose ONE backend and source its script in your shell config.

### A) Perplexity API (cloud)

1. Set your API key in your shell (e.g. `.zshrc`):
   ```sh
   export PERPLEXITY_API_KEY="API_TOKEN"
   ```
2. Source the script:
   ```sh
   source ai-suggestions/ai-perplexity.zsh
   ```

### B) Local Ollama + Web Search

1. Install and run Ollama, pull a model (example):
   ```sh
   ollama pull llama3.1:latest
   ```
2. Source the script:
   ```sh
   source ai-suggestions/ai-ollama.zsh
   ```
3. (Optional) Tune environment variables:
   ```sh
   # Model and host
   export OLLAMA_MODEL="llama3.1:latest"
   export OLLAMA_HOST="http://localhost:11434"

   # Web search controls
   export AI_SEARCH_RESULTS=3
   export AI_SEARCH_TIMEOUT=6
   export AI_FETCH_TIMEOUT=6
   export AI_CONTEXT_CHARS=3000
   export AI_UA="Mozilla/5.0"
   # Use HTML endpoint; fallback is duckduckgo.com/html
   export AI_DDG_HOST="https://html.duckduckgo.com/html"
   # Debug
   export AI_SEARCH_DEBUG=0
   ```

### Recommended ZSH options
For better history handling:
```sh
setopt HIST_IGNORE_SPACE
setopt APPEND_HISTORY
```

### Reload your shell
Restart your terminal or run `source ~/.zshrc` to apply changes.

## Usage

- **AI Command Completion**: Type a partial command and press <kbd>Ctrl+Space</kbd> to get an AI-generated completion.
- **Error Analysis**: After a failed command, press <kbd>Ctrl+E</kbd> to get an explanation and fix.
- **Command Help**: While typing a command, press <kbd>Ctrl+H</kbd> to get help and examples.
- **Direct AI Query**: Use the `ai` command followed by your question, e.g.:
  ```sh
  ai "How do I find all files larger than 1GB?"
  ```

## Requirements

- ZSH shell
- [jq](https://stedolan.github.io/jq/) (for JSON)
- [curl](https://curl.se/)
- [python3](https://www.python.org/) (URL encode/decode helper in Ollama backend)
- For Perplexity backend: a valid Perplexity API key and internet access
- For Ollama backend: running [Ollama](https://ollama.com/), a pulled local model, and internet access for web search

## License

MIT
