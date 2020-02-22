LN := ln -fnsv
MKDIR := mkdir -p
UNLINK := unlink

ZSHSRC = .zshenv .config/zsh/.zshrc
ZSHZWC = $(addsuffix .zwc,$(ZSHSRC))

CANDIDATES := $(shell git ls-files)  $(ZSHZWC)
EXCLUSIONS := .editorconfig .gitignore LICENSE Makefile README.md
DOTFILES := $(filter-out $(EXCLUSIONS), $(CANDIDATES))

all: build

build: $(ZSHZWC)

clean:
	$(RM) $(ZSHZWC)

install:
	@$(foreach file, $(DOTFILES), $(MKDIR) $(dir $(HOME)/$(file));)
	@$(foreach file, $(DOTFILES), $(LN) "$(abspath $(file))" "$(HOME)/$(file)";)

uninstall:
	@$(foreach file, $(DOTFILES), $(UNLINK) "$(HOME)/$(file)";)

list:
	@$(foreach file, $(DOTFILES), echo $(file);)

%.zwc: %
	zsh -c "zcompile $<"

.PHONY: build clean install uninstall list
