#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Aug 11 11:19:53 2021

@author: shunyang
"""

import numpy as np 
import os 
a0=0.52918
R = 13.6057
n=1
Q =1
N =2
ran = np.arange(5,2000,2)

def num_there(s):
    return any(i.isdigit() for i in s)



path = '/Users/shunyang/Tools/gamess/tests/'
os.chdir(path)
files= os.listdir(path)

index = []
p0_list = []
p1_list = []


for log in files: 
    tmpname = log.split('.')
    if tmpname[-1] == 'log':
        
    
        with open(log,'r', encoding="utf8", errors='ignore') as f:
            tmp = f.readlines()
            read = False
            read2 = False
            for line in tmp:
                
                
                if ('EIGENVALUES' in line):
                    #print(line)
                    read = True
                    energy = []
                if read & (num_there(line)):
                    energy.append(line)
                   # print(line)
                  
                if 'END OF RHF CALCULATION' in line:
                    read = False
                
                
                if 'VIRIAL ANALYSIS' in line:
                    read2 = True
                    KE = []
                if read2 & ('KINETIC ENERGY OF ORBITAL' in line):
                    KE.append(line.split()[-1])
                    
        tmp = energy[1::2]
        B = []
        for line in tmp:
            for i in line.split()[:]:
                
                B.append(float(i))
            
        
        nB = np.array(B)
        nB  = -nB[nB < 0] * 27.2114
        nKE = np.array(KE,dtype=np.float64) * 27.2114
        
        try: 
            u = (nKE/nB).reshape(-1,1)
            norb = len(nB)
            
            S = (4*np.pi * np.square(a0) * N * np.square(R/nB)).reshape(-1,1)
            
            
            T = np.tile(ran,(norb,1))
            for i in range(0,norb):
                tmp = T[i,:]
                tmp[tmp < nB[i]] = 0
                T[i,:] = tmp
            
            t = 1/nB.reshape(-1,1) * T 
            
            pre = S * np.reciprocal(t+(u+1)/n)
            
            
            T = 70
            t = (T/nB).reshape(-1,1)
            pre = S * np.reciprocal(t+(u+1)/n)
            a1 = Q*np.log(t)/2* (1 - 1/ np.square(t))
            
            a2 = (2-Q)* (1- 1/t - np.log(t) * np.reciprocal(t+1))
                
                
            sigma_T = pre*(a1 +a2)
            
            #p = sigma_T/sigma_T.sum()*100
            
            p0 = sigma_T[-1]/(sigma_T[-1] + sigma_T[-2]) * 100
            p1 = sigma_T[-2]/(sigma_T[-1] + sigma_T[-2]) * 100
            index.append(tmpname[0])
            p0_list.append(p0[0])
            p1_list.append(p1[0])
        except:
            pass

import pandas as pd 
df = pd.DataFrame({'index':index,
                   'p0':p0_list,
                   'p1':p1_list})

df.to_csv('p.csv')



