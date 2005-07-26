
include scf/db-rules.mk

$(FOS_STRUCTURE):: $(FOS_SOURCE)
	$(FOSC_BIN) $(FOS_SOURCE) --structure-only $(FOSC_PLUGIN) > $(FOS_STRUCTURE)

$(FOS_INTEGRITY):: $(FOS_SOURCE)
	$(FOSC_BIN) $(FOS_SOURCE) --integrity-only $(FOSC_PLUGIN) > $(FOS_INTEGRITY)



