basedir = '/Volumes/Data/Human';
%infodir = '/Volumes/Data/Human/STN';
savedir = '/Volumes/Data/Human/STN/TEST2';

[~,infodir] = gbmov.getPaths();
area = 'STN';
recording = 'Postop';
overwrite = false;

% conditions = {'OFF' 'ON' 'PRISEDOPA'};%{'OFF' 'ON' 'PRISEDOPA'}
% tasks = {'BASELINEASSIS' 'BASELINEDEBOUT'};%{'BASELINEASSIS' 'BASELINEDEBOUT' 'MSUP' 'REACH'};
conditions = {'OFF' 'ON'};%{'OFF' 'ON' 'PRISEDOPA'}
tasks = {'BASELINEASSIS'};%{'BASELINEASSIS' 'BASELINEDEBOUT' 'MSUP' 'REACH'};

% Pull clinical data
[NUM,TXT,RAW] = xlsread(fullfile(infodir,'PatientInfo.xlsx'));
labels = RAW(1,:);
RAW(1,:) = [];
n = size(RAW,1);
for i = 1:numel(labels)
   [info(1:n).(labels{i})] = deal(RAW{:,i});
end

for i = 1:numel(info)
   for j = 1:numel(tasks)
      for k = 1:numel(conditions)
         temp = info(i);
         temp = rmfield(temp,'DELINE');
         
         gbmov.preprocess(...
            'patient',info(i).PATIENTID,...
            'basedir',basedir,...
            'savedir',savedir,...
            'area',area,...
            'recording',recording,...
            'condition',conditions{k},...
            'task',tasks{j},...
            'deline',false,...%logical(info(i).DELINE),...
            'Fpass',1,...
            'resample',0,...
            'trim',0,...
            'overwrite',overwrite,...
            'data',temp,...
            'dataName','clinic'...
            );
      end
   end
end
% 
% cd(savedir);
% d2 = dir('*.mat');
% name = {d2.name};
% for i = 1:numel(name)
%    try
%       s = load(['/Volumes/Data/Human/STN/TEST/' name{i}]);
%       t = load(fullfile(savedir,name{i}));
%       if isfield(s,'artifacts')
%          if all([s.data.tEnd] == [t.data.tEnd])
%             % match labels of artifacts (handles)
%             artifacts = matchLabels(t.data,s.artifacts);
%             % assign quality
%             data = t.data;
%             for j = 1:numel(data)
%               data(j).quality = s.data(j).quality;
%             end
%             save(fullfile(savedir,name{i}),'data','artifacts');
%             disp([name{i} '-ok']);
%          else
%             error('mismatched times');
%          end
%       else
%          disp([d(i).name '-clean']);
%       end
%    catch
%       if exist('s','var')
%          fprintf([name{i} ' no artifacts\n']);
%       else
%          fprintf([name{i} ' not found\n']);
%       end
%    end
%    clear s t data artifacts;
% end
