#!/usr/bin/env bash
set -e

echo "=== HOST ==="
hostname

echo "=== UPTIME ==="
uptime

echo "=== CPU ==="
lscpu | grep -E 'CPU\(s\)|Model name|Hypervisor vendor|Virtualization type'

echo "=== MEMORY ==="
free -h

echo "=== DISK ==="
df -h /

echo "=== MEMORY TOUCH TEST ==="
python3 - <<'PY'
import time
n = 50_000_000
t0 = time.time()
a = bytearray(n)
for i in range(0, n, 4096):
    a[i] = 1
print("elapsed:", time.time() - t0)
PY