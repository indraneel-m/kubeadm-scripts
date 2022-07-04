#!/bin/bash
export ZONEFS_FILE_PREFIX="/mnt/zonefs"
sudo umount $ZONEFS_FILE_PREFIX

set -e
set -x

export TEST_BLKDEV="${TEST_BLKDEV:-/dev/nvme0n2}"
dev=${TEST_BLKDEV##*/}
zoned=$(cat /sys/block/${dev}/queue/zoned)
if [ "host-managed" == "$zoned" ]; then
    sudo sh -c "echo 'mq-deadline' > /sys/block/${dev}/queue/scheduler"
    sudo blkzone reset /dev/$dev
    sudo mkzonefs /dev/$dev
    sudo mkdir -p $ZONEFS_FILE_PREFIX
    sudo mount -t zonefs /dev/$dev $ZONEFS_FILE_PREFIX
else
    echo "ZoneFS is only supported on ZBD devices"
    exit 1
fi

cat ./zonefs-fioping.yaml | envsubst
cat ./zonefs-fioping.yaml | envsubst | kubectl apply -f -
