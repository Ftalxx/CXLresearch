\# CXL Memory Sharing Simulation for LLM Workloads



This project explores memory disaggregation using Compute Express Link (CXL) in a simulated environment.



The goal is to study how memory latency and overall system performance change when large workloads—such as LLM inference—access shared CXL Type-3 memory instead of local DRAM.



Because real CXL hardware is not available, the system is implemented through simulation using:



\- QEMU virtual machines as host systems  

\- SST (Structural Simulation Toolkit) for architecture modeling  

\- A custom CXL switch model implemented in SST  

\- Emulated CXL Type-3 memory latency



---



\# Current Progress



\- SST simulator installed and validated  

\- Ariel test configuration executed successfully  

\- QEMU virtualization environment configured  

\- Ubuntu VM host template created  

\- Bridge/tap networking implemented for VM communication  

\- Host ↔ VM networking verified using static addressing  



---



\# Next Step



Build a multi-host VM environment so several simulated hosts can access shared memory through the modeled CXL fabric.



This will allow experiments measuring the effect of shared memory access on workload latency.



---



\# Architecture



```

Host VMs → CXL Switch → Shared CXL Memory

```

Multiple simulated hosts connect through a CXL switch that manages access to a shared memory pool.  

The switch and memory behavior are modeled inside SST.



---



\# Research Goals



\- Simulate CXL memory sharing across multiple hosts  

\- Measure latency compared to local DRAM access  

\- Analyze the performance impact on LLM inference workloads  

\- Evaluate scalability of shared memory pools  



---



\# Technologies



\- SST Simulator  

\- QEMU  

\- CXL Type-3 memory modeling  

\- Python simulation scripts  



---



\# Repository Structure



This repository is organized to separate environment setup, simulation work, and collected results.



\- `setup/`  

&nbsp; Setup notes, validation steps, and environment configuration for SST and QEMU.



\- `setup/qemu/`  

&nbsp; Documentation and scripts for the QEMU VM simulation environment.



\- `setup/sst/`  

&nbsp; SST installation notes, configuration steps, and validation results.



\- `docs/`  

&nbsp; General documentation and supporting notes for the project.



\- `experiments/`  

&nbsp; Experiment definitions and workload configurations used during testing.



\- `results/`  

&nbsp; Output logs and collected performance measurements.



\- `scripts/`  

&nbsp; Utility scripts used to automate environment setup, launching simulations, or processing results.



\- `qemu/`  

&nbsp; QEMU-related runtime files or VM resources used during simulation.



This structure is intended to keep the simulation environment reproducible while separating setup work from experiment execution.

