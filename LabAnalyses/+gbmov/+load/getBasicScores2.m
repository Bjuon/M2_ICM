%function out = getBasicScores(condition)

% Variables we don't want to keep
remove = {'PATIENTID2' 'DELINE' 'C0D' 'C1D' 'C2D' 'C3D' ...
   'C0G' 'C1G' 'C2G' 'C3G'};

conditionMatch = {'UPDRSIII' 'BRADYKINESIA' 'RIGIDITY' 'TREMOR' 'AXIAL' 'UPDRSIII_STIM'};

%%% MISSING HEMIBODY FOR UPDRSIII_STIM
conditionSideMatch = {'UPDRSIII' 'BRADYKINESIA' 'RIGIDITY' 'TREMOR'};

%% Get paths to data & load clinical data
[datadir,infodir,savedir] = gbmov.getPaths();
conditions = {'OFF' 'ON'};
tasks = {'BASELINEASSIS'};
info = gbmov.PatientInfo('path',infodir);

%%
%band = [4 8; 8 12 ; 12 20 ; 20 30 ; 8 35 ; 60 90];
band = [3.5 7.5; 8.25 12.25 ; 13 20 ; 20.75 35 ; 35.75 60.75 ; 61.25 91.25];
exclude = [49 51];
normalize = [];%struct('fmin',90,'fmax',110,'method','integral');
dB = false;
psd = 'raw';
coordinate = 'STN';
outputfile = 'PSD_RAW_STN56';

bandnames = {};
for i = 1:size(band,1)
   str = ['f_' num2str(band(i,1)) '_' num2str(band(i,2))];
   bandnames{i} = strrep(str,'.','p');
end

out = table();
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
            
            power = temp.PSD.measureInBand(band,'psd',psd,'exclude',exclude,...
               'measure','integral','dB',dB,'normalize',normalize);
            
            clinicInfo = struct2table(repmat(info.info(id),numel(labels),1),'RowNames',{labels.name});

            therapeutic = info.therapeutic(id);
            if ~isempty(therapeutic)
               temp = {labels.name};
               [C,IA,IB] = intersect(temp,therapeutic);
               temp = false(numel(labels),1);
               temp(IA) = true;
               clinicInfo.THERAPEUTIC = temp;
            else
               clinicInfo.THERAPEUTIC = NaN(numel(labels),1);
            end
            
            % Condition matched scores (matched to condition during recording)
            clear conditionMatchedClinic;
            for n = 1:numel(conditionMatch)
               if strcmp(conditions{k},'OFF')
                  conditionMatchedClinic.([conditionMatch{n} '_COND']) = ...
                     info.info(id).([conditionMatch{n} '_OFF']);
               else
                  conditionMatchedClinic.([conditionMatch{n} '_COND']) = ...
                     info.info(id).([conditionMatch{n} '_ON']);
               end
            end

            conditionMatchedClinicInfo = struct2table(repmat(conditionMatchedClinic,numel(labels),1),'RowNames',{labels.name});

            % Variables are currently Right/Left, given electrode info we
            % now generate ipsi/contra
            clear psdInfo;
            clear clinicInfo2;
            clear conditionSideMatchedClinic;
            for m = 1:numel(labels)
               % Assign the power for each band to a named variable
               for n = 1:size(power,1)
                  psdInfo(m).(bandnames{n}) = power(n,m);
               end
               psdInfo(m).CONDITION = conditions{k};
               psdInfo(m).CHANNEL = labels(m).name;
               psdInfo(m).SIDE = labels(m).side;
               psdInfo(m).DIPOLE = [labels(m).name(1) '_' labels(m).name(2)];
               [x,y,z] = info.loc(id(1:4),coordinate,labels(m).name);
               psdInfo(m).locML = x;
               psdInfo(m).locAP = y;
               psdInfo(m).locDV = z;
               
               % Create a second table to hold clinical scores mapped to
               % CONTRA/IPSI relative to recording electrode instead of R/L
               % of patient
               temp = clinicInfo.Properties.VariableNames;
               if strcmp(labels(m).side,'left')
                  ind = cellfun(@(x) numel(strfind(x,'_R'))==1,temp);
                  temp = temp(ind);
                  temp2 = strrep(temp,'_R','_CONTRA');
               else
                  ind = cellfun(@(x) numel(strfind(x,'_L'))==1,temp);
                  temp = temp(ind);
                  temp2 = strrep(temp,'_L','_CONTRA');
               end
               for n = 1:numel(temp)
                  clinicInfo2(m).(temp2{n}) = info.info(id).(temp{n});
               end
               
               % generate condition matched scores...
               for n = 1:numel(conditionSideMatch)
                  temp = clinicInfo.Properties.VariableNames;
                  if strcmp(conditions{k},'OFF')
                     ind = cellfun(@(x) numel(strfind(x,'_OFF'))==1,temp);
                     temp = temp(ind);
                     temp2 = strrep(temp,'_OFF','_COND');
                  else
                     ind = cellfun(@(x) numel(strfind(x,'_ON'))==1,temp);
                     temp = temp(ind);
                     temp2 = strrep(temp,'_ON','_COND');
                  end
                  
                  if strcmp(labels(m).side,'left')
                     ind = cellfun(@(x) numel(strfind(x,'_R'))==1,temp);
                     temp = temp(ind);
                     temp2 = temp2(ind);
                     temp2 = strrep(temp2,'_R','_CONTRA');
                  else
                     ind = cellfun(@(x) numel(strfind(x,'_L'))==1,temp);
                     temp = temp(ind);
                     temp2 = temp2(ind);
                     temp2 = strrep(temp2,'_L','_CONTRA');
                  end
                  for p = 1:numel(temp)
                     conditionSideMatchedClinic(m).(temp2{p}) = info.info(id).(temp{p});
                  end
               end
            end
            
            a = struct2table(psdInfo,'RowNames',{labels.name});
            clinicInfo.HAND = [];
            if any(strcmp(clinicInfo.Properties.VariableNames,'EXTRALINES'))
               clinicInfo.EXTRALINES = [];
            end
            tab = join(a,clinicInfo,'Keys','RowNames');
            tab = join(tab,conditionMatchedClinicInfo,'Keys','RowNames');
            c = struct2table(clinicInfo2,'RowNames',{labels.name});
            tab = join(tab,c,'Keys','RowNames');
            c = struct2table(conditionSideMatchedClinic,'RowNames',{labels.name});
            tab = join(tab,c,'Keys','RowNames');
            tab.Properties.RowNames = {};
            out = [out ; tab];
         else
            disp(['    no PSD data ' id]);
         end
      end
   end
end

for i = 1:numel(remove)
   out.(remove{i}) = [];
end

writetable(out,outputfile)