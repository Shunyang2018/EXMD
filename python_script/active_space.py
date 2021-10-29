#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Aug 10 11:44:34 2021

@author: shunyang
"""

import os
from rdkit import Chem
path = '/Users/shunyang/project/xcited-state/recalculate/input/input.smi'

with open(path,'r') as f:
    smi = f.readlines()
    f.close()
n=1  
for i in smi:
    unocc = i.count('=')
    occupied = unocc + i.count('O') + i.count('N')
    name = '/Users/shunyang/project/xcited-state/recalculate/mndo/' + str(n) + '.opt'
    with open(name, 'w') as f:
        f.write('iroot=2 icross=1 ioutci=1 kci=5 ncigrd=1 +\n')
        f.write('movo=-4 ici1='+ str(occupied)+' ici2='+ str(unocc)+' nciref=1 +\n')
        f.write('mciref=0 levexc=2 +\n')
        f.write('nsav15=3 idiis=10 jop=-2 ipubo=1 nprint=-1 iscf=5 kitscf=200 iplscf=5 iop=-6 +\n')
        f.write('ifast=2 igeom=1 ktrial=11 kharge=1 iform=1 imult=2 ifermi=21000\n')
        f.close()
        
    n += 1
#%%

un = []
oc = []
n = []
m = 1
for i in smi:
    print(i)
    unocc = i.count('=')
    occupied = unocc + i.count('O') + i.count('N')
    name =  str(m) 
    un.append(unocc)
    oc.append(occupied)
    n.append(name)
        
    m += 1
import pandas as pd 

df = pd.DataFrame({'un':un,
                   'occ':oc,
                   'name':n})
df.to_csv('/Users/shunyang/project/xcited-state/recalculate/active.csv')