# DB RULES ===================================================================

install:: install_db install_sql

# Database creation ----------------------------------------------------------
install_db:: $(addsuffix .sql_install_output,$(wildcard $(INSTALLATION_SQL_FILES)))

%.sql_install_output: %
	$(call load_sql_file,$<,$(DB_NAME),$(DB_USER),$(DB_PASSWORD),$(DB_HOST),$(DB_PORT),$@);


# SQL installation -----------------------------------------------------------
install_sql:: $(addsuffix .sql_output,$(wildcard $(SQL_FILES)))

%.sql_output: %
	$(call load_sql_file,$<,$(DB_NAME),$(DB_USER),$(DB_PASSWORD),$(DB_HOST),$(DB_PORT),$@);


.PHONY: install_db install_sql
