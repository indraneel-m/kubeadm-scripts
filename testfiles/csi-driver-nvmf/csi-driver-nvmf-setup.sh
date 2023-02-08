#!/bin/bash
set -e
set -x

../launch-private-container-registry.sh
cd ~
#git clone https://github.com/kubernetes-csi/csi-driver-nvmf.git
git clone https://github.com/MeinhardZhou/csi-driver-nvmf.git
cd csi-driver-nvmf
git checkout fix/add_log
sed -i 's/docker /podman /g' release-tools/build.make
make container
podman tag localhost/nvmfplugin master-node:5000/nvmfplugin
podman push master-node:5000/nvmfplugin
sed -i 's_nvmfplugin_master-node:5000/nvmfplugin_g' deploy/kubernetes/*.yaml
kubectl create -f deploy/kubernetes
# Follow instructions of https://github.com/kubernetes-csi/csi-driver-nvmf/issues/12#issuecomment-1273247324
#kubectl create -f helloworld.yaml
