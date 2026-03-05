# CXL Memory Sharing Simulation for LLM Workloads

This project explores memory disaggregation using Compute Express Link (CXL) in simulated environments.

The goal is to analyze memory latency and performance when LLM inference workloads access shared CXL Type-3 memory.

Because real CXL hardware is unavailable, the system is simulated using:

- QEMU virtual machines as hosts
- SST Simulator for architecture modeling
- Custom CXL switch model implemented in SST
- Emulated CXL Type-3 memory latency

## Architecture

Host VMs -> CXL Switch -> Shared CXL Memory

Multiple hosts share memory through a simulated CXL fabric manager.

## Research Goals

1. Simulate CXL memory sharing across hosts
2. Measure latency compared to local memory
3. Analyze performance impact on LLM inference
4. Evaluate scalability of shared memory pools

## Technologies

- SST Simulator
- QEMU
- CXL Type-3 memory modeling
- Python simulation scripts
