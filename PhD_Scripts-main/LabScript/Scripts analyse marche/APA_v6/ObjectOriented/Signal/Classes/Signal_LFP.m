classdef Signal_LFP < Signal
    
    %SIGNAL_LFP Class for LFP Signal
   
    %% methods
    methods
        % constructor
        function sLFP = Signal_LFP(data, fech, varargin)
            sLFP@Signal(data, fech, varargin{:})
        end
        
        % data preProcessing
        function preProcessedLFP = PreProcessingLFP(thisObj)
            temp = thisObj.MeanRemoval;
            temp = temp.BandPassFilter(1,200,4);
            preProcessedLFP = temp.NotchFilter(2,4);
            preProcessedLFP.Description = [preProcessedLFP.Description ', PreProcessed'];
        end
    end
end
