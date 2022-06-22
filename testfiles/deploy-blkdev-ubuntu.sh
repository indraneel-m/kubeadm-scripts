#!/bin/bash
set -e
set -x

export TEST_BLKDEV="${TEST_BLKDEV:-/dev/nvme0n2}"
cat ./blkdev-ubuntu.yaml | envsubst
cat ./blkdev-ubuntu.yaml | envsubst | kubectl apply -f -
