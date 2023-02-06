#!/bin/bash
set -e
set -x

#export TEST_BLKDEV="${TEST_BLKDEV:-pcie:///0000:00:05.0}"
export TEST_BLKDEV="${TEST_BLKDEV:-/dev/nvme0n1}"
#export TEST_BLKDEV="${TEST_BLKDEV:-uring:///dev/nvme1n1}"
cat ./mayastor-raw-block-dev-helloworld-testapp.yaml | envsubst
#cat ./mayastor-raw-block-dev-helloworld-testapp.yaml | envsubst | kubectl delete -f -
cat ./mayastor-raw-block-dev-helloworld-testapp.yaml | envsubst | kubectl apply -f -
