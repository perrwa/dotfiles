# shellcheck shell=bash
# desc: link config/git/* into ~/.config/git, seed config.local
module_run() {
  local d="$DOTFILES_DIR"

  if [[ "${DRY_RUN:-false}" == true ]]; then
    info "[dry-run] would remove ~/.gitconfig (shadows XDG git config) and link config/git/*"
    return 0
  fi

  # ~/.gitconfig, if present, makes git ignore ~/.config/git/config
  # entirely (git-config(1)). So the module backs it up and removes it.
  if [[ -e "$HOME/.gitconfig" && ! -L "$HOME/.gitconfig" ]]; then
    warn "$HOME/.gitconfig exists and would shadow the XDG git config; backing up to $HOME/.gitconfig.bak"
    mv "$HOME/.gitconfig" "$HOME/.gitconfig.bak"
  elif [[ -L "$HOME/.gitconfig" ]]; then
    rm -f "$HOME/.gitconfig"
  fi

  link "$d/config/git/config" "$HOME/.config/git/config"
  link "$d/config/git/ignore" "$HOME/.config/git/ignore"

  if [[ ! -e "$HOME/.config/git/config.local" ]]; then
    cp "$d/config/git/config.local.example" "$HOME/.config/git/config.local"
    ok "seeded ~/.config/git/config.local"
  fi
}

module_unlink() {
  unlink_path "$HOME/.config/git/config"
  unlink_path "$HOME/.config/git/ignore"
  if [[ -e "$HOME/.gitconfig.bak" ]]; then
    mv "$HOME/.gitconfig.bak" "$HOME/.gitconfig"
    ok "restored ~/.gitconfig"
  fi
}
