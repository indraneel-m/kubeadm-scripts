# kubeadm-scripts
Scripts &amp; Kubernetes manifests for Kubeadm Kubernetes cluster setup

## Prerequisites
- Install vagrant: https://www.vagrantup.com/docs/installation
- Install libvirt and the vagrant libvirt plugin:
```
sudo apt install build-dep ruby-libvirt qemu libvirt-daemon \
libvirt-daemon-system libvirt-daemon-system-systemd libvirt-clients ebtables \
dnsmasq-base libxslt-dev libxml2-dev libvirt-dev \
zlib1g-dev ruby-dev libguestfs-tools

sudo systemctl start libvirtd

vagrant plugin install vagrant-libvirt
```

## Setup
To spin up a Kubernetes master and two node instances simply run: 
```
vagrant up
```

Login to the virtual machines with
```
vagrant ssh master
```
