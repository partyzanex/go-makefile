# go-makefile

Add this code to your Makefile:
```makefile
include go.mk

go.mk:
	@tmpdir=$$(mktemp -d) && \
	git clone --depth 1 --single-branch https://github.com/partyzanex/go-makefile.git $$tmpdir && \
	cp $$tmpdir/go.mk $(CURDIR)/go.mk
```

Run one of the commands:
```bash
make .gitignore
```

```bash
make .golangci.yml
```