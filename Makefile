## Trousseau.io
## Makefile

GO := go 

## Checking if go is available on the target system 
ifeq ($(origin GO), undefined)
  GO:=$(shell which go)
endif
ifeq ($(GO),)
  $(error Could not find 'go' in path. Please install go, or if already installed either add it to your path or set GO to point to its directory)
endif

pkgs = $(shell GOFLAGS=-mod=mod $(GO) list ./... | grep -vE -e /vendor/ -e /pkg/swagger/) 
pkgDirs = $(shell GOFLAGS=-mod=mod $(GO) list -f {{.Dir}} ./... | grep -vE -e /vendor/ -e /pkg/swagger/)
DIR_OUT:=/tmp

#GOLANGCI:=$(shell command -v golangci-lint 2> /dev/null)
#WWHRD:=$(shell command -v wwhrd 2> /dev/null)

GO_EXCLUDE := /vendor/|.pb.go|.gen.go
GO_FILES_CMD := find . -name '*.go' | grep -v -E '$(GO_EXCLUDE)'

# Validate Swagger Spec file
.PHONY: validate
validate:
	swagger validate pkg/swagger/swagger.yml

# Swagger API Go Code generation
.PHONY: generate
generate: validate
	@echo "==> Go code generation from pkgs"
	GOFLAGS=-mod=mod $(GO) generate $(pkgs)

# Clean the playground
.PHONY: clean 
clean: 
	@echo "==> Clean the playground"
	rm -rf bin 
	rm -rf vendor 
	rm -rf pkg/swagger/server 

.PHONY: depend 
depend: generate
	@echo "==> Clean and updating trousseau's dependencies"
	$(GO) mod tidy -v 
	$(GO) mod verify 
	$(GO) mod vendor 
	# $(GO) get -u -v 

.PHONY: build
build: clean depend
	@echo "==> Build trousseau's binaries"
	$(GO) build -o bin/trousseaud trousseaud/main.go

