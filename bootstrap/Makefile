.POSIX:
GPG_KEY ?= 0219327A
GPG_TMP ?= /tmp/key.asc
default: namespace argocd root

argocd/charts: argocd/Chart.yaml
	cd argocd \
		&& helm dependency update

namespace:
	kubectl create namespace argocd --dry-run=client --output=yaml \
		| kubectl apply -f -
gpg:
	gpg --full-generate-key --rfc4880

secret:
	gpg --armor --export-secret-keys $(GPG_KEY) > $(GPG_TMP)
	kubectl -n argocd create secret generic helm-secrets-private-keys --from-file=$(GPG_TMP)

.PHONY: argocd
argocd: argocd/charts
	cd argocd && \
		../../scripts/apply.sh

.PHONY: root
root:
	cd root && \
		./apply.sh
