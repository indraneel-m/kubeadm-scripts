# kubeadm-scripts
Scripts &amp; Kubernetes manifests for Kubeadm Kubernetes cluster setup

## Prerequisites
- Install vagrant: https://www.vagrantup.com/docs/installation (skip this for Fedora as Fedora already packages vagrant)
- Install libvirt and the vagrant libvirt plugin:
  - Debian:
    ```
    sudo apt install build-dep ruby-libvirt qemu libvirt-daemon libvirt-daemon-system libvirt-daemon-system-systemd libvirt-clients ebtables dnsmasq-base libxslt-dev libxml2-dev libvirt-dev zlib1g-dev ruby-dev libguestfs-tools
    ```
  - Ubuntu:
    ```
    sudo apt install build-dep ruby-libvirt qemu libvirt-daemon libvirt-daemon-system libvirt-daemon-system-systemd libvirt-clients ebtables dnsmasq-base libxslt1-dev libxml2-dev libvirt-dev zlib1g-dev ruby-dev libguestfs-tools vagrant
    ```
  - Fedora:
    ```
    sudo dnf install @virtualization
    sudo dnf install rubygem-ruby-libvirt qemu dnsmasq dnsmasq-utils libxslt-devel libxml2-devel libvirt-devel zlib-devel libguestfs-tools util-linux
    ```

 - Start libvirtd and install the vagrant libvirt plugin
    ```
    sudo systemctl enable --now libvirtd

    vagrant plugin install vagrant-libvirt

    sudo systemctl enable --now virtnetworkd [Fedora]

    usermod --append --groups libvirt `whoami` [Fedora - else password is asked and also failure on headless ssh vagrant execution]
    ```
- Custom Kernel: Install podman in order to build a new kernel that will be applied to the nodes.
    ```
    sudo apt install podman
    ```

    If you wish to run a specific kernel on your nodes run the `generate-kernel.sh` script in `scripts/kernel-builder`. Environment variables `GIT_KERNEL_SOURCE` and `GIT_KERNEL_CHECKOUT` can be set to overwrite the default kernel selection which is the Linux master tree:
    ```
    cd scripts/kernel-builder
    # The following takes some time. Pick up a cup of coffee in the meantime (or any other favorite drink)
    GIT_KERNEL_SOURCE=https://github.com/torvalds/linux.git GIT_KERNEL_CHECKOUT=v5.19 ./generate-kernel.sh
    cd -
    ```

- Sharing files
    Files are shared using 9p filesystem using the passthrough mode. This approach requires that qemu runs in root mode. If you do not want to run qemu as root. Then you may either chown the testfiles directory to the qemu user, or add the qemu user to be part of a group that does have access to the directory. In case this is done, update the 9p synced_folder line in the 'Vagrantfile' from 'passthrough' to 'mapped'.
        

## Setup
To spin up a Kubernetes master and two node instances run: 
```
./setup-cluster.sh
```

Login to the virtual machine of the master node with
```
vagrant ssh master
```

## ZBD Storage Classes

### Local Persistent Volumes
Nodes might have locally attached storage. This storage can be exposed to pods either through a filesystem which is mounted on the node or as a raw block device.

> [...] note that local volumes are not suitable for most applications. Using local storage ties your application to that specific node, making your application harder to schedule. If that node or local volume encounters a failure and becomes inaccessible, then that pod also becomes inaccessible. In addition, many cloud providers do not provide extensive data durability guarantees for local storage, so you could lose all your data in certain scenarios.
> 
> For those reasons, most applications should continue to use highly available, remotely accessible, durable storage.
> 
> Suitable workloads
> Some use cases that are suitable for local storage include:
> 
> Caching of datasets that can leverage data gravity for fast processing
> Distributed storage systems that shard or replicate data across multiple nodes. Examples include distributed datastores like Cassandra, or distributed file systems like Gluster or Ceph.
> Suitable workloads are tolerant of node failures, data unavailability, and data loss. They provide critical, latency-sensitive infrastructure services to the rest of the cluster, and should run with high priority compared to other workloads.
>
> -- <cite>https://kubernetes.io/blog/2018/04/13/local-persistent-volumes-beta/</cite>

#### Example deployments for ZBD local persistent volumes:
* `testfiles/deploy-blkdev-ioping.sh`: This deployment is passing the raw ZBD (or any other block device) specified in the `TEST_BLKDEV` environment variable into a pod which ioping's this device. 
* `testfiles/deploy-myrocks-sysbench.sh`: This deployment is passing the raw ZBD specified in the `TEST_BLKDEV` environment variable into a pod which setups a MyRocks instance on the raw ZBD through the ZenFS RocksDB plugin.
* `testfiles/deploy-posix-fs-myrocks-sysbench.sh`: This deployment is createing and mounting btrfs on the node backed by a raw ZBD (or any other block device) specified in the `TEST_BLKDEV` environment variable. The mount point is then passed into a pod which setups a MyRocks instance on this filesystem mount point.
* `testfiles/deploy-zonefs-fioping.sh`: This deployment is creating and mounting ZoneFS on the node backed by a raw ZBD specified in the `TEST_BLKDEV` environment variable. Two different zone files are passed into two different pods which issue a simple (direct) sequential write workload on the given zone file.


### Mayastor
Deploy Mayastor setup on the master node with:
```
cd testfiles/mayastor
./deploy-mayastor.sh
```

Now the test application from the [quickstart-guide](https://mayastor.gitbook.io/introduction/quickstart/deploy-a-test-application) can be deployed and tested with:
```
kubectl apply -f mayastor-helloworld-testapp.yaml
kubectl exec -it fio -- fio --name=benchtest --size=800m --filename=/volume/test --direct=1 --rw=randrw --ioengine=libaio --bs=4k --iodepth=16 --numjobs=8 --time_based --runtime=60
```

### Common errors and solutions
In-case of the error 'Name 'kubeadm-scripts-master' o domain about to create already taken. Please try to run vagrant up again'
virsh vol-list default
virsh destroy failing_domain_name

### Common Mayastor commands
```
kubectl delete -f <prev-applied-spec.yaml> [to delete the underlying pool/pv/pvc/pod]
kubectl delete pod task-pv-pod
kubectl delete pvc task-pv-claim
kubectl delete pv task-pv-volume

kubectl -n mayastor get pods -o wide
kubectl -n mayastor logs <podname> mayastor [podname obtained from above cmd]

journalctl -xeu containerd.service [to view logs]

kubectl get nodes
kubectl get pods

kubectl get pod <podname>
kubectl get pvc <pvcname>
kubectl get pv <pvname>

kubectl describe node <nodename>
kubectl describe pod <podname>
kubectl describe pvc <pvcname> -n <namespace>
kubectl describe msp <poolname> -n <namespace>
kubectl getpods --field-selector=status.phase=Pending
```
