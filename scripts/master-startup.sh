#!/bin/bash
sudo swapoff -a

mkdir -p $HOME/.kube
sudo cp -n /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
