# QEMU Setup Files

This folder contains the setup and networking documentation for the QEMU-based VM simulation environment.

## Files

- `qemu_setup.md`  
  Full record of the QEMU build process, VM creation, guest networking fixes, and planned CXL-oriented topology.

- `qemu_networking.md`  
  Documentation for bridge and TAP networking used to connect QEMU guests to the WSL host and future peer VMs.

- `qemu_setup.log`  
  Setup and validation log captured during environment bring-up.

- `start_vm.sh`  
  Launch script that recreates the bridge/TAP networking environment and starts the VM.