#!/bin/bash

sudo swapoff -a

IPADDR=$(hostname -I | awk '{print $1}')

NODENAME=$(hostname -s)

sudo systemctl status containerd
sudo systemctl status docker
sudo kubeadm init --apiserver-advertise-address=$IPADDR  --apiserver-cert-extra-sans=$IPADDR  --pod-network-cidr=192.168.0.0/16 --node-name $NODENAME --ignore-preflight-errors Swap

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

