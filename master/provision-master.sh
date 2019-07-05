#!/bin/bash -x

# This script is designed to run as non-root user

InstallKubectlAutocompletion() {
# amends ~/.bashrc to provide kubectl auto completion
    cat <<EOF >> $HOME/.bashrc
# enables kubectl auto completion
source <(kubectl completion bash)
EOF
    source ~/.bashrc
}

InstallPodNetworking() {
    # Sets up Network add-on (https://kubernetes.io/docs/concepts/cluster-administration/networking/)
    kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
}

InstallKubeConfig() {
    mkdir -p $HOME/.kube
    sudo cp -Rf /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
    export KUBECONFIG=$HOME/.kube/config
}

InstallDashboard() {
    # Sets up Kubernetes Dashboard
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml
    kubectl proxy &
}

# Main
sudo kubeadm reset -f
sudo kubeadm init --apiserver-advertise-address=${MASTER_IP} --pod-network-cidr=${POD_CIDR} --token ${KUBETOKEN} --token-ttl 0

InstallKubeConfig
InstallKubectlAutocompletion
InstallPodNetworking
InstallDashboard