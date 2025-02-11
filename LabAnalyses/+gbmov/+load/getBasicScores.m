function out = getBasicScores(condition)

[datadir,infodir] = gbmov.getPaths();
%condition = 'ON';
tasks = {'BASELINEASSIS'};
info = gbmov.PatientInfo('path',infodir);

%%
band = [5 12; 8 35 ; 13 20 ; 21 30];
exclude = [49 51];
normalize = struct('fmin',4,'fmax',95,'method','integral');
dB = false;
psd = 'raw';
for i = 1:info.n
   id = info.clinicInfo(i).PATIENTID;
   for j = 1:numel(tasks)
      d = dir([datadir '/' id '*' tasks{j} '*' condition '*.mat']);
      
      if (numel(d) == 1)
         out(i).id = id;
         out(i).condition = condition;
         
         temp = load(fullfile(datadir,d.name));
         out(i).labels = temp.PSD.labels_;
         out(i).p = temp.PSD.measureInBand(band,'psd',psd,'exclude',exclude,...
            'measure','integral','dB',dB,'normalize',normalize);
         
         % non-lateralized
         out(i).UPDRSIII_ON = repmat(info.info(id).UPDRSIII_ON,1,numel(out(i).labels));
         out(i).UPDRSIII_OFF = repmat(info.info(id).UPDRSIII_OFF,1,numel(out(i).labels));
         out(i).UPDRSIII_IMPROV = repmat(info.info(id).UPDRSIII_IMPROV,1,numel(out(i).labels));
         out(i).BRADYKINESIA_OFF = repmat(info.info(id).BRADYKINESIA_OFF,1,numel(out(i).labels));
         out(i).BRADYKINESIA_ON = repmat(info.info(id).BRADYKINESIA_ON,1,numel(out(i).labels));
         out(i).RIGIDITY_OFF = repmat(info.info(id).RIGIDITY_OFF,1,numel(out(i).labels));
         out(i).RIGIDITY_ON = repmat(info.info(id).RIGIDITY_ON,1,numel(out(i).labels));
         out(i).TREMOR_OFF = repmat(info.info(id).TREMOR_OFF,1,numel(out(i).labels));
         out(i).TREMOR_ON = repmat(info.info(id).TREMOR_ON,1,numel(out(i).labels));
         out(i).AXIAL_OFF = repmat(info.info(id).AXIAL_OFF,1,numel(out(i).labels));
         out(i).AXIAL_ON = repmat(info.info(id).AXIAL_ON,1,numel(out(i).labels));
         out(i).BR_OFF = repmat(info.info(id).BR_OFF,1,numel(out(i).labels));
         out(i).BR_ON = repmat(info.info(id).BR_ON,1,numel(out(i).labels));
         out(i).BR_IMPROV = repmat(info.info(id).BR_IMPROV,1,numel(out(i).labels));
         out(i).LDOPA = repmat(info.info(id).LDOPA,1,numel(out(i).labels));
         out(i).UPDRSIV = repmat(info.info(id).UPDRSIV,1,numel(out(i).labels));
         
         % NOTE CONTRALATERAL
         out(i).BR_CONTRA_OFF = nan(1,numel(out(i).labels));
         out(i).BR_CONTRA_ON = nan(1,numel(out(i).labels));
         ind = strcmp({out(i).labels.side},'right');
         if any(ind)
            out(i).BR_CONTRA_OFF(ind) = info.info(id).BR_OFF_L;
            out(i).BR_CONTRA_ON(ind) = info.info(id).BR_ON_L;
         end
         ind = strcmp({out(i).labels.side},'left');
         if any(ind)
            out(i).BR_CONTRA_OFF(ind) = info.info(id).BR_OFF_R;
            out(i).BR_CONTRA_ON(ind) = info.info(id).BR_ON_R;
         end
         
         x = []; y = []; z = [];
         out(i).X = []; out(i).Y = []; out(i).Z = [];
         for k = 1:numel(out(i).labels)
            [x,y,z] = info.loc(id(1:4),'STN',out(i).labels(k).name);
            out(i).X = [out(i).X , x];
            out(i).Y = [out(i).Y , y];
            out(i).Z = [out(i).Z , z];
         end
      else
         out(i).id = id;
      end
   end
end