function [f,out] = getBasicScores3(psd,dB)
keep = {'PSD' 'SIG' 'CONDITION' 'CHANNEL' 'SIDE' 'DIPOLE'...
   'PATIENTID' 'PROTOCOL' ...
   'UPDRSIV' 'SCORE_OFF' 'DYSKINESIA' 'DYSTONIA'...
   'UPDRSIII_OFF_CONTRA' 'UPDRSIII_ON_CONTRA' ...
   'BRADYKINESIA_OFF_CONTRA' 'BRADYKINESIA_ON_CONTRA' ...
   'RIGIDITY_OFF_CONTRA' 'RIGIDITY_ON_CONTRA' ...
   'TREMOR_OFF_CONTRA' 'TREMOR_ON_CONTRA' ...
   'AXIAL_OFF' 'AXIAL_ON'};
% keep = {'PSD' 'SIG' 'CONDITION' 'CHANNEL' 'SIDE' 'DIPOLE' 'locML' 'locAP' 'locDV'...
%    'PATIENTID' 'PROTOCOL' ...
%    'UPDRSIV' ...
%    'UPDRSIII_OFF_CONTRA' 'UPDRSIII_ON_CONTRA' ...
%    'BRADYKINESIA_OFF_CONTRA' 'BRADYKINESIA_ON_CONTRA' ...
%    'RIGIDITY_OFF_CONTRA' 'RIGIDITY_ON_CONTRA' ...
%    'TREMOR_OFF_CONTRA' 'TREMOR_ON_CONTRA' ...
%    'AXIAL_OFF' 'AXIAL_ON'};

conditionMatch = {'UPDRSIII' 'BRADYKINESIA' 'RIGIDITY' 'TREMOR' 'AXIAL' 'UPDRSIII_STIM'};

%%% MISSING HEMIBODY FOR UPDRSIII_STIM
conditionSideMatch = {'UPDRSIII' 'BRADYKINESIA' 'RIGIDITY' 'TREMOR'};

%% Get paths to data & load clinical data
[datadir,infodir,savedir] = gbmov.getPaths();
conditions = {'OFF' 'ON'};
tasks = {'BASELINEASSIS'};
info = gbmov.PatientInfo('path',infodir);

%%
% exclude = [49 51];
normalize = [];%struct('fmin',4,'fmax',100,'method','integral');
%dB = false;
%psd = 'detail';
coordinate = 'STN';
%outputfile = 'test_RAW_STN';

f = 1:.01:100;% Frequency range desired

% bandnames = {};
% for i = 1:size(band,1)
%    str = ['f_' num2str(band(i,1)) '_' num2str(band(i,2))];
%    bandnames{i} = str;
% end

%PSD = [];
alpha = 0.05/numel(f); % bonferonni corrected alpha for each frequency

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
            
            tempP = extract(temp.PSD,'f',f,'psd',psd,'dB',dB,'normalize',normalize);
            if strcmp('detail',psd)
               [c,fsig] = threshold(temp.PSD,alpha);
               sig = tempP>=repmat(c,size(tempP,1),1);
            else
               sig = ones(size(tempP));
            end
            
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
               psdInfo(m).PSD = tempP(:,m)';
               psdInfo(m).SIG = sig(:,m)';
               psdInfo(m).CONDITION = conditions{k};
               psdInfo(m).CHANNEL = labels(m).name;
               psdInfo(m).SIDE = labels(m).side;
               psdInfo(m).DIPOLE = [labels(m).name(1) '_' labels(m).name(2)];
               [x,y,z] = info.loc(id(1:4),coordinate,labels(m).name);
               psdInfo(m).locML = x;
               psdInfo(m).locAP = y;
               psdInfo(m).locDV = z;
               %keyboard
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

varnames = out.Properties.VariableNames;
[C,IA] = setdiff(out.Properties.VariableNames,keep);
for i = 1:numel(IA)
   out.(varnames{IA(i)}) = [];
end

out = rmmissing(out);

out.UPDRSIII_DIFF_CONTRA = out.UPDRSIII_OFF_CONTRA - out.UPDRSIII_ON_CONTRA;
out.BRADYKINESIA_DIFF_CONTRA = out.BRADYKINESIA_OFF_CONTRA - out.BRADYKINESIA_ON_CONTRA;
out.RIGIDITY_DIFF_CONTRA = out.RIGIDITY_OFF_CONTRA - out.RIGIDITY_ON_CONTRA;
out.TREMOR_DIFF_CONTRA = out.TREMOR_OFF_CONTRA - out.TREMOR_ON_CONTRA;
out.AXIAL_DIFF = out.AXIAL_OFF - out.AXIAL_ON;

out.DYSKINESIA = out.DYSKINESIA - out.DYSTONIA;
%out.UPDRSIV = out.SCORE_OFF + out.DYSKINESIA;