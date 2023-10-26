ELPA_DIR = sandbox-update.elpa

DIST_DIR = dist
DIST_FILES = $(DIST_DIR)/sandbox-update.el \
             $(DIST_DIR)/sandbox-update-pkg.el \
             $(DIST_DIR)/COPYING

dist/sandbox-update.el:
	mkdir -p $(DIST_DIR)
	cp sandbox-update.el $(DIST_DIR)

dist/sandbox-update-pkg.el:
	mkdir -p $(DIST_DIR)
	cp sandbox-update-pkg.el $(DIST_DIR)

dist/COPYING:
	mkdir -p $(DIST_DIR)
	wget -q -O dist/COPYING https://www.gnu.org/licenses/gpl-3.0.txt

sandbox-update.tar: $(DIST_FILES)
	rm -rf $(ELPA_DIR) 
	mkdir -p $(ELPA_DIR)
	cp -r $(DIST_FILES) $(ELPA_DIR)
	tar -cvzf sandbox-update.tar $(ELPA_DIR)

build:
	emacs -Q --batch -f batch-byte-compile sandbox-update.el

clean:
	rm -rf sandbox-update.elc 
	rm -rf $(ELPA_DIR)
	rm -rf $(DIST_DIR)
	rm -rf sandbox-update.tar

lint:
	emacs -Q --batch -l test/test-sandbox-update.el -f elint-current-buffer

test:
	emacs -Q -batch -l test/test-sandbox-update.el -f ert-run-tests-batch-and-exit

dist: clean lint build sandbox-update.tar

.PHONY: build clean test dist
