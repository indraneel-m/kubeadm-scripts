#!/bin/bash

sudo modprobe nbd
sudo modprobe nvmet
sudo modprobe nvmet-rdma
sudo modprobe nvme-fabrics
sudo modprobe nvme-tcp
sudo modprobe nvme-rdma
sudo modprobe nvme-loop
echo 4096 | sudo tee /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages
