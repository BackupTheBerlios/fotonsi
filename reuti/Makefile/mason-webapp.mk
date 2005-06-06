# Generic Makefile to manage a Mason web application

# VARIABLE DEFINITION ========================================================

VARS_FILE ?= vars
include $(VARS_FILE)

# Mandatory variables --------------------------------------------------------
ifndef APPLICATION_ID
$(error The APPLICATION_ID variable is mandatory)
endif

ifndef APACHE_CONF_DIR
$(error The APACHE_CONF_DIR variable is mandatory)
endif

# Optional variables ---------------------------------------------------------
TEMPLATE_PROCESSOR    ?= process_conf_template
INSTALLATION_ID       ?= $(shell hostname)
# Important project subdirs
MODULES_DIR           ?= perl
MASON_DIR             ?= mason
SQL_DIR               ?= sql
# Installation files/dirs
MAIN_APACHE_CONF_FILE ?= foton-mason-$(APPLICATION_ID)-$(INSTALLATION_ID).conf
APP_CONF_FILE         ?= $(APPLICATION_ID)-$(INSTALLATION_ID).ini
APP_CONF_DIR          ?= /etc/foton
INSTALLATION_DIR      ?= /var/www/mason/$(APPLICATION_ID)
EMPTY_DIRS            ?= sesiones
# Misc. installation info
WEB_USER              ?= $(shell if getent passwd www-data; then echo www-data; else echo apache; fi)
WEB_GROUP             ?= $(shell if getent group www-data; then echo www-data; else echo apache; fi)


# GENERIC RULES ==============================================================
# "Compile" files from templates and the vars file
%: %.in $(VARS_FILE)
	$(TEMPLATE_PROCESSOR) $< $(VARS_FILE) >$@

# INSTALLATION RULES =========================================================

# Configuration installation -------------------------------------------------
install_conf:: $(APACHE_CONF_DIR)/$(MAIN_APACHE_CONF_FILE) $(APP_CONF_DIR)/$(APP_CONF_FILE)

# Apache configuration
$(APACHE_CONF_DIR)/$(MAIN_APACHE_CONF_FILE): $(INSTALLATION_ID)-apache.conf
	mkdir -p `dirname $@`
	cp $< $@

# Application configuration
$(APP_CONF_DIR)/$(APP_CONF_FILE): $(APPLICATION_ID).ini
	mkdir -p `dirname $@`
	cp $< $@



# Database creation ----------------------------------------------------------
install_db::


# SQL installation -----------------------------------------------------------
install_sql::


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
	for i in $(EMPTY_DIRS); do dir=$(INSTALLATION_DIR)/$$i; mkdir $$dir; chown $(WEB_USER).$(WEB_GROUP) $$dir; chmod 770 $$dir; done


.PHONY: install_conf install_perl install_mason
