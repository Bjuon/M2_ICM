function out = getBasicScores4(psd,dB)
keep = {'PSD' 'SIG' 'CONDITION' 'CHANNEL' 'SIDE' 'DIPOLE' 'locML' 'locAP' 'locDV'...
   'PATIENTID' 'PROTOCOL' ...
   'UPDRSIV' ...
   'UPDRSIII_OFF_CONTRA' 'UPDRSIII_ON_CONTRA' ...
   'BRADYKINESIA_OFF_CONTRA' 'BRADYKINESIA_ON_CONTRA' ...
   'RIGIDITY_OFF_CONTRA' 'RIGIDITY_ON_CONTRA' ...
   'TREMOR_OFF_CONTRA' 'TREMOR_ON_CONTRA' ...
   'AXIAL_OFF' 'AXIAL_ON'};

% keep = {'PSD' 'SIG' 'CONDITION' 'CHANNEL' 'SIDE' 'DIPOLE' 'locML' 'locAP' 'locDV'...
%    'PATIENTID' 'PROTOCOL' ...
%    'UPDRSIII_OFF_CONTRA' 'UPDRSIII_ON_CONTRA' ...
%    'BRADYKINESIA_OFF_CONTRA' 'BRADYKINESIA_ON_CONTRA' ...
%    'RIGIDITY_OFF_CONTRA' 'RIGIDITY_ON_CONTRA' ...
%    'TREMOR_OFF_CONTRA' 'TREMOR_ON_CONTRA' ...
%    'AXIAL_OFF' 'AXIAL_ON'};

conditionMatch = {'UPDRSIII' 'BRADYKINESIA' 'RIGIDITY' 'BR' 'TREMOR' 'AXIAL' 'UPDRSIII_STIM'};

%%% MISSING HEMIBODY FOR UPDRSIII_STIM
conditionSideMatch = {'UPDRSIII' 'BRADYKINESIA' 'RIGIDITY' 'BR' 'TREMOR'};

%% Get paths to data & load clinical data
[datadir,infodir,savedir] = gbmov.getPaths();
conditions = {'OFF' 'ON'};
tasks = {'BASELINEASSIS'};
info = gbmov.PatientInfo('path',infodir);

%%
% exclude = [49 51];
normalize = struct('fmin',4,'fmax',100,'method','integral');
%dB = false;
%psd = 'detail';
coordinate = 'STN';

count = 1;
for i = 1:info.n
   id = info.clinicInfo(i).PATIENTID;
   if isnan(id)
      continue;
   end
   for j = 1:numel(tasks)
      for k = 1:numel(conditions)
         fprintf('Trying %s for %s in %s\n',tasks{j},id,conditions{k});
         d = dir([datadir '/' id '*' tasks{j} '*' conditions{k} '*.mat']);
         if (numel(d) == 1)
            temp = load(fullfile(datadir,d.name));
            labels = temp.PSD.labels_;
            
            out(count).id = id;
            out(count).cond = conditions{k};
            out(count).labels = labels;
            out(count).mask = temp.PSD.mask_;
            count = count + 1;
         else
            disp(['    no PSD data ' id]);
         end
      end
   end
end
