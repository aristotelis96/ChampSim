

##
## me auto to script vriskoume koina H2P anamesa diaforetika apotelesmata ennos fakelou
## pou periexei apotelesmata gia ta statistika twn H2P, (apo eksodo tou ektelesimo measure_H2P_accuracy)
## 

import glob
import sys
import pprint

if(len(sys.argv)!=2):
    print("usage ./findcommonpcs /path/to/H2P_Measure_accuracy/files")
    exit()
files = glob.glob(sys.argv[1]+"/*.txt")


StartSet = set()
firstFile = files.pop()
print(firstFile)
with open(firstFile) as f:
    for line in f:
        if ("Printing stats for each H2P" not in line):
            continue
        break
    for line in f:
        StartSet.add(int(line.split(" ")[0]))
        
secondSet = set()
for file in files:
    with open(file) as f:
        for line in f:
            if ("Printing stats for each H2P" not in line):
                continue
            break
        for line in f:
            secondSet.add(int(line.split(" ")[0]))    
    StartSet = StartSet.intersection(secondSet)

print("Number of common IPs:",len(StartSet))
print("Common Pcs:")

pp = pprint.PrettyPrinter()
pp.pprint(StartSet)