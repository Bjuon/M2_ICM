function master_analaysis
    import spk.*
    
    %creates a point process with infos
    %generates plot of the average spkwf, the isi distribution, instantaneous rate.
    plx.batch_spikeana1_Stacie;
    
    
    %calls the fonction burst, regularity and detectPause located in
    %LabTools/subtrees/matutils/spk
    plx.batch_spikeana2_Stacie;

 
    %%creates an array of:
    % 1)patient name        2)pathology         3)side
    % BURST
    % 4)burst rate          5)Burst index       6)firing rate      7) spikes in bursts
    % PAUSE
    % 8)number of pauses    9)pause duration    10)pause rate        
    % REGULARITY
    % 11)cv value           12)lvr value        13)cv2              14)lv
    array = stc.array_all;

    %converts array from function array_all into text file to read with R:
    stc.textfile_all(array);
    

end
