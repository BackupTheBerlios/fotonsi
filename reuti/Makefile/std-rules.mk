# BASIC CONFIGURATION RULES ==================================================

# GENERIC RULES ==============================================================
# Default rule
all::

install:: all install_conf

# "Compile" files from templates and the vars file
%: %.in $(GENERATED_VARS_FILE)
	$(TEMPLATE_PROCESSOR) $< $(GENERATED_VARS_FILE) >$@ || rm -f $(GENERATED_VARS_FILE)

# Generate an "extended" vars file
$(GENERATED_VARS_FILE): $(VARS_FILE) Makefile
	0>$(GENERATED_VARS_FILE)
	@$(foreach var,$(.VARIABLES),$(if $(findstring file,$(origin $(var))),echo '$(var) = $($(var))' >>$(GENERATED_VARS_FILE);))


# CONFIGURATION RULES ========================================================
install_conf:: $(APACHE_CONF_DIR)/$(MAIN_APACHE_CONF_FILE) $(APP_CONF_DIR)/$(APP_CONF_FILE)

# Apache configuration
$(APACHE_CONF_DIR)/$(MAIN_APACHE_CONF_FILE): $(MAIN_APACHE_CONF_FILE_SOURCE)
	mkdir -p `dirname $@`
	cp $< $@

# Application configuration
$(APP_CONF_DIR)/$(APP_CONF_FILE): $(APP_CONF_FILE_SOURCE)
	mkdir -p `dirname $@`
	cp $< $@

.PHONY: all install_conf install
