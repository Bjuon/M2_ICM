%monkey = 'Flocky';
%task = '1DR';
function plotSequenceTree(monkey,task,dateStart,dateEnd,overwrite,mintrials)

if nargin < 3
   dateStart = 0;
else
   dateStart = datenum(dateStart,'dd/mm/yyyy');
end

if nargin < 4
   dateEnd = now();
else
   dateEnd = datenum(dateEnd,'dd/mm/yyyy');
end

if nargin < 5
   overwrite = false;
end

if nargin < 6
   mintrials = 100;
end

import monk.load.*

% Find filenames matching criteria
d = dir([monkey '*' task '_data-*.txt']);

for i = 1:numel(d)
   logname = d(i).name;
   ind = strfind(logname,'.txt');
   logname(ind:end) = [];
   
%    if ~overwrite
%       d2 = dir([logname '.pdf']);
%       if numel(d2) > 0
%          fprintf('%s plot alreadys exists, not overwriting\n',logname);
%          continue;
%       end
%    end
   
   hdr = loadEventIDE(logname);
   
   t = datenum(hdr.Date,'dd/mm/yyyy');
   if (t < dateStart) || (t > dateEnd)
      fprintf('%s out of date range\n',logname);
      continue;
   end
   
   [~,logtrial] = loadEventIDE(logname);
   
   if numel(logtrial) < mintrials
      fprintf('%s insufficient number of trials\n',logname);
      continue;
   end
   
   fprintf('Plotting %s\n',logname);
   [~,day] = weekday(datestr(datenum(hdr.Date,'dd/mm/yyyy'),2));
   ti = [hdr.Animal_Name ' ' hdr.Experiment ' ' hdr.Date ' ' hdr.Time ' ' day];
   logtrial.plotTrialBack(ti);
   
   print([logname '.pdf'],'-dpdf');
   close;
end


