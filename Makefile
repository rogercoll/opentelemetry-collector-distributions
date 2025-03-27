GO ?= go
GORELEASER ?= goreleaser

# SRC_ROOT is the top of the source tree.
SRC_ROOT := $(shell git rev-parse --show-toplevel)
OTELCOL_BUILDER_VERSION ?= 0.121.0
OTELCOL_BUILDER_DIR ?= ${HOME}/bin
OTELCOL_BUILDER ?= ${OTELCOL_BUILDER_DIR}/ocb

GOCMD?= go

DISTRIBUTIONS ?= "otelcol-desktop,otelcol-host"

.PHONY: ocb
ocb:
ifeq (, $(shell command -v ocb 2>/dev/null))
	@{ \
	[ ! -x '$(OTELCOL_BUILDER)' ] || exit 0; \
	set -e ;\
	os=$$(uname | tr A-Z a-z) ;\
	machine=$$(uname -m) ;\
	[ "$${machine}" != x86 ] || machine=386 ;\
	[ "$${machine}" != x86_64 ] || machine=amd64 ;\
	echo "Installing ocb ($${os}/$${machine}) at $(OTELCOL_BUILDER_DIR)";\
	mkdir -p $(OTELCOL_BUILDER_DIR) ;\
	CGO_ENABLED=0 go install -trimpath -ldflags="-s -w" go.opentelemetry.io/collector/cmd/builder@v$(OTELCOL_BUILDER_VERSION) ;\
	mv $$(go env GOPATH)/bin/builder $(OTELCOL_BUILDER) ;\
	}
else
OTELCOL_BUILDER=$(shell command -v ocb)
endif

build: go ocb
	@./scripts/build.sh -d "${DISTRIBUTIONS}" -b ${OTELCOL_BUILDER}

.PHONY: go
go:
	@{ \
		if ! command -v '$(GO)' >/dev/null 2>/dev/null; then \
			echo >&2 '$(GO) command not found. Please install golang. https://go.dev/doc/install'; \
			exit 1; \
		fi \
	}
