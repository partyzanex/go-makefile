LOCAL_BIN=$(CURDIR)/bin
MAKE_PATH=$(LOCAL_BIN):/bin:/usr/bin:/usr/local/bin

.PHONY: bin-default
bin-default:
	@mkdir -p $(LOCAL_BIN)

%:  %-default
	@  true
