#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$DOTFILES_DIR/lib/common.sh"
# shellcheck source=lib/brew.sh
source "$DOTFILES_DIR/lib/brew.sh"

ONLY=""
SKIP=""
NON_INTERACTIVE=false
DRY_RUN=false
KEEP_GOING=false
FORCE_DOCK_RESET=false
UPGRADE=false
UNLINK=false

usage() {
  cat <<'EOF'
Usage: ./bootstrap.sh [options]

Options:
  --only a,b         Run only these modules (preflight,packages,dotfiles,macos)
  --skip a,b         Run everything except these
  --list             List modules and exit
  --upgrade          Also run brew update && brew upgrade && brew cleanup
  --non-interactive  No prompts; Brewfile only, no picker
  --dry-run          Linking only: print every link/backup without performing it
  --keep-going       Continue past a failing module
  --force-dock-reset Re-arm the first-run-only Dock wipe
  --unlink           Undo the dotfiles module's symlinks, restoring backups
  --help             Show this help message
EOF
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --only)              ONLY="$2"; shift 2 ;;
    --skip)               SKIP="$2"; shift 2 ;;
    --list)               list_modules; exit 0 ;;
    --upgrade)            UPGRADE=true; shift ;;
    --non-interactive)    NON_INTERACTIVE=true; shift ;;
    --dry-run)            DRY_RUN=true; shift ;;
    --keep-going)         KEEP_GOING=true; shift ;;
    --force-dock-reset)   FORCE_DOCK_RESET=true; shift ;;
    --unlink)             UNLINK=true; shift ;;
    --help)               usage ;;
    *)
      echo "Error: Unknown option '$1'" >&2
      echo "Run with --help for available options." >&2
      exit 1
      ;;
  esac
done

export DOTFILES_DIR NON_INTERACTIVE DRY_RUN KEEP_GOING FORCE_DOCK_RESET ONLY SKIP

if [[ "$UNLINK" == true ]]; then
  header "Unlinking dotfiles"
  # shellcheck disable=SC1091
  source "$DOTFILES_DIR/modules/30-dotfiles.sh"
  module_unlink
  exit 0
fi

if [[ "$UPGRADE" == true ]]; then
  header "Upgrading Homebrew packages"
  ensure_brew
  upgrade_packages
  exit 0
fi

for module in "$DOTFILES_DIR"/modules/*.sh; do
  run_module "$module"
done

header "Setup complete!"
echo "Please restart your terminal to ensure all changes take effect."
