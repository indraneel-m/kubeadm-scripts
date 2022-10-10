#!/bin/bash
set -e
set -x

./launch-private-container-registry.sh
cd ~
git clone https://github.com/kubernetes-csi/csi-driver-nvmf.git
cd csi-driver-nvmf
sed -i 's/docker /podman /g' release-tools/build.make
make container
podman tag localhost/nvmfplugin master-node:5000/nvmfplugin
podman push master-node:5000/nvmfplugin
sed -i 's_nvmfplugin_master-node:5000/nvmfplugin_g' deploy/kubernetes/*.yaml 
kubectl create -f deploy/kubernetes
