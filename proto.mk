ifndef GO_INSTALL_VERSION
include go.mk
endif

go.mk:
	@tmpdir=$$(mktemp -d) && \
	git clone --depth 1 --single-branch https://github.com/partyzanex/go-makefile.git $$tmpdir && \
	cp $$tmpdir/go.mk $(CURDIR)/go.mk

# versions
PROTOC_GRPC_GATEWAY_VERSION=v2.19.0
PROTOC_GEN_GO_VERSION=v1.32.0
PROTOC_GEN_GO_GRPC_VERSION=v1.3.0
PROTOC_VERSION := 25.2
# paths
PROTOC_BIN=$(LOCAL_BIN)/protoc

.PHONY: protoc-install
protoc-install: bin-default
ifeq ($(wildcard $(PROTOC_BIN)),)
ifeq ($(shell uname -s), Darwin)
	@tmp=$$(mktemp -d) && zip=$$tmp/protoc.zip && \
	platform=$$(uname -s | sed 's/Darwin/osx/') && arch=$$(uname -m) && \
	curl -sSL https://github.com/protocolbuffers/protobuf/releases/download/v$(PROTOC_VERSION)/protoc-$(PROTOC_VERSION)-$$platform-$$arch.zip -o $$zip && \
	cd $$tmp && unzip $$zip &> /dev/null && cp $$tmp/bin/protoc $(PROTOC_BIN)
endif
ifeq ($(shell uname -s), Linux)
	curl -L https://github.com/protocolbuffers/protobuf/releases/download/v$(PROTOC_VERSION)/protoc-$(PROTOC_VERSION)-$(shell uname -s | sed 's/Darwin/osx/')-$(shell uname -m).zip | bsdtar -xvf- bin
endif
ifeq ($(OS),Windows_NT)
	tmp=$$(mktemp -d) && zip=$$tmp/protoc.zip && \
	curl -k -L https://github.com/protocolbuffers/protobuf/releases/download/v$(PROTOC_VERSION)/protoc-$(PROTOC_VERSION)-win64.zip -o $$zip && \
	unzip $$zip -d $$tmp &> /dev/null && ls $$tmp && cp $$tmp/bin/protoc.exe $(PROTOC_BIN)
endif
	@chmod +x $(PROTOC_BIN) && echo "protoc installed!"
endif
	@go-install -v -e github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@$(PROTOC_GRPC_GATEWAY_VERSION)
	@go-install -v -e github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@$(PROTOC_GRPC_GATEWAY_VERSION)
	@go-install -v -e google.golang.org/protobuf/cmd/protoc-gen-go@$(PROTOC_GEN_GO_VERSION)
	@go-install -v -e google.golang.org/grpc/cmd/protoc-gen-go-grpc@$(PROTOC_GEN_GO_GRPC_VERSION)

# source URLs
BUF_SOURCE_URL := github.com/bufbuild/buf/cmd/buf
BUF_LINT_SOURCE_URL := github.com/bufbuild/buf/cmd/protoc-gen-buf-breaking
BUF_BREAKING_SOURCE_URL := github.com/bufbuild/buf/cmd/protoc-gen-buf-lint
# paths
BUF_BIN=$(LOCAL_BIN)/buf
BUF_LINT_BIN=$(LOCAL_BIN)/protoc-gen-buf-lint
BUF_BREAKING_BIN=$(LOCAL_BIN)/protoc-gen-buf-breaking
BUF_TEMPLATE_PATH=$(CURDIR)/buf.yaml
BUF_GEN_TEMPLATE_PATH=$(CURDIR)/buf.gen.yaml
# versions
BUF_VERSION := v1.8.0

.PHONY: buf.yaml
buf.yaml:
	@[ ! -f $(BUF_TEMPLATE_PATH) ] || exit 0 && \
	tmpdir=$$(mktemp -d) && \
	git clone --depth 1 --single-branch https://github.com/partyzanex/go-makefile.git $$tmpdir && \
	cp $$tmpdir/buf.template.yaml $(BUF_TEMPLATE_PATH)
	@[ ! -f $(BUF_GEN_TEMPLATE_PATH) ] || exit 0 && \
	tmpdir=$$(mktemp -d) && \
	git clone --depth 1 --single-branch https://github.com/partyzanex/go-makefile.git $$tmpdir && \
	cp $$tmpdir/buf.gen.template.yaml $(BUF_GEN_TEMPLATE_PATH)

.PHONY: buf-install
buf-install: bin-default buf.yaml
	@go-install -v -e $(BUF_SOURCE_URL)@$(BUF_VERSION) $(BUF_BIN)
	@go-install -v -e $(BUF_LINT_SOURCE_URL)@$(BUF_VERSION) $(BUF_LINT_BIN)
	@go-install -v -e $(BUF_BREAKING_SOURCE_URL)@$(BUF_VERSION) $(BUF_BREAKING_BIN)

PROTO_DIR := $(CURDIR)/proto

.PHONY: proto-deps
proto-deps:
ifeq ($(wildcard $(PROTO_DIR)/google),)
# for osx
ifeq ($(shell uname -s), Darwin)
	@tmp=$$(mktemp -d) && zip=$$tmp/protoc.zip && \
	platform=$$(uname -s | sed 's/Darwin/osx/') && arch=$$(uname -m) && \
	curl -sSL https://github.com/protocolbuffers/protobuf/releases/download/v$(PROTOC_VERSION)/protoc-$(PROTOC_VERSION)-$$platform-$$arch.zip -o $$zip && \
	cd $$tmp && unzip $$zip &> /dev/null && mkdir -p $(PROTO_DIR) && cp -R $$tmp/include/google $(PROTO_DIR)
endif
# for linux
ifeq ($(shell uname -s), Linux)
	tmp=$$(mktemp -d) && zip=$$tmp/protoc.zip && echo "$$zip" && \
	curl -L https://github.com/protocolbuffers/protobuf/releases/download/v$(PROTOC_VERSION)/protoc-$(PROTOC_VERSION)-$(shell uname -s | sed 's/Darwin/osx/')-$(shell uname -m).zip -o $$zip && \
	cd $$tmp && cat $$zip | bsdtar -xvf- && mkdir -p $(PROTO_DIR) && cp -R $$tmp/include/google $(PROTO_DIR)
endif
	@mkdir -p $(PROTO_DIR)/google/api && \
 	for pf in annotations http; \
	do \
		curl -L -o $(PROTO_DIR)/google/api/$$pf.proto https://raw.githubusercontent.com/googleapis/googleapis/master/google/api/$$pf.proto; \
	done
endif

GENERATED_GO_PATH ?= $(CURDIR)/generated/go

.PHONY: proto-default
proto-default: protoc-install buf-install proto-deps
	@rm -rf $(GENERATED_GO_PATH) && mkdir -p $(GENERATED_GO_PATH) && \
	PATH=$(MAKE_PATH) $(BUF_BIN) generate proto && \
	rm -rf $(GENERATED_GO_PATH)/google
	@for dir in $(GENERATED_GO_PATH)/*/; do \
	  cd $$dir && \
	  go mod init && go mod tidy && go mod vendor; \
	done
