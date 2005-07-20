# Makefile-installer Makefile :-)

# If you change this, make sure it's in the Makefile include path
MAKEFILES_DIR=/usr/local/include/scf
BIN_DIR=/usr/local/bin

all:

install:
	mkdir -p $(MAKEFILES_DIR) $(BIN_DIR)
	cp -a *.mk $(MAKEFILES_DIR)
	for prg in *.pl; do \
	    prg_path=$(BIN_DIR)/`basename $$prg .pl`; \
            cp $$prg $$prg_path; \
            chmod +x $$prg_path; \
        done
