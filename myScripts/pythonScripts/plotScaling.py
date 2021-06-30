#!/usr/bin/env python3

import glob
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.cm as cm
import os
import pprint
from collections import OrderedDict
pp = pprint.PrettyPrinter()

def reverse(l):
    l.reverse()
    return l

benchs=['531.deepsjeng','541.leela', '557.xz','505.mcf']

MODES = [
    'Perfect_BR',
    'Perfect_H2P_TAGE8',        
    'BranchNet_CNN-TAGE64',     
    'LSTM_CNN-TAGE64',    
    "BranchNetTarsa_CNN-TAGE64",
    'TAGE64',
    'BranchNet_CNN-TAGE8',
    'LSTM_CNN-TAGE8',        
    "BranchNetTarsa_CNN-TAGE8",
    'TAGE8']
#MODES = os.listdir("/home/users/avontz/ChampSim/results/scalingResults/myTraces/{}/".format(benchs[0]))
MODES.remove("TAGE8")
MODES.insert(0, "TAGE8") # needed so tage8 is read first as a base start
#get Weights for each simpoint
#weight_DIR="C:/Users/Aristotelis/Desktop/diploma/weights-and-simpoints-speccpu"
weight_DIR="/home/users/avontz/ChampSim-Tracing/simpoints"
resultDir = "/home/users/avontz/ChampSim/results/scalingResults/myTraces"


weights=dict()
for indx, bench in enumerate(benchs):
    plt.subplot(4,1,1+indx)
    fileName = glob.glob(weight_DIR+"/"+bench+"/1B/"+bench+"_ref*.weights")[0]
    w = open(fileName)
    fileName = glob.glob(weight_DIR+"/"+bench+"/1B/"+bench+"_ref*.simpoints")[0]
    sim = open(fileName)
    weights[bench]=[]
    for line in w:
        line = line.split(" ")[0]
        if (float(line)<0.01):
            sim.readline()
            continue
        weights[bench].append([sim.readline().split(" ")[0], float(line)])    

AverageMode = {
    mode:[1]*4 for mode in MODES
}
base={}
MPKI = OrderedDict({bench : OrderedDict() for bench in benchs})
plt.figure(figsize=(9.6,11.2),dpi=200)

