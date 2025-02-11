%% Get paths to data & load clinical data
[datadir,infodir,savedir] = gbmov.getPaths();
conditions = {'OFF' 'ON'};
tasks = {'BASELINEASSIS'};
info = gbmov.PatientInfo('path',infodir);

%% Extract spectra for each patient/channel

% Parameters
band = [5 12; 13 20 ; 21 30];
exclude = [];
normalize = [];%struct('fmin',4,'fmax',95,'method','integral');
dB = false;
psd = 'raw';
clear out;
for i = 1:info.n
   for j = 1:numel(tasks)
      fprintf('Trying %s for %s\n',tasks{j},info.clinicInfo(i).PATIENTID);
      id = info.clinicInfo(i).PATIENTID;
      
      dOFF = dir([datadir '/' id '*' tasks{j} '*OFF*.mat']);
      if (numel(dOFF) == 1)
         temp = load(fullfile(datadir,dOFF.name));
         power = temp.PSD.measureInBand(band,'method','integral','psd',psd,'exclude',exclude,'dB',dB,'normalize',normalize);
         ind = strcmp({temp.PSD.labels_.side},'right');
         if any(ind)
            out(i).pOFF(:,1) = nanmean(power(:,ind),2);
         else
            out(i).pOFF(:,1) = nan(size(band,1),1);
         end
         ind = strcmp({temp.PSD.labels_.side},'left');
         if any(ind)
            out(i).pOFF(:,2) = nanmean(power(:,ind),2);
         else
            out(i).pOFF(:,2) = nan(size(band,1),1);
         end
         % NOTE CONTRALATERAL
         out(i).BR_OFF = [info.info(id).BR_OFF_L info.info(id).BR_OFF_R];
      else
         disp(['    no OFF PSD data ' info.clinicInfo(i).PATIENTID]);
         out(i).pOFF = nan(size(band,1),2);
         out(i).BR_OFF = [NaN NaN];
      end
            
      dON = dir([datadir '/' id '*' tasks{j} '*ON*.mat']);
      if (numel(dON) == 1)
         temp = load(fullfile(datadir,dON.name));
         power = temp.PSD.measureInBand(band,'method','integral','psd',psd,'exclude',exclude,'dB',dB,'normalize',normalize);
         ind = strcmp({temp.PSD.labels_.side},'right');
         if any(ind)
            out(i).pON(:,1) = nanmean(power(:,ind),2);
         else
            out(i).pON(:,1) = nan(size(band,1),1);
         end
         ind = strcmp({temp.PSD.labels_.side},'left');
         if any(ind)
            out(i).pON(:,2) = nanmean(power(:,ind),2);
         else
            out(i).pON(:,2) = nan(size(band,1),1);
         end
         % NOTE CONTRALATERAL
         out(i).BR_ON = [info.info(id).BR_ON_L info.info(id).BR_ON_R];
      else
         disp(['    no ON PSD data ' info.clinicInfo(i).PATIENTID]);
         out(i).pON = nan(size(band,1),2);
         out(i).BR_ON = [NaN NaN];
      end
   end
end
pOFF = cat(2,out.pOFF);
brOFF = cat(2,out.BR_OFF);
pON = cat(2,out.pON);
brON = cat(2,out.BR_ON);

figure;
subplot(221);
hold on
plot(brOFF,pOFF(1,:),'ro');
lsline
axis([0 25 0 1.2]);
subplot(222);
hold on
plot(brOFF,pOFF(2,:),'ro');
lsline
axis([0 25 0 .8]);
subplot(223);
hold on
plot(brOFF,pOFF(3,:),'ro');
lsline
axis([0 25 0 .8]);

subplot(224);
plot(brON-brOFF,pON(2,:)-pOFF(2,:),'bo');
