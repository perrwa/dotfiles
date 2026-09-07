# shellcheck shell=bash
set_default com.apple.dock mineffect -string "scale"
set_default com.apple.dock showhidden -bool true
set_default com.apple.dock scroll-to-open -bool true
set_default com.apple.dock expose-group-apps -bool true

# Clearing the Dock is a one-time, fresh-machine action, not something to
# repeat on every run (it would wipe a hand-curated Dock each time).
# Guarded by a sentinel; --force-dock-reset re-arms it deliberately.
DOCK_RESET_SENTINEL="$HOME/.local/state/dotfiles/dock-reset"
if [[ ! -e "$DOCK_RESET_SENTINEL" || "${FORCE_DOCK_RESET:-false}" == true ]]; then
  defaults write com.apple.dock persistent-apps -array
  mkdir -p "$(dirname "$DOCK_RESET_SENTINEL")"
  touch "$DOCK_RESET_SENTINEL"
  info "com.apple.dock persistent-apps -> cleared (first run)"
  # shellcheck disable=SC2034  # used by the parent 40-macos.sh after sourcing this file
  DEFAULTS_CHANGED=true
fi
