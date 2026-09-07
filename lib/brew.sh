#!/usr/bin/env bash
# Homebrew install/shellenv, and the Brewfile + Brewfile.optional picker.
# Sourced by bootstrap.sh (after common.sh); assumes DOTFILES_DIR is set.

BREW_PREFIX="/opt/homebrew"

ensure_brew() {
  if ! command -v brew &>/dev/null; then
    info "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    ok "Homebrew already installed"
  fi
  eval "$("$BREW_PREFIX/bin/brew" shellenv)"
  brew update
}

ensure_gum() {
  if ! command -v gum &>/dev/null; then
    info "Installing gum (interactive prompts)..."
    brew install gum
  fi
}

# Extract every `tap "..."` line from a Brewfile so a generated temp
# Brewfile always carries the taps its formulae depend on
# (e.g. qmk/qmk/qmk needs `tap "qmk/qmk"`).
_brew_taps() {
  grep -h '^tap ' "$@" 2>/dev/null || true
}

# Non-tap, non-comment, non-blank lines — the actual package entries.
_brew_entries() {
  grep -hE '^(brew|cask) ' "$1" 2>/dev/null || true
}

# install_packages — installs Brewfile always; if interactive, offers
# Brewfile.optional entries via gum and installs the chosen subset too.
install_packages() {
  local base="$DOTFILES_DIR/Brewfile"
  local optional="$DOTFILES_DIR/Brewfile.optional"
  local tmp
  tmp=$(mktemp -t dotfiles-brewfile)
  trap 'rm -f "$tmp"' RETURN

  _brew_taps "$base" "$optional" > "$tmp"
  _brew_entries "$base" >> "$tmp"

  if [[ "${NON_INTERACTIVE:-false}" != true && -f "$optional" ]]; then
    ensure_gum
    local names=() lines=()
    while IFS= read -r line; do
      [[ -z "$line" ]] && continue
      lines+=("$line")
      names+=("$(sed -E 's/^(brew|cask) "([^"]+)".*/\2/' <<<"$line")")
    done < <(_brew_entries "$optional")

    if [[ ${#names[@]} -gt 0 ]]; then
      log "Select optional packages to install (space to toggle, enter to confirm):"
      local chosen
      chosen=$(gum choose --no-limit "${names[@]}" < /dev/tty) || true
      while IFS= read -r pick; do
        [[ -z "$pick" ]] && continue
        for i in "${!names[@]}"; do
          [[ "${names[$i]}" == "$pick" ]] && printf '%s\n' "${lines[$i]}" >> "$tmp"
        done
      done <<< "$chosen"
    fi
  fi

  brew bundle --file="$tmp"
}

upgrade_packages() {
  brew update
  brew upgrade
  brew cleanup
}
