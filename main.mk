LOCAL_BIN=$(CURDIR)/bin
MAKE_PATH=$(LOCAL_BIN):/bin:/usr/bin:/usr/local/bin

.PHONY: bin-default
bin-default:
	@mkdir -p $(LOCAL_BIN)

.gitignore:
	@tmpdir=$$(mktemp -d) && \
	git clone --depth 1 --single-branch https://github.com/partyzanex/go-makefile.git $$tmpdir && \
	cp $$tmpdir/template.gitignore $(CURDIR)/.gitignore

%:  %-default
	@  true
