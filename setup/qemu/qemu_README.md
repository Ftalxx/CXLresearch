# QEMU Setup Files

This folder contains the setup, cloning, and networking documentation for the QEMU-based multi-VM simulation environment.

## Files

* `qemu_setup.md`
  Full record of the QEMU build process, VM creation, initial guest configuration, and base environment setup.

* `qemu_networking.md`
  Documentation for bridge and TAP networking used to connect QEMU guests to the WSL host and allow communication between multiple VMs.

* `qemu_cloning.md`
  Documentation describing how the base VM disk was cloned into multiple host instances, including hostname changes, machine ID regeneration, and static IP configuration.

* `qemu_setup.log`
  Setup and validation log captured during environment bring-up, including QEMU version, host networking configuration, and guest system information.

## Launch Scripts

The VM launch scripts are stored in the repository's scripts directory:

```
scripts/qemu/
```

These scripts recreate the bridge/TAP networking environment and launch the virtual machines.

* `scripts/qemu/start_vm1.sh`
  Launch script for VM **host1**.

* `scripts/qemu/start_vm2.sh`
  Launch script for VM **host2**.

* `scripts/qemu/start_vm3.sh`
  Launch script for VM **host3**.
