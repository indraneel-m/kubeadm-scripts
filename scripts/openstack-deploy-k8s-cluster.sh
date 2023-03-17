#!/bin/bash
# Delete old known_hosts entries
ssh-keygen -f "~/.ssh/known_hosts" -R "192.168.102.20"
ssh-keygen -f "~/.ssh/known_hosts" -R "192.168.102.21"
ssh-keygen -f "~/.ssh/known_hosts" -R "192.168.102.22"
ssh-keygen -f "~/.ssh/known_hosts" -R "192.168.102.23"

# Create the servers
openstack server create --image debian11-k8s-1.25.3-kernel-6.2.5-multipath-disabled-master --flavor z.master --key-name dellx1 --key-name dennis --network research_net --nic port-id=sriov-masternode masternode
openstack server create --image debian11-k8s-1.25.3-kernel-6.2.5-multipath-disabled-base --flavor z.mayastor --key-name dellx1 --key-name dennis --network research_net --nic port-id=sriov-workernode1 worker-node01
openstack server create --image debian11-k8s-1.25.3-kernel-6.2.5-multipath-disabled-base --flavor z.mayastor --key-name dellx1 --key-name dennis --network research_net --nic port-id=sriov-workernode2 worker-node02
openstack server create --image debian11-k8s-1.25.3-kernel-6.2.5-multipath-disabled-base --flavor z.mayastor --key-name dellx1 --key-name dennis --network research_net --nic port-id=sriov-workernode3 worker-node03

# Wait for vms to come up.
until ssh -o StrictHostKeyChecking=no masternode ls
do
    sleep 5
done
until ssh -o StrictHostKeyChecking=no workernode1 ls
do
    sleep 5
done
until ssh -o StrictHostKeyChecking=no workernode2 ls
do
    sleep 5
done
until ssh -o StrictHostKeyChecking=no workernode3 ls
do
    sleep 5
done

# Let the workernodes join the cluster
export kubectl_join_cmd=$(ssh -o StrictHostKeyChecking=no masternode "kubeadm token create --print-join-command" | xargs)
ssh -o StrictHostKeyChecking=no workernode1 "sudo ${kubectl_join_cmd}"
ssh -o StrictHostKeyChecking=no workernode2 "sudo ${kubectl_join_cmd}"
ssh -o StrictHostKeyChecking=no workernode3 "sudo ${kubectl_join_cmd}"

# Copy mayastor kubectl plugin on the master node
scp ~/src/kubeadm-scripts/testfiles/kubectl-mayastor-x86_64-linux-musl.zip masternode:/home/debian/ 

# Add hostnames to 
DNS_ADDITIONS=$(cat <<-END
192.168.102.20 masternode
192.168.102.20 master-node
192.168.102.21 workernode1
192.168.102.21 worker-node01
192.168.102.22 workernode2
192.168.102.22 worker-node02
192.168.102.23 workernode3
192.168.102.23 worker-node03
END

)

ssh masternode "echo \"${DNS_ADDITIONS}\" | sudo tee -a /etc/hosts"
ssh workernode1 "echo \"${DNS_ADDITIONS}\" | sudo tee -a /etc/hosts"
ssh workernode2 "echo \"${DNS_ADDITIONS}\" | sudo tee -a /etc/hosts"
ssh workernode3 "echo \"${DNS_ADDITIONS}\" | sudo tee -a /etc/hosts"
