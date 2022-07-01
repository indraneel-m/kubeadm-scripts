#!/bin/bash
set -x
set -e
GIT_KERNEL_SOURCE=$1
GIT_KERNEL_CHECKOUT=$2
git clone -b $GIT_KERNEL_CHECKOUT $GIT_KERNEL_SOURCE

cp /output/config-5.10-debian ./linux/.config

cd linux

make olddefconfig
make -j$(nproc) bindeb-pkg
cd ..
tar cf kernel-deb-packages.tar *.deb
mv kernel-deb-packages.tar /output
