#!/bin/bash
sudo swapoff -a
sudo modprobe nvmet
sudo modprobe nvme-tcp

