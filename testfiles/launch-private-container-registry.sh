#!/bin/bash
set -x
set -e

#The following is happening in the setup scripts:
# https://thenewstack.io/tutorial-host-a-local-podman-image-registry/
#In /etc/containerd/config.toml add the following:
#[plugins."io.containerd.grpc.v1.cri".registry.mirrors."master-node:5000"]
#  endpoint = ["http://master-node:5000"]
#  [plugins."io.containerd.grpc.v1.cri".registry.configs]
#    [plugins."io.containerd.grpc.v1.cri".registry.configs."master-node:5000".tls]
#      insecure_skip_verify = true'

#And then do the following:
#sudo systemctl restart containerd
#sudo crictl config runtime-endpoint /run/containerd/containerd.sock


#cat <<EOF | sudo tee -a /etc/containers/registries.conf
#unqualified-search-registries = ['master-node:5000', 'docker.io', 'quay.io', 'registry.fedoraproject.org']
#[[registry]]
#location = "master-node:5000"
#insecure = true
#EOF
#sudo systemctl restart podman

# Spin up the registry on the master node
count=$(sudo podman ps --filter name=myregistry | wc -l)
if [ $count -lt 2 ]
then
    sudo mkdir -p /var/lib/registry
    sudo podman run --privileged -d \
        --name myregistry \
        -p 5000:5000 \
        -v /var/lib/registry:/var/lib/registry \
        --restart=always registry:2
fi
#podman build -t myrocks-sysbench .
#podman image tag localhost/myrocks-sysbench:latest master-node:5000/myrocks-sysbench:latest
#podman image push master-node:5000/myrocks-sysbench:latest
# From a worker node
#podman pull master-node:5000/myrocks-sysbench:latest
