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
- Install podman in order to build a new kernel that will be applied to the nodes.
```
sudo apt install podman
```
If you wish to run a specific kernel on your nodes run the `generate-kernel.sh` script in `scripts/kernel-builder`. Environment variables `GIT_KERNEL_SOURCE` and `GIT_KERNEL_CHECKOUT` can be set to overwrite the default kernel selection which is the Linux master tree.

## Setup
To spin up a Kubernetes master and two node instances simply run: 
```
vagrant up
```

Login to the virtual machines with
```
vagrant ssh master
```
