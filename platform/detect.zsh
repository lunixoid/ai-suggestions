# Auto-detect the current platform and source the appropriate platform file.
# Can be overridden by setting AI_PLATFORM before sourcing this file.
# Supported values: linux, macos

_ai_platform_dir="${0:A:h}"

if [[ -z "$AI_PLATFORM" ]]; then
    case "$OSTYPE" in
        darwin*)  AI_PLATFORM="macos"  ;;
        linux*)   AI_PLATFORM="linux"  ;;
        *)        AI_PLATFORM="linux"  ;;
    esac
fi

source "${_ai_platform_dir}/${AI_PLATFORM}.zsh"

unset _ai_platform_dir
