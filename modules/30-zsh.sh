# shellcheck shell=bash
# desc: link home/.zsh* into place, seed *.local files
module_run() {
  local d="$DOTFILES_DIR"

  if [[ "${DRY_RUN:-false}" == true ]]; then
    info "[dry-run] would link home/.zshenv home/.zprofile home/.zshrc home/.zsh/*.zsh, seed *.local"
    return 0
  fi

  link "$d/home/.zshenv" "$HOME/.zshenv"
  link "$d/home/.zprofile" "$HOME/.zprofile"
  link "$d/home/.zshrc" "$HOME/.zshrc"

  # Link each module individually rather than the whole home/.zsh
  # directory, so a real ~/.zsh/completions/ (e.g. hand-installed
  # completion scripts) isn't backed up along with it.
  mkdir -p "$HOME/.zsh"
  for f in "$d"/home/.zsh/*.zsh; do
    link "$f" "$HOME/.zsh/$(basename "$f")"
  done

  for rc in zshenv zprofile zshrc; do
    if [[ ! -e "$HOME/.$rc.local" ]]; then
      cp "$d/home/.$rc.local.example" "$HOME/.$rc.local"
      ok "seeded ~/.$rc.local"
    fi
  done
}

module_unlink() {
  unlink_path "$HOME/.zshenv"
  unlink_path "$HOME/.zprofile"
  unlink_path "$HOME/.zshrc"
  for f in "$DOTFILES_DIR"/home/.zsh/*.zsh; do
    unlink_path "$HOME/.zsh/$(basename "$f")"
  done
}
