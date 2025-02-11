%gbmov.batch.winpsdstats;
f = m(1).f;

%% Separate
c = fig.distinguishable_colors(numel(m));
maxy = 550;
maxx = 100;
scalefac = 12.5;
q = linq(m);
peakMag = q.select(@(x) x.BASELINEASSIS.OFF.L_peakMag').toArray';
[peakMag,peakInd] = sort(max(peakMag,[],2));
figure;
subplot(121); hold on
plot([8 8],[0 maxy],'k:');
plot([35 35],[0 maxy],'k:');
subplot(122); hold on
plot([8 8],[0 maxy],'k:');
plot([35 35],[0 maxy],'k:');
count = 1;
for i = peakInd'%1:numel(m)
   if ~isempty(m(i).f)
      subplot(121);
      ind = m(i).BASELINEASSIS.OFF.L_bandmax;
      if ~all(isnan(ind))
         plot(f,m(i).BASELINEASSIS.OFF.L_power(:,ind)+scalefac*count,'-','color',c(i,:));
         plot(m(i).BASELINEASSIS.OFF.L_peakLoc(ind),...
            m(i).BASELINEASSIS.OFF.L_peakMag(ind)+scalefac*count,'x','color',c(i,:))
         plot(f,m(i).BASELINEASSIS.ON.L_power(:,ind)+scalefac*count,'--','color',c(i,:));
         text(maxx,scalefac*count,m(i).PATIENTID);
         axis([0 maxx 0 maxy]);
      end
      
      subplot(122);
      ind = m(i).BASELINEASSIS.OFF.R_bandmax;
      if ~all(isnan(ind))
         plot(f,m(i).BASELINEASSIS.OFF.R_power(:,ind)+scalefac*count,'-','color',c(i,:));
         plot(m(i).BASELINEASSIS.OFF.R_peakLoc(ind),...
            m(i).BASELINEASSIS.OFF.R_peakMag(ind)+scalefac*count,'x','color',c(i,:))
         plot(f,m(i).BASELINEASSIS.ON.R_power(:,ind)+scalefac*count,'--','color',c(i,:));
         text(maxx,scalefac*count,m(i).PATIENTID);
         axis([0 maxx 0 maxy]);
      end
      count = count + 1;
   else
      count = count + 1;
      m(i).PATIENTID
   end
end
subplot(121); title('LEFT');
subplot(122); title('RIGHT');
