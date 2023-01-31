#!/bin/bash
set -e
set -x

export TEST_BLKDEV="${TEST_BLKDEV:-/dev/nvme0n1}"
cat ./mayastor-raw-block-dev-helloworld-testapp.yaml | envsubst
cat ./mayastor-raw-block-dev-helloworld-testapp.yaml | envsubst | kubectl apply -f -
