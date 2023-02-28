#!/bin/bash
sudo swapoff -a

sudo kubeadm init

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

curl https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml -O
kubectl apply -f calico.yaml


### Mayastor + CSAL SPDK build and setup ###

cd $HOME
sh <(curl -L https://nixos.org/nix/install) --no-daemon
. /home/vagrant/.nix-profile/etc/profile.d/nix.sh
echo "nix installation done"

#Clone CSAL SPDK locally 
###git clone -b v22.05.x-mayastor-csal https://bitbucket.wdc.com/scm/esa/spdk_mayastor_csal.git spdk
cp -a ~/testfiles/mayastor/spdk .

#Clone Mayastor
###git clone -b mayastor_csal https://bitbucket.wdc.com/scm/esa/mayastor_csal.git
cp -a ~/testfiles/mayastor/mayastor_csal .
#cd ~/mayastor_csal
###git submodule update --init
#Build Mayastor
#nix-build  --option sandbox false -A images.mayastor-io-engine-dev
#nix-build  --option sandbox false -A images.mayastor-io-engine-client
