% Times are in milliseconds
classdef AllDRMonkey < metadata.Trial
   properties
      Date                   % Date from file header
      CounterTotalTrials
      CounterTrialsInBlock
      ConditionIndex
      ConditionName
      BlockIndex
      TargetIndex
      RewardIndex
      TrialResultStr
      IsRepeatTrial
      IsAbortTrial
      FixDuration
      TargetDuration
      RewardDelay
      ElapsedResponseTime %?
      RT
      TT
   end
   
   properties(Dependent=true)
      MT
      congruent
      incongruent
   end
   
   properties(SetAccess=protected)
      version = '0.1.0'
   end
   
   methods
      function self = AllDRMonkey(varargin)
         self = self@metadata.Trial;
         if nargin == 0
            return;
         end
         
         p = inputParser;
         p.KeepUnmatched = false;
         p.FunctionName = 'AllDRMonkey constructor';
         p.addParameter('Date',[],@(x) ischar(x));
         p.addParameter('CounterTotalTrials',[],@(x) isscalar(x) && isnumeric(x));
         p.addParameter('CounterTrialsInBlock',[],@(x) isscalar(x) && isnumeric(x));
         p.addParameter('ConditionIndex',[],@(x) isscalar(x));
         p.addParameter('ConditionName',[],@(x) ischar(x));
         p.addParameter('BlockIndex',[],@(x) isscalar(x));
         p.addParameter('TrialResultStr',[],@(x) ischar(x));
         p.addParameter('IsRepeatTrial',[],@(x) isscalar(x));
         p.addParameter('IsAbortTrial',[],@(x) isscalar(x));
         p.addParameter('RT',[],@(x) isscalar(x) && isnumeric(x));
         p.addParameter('TT',[],@(x) isscalar(x) && isnumeric(x));
         p.addParameter('FixDuration',[],@(x) isscalar(x) && isnumeric(x));
         p.parse(varargin{:});
         par = p.Results;
         
         fn = fieldnames(par);
         for i = 1:numel(fn)
            self.(fn{i}) = par.(fn{i});
         end
      end
      
      function MT = get.MT(self)
         MT = self.TT - self.RT;
      end
      
      function congruent = get.congruent(self)
         congruent = ((self.TargetIndex==1) & (self.RewardIndex==1)) ...
            | ((self.TargetIndex==0) & (self.RewardIndex==1));
      end
      
      function incongruent = get.incongruent(self)
         incongruent = ((self.TargetIndex==1) & (self.RewardIndex==0)) ...
            | ((self.TargetIndex==0) & (self.RewardIndex==0));
      end
      
      function [bl0,bl1,bl2,bl3,l,s] = blocklengths(self)
         nTrial = numel(self);
         if nTrial == 1
            bl = [];
            return;
         end
         
         % TODO Check trial numbers are sequential
         x = [self.BlockIndex];
         [l,s] = runlength(x);
         bl0 = l(s==0);
         bl1 = l(s==1);
         bl2 = l(s==2);
         bl3 = l(s==3);
      end
      
      function plotBasic(self,ti)
         figure;
         
         h = subplot(8,2,1);
         self.plotMetricByTrial(h,'RT',{'T0R0','T0R1'},{0 1});
         h = subplot(8,2,3);
         self.plotMetricByTrial(h,'RT',{'T0R0','T0R1'},{2 3});
         h = subplot(8,2,2);
         self.plotMetricByTrial(h,'RT',{'T1R0','T1R1'},{0 1});
         h = subplot(8,2,4);
         self.plotMetricByTrial(h,'RT',{'T1R0','T1R1'},{2 3});
         
         h = subplot(8,2,5);
         self.plotMetricByDuration(h,'Fix+Target','RT',{'T0R0','T0R1'},{0 1});
         axis tight;
         h = subplot(8,2,7);
         self.plotMetricByDuration(h,'Fix+Target','RT',{'T0R0','T0R1'},{2 3});
         axis tight;
         h = subplot(8,2,6);
         self.plotMetricByDuration(h,'Fix+Target','RT',{'T1R0','T1R1'},{0 1});
         axis tight;
         h = subplot(8,2,8);
         self.plotMetricByDuration(h,'Fix+Target','RT',{'T1R0','T1R1'},{2 3});
         axis tight;

         
         h = subplot(4,3,7);
         self.plotMetricByConditionBlock(h,'RT')
         h = subplot(4,3,8);
         self.plotMetricByConditionBlock(h,'MT')
         h = subplot(4,3,9);
         self.plotTrialBack(h);

         h = subplot(4,4,13);
         self.plotBlocklengthDistribution(h);
         h = subplot(4,4,14);
         self.plotDurationDistribution(h)
         h = subplot(4,4,15);
         self.plotAbortsByTrial(h)
         h = subplot(4,4,16);
         self.plotAbortsByCondition(h);
         
         orient landscape
         set(gcf,'paperunits','centimeters');
         set(gcf,'paperorientation','landscape');
         set(gcf,'papersize',[21.0 29.7]);
         set(gcf,'paperposition',[.25 .25 [21.0 29.7]-0.5]);
         
         if exist('ti','var')
            a = annotation('textbox', [0 0.9 1 0.1],'String',...
               ti,'EdgeColor','none','HorizontalAlignment','center',...
               'FontSize',13,'Interpreter','none');
         end
      end
      
      function plotBlocklengthDistribution(self,h)
         if nargin < 2
            h = subplot(1,1,1);
         else
            axes(h);
         end
         
         [bl0,bl1,bl2,bl3] = self.blocklengths();
         
         hold on
         maxx = 100;
         dx = 5;
         xx = [(0:dx:maxx) inf];
         
         bl = {bl0 bl1 bl2 bl3};
         for i = 1:numel(bl)
            n(:,i) = histc(bl{i},xx);
         end
         maxn = max(n)+1;
         cmaxn = [0 cumsum(maxn)];
         xx(end) = maxx+dx;
         for i = 1:numel(bl)
            g = stairs(xx,n(:,i)+cmaxn(i));
            text(dx,cmaxn(i),sprintf('Block%g',i-1),'VerticalAlignment','bottom',...
               'Fontangle','italic','color',g.Color);
         end
         
         axis([0 maxx+dx get(gca,'ylim')]);
         axis tight
         xlabel('# trials in block');
      end
      
      function plotDurationDistribution(self,h)
         if nargin < 2
            h = subplot(1,1,1);
         else
            axes(h);
         end
         
         hold on;
         maxx = 1000;
         dx = 10;
         xx = [(0:dx:maxx) inf];
         
         dur = {'FixDuration' 'TargetDuration' 'RewardDelay'};
         for i = 1:numel(dur)
            n(:,i) = histc([self.(dur{i})],xx);
         end
         maxn = max(n)+10;
         cmaxn = [0 cumsum(maxn)];
         xx(end) = maxx+dx;
         for i = 1:numel(dur)
            g = stairs(xx,n(:,i)+cmaxn(i));
            text(dx,cmaxn(i),dur{i}(1:3),'VerticalAlignment','bottom',...
               'Fontangle','italic','color',g.Color);
         end
         
         axis([0 maxx+dx get(gca,'ylim')]);
         axis tight;
         xlabel('Event duration (msec)');
      end
      
      function plotMetricByConditionBlock(self,h,metric)
         if nargin < 2
            h = subplot(1,1,1);
         elseif isempty(h)
            h = subplot(1,1,1);
         else
            axes(h);
         end
         
         condition = {self.ConditionName};
         block = [self.BlockIndex];
         
         blockStr = cellfun(@(x) num2str(x),num2cell(block),'uni',0);
         for i = 1:numel(condition)
            g{i} = [condition{i} 'B' blockStr{i}];
         end
         
         co = {'T0R0','T0R1','T1R0','T1R1','T0R0','T0R1','T1R0','T1R1'}; % Plot order
         bo = [0 1 1 0 2 3 2 3];
         go = {'T0R0B0','T0R1B1','T1R0B1','T1R1B0','T0R0B2','T0R1B3','T1R0B2','T1R1B3'}; % Plot order
         
         switch lower(metric)
            case 'rt'
               metric = [self.RT];
               ylab = 'Reaction time (msec)';
            case 'mt'
               metric = [self.MT];
               ylab = 'Movement time (msec)';
         end
         
         metric(metric==0) = NaN;                % Invalid trials
         metric([self.IsAbortTrial]==1) = NaN;   % Aborts w/ RTs
         
         for i = 1:numel(co)
            ind2 = strcmp(condition,co{i});
            ind3 = block == bo(i);
            meanMetric(i) = nanmean(metric(ind2&ind3));
            medianMetric(i) = nanmedian(metric(ind2&ind3));
         end
         
         qmin = nanmedian(metric) - 2*iqr(metric);
         qmax = nanmedian(metric) + 2*iqr(metric);
         pos = h.Position;
         boxplot(metric,g,'plotstyle','traditional','notch','on',...
            'datalim',[qmin qmax],'extrememode','compress',...
            'whisker',0,'grouporder',go,'jitter',.5,'symbol','k.');
         h.Position = pos;
         
         ylabel(ylab);
         axis([get(gca,'xlim') min(0,qmin-25) qmax+50]);
         
         hold on
         plot(1:numel(go),meanMetric,'mx');
         for i = 1:numel(go)
            t = text(i,qmax+50,sprintf('%1.1f',meanMetric(i)),...
               'HorizontalAlignment','center',...
               'VerticalAlignment','bottom',...
               'Fontangle','italic','Fontsize',6,'color','m');
            t.Units = 'points';
            s = t.Extent(4)/2.5;
            t2 = text(i,qmax+s,sprintf('%1.1f',medianMetric(i)),...
               'HorizontalAlignment','center',...
               'VerticalAlignment','bottom',...
               'Fontangle','italic','Fontsize',6,'color','r');
            t2.Units = 'points';
            t2.Position = t.Position;
            t2.Position(2) = t2.Position(2) + s;
            t.Units = 'data';
            t2.Units = 'data';
         end
      end
      
      function plotMetricByCondition(self,h,metric)
         if nargin < 2
            h = subplot(1,1,1);
         elseif isempty(h)
            h = subplot(1,1,1);
         else
            axes(h);
         end
         
         g = {self.ConditionName};
         go = {'T0R0','T0R1','T1R0','T1R1'}; % Plot order
         
         switch lower(metric)
            case 'rt'
               metric = [self.RT];
               ylab = 'Reaction time (msec)';
            case 'mt'
               metric = [self.MT];
               ylab = 'Movement time (msec)';
         end
         
         metric(metric==0) = NaN;                % Invalid trials
         metric([self.IsAbortTrial]==1) = NaN;   % Aborts w/ RTs
         
         for i = 1:numel(go)
            meanMetric(i) = nanmean(metric(strcmp(g,go{i})));
            medianMetric(i) = nanmedian(metric(strcmp(g,go{i})));
         end
         
         qmin = nanmedian(metric) - 2*iqr(metric);
         qmax = nanmedian(metric) + 2*iqr(metric);
         pos = h.Position;
         boxplot(metric,g,'plotstyle','traditional','notch','on',...
            'datalim',[qmin qmax],'extrememode','compress',...
            'whisker',0,'grouporder',go,'jitter',.5,'symbol','k.');
         h.Position = pos;
         
         ylabel(ylab);
         axis([get(gca,'xlim') qmin-25 qmax+50]);
         
         hold on
         plot(1:numel(go),meanMetric,'mx');
         for i = 1:numel(go)
            t = text(i,qmax+50,sprintf('%1.1f',meanMetric(i)),...
               'HorizontalAlignment','center',...
               'VerticalAlignment','bottom',...
               'Fontangle','italic','Fontsize',6,'color','m');
            t.Units = 'points';
            s = t.Extent(4)/2.5;
            t2 = text(i,qmax+s,sprintf('%1.1f',medianMetric(i)),...
               'HorizontalAlignment','center',...
               'VerticalAlignment','bottom',...
               'Fontangle','italic','Fontsize',6,'color','r');
            t2.Units = 'points';
            t2.Position = t.Position;
            t2.Position(2) = t2.Position(2) + s;
            t.Units = 'data';
            t2.Units = 'data';
         end
      end
      
      function plotMetricByTrial(self,h,metric,uCondition,uBlock,color,ms)
         if nargin < 2
            h = subplot(1,1,1);
         elseif isempty(h)
            h = subplot(1,1,1);
         else
            axes(h);
         end
         
         switch lower(metric)
            case 'rt'
               metric = [self.RT];
               ylab = 'Reaction time (msec)';
            case 'mt'
               metric = [self.MT];
               ylab = 'Movement time (msec)';
         end
         
         metric(metric==0) = NaN;                % Invalid trials
         metric([self.IsAbortTrial]==1) = NaN;   % Aborts w/ RTs
         
         condition = {self.ConditionName};
         block = [self.BlockIndex];
         %trial = [self.CounterTotalTrials];
         trial = 1:length(block);
         
         [~,~,~,~,l,s] = blocklengths(self);
         cl = cumsum(l);
         cl = trial(1) + [0 cl(1:end-1)+1 cl(end)];
         
         hold on;
         ex = 20;
         for i = 1:numel(uCondition)
            ind2 = strcmp(condition,uCondition{i});
            for j = 1:numel(uBlock)
               ind3 = block == uBlock{j};
               if ~any(ind2) && ~any(ind3)
                  X{i} = NaN;
                  Y{i} = NaN;
               else
                  X{i} = trial(ind2&ind3);
                  Y{i} = metric(ind2&ind3);
               end
               
               if any(ind2&ind3)
                  if exist('color','var')
                     g(i) = plot(X{i},Y{i},'.','Markersize',ms,'Color',color{i});
                  else
                     g(i) = plot(X{i},Y{i},'.','Markersize',4);
                  end
                  t = text(ex,min(max(metric(ind2&ind3)),1000),...
                     uCondition{i},'Color',g(i).Color,...
                     'HorizontalAlignment','left','FontWeight','Bold','FontAngle','Italic');
                  ex = ex + t.Extent(3) + 5;
               end
            end
         end
         %leg = legend(uCondition,'Location','southeast');
         set(gca,'yscale','log');
 
         for i = 1:numel(s)
            if ~any(cellfun(@(x) x==s(i),uBlock))
               continue;
            end
            if s(i)==1 % Block1 T0R1/T1R0
               ylim = get(gca,'ylim');
               area([cl(i) cl(i+1)],[ylim(2) ylim(2)],ylim(1),...
                  'facecolor',[.7 .7 .7],'edgecolor',[.7 .7 .7],...
                  'facealpha',.2,'edgealpha',.2);
               
               if any(strcmp(uCondition,'T0R1'))
                  ind2 = strcmp(condition,'T0R1');
               else
                  ind2 = strcmp(condition,'T1R0');
               end
               ind3 = (trial >= cl(i)) & (trial < cl(i+1));
               ind4 = block == s(i);
               m = nanmedian(metric(ind2&ind3&ind4));
               plot([cl(i) cl(i+1)],[m m],'k-');
            elseif s(i)==0      % Block0 T0R0/T1R1
               if any(strcmp(uCondition,'T0R0'))
                  ind2 = strcmp(condition,'T0R0');
               else
                  ind2 = strcmp(condition,'T1R1');
               end
               ind3 = (trial >= cl(i)) & (trial < cl(i+1));
               ind4 = block == s(i);
               m = nanmedian(metric(ind2&ind3&ind4));
               plot([cl(i) cl(i+1)],[m m],'k-');
            elseif s(i)==2      % Block2 T0R0/T1R0
               if any(strcmp(uCondition,'T0R0'))
                  ind2 = strcmp(condition,'T0R0');
               else
                  ind2 = strcmp(condition,'T1R0');
               end
               ind3 = (trial >= cl(i)) & (trial < cl(i+1));
               ind4 = block == s(i);
               m = nanmedian(metric(ind2&ind3&ind4));
               plot([cl(i) cl(i+1)],[m m],'k-');
            elseif s(i)==3      % Block3 T0R1/T1R1
               ylim = get(gca,'ylim');
               area([cl(i) cl(i+1)],[ylim(2) ylim(2)],ylim(1),...
                  'facecolor',[.7 .7 .7],'edgecolor',[.7 .7 .7],...
                  'facealpha',.2,'edgealpha',.2);

               if any(strcmp(uCondition,'T0R1'))
                  ind2 = strcmp(condition,'T0R1');
               else
                  ind2 = strcmp(condition,'T1R1');
               end
               ind3 = (trial >= cl(i)) & (trial < cl(i+1));
               ind4 = block == s(i);
               m = nanmedian(metric(ind2&ind3&ind4));
               plot([cl(i) cl(i+1)],[m m],'k-');
            end
         end
         
         ylim = get(gca,'ylim');
         axis([1 length(trial) ylim(1) min(ylim(2),1000)]);
         
         t = findobj(gca,'Type','Text');
         for i = 1:numel(t)
            t(i).Position(2) = ylim(2);
         end
         xlabel('Trial');
         ylabel(ylab);
      end
      
      function plotMetricByDuration(self,h,event,metric,uCondition,uBlock)
         if nargin < 2
            h = subplot(1,1,1);
         elseif isempty(h)
            h = subplot(1,1,1);
         else
            axes(h);
         end
         
         switch lower(metric)
            case 'rt'
               metric = [self.RT];
               ylab = 'Reaction time (msec)';
            case 'mt'
               metric = [self.MT];
               ylab = 'Movement time (msec)';
         end
         
         if strcmp(event,'Fix+Target')
            TD = [self.FixDuration] + [self.TargetDuration];
         else
            TD = [self.([event 'Duration'])];
         end
         metric(metric==0) = NaN;                % Invalid trials
         metric([self.IsAbortTrial]==1) = NaN;   % Aborts w/ RTs
         TD(isnan(metric)) = NaN;
         condition = {self.ConditionName};
         block = [self.BlockIndex];
         
         hold on;
         count = 1;
         for i = 1:numel(uCondition)
            ind2 = strcmp(condition,uCondition{i});
            for j = 1:numel(uBlock)
               ind3 = block == uBlock{j};
               if ~any(ind2) && ~any(ind3)
                  X{count} = NaN;
                  Y{count} = NaN;
               else
                  [X{count},I] = sort(TD(ind2&ind3));
                  temp = metric(ind2&ind3);
                  Y{count} = temp(I);
               end
               if sum(ind2&ind3) > 25
                  Z{count} = smooth(X{count},Y{count},25,'lowess');
               else
                  Z{count} = nan(size(X{count}));
               end
               try
                  g(count) = plot(X{count},Y{count},'.','Markersize',4);
               end
               count = count + 1;
            end
         end

         %leg = legend(uCondition,'Location','southeast');
         for i = 1:numel(g)
            try
            plot(X{i},Z{i},'-','color',g(i).Color);
            end
         end
         
         xlabel([event ' duration (msec)']);
         ylabel(ylab);
         set(gca,'xscale','log','yscale','log')
      end
      
      function plotAbortsByCondition(self,h)
         if nargin < 2
            h = subplot(1,1,1);
         else
            axes(h);
         end
         
         abort = [self.IsAbortTrial]'==1;
         res = {self.TrialResultStr}';
         condition = {self.ConditionName}';
         
         res = res(abort);
         condition = condition(abort);
         ucondition = unique(condition);
         ures = unique(res);
         c = parula(6); %parula(numel(ures));
         count = zeros(numel(ucondition),numel(ures));
         for i = 1:numel(ures)
            ind = strcmp(res,ures{i});
            for j = 1:numel(ucondition)
               ind2 = strcmp(condition,ucondition{j});
               count(j,i) = sum(ind&ind2);
            end
         end
         
         hold on;
         if ~isempty(count)
            b = bar(count,'grouped');
            for i = 1:numel(b)
               b(i).FaceColor = c(i,:);
            end
            set(gca,'xtick',1:numel(ucondition),'xticklabel',ucondition,...
               'YaxisLocation','right');
            axis tight;
         end
         ylabel('# aborts');
      end
      
      function plotAbortsByTrial(self,h)
         if nargin < 2
            h = subplot(1,1,1);
         else
            axes(h);
         end
         
         hold on;
         
         trial = [self.CounterTotalTrials]';
         abort = [self.IsAbortTrial]'==1;
         res = {self.TrialResultStr}';
         condition = {self.ConditionName}';
         
         trial = trial(abort);
         res = res(abort);
         condition = condition(abort);
         ucondition = unique(condition);
         ures = unique(res);
         c = parula(6); % parula(numel(ures));
         for i = 1:numel(ures)
            ind = strcmp(res,ures{i});
            for j = 1:numel(ucondition)
               ind2 = strcmp(condition,ucondition{j});
               switch ucondition{j}
                  case 'T0R0'
                     g = plot(trial(ind&ind2),repmat(i-.2,sum(ind&ind2),1),'o','color',c(i,:));
                  case 'T0R1'
                     g = plot(trial(ind&ind2),repmat(i+.2,sum(ind&ind2),1),'o','color',c(i,:));
                     set(g,'Markerfacecolor',g.Color);
                  case 'T1R0'
                     g = plot(trial(ind&ind2),repmat(i-.2,sum(ind&ind2),1),'v','color',c(i,:));
                  case 'T1R1'
                     g = plot(trial(ind&ind2),repmat(i+.2,sum(ind&ind2),1),'v','color',c(i,:));
                     set(g,'Markerfacecolor',g.Color);
               end
            end
            text(trial(end)+10,i,strsplit(ures{i},' '),'VerticalAlignment','middle',...
               'Fontangle','italic','Fontsize',6,'color',c(i,:));
         end
         
         xlabel('Trial');
         set(gca,'Ytick',[]);
         if ~isempty(trial)
            axis([1 trial(end)+.25*trial(end) 0 numel(ures)+1]);
         end
      end
      
      function [statval,count,patterns] = plotTrialBack(self,h,var,statistic)
         if nargin < 2
            h = subplot(1,1,1);
         elseif isempty(h)
            h = subplot(1,1,1);
         else
            axes(h);
         end
         
         if nargin < 4
            statistic = 'mean';
         end
         
         if nargin < 3
            var = 'RT';
         end
         
         abort = [self.IsAbortTrial]'==1;
         
         metric = [self.(var)]';
         metric(metric==0) = NaN;
         metric(abort) = NaN;
         
         congruent = [self.congruent]'; % TODO insert -1 for bad trials to prevent inclusion below
         
         patterns = {1 [0 1] [1 1] 0 [0 0] [1 0] [0 0 1] [0 1 1] [1 0 1] [1 1 1] [0 0 0] [1 1 0] [1 0 0] [0 1 0]};
         %patterns = {1 [0 1] [1 1] 0 [0 0] [1 0]};
         
         for i = 1:numel(patterns)
            ind = strfind(congruent',patterns{i}) + length(patterns{i}) - 1;
            if isempty(ind)
               count(i) = 0;
               statval(i) = NaN;
            else
               count(i) = numel(ind);
               switch statistic
                  case 'mean'
                     statval(i) = nanmean(metric(ind));
                  case 'median'
                     statval(i) = nanmedian(metric(ind));
               end
            end
         end
         
         hold on
         % Plot statistic at each depth
         depth = max(cellfun(@(x) numel(x),patterns));
         statval2 = stat.wmean(statval,1./count);
         plot(depth,statval2,'k.');
         %text(depth,statval2,'ALL','HorizontalAlignment','left');
         for i = 1:depth
            ind = find(cellfun(@(x) numel(x)==i,patterns));
            for j = ind
               c = 'k';
               plot(depth-i,statval(j),[c '.']);
               
               s = strrep(num2str(patterns{j}),' ','');
               s = strrep(s,'1','C');
               s = strrep(s,'0','I');
               text(depth-i,statval(j),s,'HorizontalAlignment','right',...
                  'VerticalAlignment','bottom','FontSize',8);
            end
         end
         
         % Connect lines at neighboring depths
         for i = depth:-1:1
            ind = find(cellfun(@(x) numel(x)==i,patterns));
            for j = ind
               if i == 1
                  temp = statval2;
               else
                  ind2 = find(cellfun(@(x) numel(x)==i-1,patterns));
                  tar = patterns{j}(2:end);
                  [~,I]=intersect(cat(1,patterns{ind2}),tar,'rows');
                  ind3 = ind2(I);
                  temp = statval(ind3);
               end
               
               if patterns{j}(1) == 1
                  c = 'b';
               else
                  c = 'r';
               end
               plot([depth-i depth-i+1],[statval(j) temp],[c '-']);
            end
         end
         
         for i = 1:depth
            str{i} = ['N-' num2str(depth-i)];
         end
         str{end + 1} = 'ALL';
         
         set(gca,'xtick',0:depth,'xticklabel',str,'YaxisLocation','right');
         axis tight;
         axis([-.25 depth get(gca,'ylim')]);
      end
      
      function [m_01_0,m_01_1,m_10_0,m_10_1] = transitionMat(self,var,pre,post)
         if nargin < 4
            post = 5;
         end
         if nargin < 3
            pre = 5;
         end
         if nargin < 2
            var = 'RT';
         end
         
         dates = {self.Date}';
         uDates = unique(dates);
         if numel(uDates) > 1
            m_01_0 = [];
            m_01_1 = [];
            m_10_0 = [];
            m_10_1 = [];
            for d = 1:numel(uDates)
               ind = strcmp(dates,uDates{d});
               [t_01_0,t_01_1,t_10_0,t_10_1] = transitionMat(self(ind),var,pre,post);
               m_01_0 = [m_01_0 , t_01_0];
               m_01_1 = [m_01_1 , t_01_1];
               m_10_0 = [m_10_0 , t_10_0];
               m_10_1 = [m_10_1 , t_10_1];
            end
            return;
         end
         
         metric = [self.(var)]';
         metric(metric==0) = NaN;
         abort = [self.IsAbortTrial]'==1; 
         metric(abort) = NaN;
         
         trial = [self.CounterTrialsInBlock]';
         block = [self.BlockIndex]';
         target = [self.TargetIndex]';
         trans = find(trial==1);
         
         mat0 = [];
         T = [];
         B = [];
         for i = 2:numel(trans)
            %             if i > 1
            %             end
            ind = (-pre:(post-1)) + trans(i);
            if ind(end) <= numel(metric)
               mat0 = [mat0 , metric(ind)];
               T = [T , target(ind)];
               B = [B , block(ind)];
            end
         end
         
         % Block transitions 1 -> 0
         indB = B(1,:) == 1;
         % Target = 0
         m_01_0 = mat0(:,indB);
         tempTarget = T(:,indB);
         m_01_0(~logical(tempTarget)) = NaN;
         % Target = 1
         m_01_1 = mat0(:,indB);
         tempTarget = T(:,indB);
         m_01_1(logical(tempTarget)) = NaN;
         
         % Block transitions 0 -> 1
         indB = B(1,:) == 0;
         % Target = 0
         m_10_0 = mat0(:,indB);
         tempTarget = T(:,indB);
         m_10_0(~logical(tempTarget)) = NaN;
         % Target = 1
         m_10_1 = mat0(:,indB);
         tempTarget = T(:,indB);
         m_10_1(logical(tempTarget)) = NaN;
      end
      
      function plotTransition(self,h,var,pre,post)
         if nargin < 5
            post = 5;
         end
         if nargin < 4
            pre = 5;
         end
         if nargin < 2
            h = subplot(1,1,1);
         elseif isempty(h)
            h = subplot(1,1,1);
         else
            axes(h);
         end
         
         [m_01_0,m_01_1,m_10_0,m_10_1] = transitionMat(self,var,pre,post);
         
         ind = [-pre:-1 1:post];
         subplot(121);
         hold on;
         g = plot(ind,nanmedian(m_01_0,2));
         plot(ind,nanmedian(m_01_0,2),'o','MarkerEdgeColor',g.Color,'MarkerFaceColor',g.Color);
         g = plot(ind,nanmedian(m_01_1,2));
         plot(ind,nanmedian(m_01_1,2),'o','MarkerEdgeColor',g.Color,'MarkerFaceColor',g.Color);
         plot([0 0],get(gca,'ylim'),'--');
         subplot(122);
         hold on;
         g = plot(ind,nanmedian(m_10_0,2));
         plot(ind,nanmedian(m_10_0,2),'o','MarkerEdgeColor',g.Color,'MarkerFaceColor',g.Color);
         g = plot(ind,nanmedian(m_10_1,2));
         plot(ind,nanmedian(m_10_1,2),'o','MarkerEdgeColor',g.Color,'MarkerFaceColor',g.Color);
         plot([0 0],get(gca,'ylim'),'--');
      end
      
      function t = toTable(self)
         % Remove non-data properties
         p = properties(self(1));
         ind = find(strcmp(p,'version'));
         p(ind:end) = [];
         
         for i = 1:numel(p)
            if ischar(self(1).(p{i}))
               s.(p{i}) = {self.(p{i})}';
            else
               s.(p{i}) = [self.(p{i})]';
            end
         end
         
         t = struct2table(s);
      end
      
      function print(self)
         t = toTable(self);
         disp(t);
      end
      
      function summary(self)
         t = toTable(self);
         summary(t);
      end
      
   end
end