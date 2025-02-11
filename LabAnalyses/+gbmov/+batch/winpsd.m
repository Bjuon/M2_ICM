basedir = '/Volumes/Data/Human/STN/TEST2';
%infodir = '/Volumes/Data/Human/STN';
savedir = '/Volumes/Data/Human/STN/TEST2';

[~,infodir] = gbmov.getPaths();

overwrite = false;
conditions = {'OFF' 'ON'};%{'PRISEDOPA'};%
tasks = {'BASELINEASSIS'};%{'BASELINEASSIS' 'BASELINEDEBOUT' 'MSUP' 'REACH'};
%tasks = {'MSUP' 'REACH'};

f = [0:.25:250]';

[NUM,TXT,RAW] = xlsread(fullfile(infodir,'PatientInfo.xlsx'));
labels = RAW(1,:);
RAW(1,:) = [];
n = size(RAW,1);
for i = 1:numel(labels)
   [info(1:n).(labels{i})] = deal(RAW{:,i});
end

%% Calculate spectra
for i = 1:numel(info)
   i
   for j = 1:numel(tasks)
      for k = 1:numel(conditions)
         temp = info(i);
         temp = rmfield(temp,'DELINE');

         gbmov.winpsd('patient',info(i).PATIENTID,'basedir',basedir,'savedir',savedir,...
            'condition',conditions{k},'task',tasks{j},...
            'f',f,'overwrite',overwrite,'data',temp,'dataName','clinic');
      end
      gbmov.plot.winpsd('patient',info(i).PATIENTID,'basedir',basedir,'savedir',savedir,...
         'ylim',[-2 25],'saveplot',true,...
         'task',tasks{j},'overwrite',overwrite);
   end
end
