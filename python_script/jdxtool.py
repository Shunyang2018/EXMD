#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Oct  2 19:48:37 2020

@author: shunyang
"""
import pandas as pd
import numpy as np
import os
import sys

debug = False

def cos_sim(a, b):
    '''
    calculate cosine similarity of two vetcors
    Input
        a: np.array
        b: np.array
    Output
        res: float

    '''
    dot_product = np.dot(a, b)
    norm_a = np.linalg.norm(a)
    norm_b = np.linalg.norm(b)
    res = dot_product / (norm_a * norm_b)
    return res *1000


def dot_sim(x,y):
    '''
    calculate dot product of two mass spectrums
    Input
        a: np.array
        b: np.array
    Output
        dot: float normalized in 1000
    '''
    m=0.5
    n=3
    #mast use different parameters!!!otherwise you will destory the initial array!!!!!!
    a = np.copy(x)
    b = np.copy(y)
    for i in range(0, len(a)-1):
        a[i] = (i**n)*(a[i]**m)
    for i in range(0, len(b)-1):
        b[i] = i**n*(b[i]**m)
    dot = np.dot(a, b)/(np.linalg.norm(a)*np.linalg.norm(b))*1000
    return dot

def readspec(x):

    np.putmask(x, x >= 0.01, 1)
    np.putmask(x, x < 0.01, 0)
    #!!!!watch out here, you will change the original x array!!!!
    return x

def peak(x,y):
    '''
    Parameters
    ----------
    x : ARRAY
        computational results.
    y : ARRAy
        experimental results.

    Returns
    -------
    confusion_matrix

    '''
    x = readspec(x)
    x = np.copy(2 * x)
    y = readspec(y)

    tmp = x-y
    if debug == True:
        print('x',x)
        print('y',y)
        print('tmp',tmp)
    FP = np.count_nonzero(tmp == 2)# only in computational FalsePositive
    TP = np.count_nonzero(tmp == 1)# both have TruePositive
    FN = np.count_nonzero(tmp == -1)#only in experimental FalseNegative
    TN = np.count_nonzero(tmp == 0)# No peak TrueNegative

    return np.array([[TP, FP, FN, TN]])



def match(x, y):
    '''
    NIST match scores
    '''
    dot = dot_sim(x,y)
    N_y = np.count_nonzero(y)
    N = 0
    SUM = 0
    a = []
    b = []
    for i in range(1, len(y)):
        if (x[i] != 0) & (y[i] != 0):
            N += 1
            a.append(x[i])#a is lib, while b is unknown
            b.append(y[i])
    for j in range(1, N):
        temp = a[j]*b[j-1]/(a[j-1]*b[j])
        if temp > 1:
            temp = 1/temp
        SUM += temp

    return (N_y*dot + SUM*1000)/(N_y + N)



def readjdx(filename):
    '''
    read and clean computational mass spectrum result jdx file
    Input
        filename: str, name and path of the jdx file
    Output
        x: normalized mass spectrum
    '''
    df = pd.read_csv(filename, header=6)

    df['Mass'],df['intensity']= df.iloc[:-1,0].str.split().str
    df = df.drop(columns='##PEAK TABLE=(XY..XY) 1').drop(df.tail(1).index)
    #get mass and intensity
    mass = df.values[:,0].astype(float).astype(np.int32)
    intensity = df.values[:,1].astype(np.int32)
    #generate computational spec
    x=np.zeros([699,])# mass from 0 to 699
    for i in range(0,len(mass)-1):
        x[mass[i]] = intensity[i]
    print('max',np.amax(x))
    x = x/np.amax(x)
    if debug:
        print('x norm', x)
    return x
    # another way to drop last column
    #df = df.drop(df.columns[len(df.columns)-1],axis = 1)
def readdatabase(database):
    '''
    read database of experimental mass spectrum
    Input
        filename: str, name and path of the jdx file
    Output
        dataframe
    '''

    df = pd.read_csv(database)#mast have[0],to remove OrderedDict in header
    return df






def trans(y):
    y_out = []
    for i in range(1, len(y)):
        if y[i] !=0:
            y_out.append([i,y[i]])
    y_out = np.array(y_out)
    return  y_out

