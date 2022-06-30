#!/bin/bash
set -e
set -x

cd ~/testfiles/myrocks-sysbench
bash ./build.sh
cd -

export TEST_BLKDEV="${TEST_BLKDEV:-/dev/nvme0n2}"
dev=${TEST_BLKDEV##*/}
sudo sh -c "echo 'mq-deadline' > /sys/block/${dev}/queue/scheduler"
cat ./myrocks-sysbench.yaml | envsubst
cat ./myrocks-sysbench.yaml | envsubst | kubectl apply -f -
