#!/bin/bash

kubectl exec -n piraeus-operator deploy/linstor-controller -- curl -s --key /etc/linstor/client/tls.key --cert /etc/linstor/client/tls.crt --cacert /etc/linstor/client/ca.crt https://linstor-controller.piraeus-operator.svc:3371/v1/controller/version

