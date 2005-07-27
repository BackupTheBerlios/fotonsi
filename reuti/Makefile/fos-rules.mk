
$(FOS_STRUCTURE):: $(FOS_SOURCE)
	$(FOSC_BIN) $(FOS_SOURCE) --structure-only $(FOSC_PLUGIN) > $(FOS_STRUCTURE)

$(FOS_INTEGRITY):: $(FOS_SOURCE)
	$(FOSC_BIN) $(FOS_SOURCE) --integrity-only $(FOSC_PLUGIN) > $(FOS_INTEGRITY)


install_db:: $(FOS_STRUCTURE) $(FOS_INTEGRITY) 

clean::
	rm -f $(FOS_INTEGRITY) $(FOS_STRUCTURE)

include scf/db-vars.mk

INSTALLATION_SQL_FILES := $(FOS_STRUCTURE) $(INSTALLATION_SQL_FILES) $(FOS_INTEGRITY)

include scf/db-rules.mk

.PHONY: clean
