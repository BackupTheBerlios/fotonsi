# Generic Makefile to manage a Mason web application

# VARIABLE DEFINITION ========================================================

# Don't change this unless you know what you're doing
SCF_INSTALL_DIR=/usr/local/share/scf

# Application id
ifndef APPLICATION_ID
$(error The APPLICATION_ID variable is mandatory)
endif
# Installation id (you can use a file named "default_install" to set the
# default installation, or pass the INSTALLATION_ID as a Makefile variable. If
# not, it default to the hostname)
INSTALLATION_ID       ?= $(shell if [ -r default_install ]; then cat default_install; else hostname; fi)

# Find out a suitable variables file
VARS_FILE ?= $(shell if [ -r vars-$(INSTALLATION_ID) ]; then echo vars-$(INSTALLATION_ID); else echo vars; fi)
ifeq ($(strip $(shell [ -r $(VARS_FILE) ] && echo -n $(VARS_FILE))),)
$(error No se encuentra el fichero de variables para la instalación $(INSTALLATION_ID) ('$(VARS_FILE)'))
endif
# Actually include it
include $(VARS_FILE)

# Included Makefile snippets -------------------------------------------------
include $(SCF_INSTALL_DIR)/sql_defaults.mk

# Optional variables ---------------------------------------------------------
TEMPLATE_PROCESSOR      ?= process_conf_template
MAIN_APACHE_SOURCE_CONF ?= $(shell if [ -r $(INSTALLATION_ID)-apache.conf ]; then echo $(INSTALLATION_ID)-apache.conf; else echo apache.conf; fi )
GENERATED_VARS_FILE     ?= vars-tmp
# Important project subdirs
MODULES_DIR           ?= perl
MASON_DIR             ?= mason
SQL_DIR               ?= sql
# Installation files/dirs
APACHE_CONF_DIR       ?= /etc/apache/conf.d
MAIN_APACHE_CONF_FILE ?= foton-mason-$(APPLICATION_ID)-$(INSTALLATION_ID).conf
APP_CONF_FILE         ?= $(APPLICATION_ID)-$(INSTALLATION_ID).ini
APP_CONF_DIR          ?= /etc/foton
INSTALLATION_DIR      ?= /var/www/mason/$(APPLICATION_ID)
EMPTY_DIRS            ?= sesiones
# Database/SQL related
INSTALLATION_SQL_FILES ?= $(SQL_DIR)/*.sql_install
SQL_FILES              ?= $(SQL_DIR)/*.sql
# Misc. installation info
WEB_USER  ?= $(shell if getent passwd www-data >/dev/null; then echo www-data; else echo apache; fi)
WEB_GROUP ?= $(shell if getent group www-data >/dev/null; then echo www-data; else echo apache; fi)


# GENERIC RULES ==============================================================
# Default rule
all:

# "Compile" files from templates and the vars file
%: %.in $(GENERATED_VARS_FILE)
	$(TEMPLATE_PROCESSOR) $< $(GENERATED_VARS_FILE) >$@ || rm -f $(GENERATED_VARS_FILE)

# Generate an "extended" vars file
$(GENERATED_VARS_FILE): $(VARS_FILE) Makefile
	0>$(GENERATED_VARS_FILE)
	@$(foreach var,$(.VARIABLES),$(if $(findstring file,$(origin $(var))),echo '$(var) = $($(var))' >>$(GENERATED_VARS_FILE);))


# INSTALLATION RULES =========================================================

# Main installation rule -----------------------------------------------------
install:: install_conf install_sql install_perl install_mason


# Configuration installation -------------------------------------------------
install_conf:: $(APACHE_CONF_DIR)/$(MAIN_APACHE_CONF_FILE) $(APP_CONF_DIR)/$(APP_CONF_FILE)

# Apache configuration
$(APACHE_CONF_DIR)/$(MAIN_APACHE_CONF_FILE): $(MAIN_APACHE_SOURCE_CONF)
	mkdir -p `dirname $@`
	cp $< $@

# Application configuration
$(APP_CONF_DIR)/$(APP_CONF_FILE): $(APPLICATION_ID).ini
	mkdir -p `dirname $@`
	cp $< $@



# Database creation ----------------------------------------------------------
install_db:: $(addsuffix .sql_install_output,$(wildcard $(INSTALLATION_SQL_FILES)))

%.sql_install_output: %
	$(call load_sql_file,$<,$(DB_NAME),$(DB_USER),$(DB_PASSWORD),$(DB_HOST),$(DB_PORT),$@);


# SQL installation -----------------------------------------------------------
install_sql:: $(addsuffix .sql_output,$(wildcard $(SQL_FILES)))

%.sql_output: %
	$(call load_sql_file,$<,$(DB_NAME),$(DB_USER),$(DB_PASSWORD),$(DB_HOST),$(DB_PORT),$@);


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


.PHONY: install install_conf install_db install_sql install_perl install_mason
