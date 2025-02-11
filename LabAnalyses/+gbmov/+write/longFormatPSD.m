%function out = getBasicScores(condition)

% Variables we don't want to keep
remove = {'PATIENTID2' 'DELINE' 'C0D' 'C1D' 'C2D' 'C3D' ...
   'C0G' 'C1G' 'C2G' 'C3G'};

conditionMatch = {'UPDRSIII' 'BRADYKINESIA' 'RIGIDITY' 'BR' 'TREMOR' 'AXIAL' 'UPDRSIII_STIM'};

conditionSideMatch = {'UPDRSIII' 'BRADYKINESIA' 'RIGIDITY' 'BR' 'TREMOR'};

%% Get paths to data & load clinical data
[datadir,infodir,savedir] = gbmov.getPaths();
conditions = {'OFF' 'ON'};
tasks = {'BASELINEASSIS'};
info = gbmov.PatientInfo('path',infodir);

%%
f = 1:.01:100; % Frequency range desired
exclude = [49 51];
dwnsmpl = 5;
normalize = [];%struct('fmin',5,'fmax',45,'method','integral');
dB = false;
psd = 'detail';
coordinate = 'STN';
outputfile = 'test';

out = table();
for i = 1:info.n
   id = info.clinicInfo(i).PATIENTID;
   for j = 1:numel(tasks)
      for k = 1:numel(conditions)
         fprintf('Trying %s for %s in %s\n',tasks{j},id,conditions{k});
         d = dir([datadir '/' id '*' tasks{j} '*' conditions{k} '*.mat']);
         if (numel(d) == 1)
            temp = load(fullfile(datadir,d.name));
            labels = temp.PSD.labels_;
            
            [power,ftemp] = extract(temp.PSD,'f',f,'psd',psd,'dB',dB,'normalize',normalize);

            power = power(1:dwnsmpl:end,:);
            ftemp = ftemp(1:dwnsmpl:end);
            nf = numel(ftemp);
            
            power = power(:);
            count = 1;
            for n = 1:numel(labels)
               for q = 1:nf
                  rownames{count} = [labels(n).name '_' num2str(q)];
                  %fprintf('%s\n',rownames{count});
                  count = count + 1;
               end
            end

         else
            disp(['    no PSD data ' id]);
         end
      end
   end
end
