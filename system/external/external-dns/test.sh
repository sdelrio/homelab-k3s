#!/bin/bash

NS=${NS:-`basename "$PWD"`}

curl -X GET "https://api.cloudflare.com/client/v4/zones" \
    -H "Content-Type:application/json" \
    -H "Authorization: Bearer $(kubectl -n ${NS} get secrets cloudflare-api-token -o jsonpath='{.data.value}' | base64 -d)"

