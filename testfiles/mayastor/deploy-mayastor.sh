#!/bin/bash
set -ex
# Mayastor setup
sudo modprobe nvme-core
sudo modprobe nvme-fabrics
sudo modprobe nvme-fc
sudo modprobe nvme-rdma
sudo modprobe nvme-tcp
sudo modprobe nvmet

../launch-private-container-registry.sh

#Install the mayastor kubectl plugin from the binaries
#https://github.com/openebs/mayastor-extensions/actions/runs/4066024991
# Then dumping logs is possible
#kubectl mayastor dump pools
# General logging:
#kubectl logs mayastor-io-engine-* -n mayastor
#kubectl logs mayastor-io-engine-m94d5  -c io-engine -n mayastor

sudo unzip /home/vagrant/testfiles/kubectl-mayastor-x86_64-linux-musl.zip -d /usr/local/bin
sudo chmod +x /usr/local/bin/kubectl-mayastor

kubectl label node worker-node01 openebs.io/engine=mayastor
kubectl label node worker-node02 openebs.io/engine=mayastor
kubectl label node worker-node03 openebs.io/engine=mayastor

cd
git clone https://github.com/MaisenbacherD/mayastor.git
cd mayastor
git checkout zns-support
git submodule update --init
INITIAL_TAG=$(git rev-parse --short=12 HEAD)
CONTAINER_ENV=podman ./scripts/release.sh --registry master-node:5000 --image mayastor-io-engine
podman tag master-node:5000/openebs/mayastor-io-engine:$INITIAL_TAG master-node:5000/openebs/mayastor-io-engine:v2.0.0-rc.2
podman push master-node:5000/openebs/mayastor-io-engine:v2.0.0-rc.2


# mayastor-io-engine docker image is build from source with custom changes
#podman pull docker.io/openebs/mayastor-io-engine:v2.0.0-rc.2
#podman tag docker.io/openebs/mayastor-io-engine:v2.0.0-rc.2 master-node:5000/openebs/mayastor-io-engine:v2.0.0-rc.2
#podman push master-node:5000/openebs/mayastor-io-engine:v2.0.0-rc.2

####### k8scsi
podman pull quay.io/k8scsi/csi-provisioner:v2.1.1
podman tag quay.io/k8scsi/csi-provisioner:v2.1.1 master-node:5000/k8scsi/csi-provisioner:v2.1.1
podman push master-node:5000/k8scsi/csi-provisioner:v2.1.1

podman pull quay.io/k8scsi/csi-attacher:v3.1.0
podman tag quay.io/k8scsi/csi-attacher:v3.1.0 master-node:5000/k8scsi/csi-attacher:v3.1.0
podman push master-node:5000/k8scsi/csi-attacher:v3.1.0

######## sig-storage
podman pull k8s.gcr.io/sig-storage/csi-node-driver-registrar:v2.5.0
podman tag k8s.gcr.io/sig-storage/csi-node-driver-registrar:v2.5.0 master-node:5000/sig-storage/csi-node-driver-registrar:v2.5.0
podman push master-node:5000/sig-storage/csi-node-driver-registrar:v2.5.0

######## openebs
podman pull docker.io/openebs/mayastor-agent-ha-cluster:v2.0.0-rc.2
podman tag docker.io/openebs/mayastor-agent-ha-cluster:v2.0.0-rc.2 master-node:5000/openebs/mayastor-agent-ha-cluster:v2.0.0-rc.2
podman push master-node:5000/openebs/mayastor-agent-ha-cluster:v2.0.0-rc.2

podman pull docker.io/openebs/mayastor-agent-core:v2.0.0-rc.2
podman tag docker.io/openebs/mayastor-agent-core:v2.0.0-rc.2 master-node:5000/openebs/mayastor-agent-core:v2.0.0-rc.2
podman push master-node:5000/openebs/mayastor-agent-core:v2.0.0-rc.2

podman pull docker.io/openebs/mayastor-api-rest:v2.0.0-rc.2
podman tag docker.io/openebs/mayastor-api-rest:v2.0.0-rc.2 master-node:5000/openebs/mayastor-api-rest:v2.0.0-rc.2
podman push master-node:5000/openebs/mayastor-api-rest:v2.0.0-rc.2

podman pull docker.io/openebs/mayastor-csi-node:v2.0.0-rc.2
podman tag docker.io/openebs/mayastor-csi-node:v2.0.0-rc.2 master-node:5000/openebs/mayastor-csi-node:v2.0.0-rc.2
podman push master-node:5000/openebs/mayastor-csi-node:v2.0.0-rc.2

podman pull docker.io/openebs/mayastor-obs-callhome:v2.0.0-rc.2
podman tag docker.io/openebs/mayastor-obs-callhome:v2.0.0-rc.2 master-node:5000/openebs/mayastor-obs-callhome:v2.0.0-rc.2
podman push master-node:5000/openebs/mayastor-obs-callhome:v2.0.0-rc.2

podman pull docker.io/openebs/mayastor-operator-diskpool:v2.0.0-rc.2
podman tag docker.io/openebs/mayastor-operator-diskpool:v2.0.0-rc.2 master-node:5000/openebs/mayastor-operator-diskpool:v2.0.0-rc.2
podman push master-node:5000/openebs/mayastor-operator-diskpool:v2.0.0-rc.2

podman pull docker.io/openebs/mayastor-csi-controller:v2.0.0-rc.2
podman tag docker.io/openebs/mayastor-csi-controller:v2.0.0-rc.2 master-node:5000/openebs/mayastor-csi-controller:v2.0.0-rc.2
podman push master-node:5000/openebs/mayastor-csi-controller:v2.0.0-rc.2

podman pull docker.io/openebs/mayastor-agent-ha-node:v2.0.0-rc.2
podman tag docker.io/openebs/mayastor-agent-ha-node:v2.0.0-rc.2 master-node:5000/openebs/mayastor-agent-ha-node:v2.0.0-rc.2
podman push master-node:5000/openebs/mayastor-agent-ha-node:v2.0.0-rc.2

podman pull docker.io/openebs/mayastor-metrics-exporter-pool:v2.0.0-rc.2
podman tag docker.io/openebs/mayastor-metrics-exporter-pool:v2.0.0-rc.2 master-node:5000/openebs/mayastor-metrics-exporter-pool:v2.0.0-rc.2
podman push master-node:5000/openebs/mayastor-metrics-exporter-pool:v2.0.0-rc.2


# Add repo
helm repo add mayastor https://openebs.github.io/mayastor-extensions/
# Search releases
#helm search repo mayastor --devel --versions
# Install specific version on non-prod playground
#helm install mayastor mayastor/mayastor -n mayastor --create-namespace --set="etcd.replicaCount=1,etcd.persistence.storageClass=manual,etcd.livenessProbe.initialDelaySeconds=5,etcd.readinessProbe.initialDelaySeconds=5,loki-stack.loki.persistence.storageClassName=manual" --version 2.0.0-rc.2
helm install mayastor mayastor/mayastor -n mayastor --create-namespace --set="etcd.replicaCount=1,etcd.persistence.storageClass=manual,etcd.livenessProbe.initialDelaySeconds=5,etcd.readinessProbe.initialDelaySeconds=5,loki-stack.loki.persistence.storageClassName=manual,image.registry=master-node:5000" --version 2.0.0-rc.2
# See the state of the deployed pods
#kubectl get pods -n mayastor
# List helm deployments
#helm list -A
# Uninstall helm deployment
#helm uninstall mayastor -n mayastor
