APP := ansible
WORKON_HOME ?= .venv
VENV_BASE := $(WORKON_HOME)/$(APP)
PYTHON := $(VENV_BASE)/bin/python3
PYTHON_BIN_DIR := $(VENV_BASE)/bin

SSH_KEY_FILE ?= ~/.ssh/id_ed25519
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
venv:	# Create Virtual ENV
	@if [ ! -d "$(VENV_BASE)" ]; then \
		python3 -m venv $(VENV_BASE); \
	fi

.PHONY: requirements
requirements:	# Install PIP dependencies
requirements: venv
	@echo Upgrade PIP
	@$(PYTHON) -m pip install --upgrade pip > /dev/null
	@echo Install requirements
	@${PYTHON} -m pip install -r requirements.txt > /dev/null

.PHONY: requirements-ansible
requirements-ansible:	# Install Ansiblie collections requirements
requirements-ansible: requirements
	@echo Install ansible-galaxy collections requirements
	@${PYTHON_BIN_DIR}/ansible-galaxy install -r requirements.yml > /dev/null
	@${PYTHON_BIN_DIR}/ansible-galaxy collection install -r requirements.yml > /dev/null

.PHONY: cluster
cluster:	## Create k3s cluster, terraform config+apply and install all manifests
cluster: $(SSH_KEY_FILE) requirements-ansible system-init-node system platform ansible/install/terraformconfig apply-tf

.PHONY: system
system:		## Install /system folder manifests
system: system-network ansible/install/cilium-validate system-storage system-external system-internal
system-network: $(addprefix apply-manifest/,$(sort $(dir $(wildcard ../system/network/*/))))
system-external: $(addprefix apply-manifest/,$(sort $(dir $(wildcard ../system/external/*/))))
system-internal: $(addprefix apply-manifest/,$(sort $(dir $(wildcard ../system/internal/*/))))
system-storage: $(addprefix apply-manifest/,$(sort $(dir $(wildcard ../system/storage/*/))))

system-init-node: 	## Add new node to cluster, config os, create loop device and install k3s
system-init-node: ansible/install/os ansible/install/loop-device ansible/install/k3s

.PHONY: platform
platform:	## Install /platform folder manifests
platform: $(addprefix apply-manifest/,$(sort $(dir $(wildcard ../platform/*/))))

.PHONY: tools
tools:	## Install k9s and nerdctl tools in nodes
tools: $(SSH_KEY_FILE) requirements-ansible ansible/install/tools

.PHONY: version
version:
version:
	@echo "* ANSIBLE:"
	@$(PYTHON_BIN_DIR)/ansible --version
	@$(PYTHON_BIN_DIR)/ansible-playbook --version
	@echo "* PIP:"
	@$(PYTHON_BIN_DIR)/pip list

versions:	# Show tools versions (ansible & pip)
versions:	version

ansible/install/%:	## playbooks/install/<name> (without .yml)
	@${PYTHON_BIN_DIR}/ansible-playbook \
		$(ANSIBLE_EXTRA_ARGS) \
		playbooks/install/$*.yml

ansible/diff/%:	## playbooks/install/<name> (without .yml)
	@${PYTHON_BIN_DIR}/ansible-playbook \
		$(ANSIBLE_EXTRA_ARGS) \
		--check --diff \
		playbooks/install/$*.yml

ansible/uninstall/%:	## playbooks/uninstall/<name> (without .yml)
	@${PYTHON_BIN_DIR}/ansible-playbook \
		$(ANSIBLE_EXTRA_ARGS) \
		playbooks/uninstall/$*.yml

ansible/destroy/%:	## playbooks/destroy/<name> (without .yml)
	@${PYTHON_BIN_DIR}/ansible-playbook \
		$(ANSIBLE_EXTRA_ARGS) \
		playbooks/destroy/$*.yml

apply-tf:	## Run terraform: Create cloudflare api token ConfigMaps
apply-tf:
	@cd ../terraform && \
		make && echo Success on terraform apply

apply-manifest/%:	## apply manifest/<directory>
	@echo apply: $@
	@echo cd $*
	@export KUBECONFIG=$$(pwd)/kubeconfig.yaml && echo KUBECONFIG=$$KUBECONFIG && cd $* && $(BASE_DIR)/scripts/apply.sh

delete-manifest/%:	## delete manifest/<directory>
	@echo apply: $@
	@echo $(BASE_DIR)
	@export KUBECONFIG=$$(pwd)/kubeconfig.yaml && echo KUBECONFIG=$$KUBECONFIG && cd $* && $(BASE_DIR)/scripts/delete.sh

.PHONY: system/nginx
system/nginx:
system/nginx: apply-manifest/../system/nginx-internal apply-manifest/../system/nginx-external

.PHONY: console
console:	# Ansible Console
console: $(SSH_KEY_FILE) requirements
	${PYTHON_BIN_DIR}/ansible-console \
		$(ANSIBLE_EXTRA_ARGS) \
		--become

