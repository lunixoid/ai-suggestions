# AI Terminal Assistant for ZSH

This project provides an AI-powered assistant for your ZSH terminal with two backends:

- Perplexity API (cloud)
- Local Ollama + web search context (DuckDuckGo + Jina Reader)

## Features

- **AI Command Completion**: Get shell command suggestions and autocompletions with <kbd>Ctrl+Space</kbd>.
- **Error Analysis**: Instantly analyze and get fixes for failed commands with <kbd>Ctrl+E</kbd>.
- **Command Help**: Get concise help and examples for any command with <kbd>Ctrl+H</kbd>.
- **Direct AI Query**: Use the `ai` alias to ask the AI anything related to the terminal.

## Project structure

```
ai-perplexity.zsh      # Perplexity API backend
ai-ollama.zsh          # Local Ollama + web search backend
widgets.zsh            # Shared ZLE widgets (sourced automatically)
platform/
  detect.zsh           # Auto-detects OS and sources the right platform file
  linux.zsh            # Linux: reads /etc/lsb-release, sets Linux User-Agent
  macos.zsh            # macOS: reads sw_vers, sets macOS User-Agent
```

Platform detection is automatic via `$OSTYPE`. You can override it by setting `AI_PLATFORM` to `linux` or `macos` before sourcing any backend script.

## Installation

Choose ONE backend and source its script in your shell config (e.g. `~/.zshrc`). Platform detection happens automatically — no separate macOS script needed.

### A) Perplexity API (cloud)

1. Set your API key:
   ```sh
   export PERPLEXITY_API_KEY="API_TOKEN"
   ```
2. Source the script (works on Linux and macOS):
   ```sh
   source /path/to/ai-perplexity.zsh
   ```

### B) Local Ollama + Web Search

1. Install and run Ollama, pull a model (example):
   ```sh
   ollama pull llama3.1:latest
   ```
2. Source the script (works on Linux and macOS):
   ```sh
   source /path/to/ai-ollama.zsh
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

### Platform override

By default, the platform is detected from `$OSTYPE`. To force a specific platform:
```sh
export AI_PLATFORM="macos"   # or "linux"
source /path/to/ai-perplexity.zsh
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

On macOS, install dependencies via [Homebrew](https://brew.sh/):
```sh
brew install jq curl python3
```

## License

MIT
