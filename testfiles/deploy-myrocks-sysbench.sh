#!/bin/bash
set -e
set -x

export TEST_BLKDEV="${TEST_BLKDEV:-/dev/nvme0n2}"
cat ./myrocks-sysbench.yaml | envsubst
cat ./myrocks-sysbench.yaml | envsubst | kubectl apply -f -
