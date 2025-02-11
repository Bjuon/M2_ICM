function step3_R(csvFile, data, e, protocol)

lfp = VG.batch.matrixForR_optim(data, e, 'LFP', protocol);
export(cell2dataset(lfp),'File',csvFile);
clear lfp

% 
% %set working directory
% % cd(['D:/13_GAITPARK/Dropbox Antoine/TRAITEMENT/02_electrophysiologie/POSTOP/R/']);
% % cd(['D:/13_GAITPARK/MarcheVirtuelle/04_traitement/02_CSV/']);
% cd('F:\DBStmp_Matthieu\data\analyses\CHd_0343\PPNPitie_2016_11_17_CHd\POSTOP')
% 
% if norm == 1
%     
%     lfp = matrixForR_optim(data, e, 'LFP');
%     export(cell2dataset(lfp),'File',[protocol '_POSTOP_' subject '_MARCHEVIRTUELLE_TF_NOR_' e{1} '.csv']);
%     clear lfp
%     
% else
%     
%     lfp = matrixForR_optim(data, e, 'LFP');
%     export(cell2dataset(lfp),'File',[protocol '_POSTOP_' subject '_MARCHEVIRTUELLE_TF_RAW_' e{1} '.csv']);
%     clear lfp
%     
% end

end
