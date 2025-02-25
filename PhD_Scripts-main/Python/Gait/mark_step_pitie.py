# -*- coding: utf-8 -*-
"""
Created on Fri Feb 11 11:56:27 2022

@author: mathieu.yeche
"""

def mark_step(marker_left = 'LHEE', marker_right = 'RHEE', markerHaluxLeft = 'LHLX', markerHaluxRight = 'RHLX', plot = 0, pitie=True , frequencyDifferenceCamerasForcePlate = 5, autoAPA = True):
    """
    Mark the foot strike/contact and the foot off in the current session opened in Vicon Nexus.

    Parameters
    ----------
    marker_left : str, optional
        DESCRIPTION. The default is LHEE.
    
    marker_right : str, optional
        DESCRIPTION. The default is RHEE.
    
    plot : int, optional
        DESCRIPTION. The default is 0.
        A value fixed to 1 display a plot with the foot strike and the foot off of each side

    Returns
    -------
    None.

    """
    
    
    #Imports
     
    from viconnexusapi import ViconNexus
    from scipy.signal import find_peaks, butter, filtfilt , freqz
    import matplotlib.pyplot as plt
    import numpy as np
    from IPython import get_ipython
    import easygui
    
    
    #Input box for Turn Statistics
    #turnstat=[1500,1900] ;     print("ATTENTION FAUX TURN ; Développement uniquement")
    turnstat = easygui.multenterbox("Which is the approximate frame of : ","ICM Pitié Nexus Analysis Pipeline", ["Start Turn","End Turn"]) ; turnstat[0]=int(turnstat[0]) ; turnstat[1]=int(turnstat[1])
    
    
    
    vicon = ViconNexus.ViconNexus()
    #vicon.ClearAllEvents() ;     print("SUPPRESSION DES APAs ; Développement uniquement")
    
    #Get trajectories from Vicon into array. 0 for X, 1 for Y, 2 for Z, 3 Labelization for each frame.     
    lhee = np.asarray(vicon.GetTrajectory(vicon.GetSubjectNames()[0], 'LHEE'))[1]
    rhee = np.asarray(vicon.GetTrajectory(vicon.GetSubjectNames()[0], 'RHEE'))[1]
    lhlx = np.asarray(vicon.GetTrajectory(vicon.GetSubjectNames()[0], 'LHLX'))[2]
    rhlx = np.asarray(vicon.GetTrajectory(vicon.GetSubjectNames()[0], 'RHLX'))[2]
    
    
    
    # Peak detection
    # Halux Z prime give the best results for foot off
    # For foot stike, we use a low pass butterworth filter to get a clearer view at peaks preceding plateau in the Y axis
    lhlx_peaks, _ = find_peaks(np.diff(lhlx), prominence = 2) # Foot Off Gauche
    rhlx_peaks, _ = find_peaks(np.diff(rhlx), prominence = 2) # Foot Off Droit
    
    # Foot Strike Gauche
    data = lhee
    fs = 100.0 ; cutoff = 2.5 ; order = 6 ; nyq = 0.5 * fs ; normal_cutoff = cutoff / nyq
    filtParamB, filtParamA = butter(order, normal_cutoff, btype='low', analog=False)
    datafilt = filtfilt(filtParamB, filtParamA, data)
    lhee_peaks_inverse, _ = find_peaks(datafilt, prominence = 2) 
    lhee_peaks_inverse=lhee_peaks_inverse-10
    
    # Foot Strike Droit
    data = rhee
    fs = 100.0 ; cutoff = 2.5 ; order = 6 ; nyq = 0.5 * fs ; normal_cutoff = cutoff / nyq
    filtParamB, filtParamA = butter(order, normal_cutoff, btype='low', analog=False)
    datafilt = filtfilt(filtParamB, filtParamA, data)
    rhee_peaks_inverse, _ = find_peaks(datafilt, prominence = 2) 
    rhee_peaks_inverse=rhee_peaks_inverse-10
    
    #Deletion of events during matlab treated region of interest
    if autoAPA == False :
        frames=[]
        frames2=[]   
        frames, _ = vicon.GetEvents(vicon.GetSubjectNames()[0], 'Left', 'Foot Strike' )
        frames2, _ = vicon.GetEvents(vicon.GetSubjectNames()[0], 'Right', 'Foot Strike' )
        if frames2[0] > frames[0] :
            frames[0] = frames2[0]
        for element in lhlx_peaks :
            if element < frames[0] :
                lhlx_peaks = np.delete(lhlx_peaks, np.where(lhlx_peaks == element))
        for element in rhlx_peaks :
            if element < frames[0] :
                rhlx_peaks = np.delete(rhlx_peaks, np.where(rhlx_peaks == element))
        for element in rhee_peaks_inverse :
            if element < frames[0]+5 :
                rhee_peaks_inverse = np.delete(rhee_peaks_inverse, np.where(rhee_peaks_inverse == element))
        for element in lhee_peaks_inverse :
            if element < frames[0]+5 :
                lhee_peaks_inverse = np.delete(lhee_peaks_inverse, np.where(lhee_peaks_inverse == element))
    
    #On va maintenant eliminer les foot off surnuméraires
    if lhee_peaks_inverse[0] < rhee_peaks_inverse[0] :
        leftStart=True
    else :
        leftStart=False
    print("Inclure suppression des evenements pendant les FOG + inclure ajout des labelisation auto en s'inspirant de 'analyse marche auto.m' v")
    
    #First step, get rid of the events during the balance of the other leg
    #Left
    if leftStart==True : 
        cntL=0
        cntR=0
    else:
        cntL=0
        cntR=1
    for element in lhlx_peaks :
            if element > rhee_peaks_inverse [cntR] :
                cntR+=1
                cntL+=1
                if rhee_peaks_inverse [cntR] > turnstat[1]-((turnstat[1]-turnstat[0])/3*2) :
                    break
            if lhee_peaks_inverse[cntL] < element < rhee_peaks_inverse [cntR]  :
                lhlx_peaks = np.delete(lhlx_peaks, np.where(lhlx_peaks == element))
                
    #Right
    if leftStart==True : 
        cntL=1
        cntR=0
    else:
        cntL=0
        cntR=0
    for element in rhlx_peaks :
            if element > rhee_peaks_inverse [cntR] :
                cntR+=1
                cntL+=1
                if rhee_peaks_inverse [cntR] > turnstat[1]-((turnstat[1]-turnstat[0])/3*2) :
                    break
            if lhee_peaks_inverse[cntL] < element < rhee_peaks_inverse [cntR]  :
                lhlx_peaks = np.delete(lhlx_peaks, np.where(lhlx_peaks == element))            
          
    
    # Nettoyage des FO a proximité des FC
    for element in lhee_peaks_inverse :
        for elem2 in rhlx_peaks :
            if elem2 - 10 < element < elem2 +10 :
                lhee_peaks_inverse = np.delete(lhee_peaks_inverse, np.where(lhee_peaks_inverse == element))
    for element in rhee_peaks_inverse :
        for elem2 in lhlx_peaks :
            if elem2 - 10 < element < elem2 +10 :
                rhee_peaks_inverse = np.delete(rhee_peaks_inverse, np.where(rhee_peaks_inverse == element))
   
    
    #Second step, delete the falsely kinetic detected FO during foot strike
    cnt=0
    for element in lhee_peaks_inverse :
        cnt+=1
        if cnt<len(lhlx_peaks):
            if lhlx_peaks[cnt] <= element:
                lhlx_peaks = np.delete(lhlx_peaks,cnt)
                if cnt<len(lhlx_peaks):
                    if lhlx_peaks[cnt] < element:
                        lhlx_peaks = np.delete(lhlx_peaks,cnt)
                        if cnt<len(lhlx_peaks):
                            if lhlx_peaks[cnt] < element:
                                    lhlx_peaks = np.delete(lhlx_peaks,cnt)
        if element > turnstat[1] :
            break
        
    
    cnt=0
    for element in rhee_peaks_inverse :
        cnt+=1
        if cnt<len(rhlx_peaks):
            if rhlx_peaks[cnt] < element:
                rhlx_peaks = np.delete(rhlx_peaks,cnt)
                if cnt<len(rhlx_peaks):
                    if rhlx_peaks[cnt] < element:
                        rhlx_peaks = np.delete(rhlx_peaks,cnt)
                        if cnt<len(rhlx_peaks):
                            if rhlx_peaks[cnt] < element:
                                rhlx_peaks = np.delete(rhlx_peaks,cnt)
        if element > turnstat[1] :
            break
    
    
    # Turn delimitation
    GlobalFootStrike = np.append(rhee_peaks_inverse,lhee_peaks_inverse)
    difference_array = np.absolute(GlobalFootStrike-turnstat[0])
    index = difference_array.argmin()
    StartTurn = GlobalFootStrike[index]
    
    difference_array = np.absolute(GlobalFootStrike-turnstat[1])
    index = difference_array.argmin()
    EndTurn = GlobalFootStrike[index]
    vicon.CreateAnEvent(vicon.GetSubjectNames()[0], 'General', 'Start_Turn', int(StartTurn), 0)
    vicon.CreateAnEvent(vicon.GetSubjectNames()[0], 'General', 'End_Turn', int(EndTurn), 0) 
    
    # Return events removal
    i=0
    while i < len(lhee_peaks_inverse) :
        if lhee_peaks_inverse[i] > StartTurn :
            lhee_peaks_inverse = np.delete(lhee_peaks_inverse,i)
        else :
            i+=1
    
    i=0
    while i < len(rhee_peaks_inverse) :
        if rhee_peaks_inverse[i] > StartTurn :
            rhee_peaks_inverse = np.delete(rhee_peaks_inverse,i)
        else :
            i+=1
    
    leftTurn = StartTurn in lhee_peaks_inverse
    
    i=0
    i2=0
    while i < len(lhlx_peaks) :
        if leftTurn == False :
            difference_array = np.absolute(lhlx_peaks-StartTurn)
            index = difference_array.argmin()
            temp=lhlx_peaks[index]
            while i2 < len(lhlx_peaks) :
                if temp < lhlx_peaks[i2] :
                    lhlx_peaks = np.delete(lhlx_peaks,i2)
                else :
                    i2+=1
            i=9999
        else :     
            if lhlx_peaks[i] > StartTurn :
                lhlx_peaks = np.delete(lhlx_peaks,i)
            else :
                i+=1
    
    i=0
    i2=0
    while i < len(rhlx_peaks) :
        if leftTurn == True :
            difference_array = np.absolute(rhlx_peaks-StartTurn)
            index = difference_array.argmin()
            temp=rhlx_peaks[index]
            while i2 < len(rhlx_peaks) :
                if temp < rhlx_peaks[i2] :
                    rhlx_peaks = np.delete(rhlx_peaks,i2)
                else :
                    i2+=1
            i=9999
        else :     
            if rhlx_peaks[i] > StartTurn :
                rhlx_peaks = np.delete(rhlx_peaks,i)
            else :
                i+=1
    
    #Nettoyage final :
    flagAntiMoreDataTempsDoubleAppui = False
    if flagAntiMoreDataTempsDoubleAppui == True : 
        if lhlx_peaks[-1] > StartTurn :
            lhlx_peaks = np.delete(lhlx_peaks,-1)
        if rhlx_peaks[-1] > StartTurn :
            rhlx_peaks = np.delete(rhlx_peaks,-1)
    
    
    # Auto APA computing
    if autoAPA == True:
        deviceIDs = vicon.GetDeviceIDs();
        _,_,_,outputIDs,_,_ = vicon.GetDeviceDetails(deviceIDs[0]);
        _,_,_,_,_,channelIDs = vicon.GetDeviceOutputDetails(deviceIDs[0],outputIDs[2]);
        data, ready, rate = vicon.GetDeviceChannel(deviceIDs[0],outputIDs[0],channelIDs[0]);
        
        fs = 100.0 ; cutoff = 2 ; order = 6 ; nyq = 0.5 * fs ; normal_cutoff = cutoff / nyq
        filtParamB, filtParamA = butter(order, normal_cutoff, btype='low', analog=False)
        dataAPA = filtfilt(filtParamB, filtParamA, data)
        
        dataAPA = np.asarray(dataAPA)
        if leftStart == True :
            dataAPA=dataAPA*-1
            
        firstMove, _ = find_peaks(dataAPA, prominence = 25) 
        allMoveDownwards, _ = find_peaks(dataAPA*-1, prominence = 0.5) 
        for i in range (len(allMoveDownwards)) : 
            if allMoveDownwards[i]>firstMove[0] :
                startAPA = allMoveDownwards[i-1]/frequencyDifferenceCamerasForcePlate
                break
        vicon.CreateAnEvent(vicon.GetSubjectNames()[0], 'General', 'Start_APA', int(startAPA), 0)
            
      
    # Event cration in Vicon
    [vicon.CreateAnEvent(vicon.GetSubjectNames()[0], 'Left', 'Foot Off', int(i), 0) for i in lhlx_peaks]
    [vicon.CreateAnEvent(vicon.GetSubjectNames()[0], 'Right', 'Foot Off', int(i), 0) for i in rhlx_peaks]
    [vicon.CreateAnEvent(vicon.GetSubjectNames()[0], 'Left', 'Foot Strike', int(i), 0) for i in lhee_peaks_inverse]
    [vicon.CreateAnEvent(vicon.GetSubjectNames()[0], 'Right', 'Foot Strike', int(i), 0) for i in rhee_peaks_inverse]
    
    #plt.figure() ;     plt.plot(np.diff(rhlx)) ;    plt.show()
    
    # End message & Autosave option
    nbrCycles = -2+len(lhee_peaks_inverse)+len(rhee_peaks_inverse)
    reply = easygui.buttonbox("Automatic placement successfully place "+str(nbrCycles)+" cycles, please check the placement on Vicon","ICM Pitié Nexus Analysis Pipeline", choices=["I'm going to check on Vicon now","Save & Export in C3D anyways"])
    if reply == "Save & Export in C3D anyways" :
        vicon.SaveTrial
        vicon.RunPipeline( 'C3D', '', 5 )
    
    #Control plotting 
    if plot == 1:
        lhlx = np.diff(lhlx)
        rhlx = np.diff(rhlx)
        get_ipython().run_line_magic('matplotlib', 'qt')
        fig, axes = plt.subplots(2, 2, figsize=(8, 8), sharex=True)
        axes[0,0].plot(lhlx, color='lightcoral')
        axes[0,0].plot(lhlx_peaks, lhlx[lhlx_peaks], "x", color='maroon')
        axes[0,0].title.set_text('Foot Off - Gauche')
        
        axes[1,0].plot(lhee, color='lightcoral')
        axes[1,0].plot(lhee_peaks_inverse, lhee[lhee_peaks_inverse], "x", color='maroon')
        axes[1,0].title.set_text('Foot Strike - Gauche')
        
        axes[0,1].plot(rhlx, color='palegreen')
        axes[0,1].plot(rhl31740x_peaks, rhlx[rhlx_peaks], "x", color='darkgreen')
        axes[0,1].title.set_text('Foot Off - Droit')
        
        axes[1,1].plot(rhee, color='palegreen')
        axes[1,1].plot(rhee_peaks_inverse, rhee[rhee_peaks_inverse], "x", color='darkgreen')
        axes[1,1].title.set_text('Foot Strike - Droit')
        fig.savefig('img.svg')

mark_step(plot =0, autoAPA = True)


