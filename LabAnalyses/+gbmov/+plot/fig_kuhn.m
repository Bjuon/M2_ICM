%% Get paths to data & load clinical data
[datadir,infodir,savedir] = gbmov.getPaths();
conditions = {'OFF' 'ON'};
tasks = {'BASELINEASSIS'};
info = gbmov.PatientInfo('path',infodir);

%%
band = [5 12; 8 35 ; 13 20 ; 21 30];
exclude = [99 101];
normalize = [];%struct('fmin',90,'fmax',110,'method','integral');
dB = false;
psd = 'raw';
clear out;
for i = 1:info.n
   id = info.clinicInfo(i).PATIENTID;
   for j = 1:numel(tasks)
      fprintf('Trying %s for %s\n',tasks{j},id);
      
      dON = dir([datadir '/' id '*' tasks{j} '*ON*.mat']);
      dOFF = dir([datadir '/' id '*' tasks{j} '*OFF*.mat']);
      
      if (numel(dON) == 1) && (numel(dOFF) == 1)
         out(i).id = id;

         temp = load(fullfile(datadir,dOFF.name));
         out(i).labels = temp.PSD.labels_;
         out(i).pOFF = temp.PSD.measureInBand(band,'psd',psd,'exclude',exclude,...
            'measure','integral','dB',dB,'normalize',normalize);
         
         % Find peaks for each channel (note we are using the detail spectrum)
         pk = temp.PSD.findpeaks('fmin',8,'fmax',35,'psd','detail');
         
         % For each side, find the channel with peak power
         ind = strcmp({out(i).labels.side},'right');
         if any(ind)
            pks = pk.pks(ind);
            locs = pk.locs(ind);
         else
            pks(1) = nan;
         end
         if ~isnan(pks)
            maxPeak = max(pks);
            out(i).maxPeakIndR = find(pk.pks == maxPeak);
            out(i).maxFreqR = pk.locs(out(i).maxPeakIndR);
            power = temp.PSD.measureInBand(out(i).maxFreqR + [-5 +5],'psd',psd,'exclude',exclude,...
               'measure','integral','dB',dB,'normalize',normalize);
            out(i).pOFFpeakR = power(out(i).maxPeakIndR);
         else
            out(i).maxPeakIndR = NaN;
            out(i).maxFreqR = NaN;
            out(i).pOFFpeakR = NaN;
         end
         
         ind = strcmp({out(i).labels.side},'left');
         if any(ind)
            pks = pk.pks(ind);
            locs = pk.locs(ind);
         else
            pks(1) = nan;
         end
         if ~isnan(pks)
            maxPeak = max(pks);
            out(i).maxPeakIndL = find(pk.pks == maxPeak);
            out(i).maxFreqL = pk.locs(out(i).maxPeakIndL);
            power = temp.PSD.measureInBand(out(i).maxFreqL + [-5 +5],'psd',psd,'exclude',exclude,...
               'measure','integral','dB',dB,'normalize',normalize);
            out(i).pOFFpeakL = power(out(i).maxPeakIndL);
         else
            out(i).maxPeakIndL = NaN;
            out(i).maxFreqL = NaN;
            out(i).pOFFpeakL = NaN;
         end
         
         temp = load(fullfile(datadir,dON.name));
         out(i).pON = temp.PSD.measureInBand(band,'psd',psd,'exclude',exclude,...
            'measure','integral','dB',dB,'normalize',normalize);
         
         % Reuse OFF peaks
         % For each side, find the channel with peak power

         if ~isnan(out(i).pOFFpeakR)
            power = temp.PSD.measureInBand(out(i).maxFreqR + [-5 +5],'psd',psd,'exclude',exclude,...
               'measure','integral','dB',dB,'normalize',normalize);
            out(i).pONpeakR = power(out(i).maxPeakIndR);
         else
            out(i).pONpeakR = NaN;
         end
         
         if ~isnan(out(i).pOFFpeakL)
            power = temp.PSD.measureInBand(out(i).maxFreqL + [-5 +5],'psd',psd,'exclude',exclude,...
               'measure','integral','dB',dB,'normalize',normalize);
            out(i).pONpeakL = power(out(i).maxPeakIndL);
         else
            out(i).pONpeakL = NaN;
         end
         
         
