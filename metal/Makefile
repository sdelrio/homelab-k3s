APP := ansible
WORKON_HOME ?= .venv
VENV_BASE := $(WORKON_HOME)/$(APP)
PYTHON := $(VENV_BASE)/bin/python3
PYTHON_BIN_DIR := $(VENV_BASE)/bin

SSH_KEY_FILE ?= ~/.ssh/DEMOid_ed25519
ANSIBLE_EXTRA_ARGS ?=
BASE_DIR := $(shell cd .. && pwd)

default: help

$(SSH_KEY_FILE):
	ssh-keygen -t ed25519 -f "$@"

help:
	@echo "Usage: make [TARGET] ..."
	@echo ""
	@@egrep -h "#[#]" $(MAKEFILE_LIST) | sed -e 's/\\$$//' | awk 'BEGIN {FS = "[:=].*?#[#] "}; \
		{printf "\033[36m%-22s\033[0m %s\n", $$1, $$2}'
	@echo ""

.PHONY: venv
venv:	## Create Virtual ENV
	@if [ ! -d "$(VENV_BASE)" ]; then \
		python3 -m venv $(VENV_BASE); \
	fi

.PHONY: requirements
requirements:	## Install PIP dependencies
requirements: venv
	@echo Upgrade PIP
	@$(PYTHON) -m pip install --upgrade pip > /dev/null
	@echo Install requirements
	@${PYTHON} -m pip install -r requirements.txt > /dev/null

.PHONY: requirements-ansible
requirements-ansible:	## Install Ansiblie collections requirements
requirements-ansible: requirements
	@echo Install ansible-galaxy collections requirements
	@${PYTHON_BIN_DIR}/ansible-galaxy install -r requirements.yml > /dev/null
	@${PYTHON_BIN_DIR}/ansible-galaxy collection install -r requirements.yml > /dev/null

.PHONY: cluster
cluster:	## Create k3s cluster and prepare terraforom config
cluster: $(SSH_KEY_FILE) requirements-ansible ansible/install/terraformconfig ansible/install/k3s  system platform

.PHONY: system
system:		## Install /system folder
system: system-network ansible/install/cilium-validate system-storage system-external system-internal
system-network: $(addprefix apply-manifest/,$(sort $(dir $(wildcard ../system/network/*/))))
system-external: $(addprefix apply-manifest/,$(sort $(dir $(wildcard ../system/external/*/))))
system-internal: $(addprefix apply-manifest/,$(sort $(dir $(wildcard ../system/internal/*/))))
system-storage: $(addprefix apply-manifest/,$(sort $(dir $(wildcard ../system/storage/*/))))

.PHONY: platform
platform:	## Install /platform folder
platform: $(addprefix apply-manifest/,$(sort $(dir $(wildcard ../platform/*/))))  

.PHONY: tools
tools:	## Install k9s and nerdctl tools
tools: $(SSH_KEY_FILE) requirements-ansible ansible/install/tools

.PHONY: version
version:
version:
	@echo "* ANSIBLE:"
	@$(PYTHON_BIN_DIR)/ansible --version
	@$(PYTHON_BIN_DIR)/ansible-playbook --version
	@echo "* PIP:"
	@$(PYTHON_BIN_DIR)/pip list

versions:	## Show tools versions
versions:	version

ansible/install/%:	## playbook/install
	@${PYTHON_BIN_DIR}/ansible-playbook \
		$(ANSIBLE_EXTRA_ARGS) \
		playbooks/install/$*.yml

ansible/uninstall/%:	## playbooks/uninstall
	@${PYTHON_BIN_DIR}/ansible-playbook \
		$(ANSIBLE_EXTRA_ARGS) \
		playbooks/uninstall/$*.yml

system/%:	## Install system/<directory>
	@echo apply: $@
	@cd ../system/$* && ../../scripts/apply.sh

platform/%:	## Install platform/<directory>
	@echo apply: $@
	@cd ../platform/$* && ../../scripts/apply.sh

apply-manifest/%:	## apply manifest/<directory>
	@echo apply: $@
	@echo cd $*
	@cd $* && $(BASE_DIR)/scripts/apply.sh

delete-manifest/%:	## delete manifest/<directory>
	@echo apply: $@
	@echo $(BASE_DIR)
	@cd $* && $(BASE_DIR)/scripts/delete.sh

.PHONY: system/nginx
system/nginx: ## Install nginx int+ext
system/nginx: system/nginx-internal system/nginx-external

.PHONY: install-vault
install-vault: ## Instal Banzai Vault Operator + server
install-vault: system/vault-operator platform/vault-server

apply-tf:	## Run terraform: Create cloudflare api token ConfigMaps
apply-tf:
	@cd ../terraform && \
		make


.PHONY: console
console:	## Ansible Console
console: $(SSH_KEY_FILE) requirements
	${PYTHON_BIN_DIR}/ansible-console \
		$(ANSIBLE_EXTRA_ARGS) \
		--become

