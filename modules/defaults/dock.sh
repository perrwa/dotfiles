# shellcheck shell=bash
set_default com.apple.dock mineffect -string "scale"
set_default com.apple.dock showhidden -bool true
set_default com.apple.dock scroll-to-open -bool true
set_default com.apple.dock expose-group-apps -bool true

# Clearing the Dock runs once, on a fresh machine. Repeating it every run
# would wipe a hand-curated Dock each time, so it's guarded by a sentinel;
# --force-dock-reset re-arms it deliberately.
DOCK_RESET_SENTINEL="$HOME/.local/state/dotfiles/dock-reset"
DOCK_RESET_BACKUP="$HOME/.local/state/dotfiles/dock-backup.plist"
if [[ ! -e "$DOCK_RESET_SENTINEL" || "${FORCE_DOCK_RESET:-false}" == true ]]; then
  if [[ "${DRY_RUN:-false}" == true ]]; then
    info "[dry-run] would back up com.apple.dock to $DOCK_RESET_BACKUP, then clear persistent-apps"
  else
    mkdir -p "$(dirname "$DOCK_RESET_SENTINEL")"
    # Snapshot the whole domain first so even a first-run wipe is undoable:
    #   defaults import com.apple.dock ~/.local/state/dotfiles/dock-backup.plist && killall Dock
    defaults export com.apple.dock "$DOCK_RESET_BACKUP" 2>/dev/null || true
    defaults write com.apple.dock persistent-apps -array
    touch "$DOCK_RESET_SENTINEL"
    info "com.apple.dock persistent-apps -> cleared (first run, backed up to $DOCK_RESET_BACKUP)"
    # shellcheck disable=SC2034  # used by the parent 40-macos.sh after sourcing this file
    DEFAULTS_CHANGED=true
  fi
fi
