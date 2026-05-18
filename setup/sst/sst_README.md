# SST Setup and Validation

## Installed Components

The following SST components were installed for the simulation environment:

* **SST-core**
* **SST-elements**

---

## Installation Location

SST was installed locally in the research environment used by this repository.

The installation was performed inside the working research directory rather than a system-wide installation to keep the environment reproducible.

---

## Validation Test

The SST installation was validated using the OPAL basic test configuration.

Example command:

```
sst src/sst/elements/opal/tests/basic_1node_1smp.py
```

This confirms that SST-core and SST-elements were built correctly and that the simulator can execute a basic architecture model.

---

## Validation Script

A helper script is provided in the repository to run the validation test:

```
scripts/sst/validate_sst_opal.sh
```

This script runs the OPAL validation configuration and can be used to quickly verify that the SST environment is functioning.

---

## Related Files

### Installation Notes

```
setup/sst_setup.md
```

Contains the full installation procedure used to build SST-core and SST-elements.

### Validation Log

```
setup/sst_basic_run.log
```

Log captured during the initial validation run of the OPAL test.
