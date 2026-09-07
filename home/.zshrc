for f in "$HOME"/.zsh/*.zsh; do
  [[ -r "$f" ]] && source "$f"
done

[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
