#!/bin/bash

export TEST_BLKDEV=$1
export dev=${TEST_BLKDEV##*/}
if [ ! -b "/dev/$dev" ]; then
    echo "/dev/$dev does not exist."
    exit 1
fi

zoned=$(cat /sys/block/${dev}/queue/zoned)
if [ "host-managed" == "$zoned" ]; then
    echo "ZenFS mode....."
    cat /output/zenfs-prepare-drive.sh | envsubst > /output/prepare-drive.sh
    cat /output/zenfs-bulkload-mysqld.cnf | envsubst > /output/bulkload-mysqld.cnf
    cat /output/zenfs-workload-mysqld.cnf | envsubst > /output/workload-mysqld.cnf
    echo 'mq-deadline' > /sys/block/${dev}/queue/scheduler
else
    echo "Conv mode....."
    exit 1
fi

/bin/bash /output/run_script.sh
