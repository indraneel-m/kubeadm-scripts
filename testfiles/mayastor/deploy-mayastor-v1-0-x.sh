#!/bin/bash
# Mayastor setup
sudo modprobe nvme-core
sudo modprobe nvme-fabrics
sudo modprobe nvme-fc
sudo modprobe nvme-rdma
sudo modprobe nvme-tcp
#sudo modprobe nvme-loop
#sudo modprobe nvmet

wget -P /home/vagrant https://github.com/openebs/mayastor-control-plane/releases/download/v1.0.4/kubectl-mayastor-x86_64-linux-musl.zip
sudo unzip /home/vagrant/kubectl-mayastor-x86_64-linux-musl.zip -d /usr/local/bin
sudo chmod +x /usr/local/bin/kubectl-mayastor

kubectl label node master-node openebs.io/engine=mayastor
kubectl label node worker-node01 openebs.io/engine=mayastor
kubectl label node worker-node02 openebs.io/engine=mayastor
kubectl label node worker-node03 openebs.io/engine=mayastor

kubectl create namespace mayastor

##RBAC Resrouces
kubectl apply -f https://raw.githubusercontent.com/openebs/mayastor-control-plane/v1.0.4/deploy/operator-rbac.yaml

##Custom Resource Definitions
kubectl apply -f https://raw.githubusercontent.com/openebs/mayastor-control-plane/v1.0.4/deploy/mayastorpoolcrd.yaml

##NATS
kubectl apply -f https://raw.githubusercontent.com/openebs/mayastor/v1.0.4/deploy/nats-deployment.yaml
while [ $(kubectl -n mayastor get pods --selector=app=nats | grep "Running" | grep -c "2/2") -ne 3 ]; do
    echo "Waiting for NATS pods to come up"
    sleep 10
done

##etcd
kubectl apply -f https://raw.githubusercontent.com/openebs/mayastor/v1.0.4/deploy/etcd/storage/localpv.yaml
kubectl apply -f https://raw.githubusercontent.com/openebs/mayastor/v1.0.4/deploy/etcd/statefulset.yaml
kubectl apply -f https://raw.githubusercontent.com/openebs/mayastor/v1.0.4/deploy/etcd/svc.yaml
kubectl apply -f https://raw.githubusercontent.com/openebs/mayastor/v1.0.4/deploy/etcd/svc-headless.yaml
while [ $(kubectl -n mayastor get pods --selector=app.kubernetes.io/name=etcd | grep "Running" | grep -c "1/1") -ne 3 ]; do
    echo "Waiting for etcd pods to come up"
    sleep 10
done

##CSI Node Plugin
kubectl apply -f https://raw.githubusercontent.com/openebs/mayastor/v1.0.4/deploy/csi-daemonset.yaml
while [ $(kubectl -n mayastor get daemonset mayastor-csi | grep "mayastor-csi" | awk 'substr($2, length($2), 1) == 3' | awk 'substr($3, length($3), 1) == 3' | awk 'substr($4, length($4), 1) == 3' | awk 'substr($5, length($5), 1) == 3' | awk 'substr($6, length($6), 1) == 3' | wc -l) -ne 1 ]; do
    echo "Waiting for CSI node plugin to come up"
    sleep 10
done

##Core Agents
kubectl apply -f https://raw.githubusercontent.com/openebs/mayastor-control-plane/v1.0.4/deploy/core-agents-deployment.yaml
while [ $(kubectl get pods -n mayastor --selector=app=core-agents | grep "Running" | grep -c "1/1") -ne 1 ]; do
    echo "Waiting for core-agents pod to come up"
    sleep 10
done

##REST
kubectl apply -f https://raw.githubusercontent.com/openebs/mayastor-control-plane/v1.0.4/deploy/rest-deployment.yaml
kubectl apply -f https://raw.githubusercontent.com/openebs/mayastor-control-plane/v1.0.4/deploy/rest-service.yaml
while [ $(kubectl get pods -n mayastor --selector=app=rest | grep "Running" | grep -c "1/1") -ne 1 ]; do
    echo "Waiting for rest pod to come up"
    sleep 10
done

##CSI Controller
kubectl apply -f https://raw.githubusercontent.com/openebs/mayastor-control-plane/v1.0.4/deploy/csi-deployment.yaml
while [ $(kubectl get pods -n mayastor --selector=app=csi-controller | grep "Running" | grep -c "3/3") -ne 1 ]; do
    echo "Waiting for csi controller pods to come up"
    sleep 10
done

##MSP Operator
kubectl apply -f https://raw.githubusercontent.com/openebs/mayastor-control-plane/v1.0.4/deploy/msp-deployment.yaml
while [ $(kubectl get pods -n mayastor --selector=app=msp-operator | grep "Running" | grep -c "1/1") -ne 1 ]; do
    echo "Waiting for msp-operator pods to come up"
    sleep 10
done

##Data Plane
kubectl apply -f https://raw.githubusercontent.com/openebs/mayastor/v1.0.4/deploy/mayastor-daemonset.yaml
while [ $(kubectl -n mayastor get daemonset mayastor | grep "mayastor" | awk 'substr($2, length($2), 1) == 3' | awk 'substr($3, length($3), 1) == 3' | awk 'substr($4, length($4), 1) == 3' | awk 'substr($5, length($5), 1) == 3' | awk 'substr($6, length($6), 1) == 3' | wc -l) -ne 1 ]; do
    echo "Waiting for data plane to come up"
    sleep 10
done

