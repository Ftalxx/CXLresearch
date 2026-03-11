#!/bin/bash

set -e

BRIDGE=br0
TAP=tap-cxl1
SUBNET=192.168.199.1/24
QEMU_BIN=/home/ftvee/research/qemu/build/qemu-system-x86_64
DISK_IMG=/home/ftvee/research/qemu/host1.qcow2

echo "Setting up bridge..."

sudo ip link add $BRIDGE type bridge 2>/dev/null || true
sudo ip addr add $SUBNET dev $BRIDGE 2>/dev/null || true
sudo ip link set $BRIDGE up

echo "Setting up tap..."

sudo ip tuntap add dev $TAP mode tap user $USER 2>/dev/null || true
sudo ip link set $TAP master $BRIDGE
sudo ip link set $TAP up

echo "Launching QEMU..."

"$QEMU_BIN" \
-enable-kvm \
-cpu host \
-machine q35,accel=kvm,cxl=on \
-smp 8,sockets=1,cores=8,threads=1 \
-m 24G,slots=4,maxmem=32G \
-object memory-backend-ram,id=dram0,size=16G \
-object memory-backend-file,id=far0,mem-path=/dev/shm/far-mem0,size=8G,share=on \
-numa node,nodeid=0,memdev=dram0,cpus=0-7 \
-numa node,nodeid=1,memdev=far0 \
-drive file="$DISK_IMG",if=virtio \
-netdev tap,id=net0,ifname=$TAP,script=no,downscript=no \
-device virtio-net-pci,netdev=net0,mac=52:54:00:01:00:01 \
-serial stdio

