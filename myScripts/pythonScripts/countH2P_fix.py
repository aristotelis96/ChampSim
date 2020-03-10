#!/usr/bin/env python

import os

resultsDir='/home/users/avontz/ChampSim/results/H2P/H2P_with_IP'

accList=os.listdir(resultsDir)
accList.sort()
traces=os.listdir(resultsDir+"/")
traces.sort()
for trace in traces:
    h2p = set()
    if (trace=="accRest"):
        continue
    path = resultsDir+"/"+trace    
    with open(path) as fp:
        for line in fp:        
            if "IPs of H2P found" in line:
                break
        for line in fp:
            h2p.add(int(line))

    print(trace.split("champsim")[0] + " H2P: " + str(len(h2p)))

        
