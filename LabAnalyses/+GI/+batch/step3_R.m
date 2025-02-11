function step3_R(csvFile, data, e, protocol, art_temp, type)

global segType
switch segType
    case 'step'
      lfp = GI.batch.matrixForR_optim(data, e, type, protocol, art_temp);
    case 'trial'
        if strcmp(type,'CO')
            lfp = GI.batch.matrixForR_optim(data, e, type, protocol, art_temp);
        else
            lfp = GI.batch.matrixForR_optim_trial(data, e, protocol);
        end
end

export(cell2dataset(lfp),'File',csvFile);
% change csv file name in cas of norm = 4

clear lfp

