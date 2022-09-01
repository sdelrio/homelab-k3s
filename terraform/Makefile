.POSIX:

KUBE_CONFIG_PATH ?= ../metal/kubeconfig.yaml

default: init apply

help:
	@echo "Usage: make [TARGET] ..."
	@echo ""
	@@egrep -h "#[#]" $(MAKEFILE_LIST) | sed -e 's/\\$$//' | awk 'BEGIN {FS = "[:=].*?#[#] "}; \
	{printf "\033[36m%-22s\033[0m %s\n", $$1, $$2}'
	@echo ""

.PHONY: init
init:	## Terraform init
init:
	@if [ ! -d .terraform ]; then \
		terraform init && touch .terraform.lock.hcl; \
	else \
		echo already initialized; \
	fi
	@echo KUBE_CONFIG_PATH=$(KUBE_CONFIG_PATH)

.PHONY: plan
plan:	## Terraform plan
plan: .terraform.lock.hcl
	@KUBE_CONFIG_PATH=$(KUBE_CONFIG_PATH) terraform plan

.PHONY: apply
apply:	## Terraform apply with -auto-approve
apply: .terraform.lock.hcl
	@KUBE_CONFIG_PATH=$(KUBE_CONFIG_PATH) terraform apply -auto-approve

