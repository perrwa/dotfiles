# compinit: exactly once, cached for 24h (~25ms vs ~300ms full rebuild).
# The glob qualifier must stay unquoted or the 24h check never fires.
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh-24) ]]; then
  compinit -C
else
  compinit
fi

zstyle ':completion:*' menu select
