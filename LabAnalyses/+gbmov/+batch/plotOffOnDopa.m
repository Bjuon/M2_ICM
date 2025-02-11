%% Get paths to data & load clinical data
[~,infodir,savedir] = gbmov.getPaths();
datadir = '/Users/brian/Dropbox/Spectrum4';
conditions = {'OFF' 'ON'};
tasks = {'BASELINEASSIS'};
info = gbmov.PatientInfo('path',infodir);

overwrite = false;

set(0,'DefaultTextInterpreter','none');
for i = 1:info.n
   id = info.clinicInfo(i).PATIENTID;
   for j = 1:numel(tasks)
      
      dOFF = dir([datadir '/' id '*' tasks{j} '*OFF*.mat']);
      dON = dir([datadir '/' id '*' tasks{j} '*ON*.mat']);
      try
         if (numel(dOFF) == 1) && (numel(dON) == 1)
            if ~overwrite
               if exist(fullfile(savedir,[dOFF.name(1:end-11) 'OFF_ON_PSD.pdf'])) == 2
                  continue;
               else
                  d.name
               end
               
            end
            
            
            OFF = load(fullfile(datadir,dOFF.name));
            ON = load(fullfile(datadir,dON.name));
            
            gbmov.plot.psdOffOnDopa(OFF.PSD,ON.PSD);
            
            h = gcf;
            fig.suptitle({dOFF.name dON.name})
            h.PaperOrientation = 'landscape';
            savestr = [dOFF.name(1:end-7) 'ON_PSD'];
            print(h,'-dpdf','-fillpage',fullfile(savedir,savestr));
            close(h);
         end
      catch
         continue;
      end
   end
end
