# Login shells only, once per session. PATH lives here, not .zshrc.

[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv zsh)"

typeset -U path PATH  # dedupe on assign

path=(
  "$HOME/.local/bin"
  $path
)
[[ -n "$HOMEBREW_PREFIX" && -d "$HOMEBREW_PREFIX/share/google-cloud-sdk/bin" ]] && path=("$HOMEBREW_PREFIX/share/google-cloud-sdk/bin" $path)

export GPG_TTY=$(tty)
export COPILOT_AUTO_UPDATE=false

[[ -r "$HOME/.zprofile.local" ]] && source "$HOME/.zprofile.local"
