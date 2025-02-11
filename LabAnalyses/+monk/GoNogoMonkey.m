% Times are in milliseconds
classdef GoNogoMonkey < metadata.Trial
   properties
      Date                   % Date from file header
      CounterTotalTrials
      CounterTrialsInBlock
      BlockedMode
      probStayGoNogo
      probStayGoCtl
      probGo
      BlockIndex
      CueSetIndex
      ConditionIndex
      ConditionName
      TrialResult
      TrialResultStr
      IsCorrectTrial
      IsIncorrectTrial
      IsAbortTrial
      IsRepeatTrial
      Retouch
      FixDuration
      CueDuration
      RewardDelay
      TarX
      TarY
      RT
      RT2
      TT
   end
   
   properties(Dependent=true)
      MT
   end
   
   properties(SetAccess=protected)
      version = '0.3.0'
   end
   
   methods
      function self = GoNogoMonkey(varargin)
         self = self@metadata.Trial;
         if nargin == 0
            return;
         end
         
         p = inputParser;
         p.KeepUnmatched = false;
         p.FunctionName = 'GoNogoMonkey constructor';
         p.addParameter('Date',[],@(x) ischar(x));
         p.addParameter('CounterTotalTrials',[],@(x) isscalar(x) && isnumeric(x));
         p.addParameter('CounterTrialsInBlock',[],@(x) isscalar(x) && isnumeric(x));
         p.addParameter('ConditionIndex',[],@(x) isscalar(x));
         p.addParameter('ConditionName',[],@(x) ischar(x));
         p.addParameter('BlockedMode',[],@(x) isscalar(x));
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
      
      function [bl0,bl1,l,s] = blocklengths(self)
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
      end
      
      function plotBasic(self,ti)
         figure;
         
         h = subplot(4,2,1);
         self.plotMetricByTrial(h,'RT',{'Go' 'Go control'},'left')
         h = subplot(4,2,2);
         self.plotMetricByTrial(h,'RT',{'Go' 'Go control'},'right')
         
         h = subplot(4,2,3);
         self.plotMetricByDuration(h,'Fix','RT',{'Go' 'Go control'},'left')
         axis tight;
         h = subplot(4,2,4);
         self.plotMetricByDuration(h,'Fix','RT',{'Go' 'Go control'},'right')
         axis tight;
         
         h = subplot(4,3,7);
         self.plotMetricByCondition(h,'RT');
         h = subplot(4,3,8);
         self.plotMetricByCondition(h,'MT');
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
      
      function plotMetricByTrial(self,h,metric,uCondition,side)
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
         
         if ~isempty(self(1).TarX)
            tarX = [self.TarX];
            if strcmp(side,'left')
               indSide = tarX < 0;
            else
               indSide = tarX >= 0;
            end
         else
            indSide = true(size(metric));
         end
         
         metric(metric==0) = NaN;                % Invalid trials
         metric([self.IsAbortTrial]==1) = NaN;   % Aborts w/ RTs
         
         condition = {self.ConditionName};
         trial = [self.CounterTotalTrials];
         
         [~,~,l,s] = blocklengths(self);
         cl = cumsum(l);
         cl = trial(1) + [0 cl(1:end-1)+1 cl(end)];
         
         hold on;
         ex = 20;
         for i = 1:numel(uCondition)
            ind2 = indSide & strcmp(condition,uCondition{i});
            if ~any(ind2)
               X{i} = NaN;
               Y{i} = NaN;
            else
               X{i} = trial(ind2);
               Y{i} = metric(ind2);
            end
            if any(ind2)
               g(i) = plot(X{i},Y{i},'.','Markersize',4);
               t = text(ex,max(metric(ind2)),uCondition{i},'Color',g(i).Color,...
               'HorizontalAlignment','left','FontWeight','Bold','FontAngle','Italic');
            	ex = ex + t.Extent(3) + 5;
            end
         end
         %leg = legend(uCondition,'Location','southeast');
         set(gca,'yscale','log');
         
         for i = 1:numel(s)
            if s(i)==1 % Block1 Mixed
               ylim = get(gca,'ylim');
               area([cl(i) cl(i+1)],[ylim(2) ylim(2)],ylim(1),...
                  'facecolor',[.7 .7 .7],'edgecolor',[.7 .7 .7],...
                  'facealpha',.2,'edgealpha',.2);
               
               if any(strcmp(uCondition,'Go'))
                  ind2 = indSide & strcmp(condition,'Go');
               end
               ind3 = (trial >= cl(i)) & (trial < cl(i+1));
               m = nanmedian(metric(ind2&ind3));
               plot([cl(i) cl(i+1)],[m m],'k-');
            else       % Block0 Control
               if any(strcmp(uCondition,'Go control'))
                  ind2 = indSide & strcmp(condition,'Go control');
               end
               ind3 = (trial >= cl(i)) & (trial < cl(i+1));
               m = nanmedian(metric(ind2&ind3));
               plot([cl(i) cl(i+1)],[m m],'k-');
            end
         end
         
         ylim = get(gca,'ylim');
         axis([trial(1) trial(end) get(gca,'ylim')]);
         
         t = findobj(gca,'Type','Text');
         for i = 1:numel(t)
            t(i).Position(2) = ylim(2);
         end
         xlabel('Trial');
         ylabel(ylab);
      end
      
      function plotMetricByDuration(self,h,event,metric,uCondition,side)
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
         
         if ~isempty(self(1).TarX)
            tarX = [self.TarX];
            if strcmp(side,'left')
               indSide = tarX < 0;
            else
               indSide = tarX >= 0;
            end
         else
            indSide = true(size(metric));
         end
         
         if strcmp(event,'Fix+Cue')
            TD = [self.FixDuration] + [self.TargetDuration];
         else
            TD = [self.([event 'Duration'])];
         end
         metric(metric==0) = NaN;                % Invalid trials
         metric([self.IsAbortTrial]==1) = NaN;   % Aborts w/ RTs
         TD(isnan(metric)) = NaN;
         condition = {self.ConditionName};
         
         hold on;
         for i = 1:numel(uCondition)
            ind2 = indSide & strcmp(condition,uCondition{i});
            if ~any(ind2)
               X{i} = NaN;
               Y{i} = NaN;
            else
               [X{i},I] = sort(TD(ind2));
               temp = metric(ind2);
               Y{i} = temp(I);
            end
            if sum(ind2) > 25
               Z{i} = smooth(X{i},Y{i},25,'lowess');
            else
               Z{i} = nan(size(X{i}));
            end
            g(i) = plot(X{i},Y{i},'.','Markersize',4);
         end
         %leg = legend(uCondition,'Location','southeast');
         for i = 1:numel(g)
            plot(X{i},Z{i},'-','color',g(i).Color);
         end
         
         xlabel([event ' duration (msec)']);
         ylabel(ylab);
         set(gca,'xscale','log','yscale','log')
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
         if ~isempty(self(1).TarX)
            tarX = [self.TarX];
            indSide = tarX < 0;
         else
            indSide = true(size(g));
         end

         if all(indSide)
            [g{strcmp(g,'Go')}] = deal('Go');
            [g{strcmp(g,'Go control')}] = deal('GoCtl');
            go = {'GoCtl' 'Go'}; % Plot order
         else
            [g{indSide&strcmp(g,'Go')}] = deal('Go(L)');
            [g{~indSide&strcmp(g,'Go')}] = deal('Go(R)');
            [g{indSide&strcmp(g,'Go control')}] = deal('GoCtl(L)');
            [g{~indSide&strcmp(g,'Go control')}] = deal('GoCtl(R)');
            go = {'GoCtl(L)' 'Go(L)' 'GoCtl(R)' 'Go(R)'}; % Plot order
         end
         
         switch lower(metric)
            case 'rt'
               metric = [self.RT];
               ylab = 'Reaction time (msec)';
               ymin = 175;
            case 'mt'
               metric = [self.MT];
               ylab = 'Movement time (msec)';
               ymin = 50;
         end
         
         correct = [self.IsCorrectTrial];
         abort = [self.IsAbortTrial]==1;
         
         % Restrict to conditions with reaction times
         ind = zeros(size(correct));
         for i = 1:numel(go)
            ind = ind + strcmp(g,go{i});
         end
         ind = logical(ind);
         g(~ind) = [];
         correct(~ind) = [];
         abort(~ind) = [];
         
         metric(metric==0) = NaN;                % Invalid trials
         metric([self.IsAbortTrial]==1) = NaN;   % Aborts w/ RTs
         metric(~ind) = [];                      % Remove conditions not requested (ie, nogo)
         metric(~correct) = NaN;
         
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
      
      function [statval,count,patterns] = plotTrialBack(self,h)
         if nargin < 2
            h = subplot(1,1,1);
         elseif isempty(h)
            h = subplot(1,1,1);
         else
            axes(h);
         end
         
         abort = [self.IsAbortTrial]'==1;
         
         if isempty(self(1).IsIncorrectTrial)
            correct = logical([self.IsCorrectTrial]');
            incorrect = ~correct;
            incorrect(abort) = false;
         else
            incorrect = [self.IsIncorrectTrial]'==1;
         end
         
         gomix = [self.BlockIndex]'==1;
         go = [self.ConditionIndex]'==1;
         nogo = [self.ConditionIndex]'==2;
         
         % TODO Incorrect trials...
         metric = [self.RT]';
         metric(metric==0) = NaN;
         metric(abort) = NaN;
         
         try
         metricgoctl = metric(~gomix);
         metric(~gomix) = [];
         go(~gomix) = [];
         go = double(go);
         incorrect(~gomix) = [];
         catch; keyboard; end
         %          metric = 1./(metric);
         %          metricgoctl = 1./(metricgoctl);
         %          metric = log10(metric);
         %          metricgoctl = log10(metricgoctl);
         
         %go((go==1) & incorrect) = -1; % Since incorrects are repeated,
         %cannot have incorrect nogo followed by go, all = incorrect
         %go/correct go
         go(incorrect) = -1;
         go(abort) = -2;
         patterns = {1 -1 [0 1] [1 1] [-1 1] [0 0 1] [0 1 1] [1 0 1] [1 1 1]};
         
         for i = 1:numel(patterns)
            ind = strfind(go',patterns{i}) + length(patterns{i}) - 1;
            if isempty(ind)
               count(i) = 0;
               statval(i) = NaN;
            else
               count(i) = numel(ind);
               %statval(i) = nanmedian(metric(ind));
               statval(i) = nanmean(metric(ind));
            end
         end
         
         hold on
         % Plot statistic at each depth
         depth = max(cellfun(@(x) numel(x),patterns));
         statval2 = nanmean(metric(go==1));%stat.wmean(statval,1./count);%
         plot(depth,statval2,'k.');
         %text(depth,statval2,'IncorrectG','HorizontalAlignment','left');
         for i = 1:depth
            ind = find(cellfun(@(x) numel(x)==i,patterns));
            for j = ind
               c = 'k';
               plot(depth-i,statval(j),[c '.']);
               
               s = strrep(num2str(patterns{j}),' ','');
               s = strrep(s,'1','G');
               s = strrep(s,'0','N');
               text(depth-i,statval(j),s,'HorizontalAlignment','right',...
                  'VerticalAlignment','bottom','FontSize',8);
            end
         end
         plot([0 depth],[nanmean(metricgoctl) nanmean(metricgoctl)],'g');
         text(0,nanmean(metricgoctl),'GOCTL','HorizontalAlignment','right',...
            'VerticalAlignment','middle');
         
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
         axis([-.25 depth get(gca,'ylim')]);
      end
      
      function plotBlocklengthDistribution(self,h)
         if nargin < 2
            h = subplot(1,1,1);
         else
            axes(h);
         end
         
         [bl0,bl1] = self.blocklengths();
         
         hold on
         maxx = 100;
         dx = 5;
         xx = [(0:dx:maxx) inf];
         
         bl = {bl0 bl1};
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
         
         dur = {'FixDuration' 'CueDuration' 'RewardDelay'};
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
      
      function [ucondition, ures] = plotAbortsByCondition(self,h)
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
                  case 'Go'
                     g = plot(trial(ind&ind2),repmat(i+.2,sum(ind&ind2),1),'o','color',c(i,:));
                  case 'Go control'
                     g = plot(trial(ind&ind2),repmat(i+.2,sum(ind&ind2),1),'o','color',c(i,:));
                     set(g,'Markerfacecolor',g.Color);
                  case 'Nogo'
                     g = plot(trial(ind&ind2),repmat(i-.2,sum(ind&ind2),1),'v','color',c(i,:));
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