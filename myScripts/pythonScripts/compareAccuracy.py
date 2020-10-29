#!/usr/bin/env python3


##
## Me auto to script vriskoume accuracy sygkritika CNN kai Tage
## Apo arxeia apo eksodo tou 'measure_H2P_accuracy' pernoume ta statistika tou tage gia kathe h2p
## apo testerAll.py pernoume to .pt arxeio pou paragetai me statistika gia kathe H2P apo to neuroniko
## kai sigkrinei
##

import glob
import sys
import torch
if(len(sys.argv)!=3):
    print("Usage: ./compareAccuracy dict.pt H2P_accuracy.txt")
    exit()


## Coloring ##
class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

txtFile = sys.argv[2]


txt = {}
CNN = torch.load(sys.argv[1], map_location=torch.device("cpu"))

with open(txtFile) as f:
    for line in f:
        if ("Printing stats for each H2P" not in line):
            continue
        break
    for line in f:
        ip=(int(line.split(" ")[0]))
        acc = (float(line.split(" ")[-1][:-2]))
        txt[ip] = acc

improved = 0
failed = 0
for key in CNN:
    try:        
        if( round(CNN[key]['acc']*100,4) > round(txt[key],4)):
            if(round(CNN[key]['acc']*100,4)-1 < round(txt[key],4)):
                color = bcolors.WARNING
            else:
                color = bcolors.OKGREEN
            improved+=1
        else:
            color = bcolors.FAIL
            failed+=1
        print(color,"IP:", key, "CNN:", round(CNN[key]['acc']*100,4), "TAGE:",  round(txt[key],4), bcolors.ENDC)
    except:
        # this exception might occur because an IP does not exist in txt file 
        continue
print("Improved:", improved , ", Failed:" , failed)
