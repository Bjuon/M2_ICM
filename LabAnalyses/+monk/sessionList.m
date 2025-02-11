%monkey = 'Flocky';
%task = '1DR';
function list = sessionList(monkey,task,dateStart,dateEnd,mintrials)

if nargin < 3
   dateStart = 0;
else
   dateStart = datenum(dateStart,'dd/mm/yyyy');
end

if (nargin < 4) || isempty(dateEnd)
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

keep = false(size(d));
for i = 1:numel(d)
   logname = d(i).name;
   ind = strfind(logname,'.txt');
   logname(ind:end) = [];
   
   hdr = loadEventIDE(logname);
   
   t = datenum(hdr.Date,'dd/mm/yyyy');
   if (t < dateStart) || (t > dateEnd)
      fprintf('%s out of date range\n',logname);
      continue;
   end
    
   [hdr,logtrial] = loadEventIDE(logname);

   if numel(logtrial) < mintrials
      fprintf('%s insufficient number of trials\n',logname);
      continue;
   end
   
   keep(i) = true;
end

list = {d.name};
list(~keep) = [];
