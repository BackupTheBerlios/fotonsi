
include scf/db-vars.mk


FOSC_BIN 		?= fosc
FOSC_PLUGIN		?= pg

FOS_SOURCE		?= sql/$(APPLICATION_ID).fos
FOS_STRUCTURE		?= sql/$(APPLICATION_ID)-fos-struct.sql
FOS_INTEGRITY		?= sql/$(APPLICATION_ID)-fos-integrity.sql

INSTALLATION_SQL_FILES	:= $(FOS_STRUCTURE) $(INSTALLATION_SQL_FILES) $(FOS_INTEGRITY)
