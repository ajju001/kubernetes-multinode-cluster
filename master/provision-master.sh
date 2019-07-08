#!/bin/bash -x

# This script is designed to run as non-root user

InstallPodNetworking() {
    # Sets up Network add-on (https://kubernetes.io/docs/concepts/cluster-administration/networking/)
    kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
}

InstallKubeConfig() {
    mkdir -p $HOME/.kube
    sudo cp -Rf /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config

    cat <<EOF >> $HOME/.bashrc
# Sets KUBECONFIG variable
export KUBECONFIG=$HOME/.kube/config
EOF
    source ~/.bashrc
}

InstallDashboard() {
    # Sets up Kubernetes Dashboard
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml
    kubectl proxy &
}

CopyHostSshPubKey() {
    cat <<EOF >> $HOME/.ssh/authorized_keys
----HOST PUBLIC KEY BELOW------
EOF
    cat ~/.ssh/host.pub  >> $HOME/.ssh/authorized_keys
}

# Main
sudo kubeadm reset -f
sudo kubeadm init --apiserver-advertise-address=${MASTER_IP} --pod-network-cidr=${POD_CIDR} --token ${KUBETOKEN} --token-ttl 0

CopyHostSshPubKey
InstallKubeConfig
InstallPodNetworking
InstallDashboard
