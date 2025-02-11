%% Get paths to data & load clinical data
[datadir,infodir,savedir] = gbmov.getPaths();
conditions = {'OFF' 'ON'};
tasks = {'BASELINEASSIS'};
info = gbmov.PatientInfo('path',infodir);

%% Extract spectra for each patient/channel

% Parameters
f = 1:.01:40; % Frequency range desired
psd = 'raw';  % which spectrum, one of 'raw', 'base', 'detail'
dB = false;
exclude = [45 55];
normalize = struct('fmin',4,'fmax',95,'method','integral','exclude',exclude);

POFF = [];

for i = 1:info.n
   for j = 1:numel(tasks)
      fprintf('Trying %s for %s\n',tasks{j},info.clinicInfo(i).PATIENTID);
      id = info.clinicInfo(i).PATIENTID;
      dOFF = dir([datadir '/' id '*' tasks{j} '*OFF*.mat']);
      
      if (numel(dOFF) == 1)
         temp = load(fullfile(datadir,dOFF.name));
         [tempP,~,labels] = extract(temp.PSD,'f',f,'psd',psd,'dB',dB,'normalize',normalize);
         POFF = [POFF , tempP];
      else
         disp(['    no PSD data ' info.clinicInfo(i).PATIENTID]);
      end
   end
end

%%
band = [8 35];
% normalize = struct('fmin',5,'fmax',95,'method','integral','exclude',exclude);

clear out;
for i = 1:info.n
   for j = 1:numel(tasks)
      fprintf('Trying %s for %s\n',tasks{j},info.clinicInfo(i).PATIENTID);
      id = info.clinicInfo(i).PATIENTID;
      dOFF = dir([datadir '/' id '*' tasks{j} '*OFF*.mat']);
      
      if (numel(dOFF) == 1)
         temp = load(fullfile(datadir,dOFF.name));
         out(i).pOFF = temp.PSD.meanInBand(band,'psd',psd,'exclude',exclude,'dB',dB,'normalize',normalize);
         out(i).labels = {temp.PSD.labels_.name};
         out(i).UPDRSIII_OFF = repmat(info.info(id).UPDRSIII_OFF,1,numel(out(i).labels));
         out(i).BR_OFF = repmat(info.info(id).BR_OFF,1,numel(out(i).labels));
      else
         disp(['    no PSD data ' info.clinicInfo(i).PATIENTID]);
      end
   end
end
p = cat(2,arrayfun(@(x) nanmean(x.pOFF),out));
u = cat(2,arrayfun(@(x) nanmean(x.UPDRSIII_OFF),out));
br = cat(2,arrayfun(@(x) nanmean(x.BR_OFF),out));

figure;
subplot(121); hold
fig.boundedline(f,nanmean(100*POFF,2),nanstd(100*POFF,[],2)./sqrt(size(POFF,2)),'r')
%fig.boundedline(f,nanmean(100*POFF,2),nanstd(100*POFF,[],2)./sqrt(size(POFF,2)),'r','alpha')
str = which('gbmov.scans.load');
path = fileparts(str);
temp = load(fullfile(path,'Neumann-2016-fig1a.csv'));
[~,I] = sort(temp(:,1));
temp = temp(I,:);
plot(temp(:,1),temp(:,2),'r--');
axis([3 40 0 10]);

subplot(122); hold on
plot(u,100*p,'ro','markerfacecolor','r','markeredgecolor','w','markersize',10)
axis([0 70 1 4])

[rho,pval] = corr(u',100*p','type','spearman','rows','complete')
for i = 1:info.n
   fprintf('%s %g %1.2f\n',info.patient{i},u(i),100*p(i));
end
