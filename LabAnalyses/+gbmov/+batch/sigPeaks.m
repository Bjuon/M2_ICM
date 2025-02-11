%% Get paths to data & load clinical data
[~,infodir,savedir] = gbmov.getPaths();
datadir = '/Users/brian/Dropbox/Spectrum4';
conditions = {'OFF'};
tasks = {'BASELINEASSIS'};
info = gbmov.PatientInfo('path',infodir);

fmin = 8;
fmax = 35;
% fmin = 12;
% fmax = 30;


count = 1;
clear str;
for i = 1:info.n
   id = info.clinicInfo(i).PATIENTID;
   for j = 1:numel(tasks)
      
      dOFF = dir([datadir '/' id '*' tasks{j} '*OFF*.mat']);
      if ~isempty(dOFF)
         dat = load(fullfile(datadir,dOFF.name));

         [peak,f,P,labels] = dat.PSD.findpeaks2('fmin',fmin,'fmax',fmax);
         
         str(count).id = id;
         str(count).P = P;
         str(count).isPeak = cellfun(@(x) ~isempty(x),peak.Start);
         side = {labels.side};
         str(count).hasSide = numel(unique(side)); % # of hemispheres
         str(count).side = {labels.side};
         str(count).labels = labels;
         side = side(str(count).isPeak);
         str(count).isPeakSide = numel(unique(side)); % # of hemispheres with peaks on at least one channel
         for k = 1:numel(labels)
            maxp = max(peak.Max{k});
            if isempty(maxp)
               str(count).max(k) = nan;
               str(count).freq(k) = nan;
               str(count).freqCOM(k) = nan;
            else
               ind = peak.Max{k} == maxp;
               str(count).max(k) = maxp;
               str(count).freq(k) = peak.Freq{k}(ind);
               str(count).freqCOM(k) = peak.FreqCOM{k}(ind);
            end
         end
         
         str(count).maxall = nanmean(str(count).max);
         
         count = count + 1;
      end
      
   end
end

% Considering only patients with 2 hemispheres recorded
temp = [[str.hasSide]',[str.isPeakSide]'];
ind = temp(:,1)==2;
sum(temp(ind,2)==0)
sum(temp(ind,2)==0)/sum(ind)
sum(temp(ind,2)==1)
sum(temp(ind,2)==1)/sum(ind)
sum(temp(ind,2)==2)
sum(temp(ind,2)==2)/sum(ind)

 
[maxall,I] = sort([str.max],'descend');
ind = isnan(maxall);
maxall = [maxall(~ind),maxall(ind)];
I = [I(~ind) , I(ind)];
Pall = cat(2,str.P);
Pall = Pall(:,I);

freq = cat(2,str.freq);
freq = freq(I);

figure
imagesc(f',1:size(Pall,2),Pall')
hold on;
for i = 1:numel(freq)
   plot(freq(i),i,'rx');
end
caxis([0 3]);

% Sort by mean of max across channels by patient
[maxall,I] = sort([str.maxall],'descend');

ind = isnan(maxall);
maxall = [maxall(~ind),maxall(ind)];
I = [I(~ind) , I(ind)];

str = str(I);

Pall = cat(2,str.P);

figure;
imagesc(f',1:size(Pall,2),Pall')

hold on
count = 1;
for i = 1:numel(str)
   for j = 1:size(str(i).P,2)
      plot(str(i).freq(j),count,'bx');
      count = count + 1;
   end
end
caxis([0 3]);


%%
