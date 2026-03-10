#!/usr/bin/env bash
set -euo pipefail

mkdir -p setup
sst src/sst/elements/opal/tests/basic_1node_1smp.py | tee setup/sst_basic_run.log