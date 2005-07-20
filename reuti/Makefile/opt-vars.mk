# OPTIONAL VARIABLES =========================================================

# Important project subdirs
SQL_DIR               ?= sql
# Installation files/dirs
APACHE_CONF_DIR       ?= /etc/apache/conf.d
MAIN_APACHE_CONF_FILE ?= $(VENDOR)-$(APPLICATION_ID)-$(INSTALLATION_ID).conf
MAIN_APACHE_CONF_FILE_SOURCE ?= $(shell if [ -r $(INSTALLATION_ID)-apache.conf ]; then echo $(INSTALLATION_ID)-apache.conf; else echo apache.conf; fi )
APP_CONF_FILE         ?= $(APPLICATION_ID)-$(INSTALLATION_ID).ini
APP_CONF_FILE_SOURCE  ?= $(APPLICATION_ID).ini
APP_CONF_DIR          ?= /etc/$(VENDOR)
INSTALLATION_DIR      ?= /var/www/$(APPLICATION_ID)
EMPTY_DIRS            ?= sesiones
# Database/SQL related
INSTALLATION_SQL_FILES ?= $(SQL_DIR)/*.sql_install
SQL_FILES              ?= $(SQL_DIR)/*.sql
# Misc. installation info
WEB_USER  ?= $(shell if getent passwd www-data >/dev/null; then echo www-data; else echo apache; fi)
WEB_GROUP ?= $(shell if getent group www-data >/dev/null; then echo www-data; else echo apache; fi)
