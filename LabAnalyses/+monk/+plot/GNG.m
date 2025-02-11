% Split by direction
% split by cue set

function GNG(hdr,pp,trial,epp,varargin)

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
   
   if isempty(par.handle)
      figure;
      h = subplot(2,2,1); hold on
   else
      axes(par.handle(1));
      h = par.handle(1);
   end

   if par.splitByDirection
      ind = find(indGoCTL&indAlign&indDirection&quality);
      ind = ind(randperm(numel(ind)));
      ind = ind(1:min(par.maxTrialsRaster,numel(ind)));
      [h,y] = plot(p(ind),'grpBorder',true,'handle',h,'grpColor',c(3,:),'style','marker');
      result = ep.find('func',@(x) strcmp(x.name.name,'Liftoff'));
      plot([result(ind).tStart],1:(y-1),'rx');

      ind = find(indGoCTL&indAlign&~indDirection&quality);
      ind = ind(randperm(numel(ind)));
      ind = ind(1:min(par.maxTrialsRaster,numel(ind)));
      y0 = y;
      [h,y] = plot(p(ind),'grpBorder',true,'handle',h,'yOffset',y,'grpColor',c(4,:),'style','marker');
      result = ep.find('func',@(x) strcmp(x.name.name,'Liftoff'));
      plot([result(ind).tStart],y0:(y-1),'rx');
   elseif par.splitByCueSet
      ind = find(indGoCTL&indAlign&indCueSet&quality);
      ind = ind(randperm(numel(ind)));
      ind = ind(1:min(par.maxTrialsRaster,numel(ind)));
      [h,y] = plot(p(ind),'grpBorder',true,'handle',h,'grpColor',c(3,:),'style','marker');
      result = ep.find('func',@(x) strcmp(x.name.name,'Liftoff'));
      plot([result(ind).tStart],1:(y-1),'rx');
      
      ind = find(indGoCTL&indAlign&~indCueSet&quality);
      ind = ind(randperm(numel(ind)));
      ind = ind(1:min(par.maxTrialsRaster,numel(ind)));
      y0 = y;
      [h,y] = plot(p(ind),'grpBorder',true,'handle',h,'yOffset',y,'grpColor',c(4,:),'style','marker');
      result = ep.find('func',@(x) strcmp(x.name.name,'Liftoff'));
      plot([result(ind).tStart],y0:(y-1),'rx');
   else
      ind = find(indGoCTL&indAlign&quality);
      ind = ind(randperm(numel(ind)));
      ind = ind(1:min(par.maxTrialsRaster,numel(ind)));
      [h,y] = plot(p(ind),'grpBorder',true,'handle',h,'grpColor',c(3,:),'style','marker');
      result = ep.find('func',@(x) strcmp(x.name.name,'Liftoff'));
      plot([result(ind).tStart],1:(y-1),'rx');
   end
   
   if par.splitByDirection
      ind = find(indGo&indAlign&indDirection&quality);
      ind = ind(randperm(numel(ind)));
      ind = ind(1:min(par.maxTrialsRaster,numel(ind)));
      y0 = y;
      [h,y] = plot(p(ind),'grpBorder',true,'handle',h,'yOffset',y,'grpColor',c(1,:),'style','marker');
      result = ep.find('func',@(x) strcmp(x.name.name,'Liftoff'));
      plot([result(ind).tStart],y0:(y-1),'rx');

      ind = find(indGo&indAlign&~indDirection&quality);
      ind = ind(randperm(numel(ind)));
      ind = ind(1:min(par.maxTrialsRaster,numel(ind)));
      y0 = y;
      [h,y] = plot(p(ind),'grpBorder',true,'handle',h,'yOffset',y,'grpColor',c(2,:),'style','marker');
      result = ep.find('func',@(x) strcmp(x.name.name,'Liftoff'));
      plot([result(ind).tStart],y0:(y-1),'rx');
   elseif par.splitByCueSet
      ind = find(indGo&indAlign&indCueSet&quality);
      ind = ind(randperm(numel(ind)));
      ind = ind(1:min(par.maxTrialsRaster,numel(ind)));
      y0 = y;
      [h,y] = plot(p(ind),'grpBorder',true,'handle',h,'yOffset',y,'grpColor',c(1,:),'style','marker');
      result = ep.find('func',@(x) strcmp(x.name.name,'Liftoff'));
      plot([result(ind).tStart],y0:(y-1),'rx');
      
      ind = find(indGo&indAlign&~indCueSet&quality);
      ind = ind(randperm(numel(ind)));
      ind = ind(1:min(par.maxTrialsRaster,numel(ind)));
      y0 = y;
      [h,y] = plot(p(ind),'grpBorder',true,'handle',h,'yOffset',y,'grpColor',c(2,:),'style','marker');
      result = ep.find('func',@(x) strcmp(x.name.name,'Liftoff'));
      plot([result(ind).tStart],y0:(y-1),'rx');
   else
      ind = find(indGo&indAlign&quality);
      ind = ind(randperm(numel(ind)));
      ind = ind(1:min(par.maxTrialsRaster,numel(ind)));
      y0 = y;
      [h,y] = plot(p(ind),'grpBorder',true,'handle',h,'yOffset',y,'grpColor',c(1,:),'style','marker');
      result = ep.find('func',@(x) strcmp(x.name.name,'Liftoff'));
      plot([result(ind).tStart],y0:(y-1),'rx');
   end
   
   if ~strcmp(par.alignTo,'Liftoff') && par.plotNogo
      if par.splitByDirection
         ind = find(indNogo&indAlign&indDirection&quality);
         ind = ind(randperm(numel(ind)));
         ind = ind(1:min(par.maxTrialsRaster,numel(ind)));
         [h,y] = plot(p(ind),'grpBorder',true,'handle',h,'yOffset',y,'grpColor',c(5,:),'style','marker');
         ind = find(indNogo&indAlign&~indDirection&quality);
         ind = ind(randperm(numel(ind)));
         ind = ind(1:min(par.maxTrialsRaster,numel(ind)));
         [h,y] = plot(p(ind),'grpBorder',true,'handle',h,'yOffset',y,'grpColor',c(6,:),'style','marker');
      elseif par.splitByCueSet
         ind = find(indNogo&indAlign&indCueSet&quality);
         ind = ind(randperm(numel(ind)));
         ind = ind(1:min(par.maxTrialsRaster,numel(ind)));
         [h,y] = plot(p(ind),'grpBorder',true,'handle',h,'yOffset',y,'grpColor',c(5,:),'style','marker');
         ind = find(indNogo&indAlign&~indCueSet);
         ind = ind(randperm(numel(ind)));
         ind = ind(1:min(par.maxTrialsRaster,numel(ind)));
         [h,y] = plot(p(ind),'grpBorder',true,'handle',h,'yOffset',y,'grpColor',c(6,:),'style','marker');
      else
         ind = find(indNogo&indAlign&quality);
         ind = ind(randperm(numel(ind)));
         ind = ind(1:min(par.maxTrialsRaster,numel(ind)));
         [h,y] = plot(p(ind),'grpBorder',true,'handle',h,'yOffset',y,'grpColor',c(5,:),'style','marker');
      end
   end
   
   ylim = get(gca,'ylim');
   axis([par.window ylim]);
   title(name);

   %title(['Go' ' / ' 'GoCTL' ' / ' 'Nogo']);
   if isempty(par.handle)
      h = subplot(2,2,2); hold on
   else
      axes(par.handle(2));
      hold on;
      h = par.handle(2);
   end
   
   if par.splitByDirection
      %subplot(222); hold on
      rGo = mean(smooth(p(indGo&indAlign&indDirection&quality)));
      plot(rGo.times{1},rGo.values{1},'Color',c(1,:))
      rGo = mean(smooth(p(indGo&indAlign&~indDirection&quality)));
      plot(rGo.times{1},rGo.values{1},'Color',c(2,:))
      rGoCTL = mean(smooth(p(indGoCTL&indAlign&indDirection&quality)));
      plot(rGoCTL.times{1},rGoCTL.values{1},'Color',c(3,:))
      rGoCTL = mean(smooth(p(indGoCTL&indAlign&~indDirection&quality)));
      plot(rGoCTL.times{1},rGoCTL.values{1},'Color',c(4,:))
      if ~strcmp(par.alignTo,'Liftoff') && par.plotNogo
         rNogo = mean(smooth(p(indNogo&indAlign&indDirection&quality)));
         plot(rNogo.times{1},rNogo.values{1},'Color',c(5,:))
         rNogo = mean(smooth(p(indNogo&indAlign&~indDirection&quality)));
         plot(rNogo.times{1},rNogo.values{1},'Color',c(6,:))
      end
   elseif par.splitByCueSet
      %subplot(222); hold on
      rGo = mean(smooth(p(indGo&indAlign&indCueSet&quality)));
      plot(rGo.times{1},rGo.values{1},'Color',c(1,:))
      rGo = mean(smooth(p(indGo&indAlign&~indCueSet&quality)));
      plot(rGo.times{1},rGo.values{1},'Color',c(2,:))
      rGoCTL = mean(smooth(p(indGoCTL&indAlign&indCueSet&quality)));
      plot(rGoCTL.times{1},rGoCTL.values{1},'Color',c(3,:))
      rGoCTL = mean(smooth(p(indGoCTL&indAlign&~indCueSet&quality)));
      plot(rGoCTL.times{1},rGoCTL.values{1},'Color',c(4,:))      
      if ~strcmp(par.alignTo,'Liftoff') && par.plotNogo
         rNogo = mean(smooth(p(indNogo&indAlign&indCueSet&quality)));
         plot(rNogo.times{1},rNogo.values{1},'Color',c(5,:))
         rNogo = mean(smooth(p(indNogo&indAlign&~indCueSet&quality)));
         plot(rNogo.times{1},rNogo.values{1},'Color',c(6,:))
      end
   else
      %subplot(222); hold on
      try
      rGo = mean(smooth(p(indGo&indAlign&quality)));
      plot(rGo.times{1},rGo.values{1},'Color',c(1,:));
      catch
      end
      try
      rGoCTL = mean(smooth(p(indGoCTL&indAlign&quality)));
      plot(rGoCTL.times{1},rGoCTL.values{1},'Color',c(3,:))
      catch
      end
      if ~strcmp(par.alignTo,'Liftoff') && par.plotNogo
         try
         rNogo = mean(smooth(p(indNogo&indAlign&quality)));
         plot(rNogo.times{1},rNogo.values{1},'Color',c(5,:));
         catch
         end
      end
%       if numel(h.Children) > 3
%          keyboard;
%       end
   end
   %legend({'Go' 'GoCTL' 'Nogo'})

%    goDiff{i} = rGo{i}.values{1} - rGoCTL{i}.values{1};
   
   %suptitle(name);
end
warning on;