# SST Simulator Setup and Validation

## Overview

This document describes the installation and validation process for the **Structural Simulation Toolkit (SST)** environment used in this research. The setup enables architectural simulation of memory systems using **SST-Core**, **SST-Elements**, and the **Ariel CPU frontend with Intel PIN instrumentation**.

This environment will be used as the base simulation framework for experiments involving memory systems and CXL-based memory architectures.

The installation was performed in **WSL (Ubuntu Linux)**.

Reference documentation:
https://sst-simulator.org/

---

# System Environment

**Operating system**
Ubuntu (WSL)

**User**
ftvee

**SST installation directory**

```
/home/ftvee/sst
```

Verification commands:

```
which sst
/home/ftvee/sst/bin/sst
```

```
sst --version
SST-Core Version (-dev, git branch : master)
```

---

# Components Installed

| SST-Core     | Event-driven simulation engine
| SST-Elements | Architecture simulation components (CPU, memory, network models)
| Intel PIN    | Binary instrumentation used by Ariel CPU model

---

# SST-Core Installation

Clone the SST core repository:

```
git clone https://github.com/sstsimulator/sst-core.git
```

Create a build directory:

```
mkdir build
cd build
```

Configure installation:

```
../configure --prefix=$HOME/sst
```

Compile and install:

```
make -j4
make install
```

---

# SST-Elements Installation

Clone the elements repository:

```
git clone https://github.com/sstsimulator/sst-elements.git
```

Create build directory:

```
mkdir build
cd build
```

Configure with SST-Core and PIN support:

```
../configure \
--prefix=$HOME/sst \
--with-sst-core=$HOME/sst \
--with-pin=$HOME/tools/pin-external-3.31-98869-gfa6f126a8-gcc-linux \
PYTHON=/usr/bin/python3.9
```

Compile and install:

```
make -j4
make install
```

---

# Required Python Version

SST-Elements requires **Python 3.9** for compatibility with the Ariel frontend and SST Python configuration scripts.

The configure step explicitly specifies the Python interpreter:

```
PYTHON=/usr/bin/python3.9
```

---

# Intel PIN Setup

The Ariel CPU model requires **Intel PIN** to instrument application execution.

PIN was installed at:

```
/home/ftvee/tools/pin-external-3.31-98869-gfa6f126a8-gcc-linux
```

This path was passed during SST-Elements configuration:

```
--with-pin=$HOME/tools/pin-external-3.31-98869-gfa6f126a8-gcc-linux
```

---

# Test Simulation

To verify that SST and Ariel were correctly installed, the following OPAL test simulation was executed:

Location:

```
sst-elements/src/sst/elements/opal/tests
```

Run command:

```
sst basic_1node_1smp.py
```

---

# Configuration Adjustment

During testing, a configuration issue occurred due to a mismatch between the number of Ariel CPU cores and the number of cache/MMU links defined in the simulation topology.

Original configuration:

```
corecount = 4
```

However, the topology only connected two cores, producing the error:

```
FATAL: cpu, Error: unable to configure link on port 'cache_link_2'
```

To resolve this, the Ariel CPU core count was reduced to match the topology:

```
corecount = 2
```

Additionally, the loop generating the cache hierarchy was updated to match the number of active cores.

---

# Successful Execution Output

After correcting the configuration, the simulation executed successfully.

Example output:

```
Initialized with 2 cores
Simulation is complete, simulated time: 3.02028 ms
```

This confirms that:

* SST-Core is functioning correctly
* SST-Elements components load successfully
* Ariel CPU frontend operates correctly
* PIN instrumentation launches and attaches properly

---

# Result

The SST environment is fully operational and capable of running architectural simulations with the Ariel CPU model.

This setup will serve as the foundation for future experiments involving:

* memory system behavior
* memory disaggregation
* CXL memory modeling
* simulation of multi-node memory systems