for i,bench in enumerate(benchs):
    ax=plt.subplot(4,1,i+1)
    IPC = OrderedDict({key: [] for key in MODES})
    
    for mode in MODES:
        print(mode)
        scales=sorted(os.listdir(resultDir+"/"+bench+"/"+mode))
        for i, scale in enumerate(scales):
            numerator = 0 
            denominator = 0
            mpkiValue = 0
            for weight in weights[bench]:
                benchFile = bench+"_ref*-"+weight[0]+"B.champsimtrace.xz._."+scale+".txt"
                pathFile = glob.glob(resultDir+"/"+bench+"/"+mode+"/"+scale+"/"+benchFile)
                if(len(pathFile)==0): # If Path file not exist then len(pathfile) == 0
                    continue                
                pathFile = pathFile[0]                
                with open(pathFile) as f:
                    for line in f:
                        if line.startswith("CPU 0 cumulative IPC:"):
                            lineSplitted = line.split()
                            numerator+=float(lineSplitted[4])*weight[1]
                            denominator+=weight[1]
                        if line.startswith("CPU 0 Branch Prediction"):
                            lineSplitted = line.split("MPKI:")[1]
                            lineSplitted = lineSplitted.split()
                            mpkiValue += float(lineSplitted[0])*weight[1]
            if(scale=="x01_tage8"):
                base[bench] = numerator/denominator
                IPC[mode].append(1)  
                MPKI[bench][mode] = (mpkiValue/denominator)
            else:
                IPC[mode].append((numerator/denominator)/base[bench])
                AverageMode[mode][i]*=(numerator/denominator)/base[bench]     
                MPKI[bench][mode] = (mpkiValue/denominator)     
            if (bench=='505.mcf' and "BranchNetTarsa" in mode):
                MPKI[bench][mode] = 0
                IPC[mode][-1] = 0
    x_axis = np.arange(len(scales))
    width = 0.09
    width
    #plt.clf()
    #plt.figure(figsize=(15,7))
    IPC.move_to_end('TAGE8')
    if "505" not in bench:
        p9 = plt.bar(x_axis+5*width, IPC["Perfect_BR"], width, color='cyan')    
        p8 = plt.bar(x_axis+4*width, IPC["Perfect_H2P_TAGE8"], width, color='lime')
        p7 = plt.bar(x_axis+3*width, IPC["BranchNet_CNN-TAGE64"], width, color='royalblue')
        p6 = plt.bar(x_axis-1*width, IPC["BranchNet_CNN-TAGE8"], width, color='cornflowerblue')
        p5 = plt.bar(x_axis+2*width, IPC["LSTM_CNN-TAGE64"], width, color='darkgoldenrod')
        p4 = plt.bar(x_axis-2*width, IPC["LSTM_CNN-TAGE8"], width, color='goldenrod')    
        p3 = plt.bar(x_axis+1*width, IPC["BranchNetTarsa_CNN-TAGE64"], width, color='indianred')
        p2 = plt.bar(x_axis-3*width, IPC["BranchNetTarsa_CNN-TAGE8"], width, color='lightcoral')
        p1 = plt.bar(x_axis-0*width, IPC["TAGE64"], width, color='gray')
        p0 = plt.bar(x_axis-4*width, IPC["TAGE8"], width, color='silver')    
    else:        
        p9 = plt.bar(x_axis+4*width, IPC["Perfect_BR"], width, color='cyan')    
        p8 = plt.bar(x_axis+3*width, IPC["Perfect_H2P_TAGE8"], width, color='lime')
        p7 = plt.bar(x_axis+2*width, IPC["BranchNet_CNN-TAGE64"], width, color='royalblue')
        p6 = plt.bar(x_axis-1*width, IPC["BranchNet_CNN-TAGE8"], width, color='cornflowerblue')
        p5 = plt.bar(x_axis+1*width, IPC["LSTM_CNN-TAGE64"], width, color='darkgoldenrod')
        p4 = plt.bar(x_axis-2*width, IPC["LSTM_CNN-TAGE8"], width, color='goldenrod')    
        p1 = plt.bar(x_axis-0*width, IPC["TAGE64"], width, color='gray')
        p0 = plt.bar(x_axis-3*width, IPC["TAGE8"], width, color='silver')
        plt.legend([p9,p8,p7,p6,p5,p4,p3,p2,p1,p0], ["Perfect-BR","Perfect-H2P", "BranchNet-TAGE64", "BranchNet-TAGE8", "LSTM-TAGE64", "LSTM-TAGE8", 
    "Tarsa-TAGE64" ,"Tarsa-TAGE8","TAGE64", "TAGE8"], bbox_to_anchor=(1.05, 1),fontsize=12)
        plt.xlabel("Pipeline capacity scaling", fontsize=16)
        

   #plt.legend([p7,p6,p5,p4,p1,p0],["Perfect Branch Prediction","Perfect H2P","BranchNet+TAGE64", "BranchNet+TAGE8", "TAGE-SC-L-64KB", "TAGE-SC-L-8KB"])        

    plt.xticks(x_axis, [i[0:3] for i in scales])#,fontsize=20)
#    plt.yticks(np.linspace(1, max(i for i in IPC["BranchNet_CNN-TAGE64"])+0.1,10))
#    plt.ylim(0.95, max(i for i in IPC["BranchNet_CNN-TAGE64"])+0.01)
    plt.yticks(np.arange(1,1.35,0.05))#, fontsize=20)
    plt.ylim(0.95, 1.35)
    #ax = plt.axes()
    ax.yaxis.grid(True)    
    for i, rect in enumerate(p9+p8):
        height = rect.get_height()
        plt.text(rect.get_x() + rect.get_width() / 2.0,
            (1.295 if height>1.295 else height) if i>3 else 1.32 , 
            str(round(height,2)), ha='center', va='bottom')#, fontsize=20)
    plt.title(bench)#,fontsize=24)
    plt.ylabel("IPC relative to x01-TAGE-8KB")
    print(bench)
    pp.pprint(IPC)

    
    # plt.legend([p9,p8,p1,p0],['Perfect-BR','TAGE64KB','TAGE8KB'])
    plt.tight_layout()
    plt.savefig("./{}_IPC.png".format(bench))#,bbox_inches='tight',dpi=200)

 

