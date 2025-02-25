classdef Signal_EMG < Signal
    
    %SIGNAL Summary of this class goes here
    %
    %Data = data of the signal (m channels x n samples : double)
    %Fech = Sampling frequency (1 x 1 : double)
    %Tag = names of the m channels : (m x 1 : string);
    %trial_name = name of the source file (1 x 1 : string);
    %trial_num = number of the trial in a list of trials (1 x 1 : double);
    %Description = description of the signal (1 x 1 string);
    %Time = time vector (1 x n samples : double);
    
    % Modifié en nov 15 pour avoir même procédure que Solnik et al. 2010 (Eur J Appl Physiol)
   
    methods
        
        function sEMG = Signal_EMG(data, fech, varargin)
            sEMG@Signal(data, fech, varargin{:})
        end
        
        function newSignal = TKEOprocess(thisSignal)
            newSignal = thisSignal.BandPassFilter(30,300,6); % (LowFreq, HighFreq, Order)
            newSignal = newSignal.TKEO;
            newSignal.Data = abs(newSignal.Data);
            newSignal = newSignal.LowPassFilter(50,2);
            newSignal.TrialName = newSignal.TrialName;
            newSignal.TrialNum = newSignal.TrialNum;
            newSignal.Description = {'TKEO processing'};
        end
    end
end
