function [StartTime, FIXtime, CUEtime] = GetCueFixTime(h)

    % Load
    frameAna = btkGetAnalogFrequency(h);
    [analogs, ~] = btkGetAnalogs(h) ;

    % Get analog trigger
    if isfield(analogs,'Voltage_Trigger')
        voltTrigger= btkGetAnalog(h, 'Voltage.Trigger');
    elseif isfield(analogs,'Voltage_GO')
        voltTrigger= btkGetAnalog(h, 'Voltage.GO');
    elseif isfield(analogs,'GO')
        voltTrigger= btkGetAnalog(h, 'GO');
    else
        voltTrigger = zeros(3.7 * frameAna,1) ;
        disp('No voltTrigger')
    end

    % Detect peaks
    peakVoltTrig = {};
    voltTrigger = normalize(voltTrigger,'range') ;
    for i = 1:length(voltTrigger)
        if voltTrigger(i) > 0.7
            voltTrigger(i) = 1 ;
        else
            voltTrigger(i) = 0 ;
        end
    end
    i=1 ;
    MaxTrigCheck = min(3.7 * frameAna, length(voltTrigger)) ;
    while i < MaxTrigCheck
        i=i+1 ;
        if voltTrigger(i) ~= voltTrigger(i-1)
            peakVoltTrig{end+1}=i/frameAna;                                 %#ok<AGROW> 
        end
    end

    % Allocate values
    if length(peakVoltTrig) > 2
        CUEtime = peakVoltTrig{end-1};
        if length(peakVoltTrig) == 3
            FIXtime = peakVoltTrig{end-2} - 0.205;
        else
            FIXtime = peakVoltTrig{end-3} ;
        end
        if length(peakVoltTrig) == 6
            StartTime = peakVoltTrig{1};
        elseif length(peakVoltTrig) == 5
            StartTime = peakVoltTrig{1} - 0.205;
        else
            StartTime = NaN;
        end
    else
        StartTime = NaN;
        FIXtime   = NaN;
        CUEtime   = NaN;
    end


end

