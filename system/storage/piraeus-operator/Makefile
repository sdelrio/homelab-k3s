APP := piraeus-operator
PO_VERSION := 1.10.1
PO_URL := https://github.com/piraeusdatastore/piraeus-operator/archive/refs/tags/v$(PO_VERSION).tar.gz
# Since there is no oficial chart repo, it's only available on github

default: help

help:
	@echo "Usage: make [TARGET] ..."
	@echo ""
	@@egrep -h "#[#]" $(MAKEFILE_LIST) | sed -e 's/\\$$//' | awk 'BEGIN {FS = "[:=].*?#[#] "}; \
		{printf "\033[36m%-22s\033[0m %s\n", $$1, $$2}'
	@echo ""

download:	## Download $(APP) and extract chart
download:
	@echo piraeus-operator-$(PO_VERSION)/charts/piraeus/
	curl -L $(PO_URL) \
		| tar -xzv --strip-components=3 --overwrite piraeus-operator-$(PO_VERSION)/charts/piraeus

