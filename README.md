# AI Terminal Assistant for ZSH

This project provides an AI-powered assistant for your ZSH terminal, leveraging the Perplexity AI API to enhance your command-line experience with smart suggestions, error explanations, command help, and autocompletion.

## Features

- **AI Command Completion**: Get shell command suggestions and autocompletions with <kbd>Ctrl+Space</kbd>.
- **Error Analysis**: Instantly analyze and get fixes for failed commands with <kbd>Ctrl+E</kbd>.
- **Command Help**: Get concise help and examples for any command with <kbd>Ctrl+H</kbd>.
- **Direct AI Query**: Use the `ai` alias to ask the AI anything related to the terminal.

## Installation

1. **Download the configuration file**
   Place `ai-config.zsh` in your preferred configuration directory, for example: `~/.config/zsh/ai-config.zsh`.

2. **Set your Perplexity API key**
   Export your API key in your shell configuration (e.g., `.zshrc`):
   ```sh
   export PERPLEXITY_API_KEY="API_TOKEN"
   ```

3. **Source the AI configuration**
   Add the following lines to your `.zshrc` or equivalent config:
   ```sh
   # Load AI configuration
   if [[ -f ~/.config/zsh/ai-config.zsh ]]; then
       source ~/.config/zsh/ai-config.zsh
   fi
   ```

4. **(Optional) Recommended ZSH options**
   For better history handling:
   ```sh
   setopt HIST_IGNORE_SPACE
   setopt APPEND_HISTORY
   ```

5. **Reload your shell**
   Restart your terminal or run `source ~/.zshrc` to apply changes.

## Usage

- **AI Command Completion**: Type a partial command and press <kbd>Ctrl+Space</kbd> to get an AI-generated completion.
- **Error Analysis**: After a failed command, press <kbd>Ctrl+E</kbd> to get an explanation and fix.
- **Command Help**: While typing a command, press <kbd>Ctrl+H</kbd> to get help and examples.
- **Direct AI Query**: Use the `ai` command followed by your question, e.g.:
  ```sh
  ai How do I find all files larger than 1GB?
  ```

## Requirements

- ZSH shell
- [jq](https://stedolan.github.io/jq/) (for parsing JSON)
- [curl](https://curl.se/)
- A valid Perplexity API key

## License

MIT
