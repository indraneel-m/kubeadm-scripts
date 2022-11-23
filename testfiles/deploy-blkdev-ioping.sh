#!/bin/bash
set -e
set -x

export TEST_BLKDEV="${TEST_BLKDEV:-/dev/nvme0n1}"
cat ./blkdev-ioping.yaml | envsubst
cat ./blkdev-ioping.yaml | envsubst | kubectl apply -f -
