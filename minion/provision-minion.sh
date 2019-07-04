#!/bin/bash -x

kubeadm reset -f
kubeadm join --discovery-token-unsafe-skip-ca-verification --token ${KUBETOKEN} ${MASTER_IP}:6443
