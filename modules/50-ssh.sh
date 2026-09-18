# shellcheck shell=bash
# desc: link ssh/config into ~/.ssh, seed config.local
module_run() {
  local d="$DOTFILES_DIR"

  if [[ "${DRY_RUN:-false}" == true ]]; then
    info "[dry-run] would link ssh/config, chmod ~/.ssh 700, seed ~/.ssh/config.local"
    return 0
  fi

  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  link "$d/ssh/config" "$HOME/.ssh/config"
  chmod 600 "$HOME/.ssh/config"

  if [[ ! -e "$HOME/.ssh/config.local" ]]; then
    cp "$d/ssh/config.local.example" "$HOME/.ssh/config.local"
    ok "seeded ~/.ssh/config.local (edit identities/paths as needed)"
  fi
  # Not only the seed branch — a hand-created config.local may have been
  # left world/group readable.
  chmod 600 "$HOME/.ssh/config.local"
}

module_unlink() {
  unlink_path "$HOME/.ssh/config"
}
