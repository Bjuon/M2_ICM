% Load/plot data from various papers examining relation between STN LFP
% power and clinical scores.
%
% Data were obtained using FEX function 'grabit' from figure scans.
%
% 'kuhn-2009' = figure 5A from:
% Kühn A a, Tsui A, Aziz T, Ray N, Brücke C, Kupsch A, et al. (2009): 
% Pathological synchronisation in the subthalamic nucleus of patients 
% with Parkinson’s disease relates to both bradykinesia and rigidity. 
% Exp Neurol. 215: 380–7.
% 
% 'beudel-2016' = figure 1 from:
% Beudel M, Oswal A, Jha A, Foltynie T, Zrinzo L, Hariz M, et al. (2017): 
% Oscillatory Beta Power Correlates With Akinesia-Rigidity in the 
% Parkinsonian Subthalamic Nucleus. 
% Mov Disord. 32: 174–175.
% 
% 'neumann-2016' = figure 1B from:
% Neumann W-J, Degen K, Schneider G-H, Brücke C, Huebl J, Brown P, Kühn A a. 
% (2016): Subthalamic synchronized oscillatory activity correlates with motor 
% impairment in patients with Parkinson’s disease. 
% Mov Disord. 31: 1748–1751.
% 
% 'west-2016-b' = figure 4B from:
% West T, Farmer S, Berthouze L, Jha A, Beudel M, Foltynie T, et al. (2016): 
% The Parkinsonian Subthalamic Network: Measures of Power, Linear, and Non-
% linear Synchronization and their Relationship to L-DOPA Treatment and OFF 
% State Motor Severity. 
% Front Hum Neurosci. 10: 517.

function out = load(id)

str = which('gbmov.scans.load');
path = fileparts(str);

switch lower(id)
   case 'kuhn-2009'
      RAW = load(fullfile(path,'Kuhn-2009-fig5a_Oxford.csv'));
      data.clinic = RAW(:,1);
      data.lfp = RAW(:,2);
      data.site = repmat({'Oxford'},size(data.clinic,1),1);
      RAW = load(fullfile(path,'Kuhn-2009-fig5a_Berlin.csv'));
      data.clinic = [data.clinic ; RAW(:,1)];
      data.lfp = [data.lfp ; RAW(:,2)];
      data.site = cat(1,data.site,repmat({'Berlin'},size(RAW,1),1));
      
      if nargout == 0
         b = regress(data.lfp,[ones(size(data.clinic)) , data.clinic]);
         figure; hold on
         ind = strcmp(data.site,'Berlin');
         plot(data.clinic(ind),data.lfp(ind),'ko','markerfacecolor','k');
         ind = strcmp(data.site,'Oxford');
         plot(data.clinic(ind),data.lfp(ind),'o','markeredgecolor',[.7 .7 .7],...
            'markerfacecolor',[.7 .7 .7]);
         legend({'Berlin' 'Oxford'});
         axis([-5 105 -100 105]);
         plot([-5 105],b(1) + b(2)*[-5 105],'k');
         xlabel('% improvement');
         ylabel({'% change in power' 'positive = suppression on'});
      end
   case 'beudel-2016'
      [~,~,RAW] = xlsread(fullfile(path,'Beudel-2016-fig1.xlsx'));
      
      data.clinic = round(str2num([RAW{2:end,1}])');
      data.lfp = str2num([RAW{2:end,2}])';
      data.lfp(data.lfp<0) = 0;
      
      if nargout == 0
         figure; hold on
         plot(data.lfp,data.clinic,'bo','Markerfacecolor','b');
         lsline
         axis([0 2 0 25]);
         xlabel('Normalised, log-transformed 13-30 Hz LFP PSD');
         ylabel('Contralateral AR score');
      end
   case 'neumann-2016'
      RAW = load(fullfile(path,'Neumann-2016-fig1b.csv'));
      data.clinic = round(RAW(:,1));
      data.lfp = RAW(:,2);
      
      if nargout == 0
         b = regress(data.lfp,[ones(size(data.clinic)) , data.clinic]);
         figure; hold on
         plot([10 70],b(1) + b(2)*[-5 105],'-','color',[.6 .6 .6]);
         plot(data.clinic,data.lfp,'o','markersize',10,'markeredgecolor','w','Markerfacecolor','r');
         
         axis([10 70 1 4]);
         xlabel('UPDRS');
         ylabel('Relative spectral power [%]');
         disp('LFP = power in 8-35 Hz range, averaged over all channels');
      end
   case 'west-2016-b'
      [~,~,RAW] = xlsread(fullfile(path,'West-2016-fig4b.xlsx'));
      data.clinic = round(str2num([RAW{2:end,1}])');
      data.lfp = str2num([RAW{2:end,2}])';
      
      if nargout == 0
         b = regress(data.lfp,[ones(size(data.clinic)) , data.clinic]);
         figure; hold on
         plot([0 30],b(1) + b(2)*[0 30],'-','color',[.6 .6 .6]);
         plot(data.clinic,data.lfp,'ro','markersize',8);
         axis square
         axis([0 30 .1 .8]);
         xlabel('UPDRS');
         ylabel('Low Beta Power');
         disp('Clinic = OFF state UPDRS (bradykinesia/rigidity)');
         disp('LFP = integral of power in 13-20 Hz range');
      end
end

if nargout == 1
   out = data;
end