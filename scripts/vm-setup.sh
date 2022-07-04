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
     xfsprogs \
     curl
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i '/.*containerd.runtimes.runc.options.*/a SystemdCgroup = true' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl status containerd

#Install btrfs-progs (optional)
sudo apt-get update -y
sudo apt-get -y install \
     git \
     uuid-dev \
     libblkid-dev \
     liblzo2-dev \
     zlib1g-dev \
     zlib1g \
     libzstd-dev \
     libudev-dev \
     libgcrypt-dev \
     libsodium-dev \
     libkcapi-dev \
     e2fslibs-dev \
     python3-dev \
     python3-pip \
     python-is-python3 \
     python3-sphinx

git clone https://github.com/kdave/btrfs-progs.git
cd btrfs-progs
git checkout v5.18
./autogen.sh
./configure --disable-documentation --enable-zoned
make
sudo make install
cd ..
sudo rm -r btrfs-progs

#Install zonefs-tools (optional)
sudo apt-get update -y
sudo apt-get -y install \
     m4 \
     autoconf \
     automake \
     libtool \
     uuid-dev \
     libblkid-dev

git clone https://github.com/damien-lemoal/zonefs-tools.git
cd zonefs-tools
sh ./autogen.sh
./configure
make
sudo make install
cd ..
sudo rm -r zonefs-tools

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
