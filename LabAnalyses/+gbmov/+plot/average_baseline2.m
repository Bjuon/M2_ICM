function [f,PON,POFF,SigON,SigOFF] = average_baseline2(psd,dB)
%% Get paths to data & load clinical data
[datadir,infodir,savedir] = gbmov.getPaths();
conditions = {'OFF' 'ON'};
tasks = {'BASELINEASSIS'};
info = gbmov.PatientInfo('path',infodir);

%% Extract spectra for each patient/channel

% Parameters
f = 1:.01:100;% Frequency range desired
%psd = 'raw';
%dB = true;
normalize = [];%struct('fmin',4,'fmax',48,'method','integral');

alpha = 0.05/numel(f); % bonferonni corrected alpha for each frequency

PON = [];  % psd ON
POFF = []; % psd OFF

therapeuticON = []; % boolean indicating therapeutic channel 
therapeuticOFF = []; % boolean indicating therapeutic channel 

SigON = []; % significant power ON (relative to baseline)
SigOFF = []; % significant power ON (relative to baseline)

for i = 1:info.n
   id = info.clinicInfo(i).PATIENTID;
   if isnan(id)
      continue;
   end
   for j = 1:numel(tasks)
      
      fprintf('Trying %s for %s\n',tasks{j},info.clinicInfo(i).PATIENTID);

      dON = dir([datadir '/' id '*' tasks{j} '*ON*.mat']);
      dOFF = dir([datadir '/' id '*' tasks{j} '*OFF*.mat']);
      
      if (numel(dON) == 1) && (numel(dOFF) == 1)
         temp = load(fullfile(datadir,dON.name));
         try
         [tempP,~,labels] = extract(temp.PSD,'f',f,'psd',psd,'dB',dB,'normalize',normalize);
         catch, keyboard; end
         PON = [PON , tempP];
         
         if strcmp('detail',psd)
            [c,fsig] = threshold(temp.PSD,alpha);
            sig = tempP>=repmat(c,size(tempP,1),1);
            SigON = [SigON , sig];
         else
            SigON = [SigON , nan(size(tempP))];
         end
         
         [~,ind] = intersect({labels.name},info.therapeutic(id),'stable');
         junk = false(1,numel(labels));
         junk(ind) = true;
         therapeuticON = [therapeuticON , junk];
         
         temp = load(fullfile(datadir,dOFF.name));
         [tempP,~,labels] = extract(temp.PSD,'f',f,'psd',psd,'dB',dB,'normalize',normalize);
         POFF = [POFF , tempP];
         
         if strcmp('detail',psd)
            [c,fsig] = threshold(temp.PSD,alpha);
            sig = tempP>=repmat(c,size(tempP,1),1);
            SigOFF = [SigOFF , sig];
         else
            SigOFF = [SigOFF , nan(size(tempP))];
         end
         
         [~,ind] = intersect({labels.name},info.therapeutic(id),'stable');
         junk = false(1,numel(labels));
         junk(ind) = true;
         therapeuticOFF = [therapeuticOFF , junk];
      elseif (numel(dON) == 0) && (numel(dOFF) == 1)
         temp = load(fullfile(datadir,dOFF.name));
         [tempP,~,labels] = extract(temp.PSD,'f',f,'psd',psd,'dB',dB,'normalize',normalize);
         POFF = [POFF , tempP];
         PON = [PON , tempP*NaN];
         
         [c,fsig] = threshold(temp.PSD,alpha);
         sig = tempP>=repmat(c,size(tempP,1),1);
         if strcmp('detail',psd)
            [c,fsig] = threshold(temp.PSD,alpha);
            sig = tempP>=repmat(c,size(tempP,1),1);
            SigOFF = [SigOFF , sig];
            SigON = [SigON , tempP*NaN];
         else
            SigOFF = [SigOFF , nan(size(tempP))];
            SigON = [SigON , tempP*NaN];
         end
         
         [~,ind] = intersect({labels.name},info.therapeutic(id),'stable');
         junk = false(1,numel(labels));
         junk(ind) = true;
         therapeuticOFF = [therapeuticOFF , junk];
         therapeuticON = [therapeuticON , nan(1,size(tempP,2))];
      elseif (numel(dON) == 1) && (numel(dOFF) == 0)
         temp = load(fullfile(datadir,dON.name));
         [tempP,~,labels] = extract(temp.PSD,'f',f,'psd',psd,'dB',dB,'normalize',normalize);
         PON = [PON , tempP];
         POFF = [POFF , tempP*NaN];
         
         [c,fsig] = threshold(temp.PSD,alpha);
         sig = tempP>=repmat(c,size(tempP,1),1);
         if strcmp('detail',psd)
            [c,fsig] = threshold(temp.PSD,alpha);
            sig = tempP>=repmat(c,size(tempP,1),1);
            SigON = [SigON , sig];
            SigOFF = [SigOFF , tempP*NaN];
         else
            SigON = [SigON , nan(size(tempP))];
            SigOFF = [SigOFF , tempP*NaN];
         end
         
         [~,ind] = intersect({labels.name},info.therapeutic(id),'stable');
         junk = false(1,numel(labels));
         junk(ind) = true;
         therapeuticON = [therapeuticON , junk];
         therapeuticOFF = [therapeuticOFF , nan(1,size(tempP,2))];
      else
         disp(['    no PSD data ' info.clinicInfo(i).PATIENTID]);
      end
      
   end
end
