#!/bin/bash

#Disable selinux (set to permissive mode)
sudo setenforce 0

#Disable swap on Fedora
sudo dnf -y remove zram-generator-defaults

#Disable Firewall
sudo systemctl stop firewalld
sudo systemctl disable firewalld
sudo systemctl mask --now firewalld

#For file sharing b/w Host & VM
sudo modprobe 9p
sudo modprobe 9pnet_virtio
sudo modprobe 9pnet
sudo modprobe overlay

# Following this guide: https://www.hostafrica.co.za/blog/servers/kubernetes-cluster-debian-11-containerd/
# Enable Huge Page Support for mayastor https://mayastor.gitbook.io/introduction/quickstart/preparing-the-cluster
echo 1024 | sudo tee /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
echo vm.nr_hugepages = 1024 | sudo tee -a /etc/sysctl.conf

# Configuration
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
sudo modprobe br_netfilter
sudo modprobe nvmet
sudo modprobe nvme-tcp

cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system

#Containerd
#export DEBIAN_FRONTEND=noninteractive
#sudo dnf update -y
sudo dnf -y install \
	iproute-tc \
    containerd \
    podman \
    ca-certificates \
    gnupg \
    xfsprogs \
    curl \
    coreutils \
	util-linux-core \
	libnvme \
	libnvme-devel \
	libblkid-devel
#	docker


sudo swapoff –a

#Kubernetes
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
sudo yum install -y kubeadm kubectl kubelet

#sudo apt-get update -y

#Prevent removal as other app dependency
sudo dnf mark install kubelet kubeadm kubectl

#The following steps are commented out because etc-contaierd-config.toml is being copied beforehand.
sudo mkdir -p /etc/containerd
containerd config default | tee ~/temp_config.toml

#sudo sed -i '/.*containerd.runtimes.runc.options.*/a SystemdCgroup = true' /etc/containerd/config.toml
# Above does not work on Fedora, instead use this
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' ~/temp_config.toml
sed -i 's|\<registry.mirrors\>]|registry.mirrors."master-node:5000"]\nendpoint = ["http://master-node:5000"]|g' ~/temp_config.toml

# Local registry preparation - on Fedora
awk '/.registry.configs]/{print $0 "\n[plugins.\"io.containerd.grpc.v1.cri\".registry.configs.\"master-node:5000\"]\n[plugins.\"io.containerd.grpc.v1.cri\".registry.configs.\"master-node:5000\".tls]\ninsecure_skip_verify = true\n";next}1'  ~/temp_config.toml | tee ~/config.toml

sudo mv ~/config.toml /etc/containerd
rm ~/temp_config.toml

# Local registry preperation crictl(Debian) - does NOT work on Fedora
#And apply the following #https://stackoverflow.com/questions/65681045/adding-insecure-registry-in-containerd
#awk '/endpoint/{print $0 "\n[plugins.\"io.containerd.grpc.v1.cri\".registry.mirrors.\"master-node:5000\"]\nendpoint = [\"http://master-node:5000\"]\n[plugins.\"io.containerd.grpc.v1.cri\".registry.configs]\n[plugins.\"io.containerd.grpc.v1.cri\".registry.configs.\"master-node:5000\".tls]\ninsecure_skip_verify = true";next}1' /etc/containerd/config.toml | sudo tee /etc/containerd/config.toml
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
#sudo dnf update -y
sudo dnf -y install \
     nvme-cli \
     fio

#Install btrfs-progs (optional)
#sudo dnf update -y
#sudo dnf -y install \
#     git \
#     uuid-devel \
#     libblkid-devel \
#     lzo-devel \
#     zlib-devel \
#     zlib \
#     libzstd-devel \
### instead use systemd-devel ###     libudev-dev \
#     systemd-devel \
#     libgcrypt-devel \
#     libsodium-devel \
#     libkcapi-devel \
#     e2fsprogs-devel \
#     python3-devel \
#     python3-pip \
#     python-unversioned-command \
#     python3-sphinx

#git clone https://github.com/kdave/btrfs-progs.git
#cd btrfs-progs
#git checkout v5.18
#./autogen.sh
#./configure --disable-documentation --enable-zoned
#make
#sudo make install
#cd ..
#sudo rm -r btrfs-progs

#Install zonefs-tools (optional)
#sudo apt-get update -y
#sudo apt-get -y install \
#     m4 \
#     autoconf \
#     automake \
#     libtool \
#     uuid-devel \
#     libblkid-devel

#git clone https://github.com/damien-lemoal/zonefs-tools.git
#cd zonefs-tools
#sh ./autogen.sh
#./configure
#make
#sudo make install
#cd ..
#sudo rm -r zonefs-tools

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

#curl -L https://nixos.org/nix/install | sh
#. /home/vagrant/.nix-profile/etc/profile.d/nix.sh

#git clone https://github.com/openebs/mayastor.git
#cd ~/mayastor
#git submodule update --init


#Install go
#sudo apt-get update -y
#sudo dnf install -y wget
#wget https://golang.org/dl/go1.17.linux-amd64.tar.gz
#sudo tar -zxvf go1.17.linux-amd64.tar.gz -C /usr/local/
#rm go1.17.linux-amd64.tar.gz
#echo "export PATH=/usr/local/go/bin:${PATH}" | sudo tee /etc/profile.d/go.sh
#source /etc/profile.d/go.sh
#echo "export PATH=/usr/local/go/bin:${PATH}" | sudo tee -a $HOME/.profile
#source $HOME/.profile
