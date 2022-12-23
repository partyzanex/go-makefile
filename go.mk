ifndef LOCAL_BIN
include main.mk
endif

main.mk:
	@tmpdir=$$(mktemp -d) && \
	git clone --depth 1 --single-branch https://github.com/partyzanex/go-makefile.git $$tmpdir && \
	cp $$tmpdir/main.mk $(CURDIR)/main.mk

GO_INSTALL_VERSION :=v0.2.1
GO_INSTALL_URL :=github.com/partyzanex/go-admin-bootstrap/cmd/go-install

.PHONY: go-install
go-install: bin-default
	@go install $(GO_INSTALL_URL)@$(GO_INSTALL_VERSION)

.PHONY: test-default
test-default:
	@go test -v -count=1 -race ./...

GOLANGCI_LINT_VERSION :=v1.50.1
GOLANGCI_LINT_BIN :=$(LOCAL_BIN)/golangci-lint

.PHONY: golangci-lint-install
golangci-lint-install: bin-default
	@go-install -v -e github.com/golangci/golangci-lint/cmd/golangci-lint@$(GOLANGCI_LINT_VERSION) $(GOLANGCI_LINT_BIN) \
	&& echo "$(GOLANGCI_LINT_BIN)@$(GOLANGCI_LINT_VERSION) installed."

.PHONY: lint-default
lint-default: golangci-lint-install
	@$(GOLANGCI_LINT_BIN) run

GOOSE_VERSION :=v3.7.0
GOOSE_BIN=$(LOCAL_BIN)/goose

.PHONY: goose-install
goose-install:
	@go-install -v -e github.com/pressly/goose/v3/cmd/goose@$(GOOSE_VERSION) \
	&& echo "$(GOOSE_BIN)@$(GOOSE_VERSION) installed."

PG_WAIT_VERSION :=v0.1.3
PG_WAIT_BIN=$(LOCAL_BIN)/pg-wait

.PHONY: pg-wait-install
pg-wait-install:
	@go-install -v -e github.com/partyzanex/pg-wait/cmd/pg-wait@$(PG_WAIT_VERSION) \
	&& echo "$(PG_WAIT_BIN)@$(PG_WAIT_VERSION) installed."

.PHONY: pg-wait
pg-wait: pg-wait-install
ifdef POSTGRES_DSN
	@$(PG_WAIT_BIN) -d $(POSTGRES_DSN) -v
else
	@echo "POSTGRES_DSN is undefined!"
endif

.PHONY: goose-up
goose-up: goose-install
ifdef POSTGRES_DSN
	@$(GOOSE_BIN) -dir $(CURDIR)/migrations postgres $(POSTGRES_DSN) up
else
	@echo "POSTGRES_DSN is undefined!"
endif

.PHONY: goose-down
goose-down: goose-install
ifdef POSTGRES_DSN
	@$(GOOSE_BIN) -dir $(CURDIR)/migrations postgres $(POSTGRES_DSN) down
else
	@echo "POSTGRES_DSN is undefined!"
endif

GRPCURL_VERSION := v1.8.7
GRPCURL_BIN := $(LOCAL_BIN)/grpcurl

.PHONY: grpcurl-install
grpcurl-install:
	@go-install -v -e github.com/fullstorydev/grpcurl/cmd/grpcurl@$(GRPCURL_VERSION) $(GRPCURL_BIN) \
	&& echo "$(GRPCURL_BIN)@$(GRPCURL_VERSION) installed."

MOCKGEN_VERSION := v1.6.1
MOCKGEN_BIN := $(LOCAL_BIN)/mockgen

.PHONY: mockgen-install
mockgen-install:
	@go-install -v -e github.com/golang/mock/mockgen@$(MOCKGEN_VERSION) $(MOCKGEN_BIN) \
	&& echo "$(MOCKGEN_BIN)@$(MOCKGEN_VERSION) installed."
