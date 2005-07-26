# Generic Makefile to manage a Mason web application

include scf/std-vars.mk

# Installation files/dirs
MAIN_APACHE_CONF_FILE ?= $(VENDOR)-webware-$(APPLICATION_ID)-$(INSTALLATION_ID).conf
APP_CONF_FILE         ?= $(APPLICATION_ID).ini

# WebWare specific
WEBWARE_DIR           ?= webware
WEBWARE_CONTEXT       ?= $(APPLICATION_ID)
WEBWARE_CONF_DIR      ?= $(shell if [ -d /usr/local/share/webware/inst/Configs ]; then echo /usr/local/share/webware/inst/Configs; fi)
ifeq ($(strip $(WEBWARE_CONF_DIR)),)
$(error Can\'t guess WebWare config dir. Please set WEBWARE_CONF_DIR.)
endif
WEBWARE_CONF_FILE     ?= $(WEBWARE_CONF_DIR)/Application.config

# Check if Application.config has this context
CONFIGURED_DIR_FOR_CONTEXT=$(shell python -c "exec 'k='+open('$(WEBWARE_CONF_FILE)').read(); print k['Contexts']['$(WEBWARE_CONTEXT)']" 2> /dev/null)
EXPECTED_DIR_FOR_CONTEXT=$(shell pwd)/$(WEBWARE_DIR)/$(APPLICATION_ID)
ifeq ($(CONFIGURED_DIR_FOR_CONTEXT),)
$(warning THERE SEEMS TO BE NO CONTEXT DEFINED FOR $(WEBWARE_CONTEXT).)
$(warning MAKE SURE WEBWARE IS CONFIGURED TO RUN THE APPLICATION!)
$(warning SHOULD BE '$(EXPECTED_DIR_FOR_CONTEXT)')
else
    ifneq ($(CONFIGURED_DIR_FOR_CONTEXT),$(EXPECTED_DIR_FOR_CONTEXT))
$(warning IT SEEMS THAT THERE'S AN INCONSISTENCY IN THE)  # ')$( <- VIM SYNTAX
$(warning WEBWARE CONTEXT CONFIGURATION:) 		  #)
$(warning FOUND '$(CONFIGURED_DIR_FOR_CONTEXT)' IN)
$(warning '$(WEBWARE_CONF_FILE)',)
$(warning SHOULD BE '$(EXPECTED_DIR_FOR_CONTEXT)')
    endif
endif

include scf/opt-vars.mk
include scf/fos-vars.mk


# INSTALLATION RULES =========================================================

include scf/std-rules.mk
include scf/fos-rules.mk
