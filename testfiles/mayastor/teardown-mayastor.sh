#!/bin/bash
set -ex
helm uninstall mayastor -n mayastor
sudo podman rm -f $(sudo podman ps -aqf "name=registry")
sudo rm -r /var/lib/registry
