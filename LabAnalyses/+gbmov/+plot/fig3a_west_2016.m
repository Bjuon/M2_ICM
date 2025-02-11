%% Get paths to data & load clinical data
[datadir,infodir,savedir] = gbmov.getPaths();
conditions = {'OFF' 'ON'};
tasks = {'BASELINEASSIS'};
info = gbmov.PatientInfo('path',infodir);

%% Extract spectra for each patient/channel

% Parameters
f = 4:.01:40; % Frequency range desired
psd = 'raw';  % which spectrum, one of 'raw', 'base', 'detail'
dB = false;
normalize = struct('fmin',4,'fmax',48,'method','integral');

PON = [];
POFF = [];

for i = 1:info.n
   for j = 1:numel(tasks)
      fprintf('Trying %s for %s\n',tasks{j},info.clinicInfo(i).PATIENTID);
      
      dON = dir([datadir '/' info.clinicInfo(i).PATIENTID '*' tasks{j} '*ON*.mat']);
      dOFF = dir([datadir '/' info.clinicInfo(i).PATIENTID '*' tasks{j} '*OFF*.mat']);
      
      if (numel(dON) == 1) && (numel(dOFF) == 1)
         temp = load(fullfile(datadir,dON.name));
         [tempP,~,labels] = extract(temp.PSD,'f',f,'psd',psd,'dB',dB,'normalize',normalize);
         PON = [PON , tempP];
         
         temp = load(fullfile(datadir,dOFF.name));
         [tempP,~,labels] = extract(temp.PSD,'f',f,'psd',psd,'dB',dB,'normalize',normalize);
         POFF = [POFF , tempP];
      elseif (numel(dON) == 0) && (numel(dOFF) == 1)
         temp = load(fullfile(datadir,dOFF.name));
         [tempP,~,labels] = extract(temp.PSD,'f',f,'psd',psd,'dB',dB,'normalize',normalize);
         POFF = [POFF , tempP];
         PON = [PON , tempP*NaN];
      elseif (numel(dON) == 1) && (numel(dOFF) == 0)
         temp = load(fullfile(datadir,dON.name));
         [tempP,~,labels] = extract(temp.PSD,'f',f,'psd',psd,'dB',dB,'normalize',normalize);
         PON = [PON , tempP];
         POFF = [POFF , tempP*NaN];
      else
         disp(['    no PSD data ' info.clinicInfo(i).PATIENTID]);
      end
   end
end

figure; hold on
area([5 12],[.07 .07],'facecolor',[0 .5 0],'edgecolor',[0 .5 0],'facealpha',0.15,'linestyle','none')
area([13 20],[.07 .07],'facecolor',[0 0 1],'edgecolor',[0 0 1],'facealpha',0.15,'linestyle','none')
area([21 30],[.07 .07],'facecolor',[1 0 0],'edgecolor',[1 0 0],'facealpha',0.15,'linestyle','none')
plot(f,nanmean(POFF,2),'r')
plot(f,nanmean(PON,2),'b')
% plot(f,nanstd(POFF,[],2),'r--')
% plot(f,nanstd(PON,[],2),'b--')
% plot(f,nanmedian(POFF,2),'r--')
% plot(f,nanmedian(PON,2),'b--')
axis([4 40 0 0.07]);

% Plot data points from West
str = which('gbmov.scans.load');
path = fileparts(str);
temp = load(fullfile(path,'West-2016-figure1a_OFF.csv'));
[~,I] = sort(temp(:,1));
temp = temp(I,:);
plot(temp(:,1),temp(:,2),'r--');
temp = load(fullfile(path,'West-2016-figure1a_ON.csv'));
[~,I] = sort(temp(:,1));
temp = temp(I,:);
plot(temp(:,1),temp(:,2),'b--');

% % Restrict to patients where both ON and OFF tested
% ind = PON.*POFF;
% ind = double(~isnan(ind));
% ind(ind==0) = NaN;
% plot(f,nanmean(POFF.*ind,2),'r:')
% plot(f,nanmean(PON.*ind,2),'b:')

figure; hold on
fig.boundedline(f,nanmean(POFF,2),nanstd(POFF,[],2),'r','alpha')
fig.boundedline(f,nanmean(PON,2),nanstd(PON,[],2),'b','alpha')
axis([4 40 0 0.07]);

