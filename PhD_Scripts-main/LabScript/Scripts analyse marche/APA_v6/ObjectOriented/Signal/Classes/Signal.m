classdef Signal
    
    %SIGNAL Class for signal bojects
    %
    %Data = data of the signal (m channels x n samples : double)
    %Fech = Sampling frequency (1 x 1 : double)
    %Tag = names of the m channels : (m x 1 : string);
    %TrialName = name of the source file (1 x 1 : string);
    %TrialNum = number of the trial in a list of trials (1 x 1 : double);
    %Description = description of the signal (1 x 1 string);
    %Time = time vector (1 x n samples : double);
    
    %% properties
    properties
        Fech = [];
        Data = [];
        Tag = {''};
        Units = {''};
        Time = [];
        TrialName = '';
        TrialNum = [];
        Description = '';
    end
    
    %% methods
    methods
        
        % constructor
        function thisObj = Signal(data, fech, varargin)
            % varargin format : (...,'PropertyName', 'PropertyValue',...)
            thisObj.Fech = fech;
            thisObj.Data = data;
            thisObj.Time = (1:size(data,2))/fech;
            if nargin >= 3 && ~isempty(varargin)
                if mod(length(varargin),2)==0
                    for i_argin = 1 : 2 : length(varargin)
                        switch lower(varargin{i_argin})
                            case 'tag'
                                thisObj.Tag = varargin{i_argin + 1};
                            case 'units'
                                thisObj.Units = varargin{i_argin + 1};
                            case 'trialname'
                                thisObj.TrialName = varargin{i_argin + 1};
                            case 'trialnum'
                                thisObj.TrialNum = varargin{i_argin + 1};
                            case 'description'
                                thisObj.Description = varargin{i_argin + 1};
                            case 'time'
                                thisObj.Time = varargin{i_argin + 1};
                            otherwise
                                error(['Propriete ' varargin{i_argin} 'inexistante dans la classe'])
                        end
                    end
                else
                    error('Nombre impair d''arguments supplementaires')
                end
            end
        end 
        % low-pass filtering
        function lpFilteredSignal = LowPassFilter(thisObj, cutoff, order)
            lpFilteredSignal = thisObj;
            for j = 1 : size(thisObj.Data,1)
                x = thisObj.Data(j,:);
                [b,a] = butter(order,(cutoff/(thisObj.Fech/2)),'low');
                x(isnan(x))=0;
                x =  filtfilt (b,a,x);
                lpFilteredSignal.Data(j,:) = x;
            end
        end
        % high-pass filtering
        function hpFilteredSignal = HighPassFilter(thisObj, cutoff, order)
            hpFilteredSignal = thisObj;
            for j = 1 : size(thisObj.Data,1)
                x = thisObj.Data(j,:);
                [b,a] = butter(order,(cutoff/(thisObj.Fech/2)),'high');
                x(isnan(x))=0;
                x =  filtfilt (b,a,x);
                hpFilteredSignal.Data(j,:) = x;
            end
        end
        % notch filtering (50Hz)
        function notchedSignal = NotchFilter(thisObj, width, order, Freq)
            notchedSignal = thisObj;
            for j = 1 : size(thisObj.Data,1)
                x = thisObj.Data(j,:);
                [b,a] = butter(order,([Freq-width/2 Freq+width/2]/(thisObj.Fech/2)),'stop');
                x(isnan(x))=0;
                x =  filtfilt (b,a,x);
                notchedSignal.Data(j,:) = x;
            end
        end
        % band-pass filtering
        function bpFilteredSignal = BandPassFilter(thisObj, cutoffLow, cutoffHigh, order)
            bpFilteredSignal = thisObj;
            for j = 1 : size(thisObj.Data,1)
                x = thisObj.Data(j,:);
                [b,a] = butter(order,([cutoffLow cutoffHigh]/(thisObj.Fech/2)),'bandpass');
                x(isnan(x))=0;
                x =  filtfilt (b,a,x);
                bpFilteredSignal.Data(j,:) = x;
            end
        end
        % mean removal
        function zeroMeanSignal = MeanRemoval(thisObj)
            zeroMeanSignal = thisObj;
            zeroMeanSignal.Data = thisObj.Data - nanmean(thisObj.Data,2)*ones(1,length(thisObj.Data));
        end
        % TKEO
        function TKEOSignal = TKEO(thisObj)
            TKEOSignal = thisObj;
            TKEOSignal.Data(:,2:end-1) = thisObj.Data(:,2:end-1).^2 - thisObj.Data(:,1:end-2).*thisObj.Data(:,3:end);
            TKEOSignal.Data(:,1) = NaN;
            TKEOSignal.Data(:,end) = NaN;
        end
        % detrending signals (Tarvainen et al, 2002)
        function DetrendSignal = Detrending(thisObj)
            DetrendSignal = thisObj;
            T = size(thisObj.Data,2);
            lambda = 10;
            I = speye(T);
            D2 = spdiags(ones(T-2,1)*[1 -2 1],0:2,T-2,T);
            for j = 1 : size(thisObj.Data,1)
                DetrendSignal.Data(j,:) = thisObj.Data(j,:)*(I - inv(I+lambda^2*(D2'*D2)))';
            end
        end
        % plot signals
        function plot(thisObj)
            figure;
            plot(thisObj.Data');
        end
    end
end