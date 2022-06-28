#!/bin/bash
# Following this guide: https://www.hostafrica.co.za/blog/servers/kubernetes-cluster-debian-11-containerd/
# Configuration
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system

#Containerd
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -y
sudo apt-get -y install \
     containerd \
     podman \
     ca-certificates \
     gnupg \
     curl
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i '/.*containerd.runtimes.runc.options.*/a SystemdCgroup = true' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl status containerd

#Kubernetes
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

sudo apt-get update -y
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# No firewall is installed
#sudo ufw allow 6443/tcp
#sudo ufw allow 2379/tcp
#sudo ufw allow 2380/tcp
#sudo ufw allow 10250/tcp
#sudo ufw allow 10251/tcp
#sudo ufw allow 10252/tcp
#sudo ufw allow 10255/tcp
#sudo ufw reload
sudo swapoff –a
sudo systemctl enable kubelet
