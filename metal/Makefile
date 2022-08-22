APP := ansible
WORKON_HOME ?= .venv
VENV_BASE := $(WORKON_HOME)/$(APP)
PYTHON := $(VENV_BASE)/bin/python3
PYTHON_BIN_DIR := $(VENV_BASE)/bin

SSH_KEY_FILE ?= ~/.ssh/DEMOid_ed25519
ANSIBLE_EXTRA_ARGS ?=

default: help

$(SSH_KEY_FILE):
	ssh-keygen -t ed25519 -f "$@"

help:
	@echo "Usage: make [TARGET] ..."
	@echo ""
	@@egrep -h "#[#]" $(MAKEFILE_LIST) | sed -e 's/\\$$//' | awk 'BEGIN {FS = "[:=].*?#[#] "}; \
		{printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
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
cluster:	## Create k3s cluster and install cilium
cluster: $(SSH_KEY_FILE) requirements-ansible install-k3s install-cilium install-metallb-conf install-metallb

.PHONY: tools
tools:	## Install k9s and nerdctl tools
tools: $(SSH_KEY_FILE) requirements-ansible install-tools

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

install-k3s:	## Install k3s
install-k3s:
	@${PYTHON_BIN_DIR}/ansible-playbook \
		$(ANSIBLE_EXTRA_ARGS) \
		playbooks/install/k3s.yml

install-cilium:	## Install cilium
install-cilium:
	@${PYTHON_BIN_DIR}/ansible-playbook \
		$(ANSIBLE_EXTRA_ARGS) \
		playbooks/install/cilium.yml

install-metallb-conf:	## Install metallb configmap and namespace
install-metallb-conf:
	@${PYTHON_BIN_DIR}/ansible-playbook \
		$(ANSIBLE_EXTRA_ARGS) \
		playbooks/install/metallb_config.yml

install-tools:
install-tools:
	@${PYTHON_BIN_DIR}/ansible-playbook \
		$(ANSIBLE_EXTRA_ARGS) \
		playbooks/install/tools.yml

install-metallb:	## Install MetalLB
install-metallb:
	@cd ../system/metallb-system && \
		./apply.sh

.PHONY: uninstall-k3s
uninstall-k3s:	## Uninstall k3s
uninstall-k3s: $(SSH_KEY_FILE) requirements-ansible
	${PYTHON_BIN_DIR}/ansible-playbook \
		$(ANSIBLE_EXTRA_ARGS) \
		playbooks/uninstall/k3s.yml

.PHONY: console
console:	## Ansible Console
console: $(SSH_KEY_FILE) requirements
	${PYTHON_BIN_DIR}/ansible-console \
		$(ANSIBLE_EXTRA_ARGS) \
		--become

