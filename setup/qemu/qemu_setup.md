# QEMU Setup – Base Virtual Machine Environment

## Purpose

This document records the setup process used to build a QEMU virtualization environment and create a base Ubuntu virtual machine for future multi-host CXL memory simulation experiments using SST.

The goal is to establish a reproducible VM environment that can later be extended to simulate multiple hosts sharing memory through a CXL-style architecture.

---

## Host Environment

Host system:

Windows with WSL (Windows Subsystem for Linux)

Development environment runs inside the Linux subsystem.

Primary tools used:
- QEMU (built from source)
- Ubuntu Server 22.04 (guest OS)
- SSH for guest management
- SST Simulator (installed separately)

---

## QEMU Build Process

QEMU was cloned and compiled from source to allow control over the virtualization environment and compatibility with SST.

Target architecture built:
```
x86_64-softmmu
```
Configuration command used:
```
./configure --target-list=x86_64-softmmu
```
Build command:
```
ninja -C build
```

During setup several dependency and environment issues were encountered and resolved, including:

- Python virtual environment configuration problems
- setuptools and importlib metadata conflicts
- meson and ninja dependency requirements
- missing networking backends in early builds
- GLib version compatibility issues between QEMU and the existing SST environment

A compatible QEMU revision was used so that the virtualization environment could coexist with the older system libraries required by SST.

---

## Virtual Machine Creation

A base Ubuntu Server virtual machine was created to serve as the template for future simulated hosts.

Disk image creation:

```
qemu-img create -f qcow2 ubuntu.qcow2 20G
```

Ubuntu Server ISO was then booted through QEMU and installed onto the qcow2 disk.

The installation included:
- OpenSSH server
- minimal server environment
- standard Ubuntu networking configuration

---

## Initial QEMU Launch Configuration

The virtual machine was initially launched using QEMU user-mode networking with SSH port forwarding.

Example launch command:
```
./build/qemu-system-x86_64 \
-enable-kvm \
-cpu host \
-m 4096 \
-smp 4 \
-drive file=ubuntu.qcow2,if=virtio \
-netdev user,id=n0,hostfwd=tcp:127.0.0.1:2222-:22 \
-device virtio-net-pci,netdev=n0 \
-display gtk
```
Key features of this configuration:
- hardware acceleration via KVM
- 4 GB RAM allocated to the guest
- virtio network device
- SSH forwarding from host port 2222 to guest port 22

SSH access from the host:
```
ssh -p 2222 <username>@127.0.0.1
```

---

## Guest Networking Issue

During initial setup the guest interface ens3 sometimes failed to obtain an IPv4 address automatically after reboot.

Temporary workaround used:
```
sudo dhclient ens3
```
This manually triggered DHCP assignment from QEMU's user-mode network.
---

## Root Cause

The networking issue was caused by cloud-init automatically generating the Netplan configuration file:

```
/etc/netplan/50-cloud-init.yaml
```

On reboot, cloud-init regenerated this file and overwrote manual network configuration changes, preventing the interface from initializing correctly.

---

## Permanent Networking Fix

To resolve this issue:

Cloud-init network management was disabled.

File created:
```
/etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
```
Configuration:
```
network: {config: disabled}
```
The cloud-init generated Netplan file was removed.

A persistent Netplan configuration was created.

File:
```
/etc/netplan/01-netcfg.yaml
```
Configuration used:
```
network:
  version: 2
  renderer: networkd
  ethernets:
    ens3:
      dhcp4: true
```
Applied using:
```
sudo netplan apply
```
After this change the guest consistently receives its network address during boot.

Typical QEMU NAT configuration inside the VM:
```
Interface: ens3
IP: 10.0.2.15
Gateway: 10.0.2.2
Base VM Stabilization
```

Once networking and SSH access were confirmed stable, the Ubuntu image was converted into a reusable base VM template.

Additional qcow2 backing images were created to simulate multiple hosts:
```
qemu-img create -f qcow2 -b ubuntu.qcow2 host1.qcow2
qemu-img create -f qcow2 -b ubuntu.qcow2 host2.qcow2
```

This allows multiple virtual machines to share the same base disk image while storing only their differences.

--- 

Bridge and TAP Networking

For multi-host experiments, VM networking was later extended beyond QEMU user-mode networking.

A Linux bridge and TAP interface were introduced to allow direct communication between virtual machines.

Host networking configuration:
```
bridge: br0
tap interface: tap-cxl1
bridge address: 192.168.199.1/24
```
Guest VM configuration:
```
interface: enp0s2
IP address: 192.168.199.2/24
gateway: 192.168.199.1
```
This setup enables:

host ↔ VM communication

VM ↔ VM communication

scaling to multiple simulated hosts

Detailed networking configuration is documented in:
```
setup/qemu/qemu_networking.md
```
---

## Launch Script

Because TAP interfaces and bridge devices do not persist across WSL restarts, the networking environment is recreated automatically using a launch script.

Script location:
```
setup/qemu/start_vm.sh
```
The script performs the following actions:

- Creates or recreates the bridge interface br0
- Assigns the bridge address
- Creates the TAP interface tap-cxl1
- Attaches the TAP interface to the bridge
- Launches the QEMU virtual machine

This ensures the VM environment can be recreated consistently after restarting WSL.

---

## Current Status

The base virtualization environment is functioning correctly.

Working components:

- QEMU compiled from source
- compatible QEMU revision for SST environment
- Ubuntu Server base VM installed
- SSH server enabled
- persistent guest networking configuration
- qcow2 backing image cloning
- bridge/TAP networking for VM communication
- automated VM launch script

This VM now acts as the base template for simulated hosts.

---

## Planned QEMU Topology for CXL Simulation

The next configuration stage will move toward a CXL-style machine topology using QEMU.

Example planned launch configuration:
```
./build/qemu-system-x86_64 \
-enable-kvm \
-cpu host \
-machine q35,accel=kvm,cxl=on \
-smp 8,sockets=1,cores=8,threads=1 \
-m 24G,slots=4,maxmem=32G \
-object memory-backend-ram,id=dram0,size=16G \
-object memory-backend-file,id=far0,mem-path=/dev/shm/far-mem0,size=8G,share=on \
-numa node,nodeid=0,memdev=dram0,cpus=0-7 \
-numa node,nodeid=1,memdev=far0 \
-drive file=host1.qcow2,if=virtio
```
This configuration introduces:

- q35 machine type with CXL support
- explicit memory backend objects
- separate NUMA nodes representing different memory domains
- This approximates a system with both local DRAM and additional memory regions.

These virtual hosts will later be connected to an SST-modeled CXL fabric to evaluate memory sharing behavior for large workloads.