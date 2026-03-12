# VM Cluster Setup and Connectivity

## Overview

A small multi-host simulation environment was created using QEMU virtual machines.  
Each VM represents an independent host connected through a virtual bridge network.

The cluster is controlled from the WSL host environment.

---

# Cluster Nodes

| Hostname | IP Address |
|----------|-----------|
| host1 | 192.168.199.2 |
| host2 | 192.168.199.3 |
| host3 | 192.168.199.4 |

Virtual bridge gateway:

```
192.168.199.1
```

### Network Topology

```
                WSL Host
                   │
              bridge network
              192.168.199.1
                   │
        ┌──────────┼──────────┐
        │          │          │
      host1      host2      host3

192.168.199.2     .3         .4
```

This network allows:

- WSL → VM SSH access
- VM ↔ VM communication
- remote command execution across nodes

Internet access inside the VMs is not required.

---

# SSH Configuration

To simplify connections, SSH host aliases were configured.

File:

```
~/.ssh/config
```

Contents:

```
Host h1
HostName 192.168.199.2
User ftvee

Host h2
HostName 192.168.199.3
User ftvee

Host h3
HostName 192.168.199.4
User ftvee
```

Example usage:

```
ssh h1
ssh h2
ssh h3
```

---

# Passwordless SSH Setup

SSH keys were configured so nodes can connect without passwords.

## Generate Key

```
ssh-keygen
```

Default settings were accepted.

## Copy Keys to Nodes

```
ssh-copy-id ftvee@192.168.199.2
ssh-copy-id ftvee@192.168.199.3
ssh-copy-id ftvee@192.168.199.4
```

After this step:

- WSL can access all VMs
- VMs can SSH into each other
- remote commands can be executed across nodes

Example distributed command:

```
for h in h1 h2 h3; do ssh $h uptime; done
```

---

# Connectivity Verification

Connectivity was verified using:

## SSH Tests

```
ssh h1
ssh h2
ssh h3
```

## Remote Command Execution

```
for h in h1 h2 h3; do ssh $h hostname; done
```

Expected output:

```
host1
host2
host3
```

---

# Baseline Cluster Sanity Check

A script `baseline_check.sh` was created to verify system configuration and basic
performance across nodes. Script available in:

```
scripts/cluster/baseline_check.sh
```

The script reports:

- hostname
- uptime
- CPU configuration
- memory availability
- disk configuration
- simple memory-touch benchmark

Execution across nodes:

```
for h in h1 h2 h3; do
echo "===== $h ====="
ssh $h ./baseline_check.sh
done
```

---

# Baseline Results

Memory touch test results:

| Host | Time (seconds) |
|------|---------------|
| host1 | 0.026 |
| host2 | 0.034 |
| host3 | 0.022 |

Variation is expected due to VM scheduling and measurement noise.

These results confirm that the virtual hosts behave consistently and are suitable
for further experimentation.

---

# Outcome

The environment now provides:

- 3 independent virtual hosts
- SSH connectivity between all nodes
- command orchestration across nodes
- reproducible infrastructure for experiments