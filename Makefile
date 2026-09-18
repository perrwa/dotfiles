# Target names come from the word after a module file's first dash
# (30-zsh.sh -> zsh), so keep that part single-word — 30-dot-files.sh
# would produce target "dot", not "dot-files".
MODULES := $(patsubst %.sh,%,$(notdir $(wildcard modules/*.sh)))
MODULES := $(foreach m,$(MODULES),$(word 2,$(subst -, ,$(m))))
.PHONY: all upgrade dry list help dotfiles $(MODULES)
.DEFAULT_GOAL := help

all:      ; @./bootstrap.sh
upgrade:  ; @./bootstrap.sh --upgrade
dry:      ; @./bootstrap.sh --dry-run
list:     ; @./bootstrap.sh --list
dotfiles: ; @./bootstrap.sh --only zsh,git,ssh
$(MODULES): ; @./bootstrap.sh --only $@
help:     ; @echo "targets: all upgrade dry list dotfiles $(MODULES)"
