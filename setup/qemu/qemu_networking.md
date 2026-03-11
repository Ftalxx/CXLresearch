# QEMU VM Networking Setup (WSL)

This document describes the networking configuration used to allow QEMU virtual machines to communicate with the host system and with other VMs.

The environment is running inside **WSL**, which requires a slightly different networking approach compared to a native Linux system.

---

# Goal

Create a reproducible networking environment where:

- QEMU VMs can communicate with the host
- Multiple VMs can communicate with each other
- The setup can be recreated automatically after a restart

This is required for simulating multiple hosts that will later share memory through the modeled **CXL fabric**.

---

# Host Networking Overview

The host uses a Linux bridge and TAP interface to connect QEMU guests to the host network.

```
WSL Host
   │
   br0 (bridge)
   │
   tap-cxl1 (TAP interface)
   │
   QEMU VM (virtio network device)
```

The bridge acts as a virtual switch that connects the host and VM interfaces.

---

# Host Network Configuration

## Bridge Interface

```
br0
IP: 192.168.199.1/24
```

The bridge serves as the gateway for guest VMs.

## TAP Interface

```
tap-cxl1
```

The TAP interface connects the QEMU VM network device to the host bridge.

---

# Guest Network Configuration

Inside the Ubuntu guest VM the network interface is configured with a static address.

Interface:

```
enp0s2
```

Example configuration:

```
IP address: 192.168.199.2/24
Gateway: 192.168.199.1
```

This static configuration was used because DHCP via `dnsmasq` was unreliable under WSL TAP networking.

---

# Example Netplan Configuration (Guest)

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s2:
      addresses:
        - 192.168.199.2/24
      routes:
        - to: default
          via: 192.168.199.1
      nameservers:
        addresses: [8.8.8.8, 1.1.1.1]
```

Apply with:

```
sudo netplan apply
```

---

# QEMU Launch Configuration

The VM is started with a TAP-backed virtio network device.

Example:

```
-netdev tap,id=net0,ifname=tap-cxl1,script=no,downscript=no
-device virtio-net-pci,netdev=net0
```

This connects the VM network device to the TAP interface on the host.

---

# Verification Steps

## On the Host

Check bridge and TAP interfaces:

```
ip a
ip addr show br0
bridge link
```

You should see:

- `br0` with IP `192.168.199.1`
- `tap-cxl1` attached to `br0`

---

## Inside the VM

Check network configuration:

```
ip a
ip route
```

Expected:

```
192.168.199.2/24
default via 192.168.199.1
```

Test connectivity:

```
ping 192.168.199.1
```

Successful replies confirm that VM ↔ host networking is working.

---

# Future Expansion

Additional VMs can be connected by creating additional TAP interfaces.

Example:

```
tap-cxl2
tap-cxl3
```

Each VM should receive a unique static IP:

```
VM1 → 192.168.199.2
VM2 → 192.168.199.3
VM3 → 192.168.199.4
```

This will allow multiple simulated hosts to communicate over the same bridge before integrating the SST CXL fabric model.