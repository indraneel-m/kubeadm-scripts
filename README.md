# kubeadm-scripts
Scripts &amp; Kubernetes manifests for Kubeadm Kubernetes cluster setup

## Prerequisites
- Install vagrant: https://www.vagrantup.com/docs/installation
- Install libvirt and the vagrant libvirt plugin:
```
sudo apt install build-dep ruby-libvirt qemu libvirt-daemon \
libvirt-daemon-system libvirt-daemon-system-systemd libvirt-clients ebtables \
dnsmasq-base libxslt-dev libxml2-dev libvirt-dev \
zlib1g-dev ruby-dev libguestfs-tools

sudo systemctl start libvirtd

vagrant plugin install vagrant-libvirt
```
- Install podman in order to build a new kernel that will be applied to the nodes.
```
sudo apt install podman
```
If you wish to run a specific kernel on your nodes run the `generate-kernel.sh` script in `scripts/kernel-builder`. Environment variables `GIT_KERNEL_SOURCE` and `GIT_KERNEL_CHECKOUT` can be set to overwrite the default kernel selection which is the Linux master tree.

## Setup
To spin up a Kubernetes master and two node instances simply run: 
```
vagrant up
```

Login to the virtual machines with
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
