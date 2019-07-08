#!/bin/bash

# Fetches kube config
#./get-kube-config.sh

# Starts proxy
kubectl proxy&

# Opens dashboard
xdg-open http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/ &