MODULES := $(patsubst %.sh,%,$(notdir $(wildcard modules/*.sh)))
MODULES := $(foreach m,$(MODULES),$(word 2,$(subst -, ,$(m))))
.PHONY: all upgrade dry list help $(MODULES)
.DEFAULT_GOAL := help

all:      ; @./bootstrap.sh
upgrade:  ; @./bootstrap.sh --upgrade
dry:      ; @./bootstrap.sh --dry-run
list:     ; @./bootstrap.sh --list
$(MODULES): ; @./bootstrap.sh --only $@
help:     ; @echo "targets: all upgrade dry list $(MODULES)"
