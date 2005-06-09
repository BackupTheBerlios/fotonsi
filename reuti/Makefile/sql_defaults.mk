# Database connection/SQL related info
DB_USER               ?= operator
DB_PASSWORD           ?= 
DB_CREATOR_USER       ?= root
DB_CREATOR_PASSWORD   ?= 
DB_NAME               ?= $(APPLICATION_ID)
DB_TYPE               ?= postgresql

# Database dependant variables/macros ----------------------------------------
# PostgreSQL
DB_HOST_postgresql       ?= 
DB_PORT_postgresql       ?= 
load_sql_file_postgresql ?= psql -U $(3) $(if $(5),-h $(5),) $(if $(6),-p $(6),) $(2) -f $(1) >$(7) || rm -f $(7)
# MySQL
DB_HOST_mysql         ?= 
DB_PORT_mysql         ?= 
load_sql_file_mysql   ?= mysql -u $(3) $(if $(4),-P$(4),) $(if $(5),-h $(5),) -p $(6) $(2) < $(1) >$(7) || rm -f $(7)

DB_HOST               ?= $(DB_HOST_$(DB_TYPE))
DB_PORT               ?= $(DB_PORT_$(DB_TYPE))
# $(call load_sql_file,file.sql,database,user,pass,host,port,output_file)
load_sql_file         ?= $(load_sql_file_$(DB_TYPE))
