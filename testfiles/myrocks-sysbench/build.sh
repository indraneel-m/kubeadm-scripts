#!/bin/bash

podman build -t myrocks-sysbench .
podman image tag localhost/myrocks-sysbench:latest master-node:5000/repo/myrocks-sysbench:latest
podman image push master-node:5000/repo/myrocks-sysbench:latest
