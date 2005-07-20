# STANDARD VARIABLES =========================================================

# Application id
ifndef APPLICATION_ID
$(error The APPLICATION_ID variable is mandatory)
endif
# Vendor
VENDOR ?= foton
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

# Optional variables ---------------------------------------------------------
TEMPLATE_PROCESSOR      ?= process_conf_template
GENERATED_VARS_FILE     ?= vars-tmp
