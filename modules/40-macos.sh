# shellcheck shell=bash
# desc: macOS system defaults (Dock, Finder, screenshots, global, input, storage)

# set_default domain key type value
#
# Compares the current value before writing so reruns are silent and
# DEFAULTS_CHANGED only gets set on a real change (killall triggers off it).
# Handles the -bool normalization gap: `defaults write -bool true` stores
# `1`/`0`, but a plain string compare against "true"/"false" would always
# differ and force a write on every run.
set_default() {
  local domain="$1" key="$2" type="$3" value="$4"
  local current
  current=$(defaults read "$domain" "$key" 2>/dev/null || true)

  local want="$value"
  if [[ "$type" == "-bool" ]]; then
    [[ "$value" == "true" ]] && want=1 || want=0
  fi

  if [[ "$current" == "$want" ]]; then
    return 0
  fi

  defaults write "$domain" "$key" "$type" "$value"
  info "$domain $key -> $value"
  DEFAULTS_CHANGED=true
}

module_run() {
  DEFAULTS_CHANGED=false

  for f in "$DOTFILES_DIR"/modules/defaults/*.sh; do
    # shellcheck disable=SC1090
    source "$f"
  done

  if [[ "$DEFAULTS_CHANGED" == true ]]; then
    info "restarting affected apps"
    killall Dock 2>/dev/null || true
    killall Finder 2>/dev/null || true
    killall SystemUIServer 2>/dev/null || true
  else
    ok "no changes"
  fi
}
