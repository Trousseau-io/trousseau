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

pkgs = $(shell GOFLAGS=-mod=vendor $(GO) list ./... | grep -vE -e /vendor/ -e /pkg/swagger/) 
pkgDirs = $(shell GOFLAGS=-mod=vendor $(GO) list -f {{.Dir}} ./... | grep -vE -e /vendor/ -e /pkg/swagger/)
DIR_OUT:=/tmp

#GOLANGCI:=$(shell command -v golangci-lint 2> /dev/null)
#WWHRD:=$(shell command -v wwhrd 2> /dev/null)

GO_EXCLUDE := /vendor/|.pb.go|.gen.go
GO_FILES_CMD := find . -name '*.go' | grep -v -E '$(GO_EXCLUDE)'

# Clean the playground
.PHONY: clean 
clean: 
	rm -rf bin 
	rm -rf vendor 
	rm -rf pkg/swagger/server 



# Code generation
.PHONY: generate
generate: 
	@echo "==> Go code generation from pkgs"
	GOFLAGS=-mod=vendor $(GO) generate $(pkgs)


.PHONY: build
build:
	$(GO) build -o bin/trousseaud trousseaud/main.go


# Validate the swagger yaml file
.PHONY: swagger.validate
swagger.validate:
	swagger validate pkg/swagger/swagger.yml
