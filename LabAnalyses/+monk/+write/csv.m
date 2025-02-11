list = monk.sessionList('Flocky','1DR','01/04/2017',[],100);

tab = [];
for i = 1:numel(list)
   [hdr,data] = monk.load.loadEventIDE(list{i});
   
   tab = [tab ; ...
      table({data.Date}',[data.CounterTotalTrials]',[data.TargetIndex]',[data.RewardIndex]',...
      [data.RT]',[data.IsAbortTrial]',...
      'VariableNames',{'Date' 'Trial' 'Tar' 'Rew' 'RT' 'abort'})...
      ];

end

writetable(tab,'Flocky.txt')

% 
% datadir = '/Volumes/Data/Monkey/TEMP';
% savedir = '/Users/brian.lau/Dropbox/Farah/';
% 
% list = monk.sessionList('Flocky','1DR','23/02/2017',[],100);
% for i = 1:numel(list)
%    eval(['!cp ' list{i} ' ' savedir]);
% end
% 
% list = monk.sessionList('Tess','1DR','23/02/2017',[],100);
% for i = 1:numel(list)
%    eval(['!cp ' list{i} ' ' savedir]);
% end
% 
% list = monk.sessionList('Chanel','1DR','23/02/2017',[],100);
% for i = 1:numel(list)
%    eval(['!cp ' list{i} ' ' savedir]);
% end
% 
% savedir = '/Users/brian.lau/Dropbox/Farah/';
% 
% list = monk.sessionList('Flocky','GNG','17/03/2017',[],100);
% for i = 1:numel(list)
%    eval(['!cp ' list{i} ' ' savedir]);
% end
% 
% list = monk.sessionList('Tess','1DR','17/03/2017',[],100);
% for i = 1:numel(list)
%    eval(['!cp ' list{i} ' ' savedir]);
% end
% 
% list = monk.sessionList('Chanel','1DR','26/04/2017',[],100);
% for i = 1:numel(list)
%    eval(['!cp ' list{i} ' ' savedir]);
% end