#!/bin/bash -x

DisableSwap() {
    swapoff -a
    sed -i 's/\/swapfile/#\/swapfile/' /etc/fstab
}

modprobe br_netfilter

# Network configuration
cat <<EOF > /proc/sys/net/ipv4/ip_forward
1
EOF

cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF


# Applies configuration above
sysctl --system

# Configures kubernetes repo
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF

# Sets SELinux in permissive mode (effectively disabling it)
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

DisableSwap

# Updates yum packages
yum -y update

# Installs docker kubelet kubeadm kubectl
yum -y install docker kubelet kubeadm kubectl --disableexcludes=kubernetes

# Enables docker kubelet
systemctl enable --now docker kubelet

# Should be the latest line in the script
systemctl daemon-reload
systemctl restart docker kubelet