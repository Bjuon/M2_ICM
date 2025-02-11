% Preprocess raw LFP data
%
% Todo:
%   o should store rejections?
%   o allow manual rejections?
%
function preprocess(varargin)

%% Parameters
p = inputParser;
p.KeepUnmatched = true;
addParameter(p,'basedir',pwd,@ischar);
addParameter(p,'savedir',pwd,@ischar);
addParameter(p,'area','',@ischar);
addParameter(p,'patient','',@ischar);
addParameter(p,'recording','',@ischar);
addParameter(p,'protocol','',@ischar);
addParameter(p,'task','',@ischar);
addParameter(p,'condition','',@ischar);
addParameter(p,'run','',@isscalar);

% Preprocessing
addParameter(p,'trim',0,@(x) isscalar(x) || (numel(x)==2));
addParameter(p,'deline',false,@islogical);
addParameter(p,'threshold',300,@isscalar);
addParameter(p,'resample',512,@isscalar);
%highpass
addParameter(p,'Fpass',1,@isscalar);
addParameter(p,'Fstop',0.01,@isscalar);

% Additional info to store in SampledProcess
addParameter(p,'data',[]);
addParameter(p,'dataName',@ischar);

% Saving
addParameter(p,'overwrite',false,@islogical);

parse(p,varargin{:});
p = p.Results;

%% Matching files
info = filterFilename(fullfile(p.basedir,p.area,p.patient,p.recording));
info = filterFilename(info,'protocol',p.protocol,'task',...
   p.task,'condition',p.condition,'run',p.run,'filetype',{'.edf' '.Poly5'});
if isempty(info)
   fprintf('No files matching conditions\n');
   return;
end
files = buildFilename(info);

if ~isempty(files)
   % Savename
   ind = findstr(files{1},'_RUN');
   [~,fname] = fileparts(files{1}(1:ind-1));
   fname = [fname '_PRE'];
   
   if exist(fullfile(p.savedir,[fname '.mat']),'file') && ~p.overwrite
      fprintf('File found, skipping\n');
      return;
   else
       fprintf('Processing %s\n',fname);
   end
   
   switch lower(p.task)
      case {'msup'}
         seg = gbmov.load.makeSegmentsMsup(files,p);
         s = horzcat(seg{:});
         labels = s(1).sampledProcess.labels;
         for i = 1:numel(s)
            s(i).sampledProcess.labels = labels;
         end
      otherwise
         % load each run, keep as separate object
         for i = 1:numel(files)
            s(i) = loadSingleRun(files{i},p);
            
            % TODO: allow for each run to have different data
            if not(isempty(p.data))
               if isempty(p.dataName)
                  s(i).info('data') = p.data;
               else
                  s(i).info(p.dataName) = p.data;
               end
            end
         end
         
         % TODO: match labels
         if numel(s) > 1
            labels = s(1).labels;
            names = {labels.name};
            for i = 2:numel(s)
               labels2 = s(i).labels;
               names2 = {labels2.name};
               bool = cellfun(@(x,y) all(x==y),names,names2,'uni',true);
               if all(bool)
                  s(i).labels = labels;
               else
                  error('Mismatching labels!');
               end
            end
         end
   end
   
   data = s;
   % Save
   save(fullfile(p.savedir,fname),'data');
   
   clear s data;
else
   warning('requested, but not found');
end