### MPKI PLOTS ###
plt.clf()
plt.figure(figsize=(10,20))
plt.figure(figsize=(9.6,11.2),dpi=200)
for i, bench in enumerate(benchs):    
    #plt.clf()
    #plt.figure(figsize=(10,5))

    # ax = plt.axes()
    ax = plt.subplot(4,1,i+1)    

    pp.pprint(MPKI[bench])
    MPKI[bench].pop('Perfect_BR')
    MPKI[bench].move_to_end('TAGE8')
    # for key, _ in sorted(MPKI[bench].items(), key=lambda item: item[1]):
    #     MPKI[bench].move_to_end(key)
    x_axis = np.arange(9)
    width = 0.8
    if '505' in bench:
        x_axis=np.arange(7)
        del MPKI[bench]['BranchNetTarsa_CNN-TAGE8']
        del MPKI[bench]['BranchNetTarsa_CNN-TAGE64']
    p0 = plt.bar(x_axis, reverse(list(MPKI[bench].values()))[:], width)
    if '505' not in bench:
        p0[8].set_color('lime')
        p0[7].set_color('royalblue')
        p0[6].set_color('darkgoldenrod')
        p0[5].set_color('indianred')
        p0[4].set_color('gray')
        p0[3].set_color('cornflowerblue')     
        p0[2].set_color('goldenrod')
        p0[1].set_color('lightcoral')
        p0[0].set_color('silver')
    else:
        p0[6].set_color('lime')
        p0[5].set_color('royalblue')
        p0[4].set_color('darkgoldenrod')
        p0[3].set_color('gray')
        p0[2].set_color('cornflowerblue')     
        p0[1].set_color('goldenrod')
        p0[0].set_color('silver')

#    plt.legend([p6,p5,p4,p3,p2,p1,p0],["Perfect H2P prediction", "BranchNet+TAGE64", "BranchNet+TAGE8", "LSTM+TAGE64", "LSTM+TAGE8", "TAGE-SC-L-64KB", "TAGE-SC-L-8KB"], loc='lower left')
    #plt.legend([p5,p4,p1,p0],["BranchNet+TAGE64", "BranchNet+TAGE8", "TAGE-SC-L-64KB", "TAGE-SC-L-8KB"], loc='lower right')
     
    
        plt.xticks(x_axis, reverse([i.replace("BranchNet",'').replace("_CNN",'') if "Tarsa" in i else i.replace("_CNN",'') for i in list(MPKI[bench].keys())]), rotation='45', fontsize=12)    
        plt.xlabel("Predictors", fontsize=16)    
 #   plt.yticks(np.linspace(1, max(v for v in MPKI[bench].values())+0.2,10))
#    plt.ylim(min(i for i in MPKI[bench].values())-0.2, max(v for v in MPKI[bench].values())+0.2)
    plt.ylim(0,20.5)
    plt.yticks(np.arange(0,22,2))#, fontsize=20)
    ax.yaxis.grid(True)
    plt.title(bench)#,fontsize=24)
    plt.ylabel("MPKI")

    plt.tight_layout(pad=0.4, w_pad=0.5, h_pad=1.0)

    plt.savefig("./{}_MPKI.png".format(bench),bbox_inches='tight',dpi=100)        

# AVERAGE IPC PER MODE
for mode in AverageMode:
    AverageMode[mode] = [i**(1/len(benchs)) for i in AverageMode[mode]]
pp.pprint(AverageMode)
