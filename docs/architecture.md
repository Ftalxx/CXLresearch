# CXL Memory Sharing Simulation Architecture (QEMU + SST-Simulator)

## System Components

### QEMU virtual machines (host layer)

Each QEMU VM represents an independent host that runs a Linux guest and generates memory traffic. The guest is configured to expose a CXL-like device interface so that workloads can issue accesses to an address range corresponding to the simulated CXL memory pool.

QEMU is used for:
- hosting multiple isolated Linux environments
- running memory-intensive benchmarks and application workloads
- providing host identities and traffic sources for multi-host contention scenarios

QEMU alone does not provide a realistic fabric model for multi-host CXL memory sharing. The fabric timing and contention behavior is modeled in SST.

### SST-Simulator (fabric and timing layer)

SST-Simulator provides the interconnect and memory timing model that makes the simulation meaningful without physical CXL hardware. SST is responsible for representing the fabric between multiple hosts and the shared memory pool, including contention and arbitration effects that occur when multiple hosts access the same resource.

SST is used for:
- modeling a CXL switch component as a hardware module
- applying configurable switching and traversal latencies
- modeling queuing, arbitration, and congestion effects under load
- modeling Type-3 memory access timing and optional bandwidth constraints

This layer provides the experimental control required for research, including the ability to vary parameters and repeat measurements under consistent conditions.

### CXL switch model (SST component)

Because there is no physical switch in the environment, the switch is implemented as a custom SST component. The switch component accepts host-originated requests, schedules them according to an arbitration policy, and forwards them toward the memory model. It also routes responses back to the originating host.

The switch model includes:
- a set of host-facing ports and one or more memory-facing ports
- arbitration and scheduling across multiple host request streams
- queuing and backpressure behavior under contention
- configurable switch-level latency and optional link bandwidth limits

The switch component is the primary location where shared access behavior becomes observable, especially in tail latency and fairness under increasing host count.

### CXL Type-3 memory pool model (SST memHierarchy-based)

The shared memory pool is modeled as a Type-3 memory device accessed through the fabric. The model provides a tunable access delay and can optionally enforce throughput limits to represent realistic link or device constraints. The memory model is expected to be implemented using SST’s memory hierarchy components to support timing and parameterization.

The Type-3 memory model includes:
- configurable base access latency
- optional bandwidth ceilings and request service limits
- optional interleaving or address mapping policies for experiments

### Fabric Manager (control plane)

A Fabric Manager service coordinates resource allocation and sharing policy. It is responsible for determining which host is allowed to access which memory regions, managing ownership and shared mappings, and updating the enforcement state used by the fabric model.

The Fabric Manager is responsible for:
- allocating regions from the shared pool to hosts
- supporting shared access policies (granting a second host access to an existing region)
- tracking active mappings and permissions
- updating the switch enforcement tables (ACL or mapping rules) used during request validation

The Fabric Manager may run as a daemon on the host machine or in a dedicated VM, as long as it can communicate reliably with the host VMs and the SST control interface.

### QEMU–SST bridge (integration layer)

A bridge layer is required to connect QEMU’s host-side request generation to SST’s event/timing simulation. This layer transports request metadata (host identity, operation, address, size) into SST and returns completions/responses back to the correct host context.

Two approaches are considered:
- shared memory ring buffers with polling/doorbells for lower overhead and higher request rates
- Unix domain sockets for simpler implementation at the cost of additional overhead

The bridge is treated as integration infrastructure and is not the main focus of evaluation, but it is necessary for end-to-end operation.

## Access and Control Flow

1. A workload in a VM issues memory operations targeting the configured CXL address range.
2. QEMU captures or represents these operations through its CXL device emulation path and forwards the corresponding request to the bridge.
3. The bridge delivers the request to SST with host identity and request metadata.
4. The switch model validates access against Fabric Manager policy state and schedules the request under contention.
5. The request is forwarded to the Type-3 memory model, which applies the configured timing and service constraints.
6. The response is routed back through the switch and bridge to the originating VM and workload.

The primary observables are latency (including tail latency), throughput, and fairness as the number of hosts and request rates increase.

## Scope and Assumptions

This architecture targets system-level performance modeling rather than full protocol-accurate reproduction of all CXL details. The focus is on fabric-level behaviors relevant to memory sharing experiments, including contention, arbitration policy, and configurable latency/bandwidth parameters.

The implementation is structured to support incremental development:
- baseline SST validation using existing tests
- multi-VM host setup and workload generation
- switch and Type-3 timing models in SST
- Fabric Manager control plane integration
- experiment automation and results collection