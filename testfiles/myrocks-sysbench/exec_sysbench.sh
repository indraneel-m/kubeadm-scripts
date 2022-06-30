#!/bin/bash
set -x
set -e

export destination=$1
export dev=${destination##*/}
if [ ! -b "/dev/$dev" ]; then
    if grep -qs "${destination}" /proc/mounts; then
        echo "cp -Rp /var/lib/mysql ${destination}/mysql" > /output/prepare-drive.sh
        cp /output/posix-fs-bulkload-mysqld.cnf /output/bulkload-mysqld.cnf
        cp /output/posix-fs-workload-mysqld.cnf /output/workload-mysqld.cnf
    fi
else
    zoned=$(cat /sys/block/${dev}/queue/zoned)
    if [ "host-managed" == "$zoned" ]; then
        echo "ZenFS mode....."
        cat /output/zenfs-prepare-drive.sh | envsubst > /output/prepare-drive.sh
        cat /output/zenfs-bulkload-mysqld.cnf | envsubst > /output/bulkload-mysqld.cnf
        cat /output/zenfs-workload-mysqld.cnf | envsubst > /output/workload-mysqld.cnf
        echo 'mq-deadline' > /sys/block/${dev}/queue/scheduler
    else
        echo "Only raw ZBD supported. Please consider supplying a filesystem....."
        exit 1
    fi
fi

/bin/bash /output/run_script.sh
sleep 365d
