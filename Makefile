export EMACS ?= $(shell which emacs)
CASK_DIR := $(shell cask package-directory)

$(CASK_DIR): Cask
	cask install
	@touch $(CASK_DIR)

.PHONY: cask
cask: $(CASK_DIR)

.PHONY: lint
lint: cask
	cask exec emacs --quick --batch --directory . -f checkdoc

.PHONY: compile
compile: cask
	! (cask eval "(let ((byte-compile-error-on-warn t)) \
	                 (cask-cli/build))" 2>&1 \
	   | egrep -a "(Warning|Error):") ; \
	  (ret=$$? ; cask clean-elc && exit $$ret)

.PHONY: test
test: lint compile
	cask exec buttercup -L .
