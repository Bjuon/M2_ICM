function [output] = read_c3d(c3d_path, subject, RecID, TrialNum, CondMed, wanted_part_of_c3d)
    %READ_C3D and return EMG
    

    %load BTK once before using this func
    
    % Convert TrialNum to str
    TrialNumStr = num2str(TrialNum) ;
    while length(TrialNumStr) < 3
        TrialNumStr = ['0' TrialNumStr] ;                                     %#ok<AGROW> 
    end

    % find filename
    if strcmp(subject{1}, 'BAg_0496') 
        filename = ['GOGAIT_POSTOP_BARGU14_' CondMed '_GNG_' TrialNumStr(2:3) '.c3d' ]; 
        SubVicon =  'BARGU14' ;
    elseif strcmp(subject{1}, 'DEj_000a') 
        filename = ['GOGAIT_POSTOP_DESJO20_' CondMed '_GNG_' TrialNumStr(2:3) '.c3d' ]; 
        SubVicon =  'DESJO20' ;
    elseif strcmp(subject{1}, 'DRc_000a') && strcmp(CondMed, 'OFF') 
        filename = ['GAITPARK_POSTOP_DROCA16_' CondMed '_GNG_' TrialNumStr(2:3) '.c3d' ];  
        SubVicon =  'DROCA16' ;
    elseif strcmp(subject{1}, 'DRc_000a') 
        filename = ['GOGAIT_POSTOP_DROCA16_' CondMed '_GNG_' TrialNumStr(2:3) '.c3d' ];  
        SubVicon =  'DROCA16' ;
    elseif contains('COm_000a LOp_000a GIs_0550 BEm_000a REa_0526', subject{1})
        SubVicon =  subject{1}(1:3) ;
        filename = [ RecID '_GBMOV_POSTOP_' CondMed '_GNG_GAIT_' TrialNumStr(2:3) '.c3d' ]; 
    else 
        SubVicon =  subject{1}(1:3) ;
        filename = [ RecID '_MAGIC_POSTOP_' CondMed '_GNG_GAIT_' TrialNumStr(2:3) '.c3d' ];
    end

    %load trial
    h = btkReadAcquisition([c3d_path 'POSTOP' filesep SubVicon filesep filename]);

if contains(wanted_part_of_c3d,"EMG")
%   frameAna = btkGetAnalogFrequency(h);
%   [analogs, ~] = btkGetAnalogs(h) ;
    if strcmp(SubVicon, 'GUG')
        EMG      = btkGetAnalog(h, 'Voltage.EMG 1'); % RTA
        EMG(:,2) = btkGetAnalog(h, 'Voltage.EMG 2'); % RSOL
        EMG(:,3) = btkGetAnalog(h, 'Voltage.EMG 3'); % RVAS
        EMG(:,4) = btkGetAnalog(h, 'Voltage.EMG 4'); % LTA
        EMG(:,5) = btkGetAnalog(h, 'Voltage.EMG 5'); % LSOL
        EMG(:,6) = btkGetAnalog(h, 'Voltage.EMG 6'); % LVAS
    else
        EMG      = btkGetAnalog(h, 'Voltage.RTA');
        EMG(:,2) = btkGetAnalog(h, 'Voltage.RSOL');
        EMG(:,3) = btkGetAnalog(h, 'Voltage.RVAS');
        EMG(:,4) = btkGetAnalog(h, 'Voltage.LTA');
        EMG(:,5) = btkGetAnalog(h, 'Voltage.LSOL');
        EMG(:,6) = btkGetAnalog(h, 'Voltage.LVAS');
    end
    output.EMG = EMG ;
end

output.Ev = btkGetEvents(h) ;

