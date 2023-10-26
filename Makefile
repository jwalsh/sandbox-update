PROJECT = sandbox-update

ELPA_DIR = $(PROJECT).elpa

DIST_DIR = dist
DIST_FILES = $(DIST_DIR)/$(PROJECT).el \
             $(DIST_DIR)/$(PROJECT)-pkg.el \
             $(DIST_DIR)/COPYING

dist/$(PROJECT).el:
	mkdir -p $(DIST_DIR)
	cp $(PROJECT).el $(DIST_DIR)

dist/$(PROJECT)-pkg.el:
	mkdir -p $(DIST_DIR)
	cp $(PROJECT)-pkg.el $(DIST_DIR)

dist/COPYING:
	mkdir -p $(DIST_DIR)
	cp LICENSE $(DIST_DIR)/COPYING


$(PROJECT).tar: $(DIST_FILES)
	rm -rf $(ELPA_DIR) 
	mkdir -p $(ELPA_DIR)
	cp -r $(DIST_FILES) $(ELPA_DIR)
	tar -cvzf $(PROJECT).tar $(ELPA_DIR)

build:
	emacs -Q --batch -f batch-byte-compile $(PROJECT).el

clean:
	rm -rf $(PROJECT).elc 
	rm -rf $(ELPA_DIR)
	rm -rf $(DIST_DIR)
	rm -rf $(PROJECT).tar

lint:
	emacs -Q --batch -l test/test-$(PROJECT).el -f elint-current-buffer

test:
	emacs -Q -batch -l test/test-$(PROJECT).el -f ert-run-tests-batch-and-exit

dist: clean lint build $(PROJECT).tar

.PHONY: build clean test dist
