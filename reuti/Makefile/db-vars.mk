# Database connection/SQL related info
DB_USER               ?= operator
DB_PASSWORD           ?= 
DB_CREATOR_USER       ?= root
DB_CREATOR_PASSWORD   ?= 
DB_NAME               ?= $(APPLICATION_ID)
DB_TYPE               ?= postgresql
DB_ENCODING           ?= latin9

# SQL files/dirs
SQL_DIR                ?= sql
SQL_FILES              ?= $(wildcard $(SQL_DIR)/*.sql)
INSTALLATION_SQL_FILES_DIR ?= $(SQL_DIR)
INSTALLATION_SQL_FILES ?= $(wildcard $(INSTALLATION_SQL_FILES_DIR)/*.sql_install)
DB_DUMP_DATA           ?= $(SQL_DIR)/99_db-data-dump.sql

# Database dependant variables/macros ----------------------------------------
# PostgreSQL
DB_HOST_postgresql       ?= 
DB_PORT_postgresql       ?= 
load_sql_file_postgresql ?= psql -U $(3) $(if $(5),-h $(5),) $(if $(6),-p $(6),) $(2) -f $(1) > $(7) || rm -f $(7)
create_db_postgresql     ?= createdb $(if $(2),-h $(2),) $(if $(3),-p $(3),) -U $(4) -E $(7) -O $(6) $(1)
dump_db_postgresql       ?= pg_dump $(if $(2),-h $(2),) $(if $(3),-p $(3),) -U $(4) $(if $(5),-W,) $(1) >$(6)
# MySQL
DB_HOST_mysql         ?= 
DB_PORT_mysql         ?= 
load_sql_file_mysql   ?= mysql -u $(3) $(if $(4),-P$(4),) $(if $(5),-h $(5),) -p $(6) $(2) < $(1) >$(7) || rm -f $(7)
create_db_mysql       ?= mysqladmin $(if $(2),-h $(2),) $(if $(3),-P $(3),) -u $(4) $(if $(5),-p $(5),) create $(1)
dump_db_mysql         ?= mysqldump $(if $(2),-h $(2)) $(if $(3),-P $(3),) -u $(4) -p $(5) $(1) >$(6)

# Database-independent variables/macros --------------------------------------
DB_HOST               ?= $(DB_HOST_$(DB_TYPE))
DB_PORT               ?= $(DB_PORT_$(DB_TYPE))
# $(call load_sql_file,file.sql,database,user,pass,host,port,output_file)
load_sql_file         ?= $(load_sql_file_$(DB_TYPE))
load_sql_data         ?= $(foreach f,$(wildcard $(1)),$(call $load_sql_file $(f),$(2),$(3),$(4),$(5),$(6),$(7)))
# $(call create_db,database,host,port,creator_user,passwd,owner_user,encoding)
create_db             ?= $(create_db_$(DB_TYPE))
# $(call dump_db,database,host,port,user,passwd,output_file)
dump_db               ?= $(dump_db_$(DB_TYPE))
