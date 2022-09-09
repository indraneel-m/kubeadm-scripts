#!/bin/bash

set -x
set -e

sudo modprobe nvme_tcp
sudo modprobe nvme-tcp
sudo modprobe nvme
sudo modprobe nvmet
sudo modprobe nvmet-tcp

sudo nvme disconnect-all
sudo blkzone reset /dev/nvme0n2

ip=10.0.0.1

# https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/managing_storage_devices/nvme-over-fabrics-using-rdma_managing-storage-devices#setting-up-the-nvme-rdma-target-using-nvmetcli_nvme-over-fabrics-using-rdma
cd ~/src/nvmetcli
sudo python3 nvmetcli clear
sudo python3 nvmetcli restore zns-test-tcp.json

#sudo nvme discover -t tcp -a $ip -s 4420
#sudo nvme connect -t tcp -n nvmet-always -a $ip -s 4420
#sudo nvme disconnect-all


exit 0
dev=nvme0n2
sudo mkdir /sys/kernel/config/nvmet/subsystems/nvmet-${dev}-test
cd /sys/kernel/config/nvmet/subsystems/nvmet-${dev}-test
echo 1 |sudo tee -a attr_allow_any_host > /dev/null
sudo mkdir namespaces/1
cd namespaces/1/
sudo echo -n /dev/${dev} |sudo tee -a device_path > /dev/null
echo 1|sudo tee -a enable > /dev/null

sudo mkdir /sys/kernel/config/nvmet/ports/1
cd /sys/kernel/config/nvmet/ports/1
echo $ip |sudo tee -a addr_traddr > /dev/null
echo tcp|sudo tee -a addr_trtype > /dev/null
echo 4420|sudo tee -a addr_trsvcid > /dev/null
echo ipv4|sudo tee -a addr_adrfam > /dev/null
sudo ln -s /sys/kernel/config/nvmet/subsystems/nvmet-${dev}-test/ /sys/kernel/config/nvmet/ports/1/subsystems/nvmet-${dev}-t

#sudo nvme connect -t tcp -n nvmet-${dev}-test -a $ip -s 4420
