function scoreTime(dat,score)

q = linq();
t = (q(dat).select(@(x) cat(1,x.visit.monthsReIntervention)).toArray)';
%score = (q(dat).select(@(x) cat(1,x.visit.Mattis)).toArray)';
s = (q(dat).select(@(x) eval(['cat(1,x.visit.' score ')'])).toArray)';
%s = (q(dat).select(@(x) cat(1,x.visit.swallowingOff)).toArray)';
survival = [dat.survival2]';
deceased = [dat.deceased]';
causeOfDeath = {dat.causeOfDeath}';

if 0
   %[a,I] = sort(datetime({dat.doi}));
   % t = t(I,:);
   % s = s(I,:);
   % survival = survival(I);
   % deceased = deceased(I);
else
   I = 1:numel(dat);
end

for i = 1:size(t,1)
   t2{i} = t(i,~isnan(s(i,:)));
   s2{i} = s(i,~isnan(s(i,:)));
end

p = PointProcess(t2);
plot(p,'style','tick'); hold on;
for i = 1:size(t,1)
   if deceased(i)
      plot(survival(i),i,'rx');
   end
end
% hold on
% plot([0 0],[0 100],'k:');
% plot([12 12],[0 100],'k:');
% plot([24 24],[0 100],'k:');
% plot([60 60],[0 100],'k:');
% plot([120 120],[0 100],'k:');

figure; hold on
plot(t,s,'o')

figure; hold on
for i = 1:size(t,1)
   %plot(t(i,:),s(i,:),'k-','Linewidth',.25);
   plot(t2{i},s2{i},'k-','Linewidth',.25,'color',[.8 .8 .8]);
   if deceased(i)
      if any(strcmpi({'cancer'},causeOfDeath{i}))
         plot([t2{i}(end) survival(i)],[s2{i}(end) s2{i}(end)],'b--');
         plot(survival(i),s2{i}(end),'bx');
      else         
         plot([t2{i}(end) survival(i)],[s2{i}(end) s2{i}(end)],'r--');
         plot(survival(i),s2{i}(end),'rx');
     end
   end
end
plot(t,s,'o')

figure;
count = 1;
for i = 1:size(t,1)
   subplot(10,10,count); hold on
   plot(t2{i},s2{i},'k-','Linewidth',.25);
   plot(t2{i},s2{i},'ko','Linewidth',.25);
   if deceased(i)
      plot([t2{i}(end) survival(i)],[s2{i}(end) s2{i}(end)],'r--');
      plot(survival(i),s2{i}(end),'rx');
   end
   axis([-10 140 min(min(s)) max(max(s))]);
   id = dat(I(i)).id;
   id = id(1:min(4,numel(id)));
   title([num2str(I(i)) ' - ' id]);
   count = count + 1;
end
suptitle(score);