function step3_R(csvFile, data, e, protocol, art_temp, type, Size_around_event, Acceptable_Artefacted_Sample_In_Window, todoParquet)

global segType

switch segType
    case 'step'
      MAGIC.batch.matrixForR_optim(csvFile, data, e, type, protocol, art_temp, Size_around_event, Acceptable_Artefacted_Sample_In_Window, todoParquet);
    case 'trial'
      lfp = MAGIC.batch.matrixForR_optim_trial(data, e, protocol);
end

%% Export maintenant direct dans matrixForR_optim (step)

% Ancienne Methode d export
% warning('off','stats:dataset:ModifiedVarnames')
% export(cell2dataset(lfp),'File',csvFile);
% warning('on','stats:dataset:ModifiedVarnames')

                    %  WORK IN PROGRESS
                    % Nouvelle Methode
                    %writecell(lfp,csvFile,'Delimiter','tab') ;
                    % change csv file name in cas of norm = 4
                    
                    %save([csvFile(1 : end-4) '_export.mat'],"lfp") 
                    % fprintf(2, 'modifier le .mat de sortie pour qu il ressemble au .csv original  \n' )
                    % fprintf(2, 'pas d export step 3  \n' )

clear lfp

