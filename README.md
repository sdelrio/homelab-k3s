# homelab-k3s


## Metal

### Requirements

set `ANSIBLE_EXTRA_ARGS` for cloudflare settings. Sample guide:

```
export ANSIBLE_EXTRA_ARGS"=--extra-vars \"cloudflare_email=email@domain.com cloudflare_api_key=<CF_AP_KEY> cloudflare_account_id=<CF_ACCOUNT_ID>\""
```


### make

* cluster
  * ansible requirements
  * ansible os role
  * ansible k3s install
  * system
    * CNI cilium network
    * ansible cilium-validate role
    * create loop device
    * storage
        * piraeus linbit operator
        * metallb
    * external
        * cert-manager
        * external-dns
    * internal
        * intel-gpu-plugin
        * kyverno
        * node discovery
        * reloader
        * vault-operator
  * platform
        * external-secrets
        * vault-server
  * terraformconfig
    * create tfvars
    * create ingress with external-dns for dynamic IP update
  * terraforom apply
    * create cloudflare token for cert-manager
    * create cloudflare token for external-domains

```
Usage: make [TARGET] ...

cluster                Create k3s cluster, terraform config+apply and install all manifests
system                 Install /system folder manifests
platform               Install /platform folder manifests
tools                  Install k9s and nerdctl tools in nodes
ansible/install/%      playbooks/install/<name> (without .yml)
ansible/diff/%         playbooks/install/<name> (without .yml)
ansible/uninstall/%    playbooks/uninstall/<name> (without .yml)
apply-tf               Run terraform: Create cloudflare api token ConfigMaps
apply-manifest/%       apply manifest/<directory>
delete-manifest/%      delete manifest/<directory>
```

