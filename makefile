SHELL              := $(shell which bash)

NO_COLOR           := \033[0m
OK_COLOR           := \033[32;01m
ERR_COLOR          := \033[31;01m
WARN_COLOR         := \033[36;01m
ATTN_COLOR         := \033[33;01m

GOOS               := $(shell go env GOOS)
GOARCH             := $(shell go env GOARCH)

EXT_DIR            := ${PWD}/.ext
EXT_BIN_DIR        := ${EXT_DIR}/bin
EXT_TMP_DIR        := ${EXT_DIR}/tmp

GO_VER             := 1.27
SVU_VER            := 3.4.1
GOTESTSUM_VER      := 1.13.0
GOLANGCI-LINT_VER  := 2.13.2
BUF_VER            := 1.73.0

PROJECT            := access

GIT_ORG            := "github.com/authzen"
GIT_REPO           := "${GIT_ORG}/${PROJECT}"

BUF_ORG            := "buf.build/authzen"
BUF_REPO           := "${BUF_ORG}/${PROJECT}"
BUF_LATEST         := $(shell ${EXT_BIN_DIR}/buf registry module label list ${BUF_REPO} --format json | jq -r '.labels[0].name')
BUF_BIN_DIR        := ./bin
BUF_BIN_IMAGE      := ${PROJECT}.bin
PROTO_REPO         := access

RELEASE_TAG        := $$(${EXT_BIN_DIR}/svu current)

.DEFAULT_GOAL      := buf-build

.PHONY: gover
gover:
	@echo -e "$(ATTN_COLOR)==> $@ $(NO_COLOR)"
	@(go env GOVERSION | grep "go${GO_VER}") || (echo "go version check failed expected go${GO_VER} got $$(go env GOVERSION)"; exit 1)

PHONY: go-mod-tidy
go-mod-tidy:
	@echo -e "$(ATTN_COLOR)==> $@ $(NO_COLOR)"
	@exit_code=0; \
	modules=$$(go work edit -json | jq -r '.Use[].DiskPath // empty'); \
	for mod in $$modules; do \
		if [ "$$mod" = "." ]; then \
			mod_dir=$$(pwd); \
		else \
			mod_dir=$$(realpath "$$mod" 2>/dev/null || echo "$$mod"); \
		fi; \
		echo "go mod tidy: $$mod_dir"; \
		(cd "$$mod_dir" && go mod tidy -v ) || exit_code=$$?; \
	done; \
	exit $$exit_code

.PHONY: lint
lint: gover
	@echo -e "$(ATTN_COLOR)==> $@ $(NO_COLOR)"
	@${EXT_BIN_DIR}/golangci-lint config path
	@${EXT_BIN_DIR}/golangci-lint config verify
	@exit_code=0; \
	modules=$$(go work edit -json | jq -r '.Use[].DiskPath // empty'); \
	for mod in $$modules; do \
		if [ "$$mod" = "." ]; then \
			mod_dir=$$(pwd); \
		else \
			mod_dir=$$(realpath "$$mod" 2>/dev/null || echo "$$mod"); \
		fi; \
		echo "linting: $$mod_dir"; \
		(cd "$$mod_dir" && ${EXT_BIN_DIR}/golangci-lint run --config ${PWD}/.golangci.yaml ./...) || exit_code=$$?; \
	done; \
	exit $$exit_code


.PHONY: lint-clean
lint-clean: gover
	@echo -e "$(ATTN_COLOR)==> $@ $(NO_COLOR)"
	@${EXT_BIN_DIR}/golangci-lint cache clean

.PHONY: test
test: gover
	@echo -e "$(ATTN_COLOR)==> $@ $(NO_COLOR)"
	@exit_code=0; \
	modules=$$(go work edit -json | jq -r '.Use[].DiskPath // empty'); \
	for mod in $$modules; do \
		if [ "$$mod" = "." ]; then \
			mod_dir=$$(pwd); \
		else \
			mod_dir=$$(realpath "$$mod" 2>/dev/null || echo "$$mod"); \
		fi; \
		echo "testing: $$mod_dir"; \
		(cd "$$mod_dir" && ${EXT_BIN_DIR}/gotestsum --format short-verbose -- ./... -count=1 -timeout 120s --race -v) || exit_code=$$?; \
	done; \
	exit $$exit_code

.PHONY: buf-login
buf-login:
	@echo -e "$(ATTN_COLOR)==> $@ $(NO_COLOR)"
	@${EXT_BIN_DIR}/buf registry login --username ${USER}

.PHONY: buf-generate
buf-generate:
	@echo -e "$(ATTN_COLOR)==> $@ ${BUF_REPO}:${BUF_LATEST} $(NO_COLOR)"
	@${EXT_BIN_DIR}/buf generate ${BUF_REPO}:${BUF_LATEST}

.PHONY: buf-generate-dev
buf-generate-dev:
	@echo -e "$(ATTN_COLOR)==> $@ ../${PROTO_REPO}/bin/${BUF_BIN_IMAGE} $(NO_COLOR)"
	@${EXT_BIN_DIR}/buf generate ../${PROTO_REPO}/bin/${BUF_BIN_IMAGE}

info: 
	@echo -e "$(ATTN_COLOR)==> $@ $(NO_COLOR)"
	@echo "GOOS:          ${GOOS}"
	@echo "GOARCH:        ${GOARCH}"
	@echo ""
	@echo "PROJECT:       ${PROJECT}"
	@echo ""
	@echo "GIT_ORG:       ${GIT_ORG}"
	@echo "GIT_REPO:      ${GIT_REPO}"
	@echo "RELEASE_TAG:   ${RELEASE_TAG}"
	@echo ""
	@echo "EXT_DIR:       ${EXT_DIR}"
	@echo "EXT_BIN_DIR:   ${EXT_BIN_DIR}"
	@echo "EXT_TMP_DIR:   ${EXT_TMP_DIR}"
	@echo ""
	@echo "BUF_ORG:       ${BUF_ORG}"
	@echo "BUF_REPO:      ${BUF_REPO}"
	@echo "BUF_LATEST:    ${BUF_LATEST}"
	@echo "BUF_DEV_IMAGE: ${BUF_DEV_IMAGE}"
	@echo "BUF_BIN_DIR:   ${BUF_BIN_DIR}"
	@echo ""
	@echo "PROTO_REPO:    ${PROTO_REPO}"

.PHONY: deps
deps: info install-svu install-golangci-lint install-buf install-gotestsum
	@echo -e "$(ATTN_COLOR)==> $@ $(NO_COLOR)"
	@gh --version >/dev/null 2>&1 || { echo >&2 "required dependency 'gh' is not installed.  Aborting."; exit 1; }
	@jq --version >/dev/null 2>&1 || { echo >&2 "required dependency 'jq' is not installed.  Aborting."; exit 1; }

.PHONY: install-buf
install-buf: ${EXT_BIN_DIR} ${EXT_TMP_DIR}
	@echo -e "$(ATTN_COLOR)==> $@ $(NO_COLOR)"
	@GOBIN=${EXT_BIN_DIR} go install github.com/bufbuild/buf/cmd/buf@v${BUF_VER}
	@chmod +x ${EXT_BIN_DIR}/buf
	@${EXT_BIN_DIR}/buf --version

.PHONY: install-svu
install-svu: ${EXT_BIN_DIR} ${EXT_TMP_DIR}
	@echo -e "$(ATTN_COLOR)==> $@ $(NO_COLOR)"
	@GOBIN=${EXT_BIN_DIR} go install github.com/caarlos0/svu/v3@v${SVU_VER}
	@${EXT_BIN_DIR}/svu --version

.PHONY: install-gotestsum
install-gotestsum: ${EXT_TMP_DIR} ${EXT_BIN_DIR}
	@echo -e "$(ATTN_COLOR)==> $@ $(NO_COLOR)"
	@gh release download v${GOTESTSUM_VER} --repo https://github.com/gotestyourself/gotestsum --pattern "gotestsum_${GOTESTSUM_VER}_${GOOS}_${GOARCH}.tar.gz" --output "${EXT_TMP_DIR}/gotestsum.tar.gz" --clobber
	@tar -xvf ${EXT_TMP_DIR}/gotestsum.tar.gz --directory ${EXT_BIN_DIR} gotestsum &> /dev/null
	@chmod +x ${EXT_BIN_DIR}/gotestsum
	@${EXT_BIN_DIR}/gotestsum --version

.PHONY: install-golangci-lint
install-golangci-lint: ${EXT_TMP_DIR} ${EXT_BIN_DIR}
	@echo -e "$(ATTN_COLOR)==> $@ $(NO_COLOR)"
	@gh release download v${GOLANGCI-LINT_VER} --repo https://github.com/golangci/golangci-lint --pattern "golangci-lint-${GOLANGCI-LINT_VER}-${GOOS}-${GOARCH}.tar.gz" --output "${EXT_TMP_DIR}/golangci-lint.tar.gz" --clobber
	@tar --strip=1 -xvf ${EXT_TMP_DIR}/golangci-lint.tar.gz --strip-components=1 --directory ${EXT_TMP_DIR} &> /dev/null
	@mv ${EXT_TMP_DIR}/golangci-lint ${EXT_BIN_DIR}/golangci-lint
	@chmod +x ${EXT_BIN_DIR}/golangci-lint
	@${EXT_BIN_DIR}/golangci-lint --version

.PHONY: clean
clean:
	@echo -e "$(ATTN_COLOR)==> $@ $(NO_COLOR)"
	@rm -rf ./.ext
	@rm -rf ./bin

.PHONY: clean-gen
clean-gen:
	@echo -e "$(ATTN_COLOR)==> $@ $(NO_COLOR)"
	@rm -rf ./api

${BUF_BIN_DIR}:
	@echo -e "$(ATTN_COLOR)==> $@ $(NO_COLOR)"
	@mkdir -p ${BUF_BIN_DIR}

${EXT_BIN_DIR}:
	@echo -e "$(ATTN_COLOR)==> $@ $(NO_COLOR)"
	@mkdir -p ${EXT_BIN_DIR}

${EXT_TMP_DIR}:
	@echo -e "$(ATTN_COLOR)==> $@ $(NO_COLOR)"
	@mkdir -p ${EXT_TMP_DIR}
