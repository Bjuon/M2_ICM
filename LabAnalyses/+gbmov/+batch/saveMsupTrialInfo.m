basedir = '/Volumes/Data/Human';
savedir = '/Volumes/Data/Human/STN/MATLAB2';
area = 'STN';
recording = 'Postop';
overwrite = true;

conditions = {'OFF' 'ON'};%
tasks = {'MSUP'};

% Pull clinical data
[NUM,TXT,RAW] = xlsread(fullfile(savedir,'PatientInfo.xlsx'));
labels = RAW(1,:);
RAW(1,:) = [];
n = size(RAW,1);
for i = 1:numel(labels)
   [info(1:n).(labels{i})] = deal(RAW{:,i});
end

for i = 1:numel(info)
   for j = 1:numel(tasks)
      for k = 1:numel(conditions)
         
         temp = filterFilename(fullfile(basedir,area,info(i).PATIENTID,recording));
         temp = filterFilename(temp,'protocol','','task',...
            tasks{j},'condition',conditions{k},'run','','filetype',{'.mat'});
         if isempty(temp)
            fprintf('No files matching %s %s %s\n',tasks{j},conditions{k},info(i).PATIENTID);
            continue;
         else
            files = buildFilename(temp);
            
            for f = 1:numel(files)
               trialInfo = gbmov.load.msupTrialInfo(files{f});
               [path,name,ext] = fileparts(files{f});
               savename = fullfile(path,[name '_TOPS_STRUCT' '.mat'])
               save(savename,'trialInfo');
            end
         end
      end
   end
end
