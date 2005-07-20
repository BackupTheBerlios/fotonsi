# Generic Makefile to manage a Mason web application

include scf/std-vars.mk

# Important project subdirs
MODULES_DIR           ?= perl
MASON_DIR             ?= mason
# Installation files/dirs
MAIN_APACHE_CONF_FILE ?= $(VENDOR)-mason-$(APPLICATION_ID)-$(INSTALLATION_ID).conf
INSTALLATION_DIR      ?= /var/www/mason/$(APPLICATION_ID)

include scf/opt-vars.mk
include scf/db-vars.mk


# INSTALLATION RULES =========================================================

include scf/std-rules.mk
include scf/db-rules.mk

# Main installation rule -----------------------------------------------------
install:: install_perl install_mason


# Perl modules installation --------------------------------------------------
install_perl::
	rm -rf $(MODULES_DIR)/blib $(MODULES_DIR)/pm_to_blib $(MODULES_DIR)/Makefile
	(cd $(MODULES_DIR) && $(MODULES_DIR) Makefile.PL)
	make -C $(MODULES_DIR)
	make -C $(MODULES_DIR) install


# Mason files installation ---------------------------------------------------
install_mason::
	mkdir -p `dirname $(INSTALLATION_DIR)`
	cp -a $(MASON_DIR) $(INSTALLATION_DIR)
	for i in $(EMPTY_DIRS); do dir=$(INSTALLATION_DIR)/$$i; mkdir -p $$dir; chown $(WEB_USER).$(WEB_GROUP) $$dir; chmod 770 $$dir; done


.PHONY: install_perl install_mason
