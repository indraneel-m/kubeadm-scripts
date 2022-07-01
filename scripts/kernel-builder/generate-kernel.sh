#!/bin/bash
GIT_KERNEL_SOURCE="${GIT_KERNEL_SOURCE:-https://github.com/torvalds/linux.git}"
GIT_KERNEL_CHECKOUT="${GIT_KERNEL_CHECKOUT:-master}"

podman build -t kernel-builder -f Dockerfile.kernel-builder .

podman run --rm -i -v $(pwd):/output kernel-builder /bin/bash /output/build-kernel.sh $GIT_KERNEL_SOURCE $GIT_KERNEL_CHECKOUT
