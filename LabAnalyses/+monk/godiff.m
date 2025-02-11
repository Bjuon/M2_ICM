function [goDiff,t] = godiff(hdr,pp,trial,epp,varargin)
p = inputParser;
p.KeepUnmatched = false;
p.FunctionName = '--- constructor';
p.addParameter('keepUnsorted',false,@(x) islogical(x));
p.addParameter('alignTo','Target',@ischar);
p.addParameter('window',[-1 2],@isnumeric);
p.addParameter('maxTrialsRaster',25,@isscalar);
p.addParameter('plotNogo',true,@islogical);
p.addParameter('splitByCueSet',false,@islogical);
p.addParameter('splitByDirection',false,@islogical);
p.addParameter('name',{},@iscell);
p.parse(varargin{:});
par = p.Results;

condition = {trial.ConditionName}';
indNogo = strcmp(condition,'Nogo');
indGo = strcmp(condition,'Go');
indGoCTL = strcmp(condition,'Go control') ;

indCueSet = logical([trial.CueSetIndex]');
if isempty(indCueSet)
   indCueSet = true(numel(trial),1);
   par.splitByCueSet = false;
end

indDirection = [trial.TarX]'<0;

p = copy(pp);
ep = copy(epp);

if isempty(par.name)
   n = p(1).n; % Assuming same neurons for all trials...
   cells = 1:n;
else
   labels = p(1).labels;
   ind = ismember({labels.name},par.name);
   cells = find(ind);
end

count = 1;
for i = cells
   p.reset(); ep.reset();
   result = epp.find('func',@(x) strcmp(x.name.name,par.alignTo));
   p.sync(result,'window',par.window,'eventStart',true);
   ep.sync(result,'window',par.window,'eventStart',true);
   p.subset(i);
   
   name = [hdr.Animal_Name ' ' hdr.Date ' ' p(1).labels.name];
   
   indAlign = ~strcmp({result.name},'NULL')';
   
   rGo = mean(smooth(p(indGo&indAlign)));
   rGoCTL = mean(smooth(p(indGoCTL&indAlign)));
   
   goDiff(:,count) = rGo.values{1} - rGoCTL.values{1};
   t = rGo.times{1};
   count = count + 1;
end
