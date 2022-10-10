#!/bin/bash
# Following this guide: https://www.hostafrica.co.za/blog/servers/kubernetes-cluster-debian-11-containerd/
# Enable Huge Page Support for mayastor https://mayastor.gitbook.io/introduction/quickstart/preparing-the-cluster
echo 1024 | sudo tee /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
echo vm.nr_hugepages = 1024 | sudo tee -a /etc/sysctl.conf

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
     curl \
     coreutils

#The following steps are commented out because etc-contaierd-config.toml is being copied beforehand.
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i '/.*containerd.runtimes.runc.options.*/a SystemdCgroup = true' /etc/containerd/config.toml

# Local registry preperation crictl
#And apply the following #https://stackoverflow.com/questions/65681045/adding-insecure-registry-in-containerd
awk '/endpoint/{print $0 "\n[plugins.\"io.containerd.grpc.v1.cri\".registry.mirrors.\"master-node:5000\"]\nendpoint = [\"http://master-node:5000\"]\n[plugins.\"io.containerd.grpc.v1.cri\".registry.configs]\n[plugins.\"io.containerd.grpc.v1.cri\".registry.configs.\"master-node:5000\".tls]\ninsecure_skip_verify = true";next}1' /etc/containerd/config.toml | sudo tee /etc/containerd/config.toml
#The previous line adds in /etc/containerd/config.toml under 'endpoint = ["https://registry-1.docker.io"]' the following lines:
#[plugins."io.containerd.grpc.v1.cri".registry.mirrors."master-node:5000"]
#  endpoint = ["http://master-node:5000"]
#  [plugins."io.containerd.grpc.v1.cri".registry.configs]
#    [plugins."io.containerd.grpc.v1.cri".registry.configs."master-node:5000".tls]
#      insecure_skip_verify = true' /etc/containerd/config.toml

sudo systemctl restart containerd
sudo systemctl status containerd
sudo crictl config runtime-endpoint /run/containerd/containerd.sock

# Local registry preperation podman
cat <<EOF | sudo tee -a /etc/containers/registries.conf
unqualified-search-registries = ['master-node:5000', 'docker.io', 'quay.io', 'registry.fedoraproject.org']

[[registry]]
location = "master-node:5000"
insecure = true
EOF
sudo systemctl restart containerd
sudo systemctl restart podman

#Install tools
sudo apt-get update -y
sudo apt-get -y install \
     nvme-cli \
     fio

sudo modprobe nvmet
sudo modprobe nvme-tcp

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


#Install go
sudo apt-get update -y
sudo apt-get install -y wget
wget https://golang.org/dl/go1.17.linux-amd64.tar.gz
sudo tar -zxvf go1.17.linux-amd64.tar.gz -C /usr/local/
#rm go1.17.linux-amd64.tar.gz
#echo "export PATH=/usr/local/go/bin:${PATH}" | sudo tee /etc/profile.d/go.sh
#source /etc/profile.d/go.sh
#echo "export PATH=/usr/local/go/bin:${PATH}" | sudo tee -a $HOME/.profile
#source $HOME/.profile
