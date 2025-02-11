%patients = {'RAYTh' 'VANPa' 'DESMa'};
patients = {'RAYTh'};

eventNames = {'tTargetOn' 'tCueOn' 'tCueOff'};
events = {{'name' 'target'} {'name' 'cue'} {'name' 'cue' 'eventStart' false}};

for i = 1:numel(patients)
   clear s b;
   cd(['/Volumes/Data/Human/STN/' patients{i} '/Postop']);
   
   info = filterFilename(pwd,'condition','ON','filetype','.mat');
   
   if ~isempty(info)
      fnames = buildFilename(info);
      fnames = fnames{1}(1:end-5);
      data = gbmov.load.msup(fnames);
      keyboard
      i
      tic;
      for k = 1:numel(events)
         if k == 1
            [s.(eventNames{k}),b] = gbmov.myspect2(data,eventNames{k},events{k}{:});
         else
            s.(eventNames{k}) = gbmov.myspect2(data,eventNames{k},events{k}{:});
         end
      end
      save(['/Users/brian/Documents/Work/Data/STN/Post/' patients{i} 'ON_spectrogram'],'s','b');
      toc
   end
   
   clear s b;
   info = filterFilename(pwd,'condition','OFF','filetype','.mat');
   if ~isempty(info)
      fnames = buildFilename(info);
      fnames = fnames{1}(1:end-5);
      data = gbmov.load.msup(fnames);
      i
      tic;
      for k = 1:numel(events)
         if k == 1
            [s.(eventNames{k}),b] = gbmov.myspect2(data,eventNames{k},events{k}{:});
         else
            s.(eventNames{k}) = gbmov.myspect2(data,eventNames{k},events{k}{:});
         end
      end
      save(['/Users/brian/Documents/Work/Data/STN/Post/' patients{i} 'OFF_spectrogram'],'s','b');
      toc
   end
end

