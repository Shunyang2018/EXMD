#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Aug  6 16:28:40 2021

@author: shunyang
"""
import os

def convert(tmp):
    try:
        tmp = float(tmp)/1.89 # convert to Angstrom
    except:
        pass
    return str(tmp)


def readl(txt):
    tmp = txt.split()
    tmp = list(map(convert,tmp))
    return symbol[tmp[3]] + '   '  + tmp[0] + '   '+ tmp[1] + '   '+ tmp[2]

txt = ' $CONTRL SCFTYP=RHF MULT=1 RUNTYP=ENERGY NPRINT=1 $END\n\
 $SYSTEM TIMLIM=1 $END\n\
 $SCF NPUNCH=1 NPREO(1)=0,-1,1,9999 VTSCAL=.TRUE. $END\n\
 $BASIS  GBASIS=N311 NGAUSS=6 $END\n\
 $GUESS  GUESS=HUCKEL $END\n\
 $DATA\n\
MOeneergy...3-B-1 state...RHF/6-311G\n\
C1\n'
symbol = {'c':'C  6',
          'o':'O  8',
          'h':'H  1',
          'n':'N  7'} 

path = '/Users/shunyang/project/xcited-state/recalculate/input/'
os.chdir(path)
files= os.listdir(path)
 

for tmol in files:

    try:
        index = tmol.split('.')[0].split('/')[-1]
        
        with open(tmol,'r') as f:
            tmp = f.readlines()[1:-1]
            f.close()
    
        
        result = list(map(readl, tmp))
        
        out = '/Users/shunyang/project/xcited-state/recalculate/inp/'+ index + '.inp'
        
    
        with open(out, 'w') as f:
            f.writelines(txt)
            for i in result:
                f.writelines(i+'\n')
            f.writelines(' $END\n! TRAVIS-CI SKIP\n\n')
            f.close
    except KeyError as e:
        print('Keyerror:',tmol,e)