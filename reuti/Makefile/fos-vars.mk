
include scf/db-vars.mk


FOSC_BIN 		?= fosc
FOSC_PLUGIN		?= pg

FOS_SOURCE		?= sql/$(APPLICATION_ID).fos
FOS_STRUCTURE		?= sql/000-$(APPLICATION_ID)-fos-struct.gensql
FOS_INTEGRITY		?= sql/999-$(APPLICATION_ID)-fos-integrity.gensql

INSTALLATION_SQL_FILES	:= $(FOS_STRUCTURE) $(INSTALLATION_SQL_FILES) $(FOS_INTEGRITY)
