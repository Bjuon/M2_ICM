gbmov.batch.winpsdstats;
f = m(1).f;

%% Average
offR = nan(1001,numel(m));
offL = nan(1001,numel(m));
onR = nan(1001,numel(m));
onL = nan(1001,numel(m));
for i = 1:numel(m)
   if ~isempty(m(i).f) && unique(m(i).BASELINEASSIS.OFF.origFs)
      offR(:,i) = mean(m(i).BASELINEASSIS.OFF.R_power,2);
      offL(:,i) = mean(m(i).BASELINEASSIS.OFF.L_power,2);
   end
   if ~isempty(m(i).f) && unique(m(i).BASELINEASSIS.ON.origFs)
      onR(:,i) = mean(m(i).BASELINEASSIS.ON.R_power,2);
      onL(:,i) = mean(m(i).BASELINEASSIS.ON.L_power,2);
   end
end

figure; 
subplot(121); hold on
plot(f,nanmean(offL,2),'r--');
plot(f,nanmean(onL,2),'b--');
subplot(122); hold on
plot(f,nanmean(offR,2),'r');
plot(f,nanmean(onR,2),'b');

figure; hold on
plot(f,nanmean([offL,offR],2),'r');
plot(f,nanmean([onL,onR],2),'b');

%% Separate
c = fig.distinguishable_colors(numel(m));
figure;
subplot(121); hold on
plot([8 8],[0 450],'k-');
plot([35 35],[0 450],'k-');
subplot(122); hold on
plot([8 8],[0 450],'k-');
plot([35 35],[0 450],'k-');
for i = 1:numel(m)
   if ~isempty(m(i).f)
      subplot(121);
      ind = m(i).BASELINEASSIS.OFF.L_bandmax;
      if ~all(isnan(ind))
         plot(f,m(i).BASELINEASSIS.OFF.L_power(:,ind)+12.5*i,'-','color',c(i,:));
         plot(m(i).BASELINEASSIS.OFF.L_peakLoc(ind),...
            m(i).BASELINEASSIS.OFF.L_peakMag(ind)+12.5*i,'x','color',c(i,:))
         plot(f,m(i).BASELINEASSIS.ON.L_power(:,ind)+12.5*i,'--','color',c(i,:));
         axis([0 100 0 580]);
      end
      
      subplot(122);
      ind = m(i).BASELINEASSIS.OFF.R_bandmax;
      if ~all(isnan(ind))
         plot(f,m(i).BASELINEASSIS.OFF.R_power(:,ind)+12.5*i,'-','color',c(i,:));
         plot(m(i).BASELINEASSIS.OFF.R_peakLoc(ind),...
            m(i).BASELINEASSIS.OFF.R_peakMag(ind)+12.5*i,'x','color',c(i,:))
         plot(f,m(i).BASELINEASSIS.ON.R_power(:,ind)+12.5*i,'--','color',c(i,:));
         axis([0 100 0 580]);
      end
   end
end

pOn = linq(m).select(@(x) [x.BASELINEASSIS.ON.L_bandavg x.BASELINEASSIS.ON.R_bandavg]).toList;
pOn = cat(1,pOn{:});
pOff = linq(m).select(@(x) [x.BASELINEASSIS.OFF.L_bandavg x.BASELINEASSIS.OFF.R_bandavg]).toList;
pOff = cat(1,pOff{:});
updrsIV = cat(1,m.UPDRS_IV);
equivDopa = cat(1,m.EQUIVLDOPA);

figure; hold on
plot(updrsIV,pOff,'ro')
plot(updrsIV,pOn,'bs')
lsline

figure; hold on
plot(equivDopa,pOff,'ro')
plot(equivDopa,pOn,'bs')
lsline

locZ = [locLz , locRz]

figure; hold on
plot(locZ,pOff,'ro')
plot(locZ,pOn,'bs')
lsline

figure; hold on
plot(equivDopa,pOff-pOn,'ro')
lsline
figure; hold on
plot(updrsIV,pOff-pOn,'ro')
lsline


f_range = [12 20];
ind = (f>=f_range(1)) & (f<=f_range(2));
pOn2 = nan(size(pOn));
pOff2 = nan(size(pOff));
for i = 1:numel(m)
   if ~isnan(m(i).BASELINEASSIS.ON.L_power(1,1))
      pOn2(i,:) = [mean(m(i).BASELINEASSIS.ON.L_power(ind,:),1) mean(m(i).BASELINEASSIS.ON.R_power(ind,:),1)];
   end
   if ~isnan(m(i).BASELINEASSIS.OFF.L_power(1,1))
      pOff2(i,:) = [mean(m(i).BASELINEASSIS.OFF.L_power(ind,:),1) mean(m(i).BASELINEASSIS.OFF.R_power(ind,:),1)];
   end
end






