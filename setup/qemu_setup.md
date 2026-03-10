\# QEMU Setup – Base Virtual Machine Environment



\## Purpose



This document records the setup process used to build a QEMU virtualization environment and create a base Ubuntu virtual machine for future multi-host CXL memory simulation experiments using SST.



---



\# Host Environment



Host system:



Windows + WSL environment used for development.



Primary tools used:



\- QEMU (built from source)

\- Ubuntu Server 22.04 (guest OS)

\- SSH for guest management



---



\# QEMU Build Process



QEMU was cloned and compiled from source to allow control over the virtualization environment.



Target architecture built:





x86\_64-softmmu





Configuration command used:





./configure --target-list=x86\_64-softmmu





Build command:





ninja -C build





During setup several dependency and environment issues were encountered and resolved, including:



\- Python virtual environment configuration problems

\- setuptools and importlib metadata conflicts

\- meson and ninja dependency requirements

\- GLib version compatibility issues between QEMU and the existing SST environment



A compatible QEMU revision was used so that the virtualization environment could coexist with the older system libraries required by SST.



---



\# Virtual Machine Creation



A base Ubuntu Server virtual machine was created to serve as the template for future simulated hosts.



Disk image creation:





qemu-img create -f qcow2 ubuntu.qcow2 20G





Ubuntu Server ISO was then booted through QEMU and installed onto the qcow2 disk.



The installation included:



\- OpenSSH server

\- basic networking configuration

\- minimal server environment



---



\# QEMU Launch Configuration



The virtual machine is launched using QEMU user-mode networking with port forwarding for SSH access.



Example launch command:





./build/qemu-system-x86\_64

-accel kvm

-m 4096 -smp 4

-drive file=ubuntu.qcow2,if=virtio

-netdev user,id=n0,hostfwd=tcp:127.0.0.1:2222-:22

-device virtio-net-pci,netdev=n0

-display gtk





Key features of this configuration:



\- hardware acceleration via KVM

\- 4 GB RAM allocated to the guest

\- virtio network device

\- SSH forwarding from host port 2222 to guest port 22



SSH access from the host is performed using:





ssh -p 2222 <username>@127.0.0.1





---



\# Guest Networking Issue



During initial setup the guest interface `ens3` sometimes failed to obtain an IPv4 address automatically after reboot.



Symptoms included:



\- no IP assigned to `ens3`

\- SSH connectivity failure

\- missing default route



Temporary workaround used:





sudo dhclient ens3





This manually triggered DHCP assignment from QEMU's user-mode network.



---



\# Permanent Networking Fix



The issue was resolved by configuring DHCP persistence through Netplan.



File modified:





/etc/netplan/00-installer-config.yaml





Configuration used:





network:

version: 2

renderer: networkd

ethernets:

ens3:

dhcp4: true





After applying the configuration:





sudo netplan apply





the guest consistently receives its network address on boot.



Typical QEMU NAT configuration inside the VM:





Interface: ens3

IP: 10.0.2.15

Gateway: 10.0.2.2





---



\# Current Status



The base virtualization environment is now functioning correctly.



Working components:



\- QEMU compiled from source

\- Ubuntu Server base VM installed

\- SSH server enabled

\- QEMU port forwarding configured

\- guest networking persistence fixed

\- stable VM boot and login



This VM will act as the base template for future host simulations.



---



\# Next Steps



The next phase of the project will involve:



1\. Cloning the base VM to simulate multiple hosts

2\. Connecting those hosts to an SST-based CXL memory simulation environment

3\. Running memory workloads to analyze performance behavior under shared memory conditions

