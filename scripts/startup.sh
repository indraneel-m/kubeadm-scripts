#!/bin/bash
sudo swapoff -a
sudo modprobe nvmet
sudo modprobe nvme-tcp
#Addition kernel modules for Mayastor CSAL
sudo modprobe nbd
sudo modprobe nvmet-rdma
sudo modprobe nvme-fabrics
sudo modprobe nvme-rdma
sudo modprobe nvme-loop

