ifndef LOCAL_BIN
include main.mk
endif

GO_INSTALL_VERSION :=v0.2.0
GO_INSTALL_URL :=github.com/partyzanex/go-admin-bootstrap/cmd/go-install

.PHONY: go-install
go-install: bin-default
	@go install $(GO_INSTALL_URL)@$(GO_INSTALL_VERSION)

.PHONY: test-default
test-default:
	@go test -v -count=1 -race ./...

GOLANGCI_LINT_VERSION :=v1.50.0
GOLANGCI_LINT_BIN :=$(LOCAL_BIN)/golangci-lint

.PHONY: golangci-lint-install
golangci-lint-install:
	@go-install -v -e github.com/golangci/golangci-lint/cmd/golangci-lint@$(GOLANGCI_LINT_VERSION) $(GOLANGCI_LINT_BIN)

.PHONY: lint-default
lint-default: golangci-lint-install
	@$(GOLANGCI_LINT_BIN) run
