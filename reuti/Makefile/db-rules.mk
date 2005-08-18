# DB RULES ===================================================================

install:: install_sql

GEN_INSTALL_SQL_FILES = $(addsuffix .sql_install_output,$(INSTALLATION_SQL_FILES))
GEN_SQL_FILES = $(addsuffix .sql_output,$(SQL_FILES))

# Database creation ----------------------------------------------------------
install_db:: create_db $(GEN_INSTALL_SQL_FILES)

%.sql_install_output: %
	$(call load_sql_file,$<,$(DB_NAME),$(DB_USER),$(DB_PASSWORD),$(DB_HOST),$(DB_PORT),$@);

create_db::
	$(call create_db,$(DB_NAME),$(DB_HOST),$(DB_PORT),$(DB_CREATOR_USER),$(DB_CREATOR_PASSWORD),$(DB_USER),$(DB_ENCODING))
	# dropdb $(if $(DB_HOST),-h $(DB_HOST),) $(if $(DB_PORT),-p $(DB_PORT),) -U $(DB_CREATOR_USER) $(DB_NAME) || true
	# createdb $(if $(DB_HOST),-h $(DB_HOST),) $(if $(DB_PORT),-p $(DB_PORT),) -U $(DB_CREATOR_USER) -E $(DB_ENCODING) -O $(DB_USER) $(DB_NAME)

dump_db::
	$(call dump,$(DB_NAME),$(DB_HOST),$(DB_PORT),$(DB_USER),$(DB_PASSWORD),$(DB_DUMP_DATA))
	# pg_dump -U $(DB_USER) $(if $(DB_HOST),-h $(DB_HOST),) $(if $(DB_PORT),-p $(DB_PORT),) -U $(DB_CREATOR_USER) -D --data-only $(DB_NAME) > $(DB_DUMP_DATA) || true

upgrade_db:: dump_db drop_db install_db


# SQL installation -----------------------------------------------------------
install_sql:: $(GEN_SQL_FILES)

%.sql_output: %
	$(call load_sql_file,$<,$(DB_NAME),$(DB_USER),$(DB_PASSWORD),$(DB_HOST),$(DB_PORT),$@);

# Misc -----------------------------------------------------------------------

clean::
	rm -f $(GEN_INSTALL_SQL_FILES) $(GEN_SQL_FILES)


.PHONY: install_db install_sql create_db upgrade_db clean
