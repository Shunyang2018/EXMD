#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Apr 18 10:50:34 2021

@author: shunyang
"""


log = '/Users/shunyang/Tools/gamess/running/MethylHistidine.log'

def num_there(s):
    return any(i.isdigit() for i in s)


with open(log,'r') as f:
    tmp = f.readlines()
    read = False
    read2 = False
    for line in tmp:
        
        
        if ('EIGENVALUES' in line):
            print(line)
            read = True
            energy = []
        if read & (num_there(line)):
            energy.append(line)
            print(line)
          
        if 'END OF RHF CALCULATION' in line:
            read = False
        
        
        if 'VIRIAL ANALYSIS' in line:
            read2 = True
            KE = []
        if read2 & ('KINETIC ENERGY OF ORBITAL' in line):
            KE.append(line.split()[-1])
            
            
#%%
          
tmp = energy[1::2]
B = []
for line in tmp:
    for i in line.split()[:]:
        
        B.append(float(i))
    
import numpy as np 

nB = np.array(B)
nB  = -nB[nB < 0] * 27.2114
nKE = np.array(KE,dtype=np.float64) * 27.2114



#%%
# nB = np.array([36.88, 19.83, 15.57, 12.61])
# nKE = np.array([70.71, 48.36, 59.52, 61.91])


#%%    
a0=0.52918
R = 13.6057
n=1

u = (nKE/nB).reshape(-1,1)
norb = len(nB)

Q =1
N =2

S = (4*np.pi * np.square(a0) * N * np.square(R/nB)).reshape(-1,1)

ran = np.arange(5,2000,2)
T = np.tile(ran,(norb,1))
for i in range(0,norb):
    tmp = T[i,:]
    tmp[tmp < nB[i]] = 0
    T[i,:] = tmp

t = 1/nB.reshape(-1,1) * T 

pre = S * np.reciprocal(t+(u+1)/n)

#%%
sigma = (pre 
    * (  Q*np.log(t)/2
    * (1 - 1/ np.square(t)) 
    + (2-Q) 
    * (1-1/t - np.log(t) * np.reciprocal(t+1))
      )
        )
sigma[np.isnan(sigma)] = 0


import matplotlib.pyplot as plt
f = plt.figure()
plt.cla()
plt.plot(ran, sigma.T[:,-1],label='HOMO, D0 state')
plt.plot(ran, sigma.T[:,-2],label='HOMO-1, D1 state')
plt.plot(ran, sigma.T[:,-3],label='HOMO-2')
plt.plot(ran, sigma.T[:,-4],label='HOMO-3')
plt.axvline(x=70,linestyle='dashed',color='black',linewidth=0.8)
plt.xscale('log')
plt.legend()
plt.show()
f.savefig("sigma.pdf", bbox_inches='tight')

#%%
T = 70
t = (T/nB).reshape(-1,1)
pre = S * np.reciprocal(t+(u+1)/n)
a1 = Q*np.log(t)/2* (1 - 1/ np.square(t))

a2 = (2-Q)* (1- 1/t - np.log(t) * np.reciprocal(t+1))
    
    
sigma_T = pre*(a1 +a2)

p = sigma_T/sigma_T.sum()*100
