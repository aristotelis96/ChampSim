#!/usr/bin/env python
import numpy as np

path="/home/users/avontz/ChampSim/results/H2P/H2P_TAGE8_fix/"
ips = set()
with open(path+"600.perlbench_s-210B.champsimtrace.xz.txt") as f:
    for line in f:
        if not line.startswith("IPs of H2P"):
            continue
        break

    for line in f:
        ips.add(int(line))
ips2 = set()
with open(path+"600.perlbench_s-1273B.champsimtrace.xz.txt") as f:
    for line in f:
        if not line.startswith("IPs of H2P"):
            continue
        break

    for line in f:
        ips2.add(int(line))

print(ips2.difference(ips))
