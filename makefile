SHELL              := $(shell which bash)

NO_COLOR           := \033[0m
OK_COLOR           := \033[32;01m
ERR_COLOR          := \033[31;01m
WARN_COLOR         := \033[36;01m
ATTN_COLOR         := \033[33;01m

OS                 := $(shell uname -s | tr '[:upper:]' '[:lower:]')
ARCH               := $(shell uname -m | tr '[:upper:]' '[:lower:]')

EXT_DIR            := ${PWD}/.ext
EXT_BIN_DIR        := ${EXT_DIR}/bin
EXT_TMP_DIR        := ${EXT_DIR}/tmp

SVU_VER 	         := 3.3.0
BUF_VER            := 1.61.0

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
	@echo "OS:            ${OS}"
	@echo "ARCH:          ${ARCH}"
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

deps: ${EXT_BIN_DIR}/buf ${EXT_BIN_DIR}/svu info
	@echo -e "$(ATTN_COLOR)==> $@ $(NO_COLOR)"
	@gh --version >/dev/null 2>&1 || { echo >&2 "required dependency 'gh' is not installed.  Aborting."; exit 1; }
	@jq --version >/dev/null 2>&1 || { echo >&2 "required dependency 'jq' is not installed.  Aborting."; exit 1; }

${EXT_BIN_DIR}/buf: ${EXT_BIN_DIR}
	@echo -e "$(ATTN_COLOR)==> $@ $(NO_COLOR)"
	@GOBIN=${EXT_BIN_DIR} go install github.com/bufbuild/buf/cmd/buf@v${BUF_VER}
	@chmod +x ${EXT_BIN_DIR}/buf
	@${EXT_BIN_DIR}/buf --version

${EXT_BIN_DIR}/svu: ${EXT_BIN_DIR}
	@echo -e "$(ATTN_COLOR)==> $@ $(NO_COLOR)"
	@GOBIN=${EXT_BIN_DIR} go install github.com/caarlos0/svu/v3@v${SVU_VER}
	@chmod +x ${EXT_BIN_DIR}/svu
	@${EXT_BIN_DIR}/svu --version

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
