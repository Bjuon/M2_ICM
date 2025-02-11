% Split by direction
% split by cue set

function out = regressGNG(hdr,pp,trial,epp,varargin)

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
p.addParameter('handle',[]);
p.parse(varargin{:});
par = p.Results;

condition = {trial.ConditionName}';
indNogo = strcmp(condition,'Nogo');
indGo = strcmp(condition,'Go');
indGoCTL = strcmp(condition,'Go control') ;
block = [trial.BlockIndex]';

indCueSet = logical([trial.CueSetIndex]');
if isempty(indCueSet)
   indCueSet = true(numel(trial),1);
   par.splitByCueSet = false;
end

indDirection = [trial.TarX]'<0;

p = copy(pp);
ep = copy(epp);

set(0, 'DefaulttextInterpreter', 'none');
%c = parula(6);
c = fig.distinguishable_colors(6);

warning off;

if isempty(par.name)
   n = p(1).n; % Assuming same neurons for all trials...
   cells = 1:n;
else
   labels = p(1).labels;
   ind = ismember({labels.name},par.name);
   cells = find(ind);
end

for i = cells
   p.reset(); ep.reset(); 
   result = epp.find('func',@(x) strcmp(x.name.name,par.alignTo));
   p.sync(result,'window',par.window,'eventStart',true);
   ep.sync(result,'window',par.window,'eventStart',true);
   p.subset(i);
   quality = [p.quality]' > 0;
   sum(quality)
   name = [hdr.Animal_Name ' ' hdr.Date ' ' p(1).labels.name];
   
   indAlign = ~strcmp({result.name},'NULL')';
      
   ind = indAlign & quality;
   if strcmp(par.alignTo,'Cue')
      if sum(ind) > 100
         count = [p(ind).count]';
         blk = block(ind);
         tbl = table(count,categorical(blk),'VariableNames',{'count','block'});
         
         lm = fitlm(tbl,'count ~ block');
         out(i).p = lm.Coefficients.pValue;
         out(i).b = lm.Coefficients.Estimate;
      else
         out(i).p = [NaN NaN]';
         out(i).b = [NaN NaN]';
      end
   else
      if sum(ind) > 100
         count = [p(ind).count]';
         nogo_go = indGo(ind)+indGoCTL(ind);
         blk = block(ind);
         dir = double(indDirection(ind));
         tbl = table(count,categorical(blk),categorical(dir),categorical(nogo_go),'VariableNames',{'count','block' 'dir' 'nogo_go'});
         
         lm = fitlm(tbl,'count ~ block + dir + nogo_go');
         out(i).p = lm.Coefficients.pValue;
         out(i).b = lm.Coefficients.Estimate;
      else
         out(i).p = [NaN NaN NaN NaN]';
         out(i).b = [NaN NaN NaN NaN]';
      end
   end
end
