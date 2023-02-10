#!/bin/bash
sudo swapoff -a

sudo kubeadm init

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

curl https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml -O
kubectl apply -f calico.yaml
#https://github.com/openebs/mayastor/issues/1317#issuecomment-1425427761
#kubectl patch felixconfigurations default --patch '{"spec":{"featureDetectOverride":"ChecksumOffloadBroken=true"}}' --type=merge

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
