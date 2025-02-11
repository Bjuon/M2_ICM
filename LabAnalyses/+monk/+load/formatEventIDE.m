
%logname = 'Flocky_GNG_data-2017-01-31_02-47-59.txt';
%logname = 'Jules_GNG_data-2017-02-01_10-30-30.txt';
%logname = 'Flocky_GNG_data-2017-02-02_01-26-29.txt';
%logname = 'Tess_1DR_data-2017-02-02_09-39-30.txt';
%logname = 'Flocky_1DR_data-2017-02-03_11-06-08.txt';
%logname = 'Flocky_1DR_data-2017-02-07_13-15-12.txt';
trackername = '';

tic;
[hdr,logtrial,logep,window] = loadEventIDE(logname);
toc

if isempty(trackername)
   searchstr = ['*TrackerLog*' datestr(datenum(hdr.Date,'dd/mm/yyyy'),'yyyy-dd-mm') '*'...
      datestr(datenum(hdr.Time,'HH:MM'),'HH-MM') '*'];
   d = dir(searchstr);

   if numel(d) == 1
      trackername = d.name;
      %thdr = loadEventIDETracker(trackername);
   end
end

if ~isempty(trackername)
   %tic;
   [thdr,sp] = loadEventIDETracker(trackername);
   %toc
end

tic;
sp.window = window;
sp.chop();
toc



% if numel(logep) < numel(sp)
%    assert(all([logtrial.CounterTotalTrials] == 1:numel(logep)),'trial mismatch');
%    sp = sp(1:numel(logep));
% elseif numel(logep) > numel(sp)
%    error('missing trials?');
% end
% 
% 
% 
% for i = 1:10
%    tic;
%    [hdr,logtrial,logep] = loadEventIDE(logname);
%    toc
% end
% 
% % for i = 1:10
%    tic;
%    [thdr,sp] = loadEventIDETracker(trackername);
%    toc
% end
