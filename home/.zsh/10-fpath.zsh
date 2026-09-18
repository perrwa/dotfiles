# fpath: all completion dirs go here, before the one compinit call in
# 20-completion.zsh. Numeric prefixes on these files exist to guarantee
# that ordering (the .zshrc loop sources them alphabetically).
[[ -d /opt/homebrew/share/zsh/site-functions ]] && fpath=("/opt/homebrew/share/zsh/site-functions" $fpath)
[[ -d ~/.docker/completions ]] && fpath=(~/.docker/completions $fpath)
[[ -d ~/.zfunc ]] && fpath+=(~/.zfunc)
[[ -d ~/.zsh/completions ]] && fpath+=(~/.zsh/completions)
