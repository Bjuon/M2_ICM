%gbmov.batch.winpsdstats;
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

figure;
maxx = 95;
miny = -1;
maxy = 15;
subplot(2,2,1); hold on
plot(f,nanmean([offL,offR],2));
plot(f,nanmean([onL,onR],2));
axis([0 maxx miny maxy]);
set(gca,'tickdir','out');

q = linq(m);
miny = -1;
maxy = 20;
temp = q.where(@(x) strcmpi('lauth',x.PATIENTID)).toArray;
offL = temp.BASELINEASSIS.OFF.L_power;
offR = temp.BASELINEASSIS.OFF.R_power;
onL = temp.BASELINEASSIS.ON.L_power;
onR = temp.BASELINEASSIS.ON.R_power;
subplot(2,2,2); hold on
plot(f,nanmean([offL,offR],2));
plot(f,nanmean([onL,onR],2));
axis([0 maxx miny maxy]);
title({...
   sprintf('UPDRS III OFF (%g) ON (%g)',temp.UPDRSIII_OFF,temp.UPDRSIII_ON)...
   sprintf('UPDRS IV (%g) LEDD (%g)',temp.UPDRS_IV,temp.EQUIVLDOPA)...
   });
set(gca,'tickdir','out');


q = linq(m);
miny = -1;
maxy = 20;
temp = q.where(@(x) strcmpi('canfr',x.PATIENTID)).toArray;
offL = temp.BASELINEASSIS.OFF.L_power;
offR = temp.BASELINEASSIS.OFF.R_power;
onL = temp.BASELINEASSIS.ON.L_power;
onR = temp.BASELINEASSIS.ON.R_power;
subplot(2,2,3); hold on
plot(f,nanmean([offL,offR],2));
plot(f,nanmean([onL,onR],2));
axis([0 maxx miny maxy]);
title({...
   sprintf('UPDRS III OFF (%g) ON (%g)',temp.UPDRSIII_OFF,temp.UPDRSIII_ON)...
   sprintf('UPDRS IV (%g) LEDD (%g)',temp.UPDRS_IV,temp.EQUIVLDOPA)...
   });
set(gca,'tickdir','out');

q = linq(m);
miny = -1;
maxy = 15;
temp = q.where(@(x) strcmpi('merph',x.PATIENTID)).toArray;
offL = temp.BASELINEASSIS.OFF.L_power;
offR = temp.BASELINEASSIS.OFF.R_power;
onL = temp.BASELINEASSIS.ON.L_power;
onR = temp.BASELINEASSIS.ON.R_power;
subplot(2,2,4); hold on
plot(f,nanmean([offL,offR],2));
plot(f,nanmean([onL,onR],2));
axis([0 maxx miny maxy]);
title({...
   sprintf('UPDRS III OFF (%g) ON (%g)',temp.UPDRSIII_OFF,temp.UPDRSIII_ON)...
   sprintf('UPDRS IV (%g) LEDD (%g)',temp.UPDRS_IV,temp.EQUIVLDOPA)...
   });
set(gca,'tickdir','out');
