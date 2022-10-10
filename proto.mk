ifndef GO_INSTALL_VERSION
include go.mk
endif

# versions
PROTOC_GRPC_GATEWAY_VERSION=v2.10.3
PROTOC_GEN_GO_VERSION=v1.28.0
PROTOC_GEN_GO_GRPC_VERSION=v1.2.0
PROTOC_VERSION := 21.1
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
# versions
BUF_VERSION := v1.8.0

.PHONY: buf-install
buf-install: bin-default
	@go-install -v -e $(BUF_SOURCE_URL)@$(BUF_VERSION) $(BUF_BIN)
	@go-install -v -e $(BUF_LINT_SOURCE_URL)@$(BUF_VERSION) $(BUF_LINT_BIN)
	@go-install -v -e $(BUF_BREAKING_SOURCE_URL)@$(BUF_VERSION) $(BUF_BREAKING_BIN)

PROTO_DIR := $(CURDIR)/proto

.PHONY: proto-deps
proto-deps:
# for osx
ifeq ($(shell uname -s), Darwin)
	@tmp=$$(mktemp -d) && zip=$$tmp/protoc.zip && \
	platform=$$(uname -s | sed 's/Darwin/osx/') && arch=$$(uname -m) && \
	curl -sSL https://github.com/protocolbuffers/protobuf/releases/download/v$(PROTOC_VERSION)/protoc-$(PROTOC_VERSION)-$$platform-$$arch.zip -o $$zip && \
	cd $$tmp && unzip $$zip &> /dev/null && mkdir -p $(PROTO_DIR) && cp -R $$tmp/include/google $(PROTO_DIR)
endif
# for linux
ifeq ($(shell uname -s), Linux)
	# TODO: for linux
	# curl -L https://github.com/protocolbuffers/protobuf/releases/download/v$(PROTOC_VERSION)/protoc-$(PROTOC_VERSION)-$(shell uname -s | sed 's/Darwin/osx/')-$(shell uname -m).zip | bsdtar -xvf-
endif

GENERATED_GO_PATH = $(CURDIR)/generated/go

.PHONY: proto-default
proto-default: protoc-install buf-install proto-deps
	@rm -rf $(GENERATED_GO_PATH) && mkdir -p $(GENERATED_GO_PATH) && \
	PATH=$(MAKE_PATH) $(BUF_BIN) generate proto && \
	rm -rf $(GENERATED_GO_PATH)/google
	@for dir in $(GENERATED_GO_PATH)/*/; do \
	  cd $$dir && \
	  go mod init && go mod tidy && go mod vendor; \
	done