%          pk = temp.PSD.findpeaks('fmin',8,'fmax',35,'psd','detail');
%          out(i).pOFFpeak = [];
%          for k = 1:numel(out(i).labels)
%             b = pk.locs(k) + [-5 5];
%             out(i).pOFFpeak = temp.PSD.measureInBand(b,'psd',psd,'exclude',exclude,...
%                'measure','integral','dB',dB,'normalize',normalize);
%          end
%          
%          temp = load(fullfile(datadir,dON.name));
%          out(i).pON = temp.PSD.measureInBand(band,'psd',psd,'exclude',exclude,...
%             'measure','integral','dB',dB,'normalize',normalize);
%          
%          % Reuse OFF peaks
%          %pk = temp.PSD.findpeaks('fmin',8,'fmax',35,'psd','detail');
%          out(i).pONpeak = [];
%          for k = 1:numel(out(i).labels)
%             b = pk.locs(k) + [-5 5];
%             out(i).pONpeak = temp.PSD.measureInBand(b,'psd',psd,'exclude',exclude,...
%                'measure','integral','dB',dB,'normalize',normalize);
%          end
         
         out(i).changePower = (out(i).pOFF-out(i).pON)./out(i).pOFF;
         out(i).changePowerPeakR = (out(i).pOFFpeakR-out(i).pONpeakR)./out(i).pOFFpeakR;
         out(i).changePowerPeakL = (out(i).pOFFpeakL-out(i).pONpeakL)./out(i).pOFFpeakL;
         
         % non-lateralized
         out(i).UPDRSIII_ON = repmat(info.info(id).UPDRSIII_ON,1,numel(out(i).labels));
         out(i).UPDRSIII_OFF = repmat(info.info(id).UPDRSIII_OFF,1,numel(out(i).labels));
         out(i).BR_OFF = repmat(info.info(id).BR_OFF,1,numel(out(i).labels));
         out(i).BR_ON = repmat(info.info(id).BR_ON,1,numel(out(i).labels));

         out(i).UPDRSIII_IMPROV = repmat(info.info(id).UPDRSIII_IMPROV,1,numel(out(i).labels));
         out(i).BR_IMPROV = repmat(info.info(id).BR_IMPROV,1,numel(out(i).labels));

         % NOTE CONTRALATERAL
         x = nan(1,numel(out(i).labels));
         ind = strcmp({out(i).labels.side},'right');
         if any(ind)
            x(ind) = info.info(id).BR_OFF_L;
         end
         ind = strcmp({out(i).labels.side},'left');
         if any(ind)
            x(ind) = info.info(id).BR_OFF_R;
         end
         out(i).BR_CONTRA_OFF = x;

         x = nan(1,numel(out(i).labels));
         ind = strcmp({out(i).labels.side},'right');
         if any(ind)
            x(ind) = info.info(id).BR_L_IMPROV;
         end
         ind = strcmp({out(i).labels.side},'left');
         if any(ind)
            x(ind) = info.info(id).BR_R_IMPROV;
         end
         out(i).BR_CONTRA_IMPROV = x;

%         out(i).LDOPA = repmat(info.info(id).LDOPA,1,numel(out(i).labels));
%         out(i).UPDRSIV = repmat(info.info(id).UPDRSIV,1,numel(out(i).labels));
         x = []; y = []; z = [];
         out(i).X = []; out(i).Y = []; out(i).Z = [];
         for k = 1:numel(out(i).labels)
            [x,y,z] = info.loc(id(1:4),'STN',out(i).labels(k).name);
            out(i).X = [out(i).X , x];
            out(i).Y = [out(i).Y , y];
            out(i).Z = [out(i).Z , z];
         end
      else
         out(i).id = id;
      end
   end
end

ind = arrayfun(@(x) isempty(x.labels),out);
out(ind) = [];
 
% p = cat(2,out.pOFF);
% u = cat(2,out.Y);
% hold on
% plot(u,p(2,:),'o');
% 
% X = [cat(2,out.BR_CONTRA_OFF)' , cat(2,out.X)' , cat(2,out.Y)' , cat(2,out.Z)'];
% ind = ~isnan(sum(X,2));
% X = X(ind,:);
% y = p(ind);
% [b,ci] = regress(y,X)
% 
c = fig.distinguishable_colors(numel(out)); % number of color = size of m
fac = 70;
tr = 0.75;
b = 2; % band index
figure;
axis([-5 105 -105 105]);
hold on
plot([-5 105],[0 0],'k-','linewidth',0.25);
for i = 1:numel(out)
   fig.scatter_patches(out(i).BR_CONTRA_IMPROV,100*out(i).changePower(b,:),...
      out(i).pOFF(b,:)*fac,...
      'FaceAlpha',tr,'facecolor',c(i,:),'EdgeColor','none'); %facealpha=transparency
end

