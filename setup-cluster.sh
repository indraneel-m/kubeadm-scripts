#!/bin/bash

# Basic vm setup
vagrant destroy master node01 node02 node03 -f
vagrant up
vagrant reload
vagrant reload

# Allow scheduling on master node
#vagrant ssh -c "kubectl taint nodes --all node-role.kubernetes.io/master-" master
#vagrant ssh -c "kubectl taint nodes --all node-role.kubernetes.io/control-plane-" master

# Let nodes join the cluster
export kubectl_join_cmd=$(vagrant ssh -c "kubeadm token create --print-join-command" master | xargs)
vagrant ssh -c "sudo ${kubectl_join_cmd}" node01
vagrant ssh -c "sudo ${kubectl_join_cmd}" node02
vagrant ssh -c "sudo ${kubectl_join_cmd}" node03
