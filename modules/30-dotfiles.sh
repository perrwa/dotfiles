# shellcheck shell=bash
# desc: link home/ and config/ into place, seed *.local files
module_run() {
  local d="$DOTFILES_DIR"

  header "zsh"
  if [[ "${DRY_RUN:-false}" == true ]]; then
    info "[dry-run] would link home/.zshenv home/.zprofile home/.zshrc home/.zsh/*.zsh, seed *.local"
  else
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
  fi

  header "git"
  if [[ "${DRY_RUN:-false}" == true ]]; then
    info "[dry-run] would remove ~/.gitconfig (shadows XDG git config) and link config/git/*"
  else
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
  fi

  header "ssh"
  if [[ "${DRY_RUN:-false}" == true ]]; then
    info "[dry-run] would link ssh/config, chmod ~/.ssh 700, seed ~/.ssh/config.local"
  else
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    link "$d/ssh/config" "$HOME/.ssh/config"
    chmod 600 "$HOME/.ssh/config"

    if [[ ! -e "$HOME/.ssh/config.local" ]]; then
      cp "$d/ssh/config.local.example" "$HOME/.ssh/config.local"
      chmod 600 "$HOME/.ssh/config.local"
      ok "seeded ~/.ssh/config.local (edit identities/paths as needed)"
    fi
  fi
}

module_unlink() {
  unlink_path "$HOME/.zshenv"
  unlink_path "$HOME/.zprofile"
  unlink_path "$HOME/.zshrc"
  for f in "$DOTFILES_DIR"/home/.zsh/*.zsh; do
    unlink_path "$HOME/.zsh/$(basename "$f")"
  done
  unlink_path "$HOME/.config/git/config"
  unlink_path "$HOME/.config/git/ignore"
  unlink_path "$HOME/.ssh/config"
  if [[ -e "$HOME/.gitconfig.bak" ]]; then
    mv "$HOME/.gitconfig.bak" "$HOME/.gitconfig"
    ok "restored ~/.gitconfig"
  fi
}
