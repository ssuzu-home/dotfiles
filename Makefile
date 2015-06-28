DOTFILES_EXCLUDES := .DS_Store .git
DOTFILES_TARGET   := $(wildcard .??*) bin
DOTFILES_FILES    := $(filter-out $(DOTFILES_EXCLUDES), $(DOTFILES_TARGET))

.PHONY: none
none: ;

.PHONY: all
all: install

.PHONY: test
test:
	@prove $(PROVE_OPT) $(wildcard ./etc/test/*_test.pl)

.PHONY: help
help:
	@echo "make list           #=> Show file list for deployment"
	@echo "make update         #=> Fetch changes for this repo"
	@echo "make deploy         #=> Create symlink to home directory"
	@echo "make init           #=> Setup environment settings"
	@echo "make install        #=> Run make update, deploy, init"
	@echo "make clean          #=> Remove the dotfiles and this repo"

.PHONY: list
list:
	@$(foreach val, $(DOTFILES_FILES), ls -dF $(val);)

.PHONY: pull
pull:
	git pull origin master

.PHONY: push
push:
	git add .
	git commit -a -m "Update"
	git push origin master

.PHONY: update
update:
	git pull origin master
	git submodule init
	git submodule update
	git submodule foreach git pull origin master

.PHONY: deploy
deploy:
	@echo 'Copyright (c) 2013-2015 BABAROT All Rights Reserved.'
	@echo '==> Start to deploy dotfiles to home directory.'
	@echo ''
	@$(foreach val, $(DOTFILES_FILES), ln -sfnv $(abspath $(val)) $(HOME)/$(val);)

.PHONY: init
init:
	@#$(foreach val, $(wildcard ./etc/init/*.sh), DOTPATH=$(PWD) bash $(val);)
	@DOTPATH=$(PWD) bash ./etc/init/init.sh

.PHONY: install
install: update deploy init
	@exec $$SHELL

.PHONY: clean
clean:
	@echo 'Remove dot files in your home directory...'
	@-$(foreach val, $(DOTFILES_FILES), rm -vrf $(HOME)/$(val);)
	-rm -rf $(PWD)
