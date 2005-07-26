
include scf/db-vars.mk

ifndef FOS_FILE
$(error The FOS_FILE variable is mandatory)
endif

FOSC_BIN 		?= fosc
FOSC_PLUGIN		?= pg

FOS_SOURCE		?= sql/$(APPLICATION_ID).fos
FOS_STRUCTURE		?= sql/$(APPLICATION_ID)-struct.sql
FOS_INTEGRITY		?= sql/$(APPLICATION_ID)-integrity.sql

INSTALLATION_SQL_FILES	:= $(FOS_STRUCTURE) $(INSTALLATION_SQL_FILES) $(FOS_INTEGRITY)
