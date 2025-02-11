
%% Get paths to data & load clinical data
[datadir,infodir,savedir] = gbmov.getPaths();
conditions = {'OFF' 'ON'};
tasks = {'BASELINEASSIS'};
info = gbmov.PatientInfo('path',infodir);

overwrite = false;

%% Generic Spectrum parameters
step = 4; % section size in seconds
rawParams = struct('hbw',.75,'robust','huber','detrend','linear',...
   'reshape',true,'reshape_hw',1,'reshape_nhbw',6);
baseParams = struct('method','broken-power','smoother','none');

for i = 1:info.n
   id = info.clinicInfo(i).PATIENTID;
   
   if isnan(id)
      continue;
   end
   
   for j = 1:numel(tasks)
      for k = 1:numel(conditions)
         
         d = dir(fullfile(datadir,[id '*' tasks{j} '*' conditions{k} '*.mat']));
         d.name
         
         try
            if numel(d) == 1
               if ~overwrite
                  if exist(fullfile(savedir,[d.name(1:end-7) 'PSD.mat'])) == 2
                     continue;
                  else
                     d.name
                  end
               end
               load(fullfile(datadir,d.name));
               % Specific Spectrum parameters
               if (data(1).Fs == 512) && strcmp(info.info(id).HARDWARE,'Porti')
                  rawParams.f = 0:.01:138;          % Based on aliasing cutoff
                  rawParams.reshape_f = [50 100 , info.info(id).EXTRALINES];
                  baseParams.fmax = 138;
                  baseParams.method = 'broken-power';
                  H = @(f) abs(sinc(f./data(1).Fs)).^3.^2;
               elseif (data(1).Fs == 512) && strcmp(info.info(id).HARDWARE,'Basis')
                  rawParams.f = 0:.01:250;
                  rawParams.reshape_f = [50 100 150 200 , info.info(id).EXTRALINES];
                  baseParams.fmax = 200;
                  baseParams.method = 'broken-power1';
                  H = [];
               elseif data(1).Fs == 1024 % PORTI Fs = 1024
                  rawParams.f = 0:.01:276;          % Based on aliasing cutoff
                  rawParams.reshape_f = [50 100 150 200 , info.info(id).EXTRALINES];
                  baseParams.fmax = 276;
                  baseParams.method = 'broken-power1';
                  H = @(f) abs(sinc(f./data(1).Fs)).^3.^2;
               else                      % PORTI Fs = 512
                  rawParams.f = 0:.01:552;          % Based on aliasing cutoff
                  rawParams.reshape_f = [50 100 150 200 , info.info(id).EXTRALINES];
                  baseParams.fmax = 552;
                  baseParams.method = 'broken-power1';
                  H = @(f) abs(sinc(f./data(1).Fs)).^3.^2;
               end
               
               PSD = Spectrum('input',data,'step',step,...
                  'rawParams',rawParams,'baseParams',baseParams,'filter',H);
               if exist('artifacts','var')
                  PSD.rejectParams = struct('artifacts',artifacts);
               end
               
               % estimate
               tic;PSD.run;toc
               PSD.compact();
               PSD.input = d.name;
               
               % save
               savestr = [d.name(1:end-7) 'PSD.mat'];
               save(fullfile(savedir,savestr),'PSD');
               
               % plot
               PSD.plotDiagnostics;
               h = gcf;
               fig.suptitle([id ' ' tasks{j} ' ' conditions{k} ' ' num2str(data(1).Fs)]);
               h.PaperOrientation = 'landscape';
               savestr = [d.name(1:end-7) 'PSD'];
               
               print(h,'-dpdf','-fillpage',fullfile(savedir,savestr));
               close(h);
               
               clear PSD;
               if isfield(baseParams,'fmax')
                  basParams = rmfield(baseParams,'fmax');
               end
            elseif numel(d) > 0
               error('Should not have more than one file');
            end
         catch
            keyboard
            continue;
         end
         
      end
   end
end
%
% 2048
% broken-power1 (fixed to zero, negative beta(2), positive beta(3))
%
% 512 porti
%
% 512 basis
% broken-power1 (fixed to zero, negative beta(2), positive beta(3))
% extend frequency to nyquist, and restrict bend to around 90?