figure;
axis([-5 105 -105 105]);
hold on
plot([-5 105],[0 0],'k-','linewidth',0.25);
for i = 1:numel(out)
   fig.scatter_patches(out(i).BR_CONTRA_IMPROV,100*out(i).changePowerPeak,...
      out(i).pOFFpeak*fac,...
      'FaceAlpha',tr,'facecolor',c(i,:),'EdgeColor','none'); %facealpha=transparency
end

figure;
axis([-5 105 -105 105]);
hold on
plot([-5 105],[0 0],'k-','linewidth',0.25);
count = 1;
for i = 1:numel(out)
   ind = strcmp({out(i).labels.side},'right');
   if any(ind)
      fig.scatter_patches(mean(out(i).BR_CONTRA_IMPROV(ind)),100*mean(out(i).changePowerPeak(ind)),...
         mean(out(i).pOFFpeak(ind))*fac,...
         'FaceAlpha',tr,'facecolor',c(i,:),'EdgeColor','none'); %facealpha=transparency
      temp(count).id = count;
      temp(count).clinic = mean(out(i).BR_CONTRA_IMPROV(ind));
      temp(count).power = 100*mean(out(i).changePowerPeak(ind));
      count = count + 1;
   end
   if any(~ind)
      fig.scatter_patches(mean(out(i).BR_CONTRA_IMPROV(~ind)),100*mean(out(i).changePowerPeak(~ind)),...
         mean(out(i).pOFFpeak(~ind))*fac,...
         'FaceAlpha',tr,'facecolor',c(i,:),'EdgeColor','none'); %facealpha=transparency
      temp(count).id = count;
      temp(count).clinic = mean(out(i).BR_CONTRA_IMPROV(ind));
      temp(count).power = 100*mean(out(i).changePowerPeak(ind));
      count = count + 1;
   end
end

figure;
axis([-5 105 -105 105]);
hold on
plot([-5 105],[0 0],'k-','linewidth',0.25);
for i = 1:numel(out)
   if ~isnan(out(i).changePowerPeakL)
      ind = out(i).maxPeakIndL;
      fig.scatter_patches(out(i).BR_CONTRA_IMPROV(ind),100*out(i).changePowerPeakL,...
         out(i).pOFFpeakL*fac,...
         'FaceAlpha',tr,'facecolor',c(i,:),'EdgeColor','none'); %facealpha=transparency
      stats(i).clinicL = out(i).BR_CONTRA_IMPROV(ind);
      stats(i).powerL = 100*out(i).changePowerPeakL;
   else
      stats(i).clinicL = NaN;
      stats(i).powerL = NaN;
   end
   
   if ~isnan(out(i).changePowerPeakR)
      ind = out(i).maxPeakIndR;
      fig.scatter_patches(out(i).BR_CONTRA_IMPROV(ind),100*out(i).changePowerPeakR,...
         out(i).pOFFpeakR*fac,...
         'FaceAlpha',tr,'facecolor',c(i,:),'EdgeColor','none'); %facealpha=transparency
      stats(i).clinicR = out(i).BR_CONTRA_IMPROV(ind);
      stats(i).powerR = 100*out(i).changePowerPeakR;
   else
      stats(i).clinicR = NaN;
      stats(i).powerR = NaN;
   end
end

tabL = table({out.id}',[stats.clinicL]',[stats.powerL]','VariableNames',{'id' 'clinic' 'power'});
tabR = table({out.id}',[stats.clinicR]',[stats.powerR]','VariableNames',{'id' 'clinic' 'power'});

tab = [tabL ; tabR]
% figure;
% axis([-5 105 -105 105]);
% hold on
% plot([-5 105],[0 0],'k-','linewidth',0.25);
% for i = 1:numel(out)
%    ind = strcmp({out(i).labels.side},'right');
%    if any(ind)
%       fig.scatter_patches(mean(out(i).BR_CONTRA_IMPROV(ind)),max(100*out(i).changePowerPeak(ind)),...
%          mean(out(i).pOFFpeak(ind))*fac,...
%          'FaceAlpha',tr,'facecolor',c(i,:),'EdgeColor','none'); %facealpha=transparency
%    end
%    if any(~ind)
%       fig.scatter_patches(mean(out(i).BR_CONTRA_IMPROV(~ind)),max(100*out(i).changePowerPeak(~ind)),...
%          mean(out(i).pOFFpeak(~ind))*fac,...
%          'FaceAlpha',tr,'facecolor',c(i,:),'EdgeColor','none'); %facealpha=transparency
%    end
% end