import numpy as np
import matplotlib.pyplot as plt
import os



averageIPC = {"Perfect_H2P":[], "PB":[], "TAGE":[]}

benchs = ['600.perlbench_s', '605.mcf_s', '620.omnetpp_s', '623.xalancbmk_s', '625.x264_s', '631.deepsjeng_s', '641.leela_s', '648.exchange2_s', '657.xz_s']

branches = ["Perfect_H2P", "PB", "TAGE"]

#get Weights for each simpoint
weight_DIR="C:/Users/Aristotelis/Desktop/diploma/weights-and-simpoints-speccpu"
weights=dict()
for bench in benchs:
    w = open(weight_DIR+"/"+bench+"/weights.out")
    sim = open(weight_DIR+"/"+bench+"/simpoints.out")
    weights[bench]=[]
    for line in w:
        if (float(line)<0.01):
            sim.readline()
            continue
        weights[bench].append([sim.readline()[:-1], float(line)])

#calculate for each branch
for branch in branches:
    scales=os.listdir("./scalingResults/"+branch)    
    #for each scale (x01, x02, x04 etc)
    
    for scale in scales:    
        totalAverage=0
        for bench in benchs:
            # each bench has several weights/simpoints
            for weight in weights[bench]:
                benchFile = bench+"-"+weight[0]+"B.champsimtrace.xz._."+scale+".txt"                
                with open("./scalingResults/"+branch+"/"+scale+"/"+benchFile) as f:
                    numerator = 0 
                    denominator = 0
                    for line in f:
                        if line.startswith("CPU 0 cumulative IPC:"):
                            line = line.split()
                            numerator+=float(line[4])*weight[1]
                            denominator+=weight[1]

            totalAverage+=numerator/denominator

        totalAverage=totalAverage/(len(benchs))
        averageIPC[branch].append(totalAverage)
print(averageIPC)
ind = np.arange(len(scales))
width = 0.35

p3 = plt.bar(ind, averageIPC["PB"], width, color='blue')
p2 = plt.bar(np.arange(4), averageIPC["Perfect_H2P"], width, color='lime')
p1 = plt.bar(ind, averageIPC["TAGE"], width, color='silver')

plt.legend([p3,p2,p1],["Perfect Branch Prediction","Perfect H2P","TAGE-SC-L-8KB"])

plt.xticks(ind, [i[0:3] for i in scales])
plt.yticks(np.arange(1.0,2.8,0.25))
plt.ylim(1.0, 2.5)
ax = plt.axes()
ax.yaxis.grid(True)
plt.title("Average for all benchmarks")
plt.ylabel("IPC")
plt.xlabel("Pipeline capacity scaling")
plt.savefig("./graphs/all_average.png")

plt.clf() #clear

#plot for each benchmark
for bench in benchs:
    IPC = {"PB":[], "TAGE":[], "Perfect_H2P":[]}
    for branch in branches:
        scales=os.listdir("./scalingResults/"+branch)
        for scale in scales:
            numerator = 0 
            denominator = 0
            for weight in weights[bench]:
                benchFile = bench+"-"+weight[0]+"B.champsimtrace.xz._."+scale+".txt"                
                with open("./scalingResults/"+branch+"/"+scale+"/"+benchFile) as f:
                    for line in f:
                        if line.startswith("CPU 0 cumulative IPC:"):
                            line = line.split()
                            numerator+=float(line[4])*weight[1]
                            denominator+=weight[1]
            IPC[branch].append(numerator/denominator)
    plt.clf() #clear

    ind = np.arange(len(scales))
    width = 0.35

    p3 = plt.bar(ind, IPC["PB"], width, color='blue')
    p2 = plt.bar(np.arange(4), IPC["Perfect_H2P"], width, color='lime')
    p1 = plt.bar(ind, IPC["TAGE"], width, color='silver')

    plt.legend([p3,p2,p1],["Perfect Branch Prediction","Perfect H2P","TAGE-SC-L-8KB"])

    plt.xticks(ind, [i[0:3] for i in scales])
    plt.yticks(np.linspace(min(IPC["PB"]+IPC["TAGE"]+IPC["Perfect_H2P"])-0.2, max(IPC["PB"]+IPC["TAGE"]+IPC["Perfect_H2P"])+0.2,10))
    plt.ylim(min(IPC["PB"]+IPC["TAGE"]+IPC["Perfect_H2P"])-0.2, max(IPC["PB"]+IPC["TAGE"]+IPC["Perfect_H2P"])+0.2)
    ax = plt.axes()
    ax.yaxis.grid(True)
    plt.title(bench)
    plt.ylabel("IPC")
    plt.xlabel("Pipeline capacity scaling")
    plt.savefig("./graphs/"+bench.replace(".txt", "")+".png")

