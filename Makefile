LN := ln -fnsv
MKDIR := mkdir -p
UNLINK := unlink

CANDIDATES := $(wildcard .??* .config/**/* .config/**/.??*)
EXCLUSIONS := .config .DS_Store .editorconfig .git .gitignore
DOTFILES := $(filter-out $(EXCLUSIONS), $(CANDIDATES))

install:
	@$(foreach file, $(DOTFILES), $(MKDIR) $(dir $(HOME)/$(file));)
	@$(foreach file, $(DOTFILES), $(LN) "$(abspath $(file))" "$(HOME)/$(file)";)

uninstall:
	@$(foreach file, $(DOTFILES), $(UNLINK) "$(HOME)/$(file)";)

list:
	@$(foreach file, $(DOTFILES), echo $(file);)

.PHONY: install uninstall list
