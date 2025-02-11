function [meanR,t] = psth(data,value,event,win)

key = 'Trial';
% value = 'Go';
q = linq(data);
try
temp = q.where(@(x) isKey(x.info,key))...
   .where(@(x) strcmp(x.info(key).('trial'),value))...
   .where(@(x) x.info(key).isCorrect)...
   .toArray();
catch
   meanR = [];
   t = [];
   return
end


temp.sync('name',event,'window',[-3 3]);

q = linq(temp);

clear r t labels;
count = 1;
for i = 1:numel(temp)
   if ~iscell(temp(i).pointProcess)
      times = temp(i).pointProcess.times;
      labels{count,1} = temp(i).pointProcess.labels;
      [r{count,1},t{count,1}] = spk.getPsth(times,.050,'method','qkde','window',win);
      count = count + 1;
   end
end

if exist('labels','var')
   spkNames = unique(cell.flatten(labels));
   
   R = {};
   for i = 1:numel(spkNames)
      R{i} = [];
      for j = 1:numel(r)
         ind = strcmp(labels{j},spkNames{i});
         R{i} = [R{i} , r{j}(:,ind)];
      end
   end
   
   meanR = cellfun(@(x) mean(x,2),R,'uni',false);
   meanR = cat(2,meanR{:});
   % meanR = cellfun(@(x) x./mean(x),meanR,'uni',false);
   t = t{1};
else
   meanR = [];
   t = [];
end
% figure; hold on
% cellfun(@(x) plot(t{1},x),meanR)