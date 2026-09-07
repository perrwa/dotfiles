autoload -Uz compinit
# Only rebuild the completion dump once a day.
if [[ -n "${ZDOTDIR:-$HOME}/.zcompdump"(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi
