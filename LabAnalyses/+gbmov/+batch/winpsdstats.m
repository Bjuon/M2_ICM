% Script to loop over patients, load in spectra, and calculate statistics

clear all
if ispc
   basedir = 'X:\Human\STN\MATLAB';
   savedir = 'X:\Human\STN\MATLAB';
   locfile = 'C:\Users\gbmov\Desktop\LFP_repos\NormaInterPlot2\coordinatesInterPlots.txt';
else
   basedir = '/Volumes/Data/Human/STN/MATLAB';
   savedir = '/Volumes/Data/Human/STN/MATLAB';
   locfile = '/Users/brian/Downloads/coordinatesInterPlots.txt';
end

overwrite = true;
conditions = {'OFF' 'ON'};
tasks = {'BASELINEASSIS' 'BASELINEDEBOUT'};%{'BASELINEASSIS' 'BASELINEDEBOUT' 'REACH' 'MSUP'};

normalize = true;
normalize_range = [90 120]; % normalize each channel to this band
frequency_range = [8 35]; % specifies frequency band for statistics

% Clinical scores
[NUM,TXT,RAW] = xlsread(fullfile(savedir,'PatientInfo.xlsx'));
labels = RAW(1,:);
RAW(1,:) = [];
n = size(RAW,1);
for i = 1:numel(labels)
   [info(1:n).(labels{i})] = deal(RAW{:,i});
end
fn = fieldnames(info);

for i = 1:numel(info)
   i
   for j = 1:numel(tasks)
      for k = 1:numel(conditions)
         
         % PASEl & CLANi need to be normalized differently
%          if strcmp(info(i).PATIENTID,'CLANi') && strcmp(tasks{j},'BASELINEASSIS')
%             out = gbmov.winpsdstats('patient',info(i).PATIENTID,'basedir',basedir,'savedir',savedir,...
%                'condition',conditions{k},'task',tasks{j},'normalize_range',[1 50],'frequency_range',frequency_range);
%          elseif strcmp(info(i).PATIENTID,'PASEl')
%             out = gbmov.winpsdstats('patient',info(i).PATIENTID,'basedir',basedir,'savedir',savedir,...
%                'condition',conditions{k},'task',tasks{j},'normalize_range',[1 50],'frequency_range',frequency_range);
%          else
            out = gbmov.winpsdstats('patient',info(i).PATIENTID,'basedir',basedir,'savedir',savedir,...
               'condition',conditions{k},'task',tasks{j},'normalize',normalize,...
               'normalize_range',normalize_range,'frequency_range',frequency_range);
%          end
         
         for n = 1:numel(fn)
            m(i).(fn{n}) = info(i).(fn{n});
         end
                  
         if ~isempty(out)
            m(i).(tasks{j}).(conditions{k}).Fs = out.Fs;
            m(i).(tasks{j}).(conditions{k}).origFs = out.origFs;
            m(i).(tasks{j}).(conditions{k}).L_peakLoc = out(1).peakLoc;
            m(i).(tasks{j}).(conditions{k}).L_peakMag = out(1).peakMag;
            m(i).(tasks{j}).(conditions{k}).L_peakDetected = out(1).peakDetected;
            m(i).(tasks{j}).(conditions{k}).L_truePeak = out(1).truePeak;
            m(i).(tasks{j}).(conditions{k}).L_bandmax = out(1).bandmax;
            m(i).(tasks{j}).(conditions{k}).L_bandavg = out(1).bandavg;
            m(i).(tasks{j}).(conditions{k}).L_offavg = out(1).offavg;
            m(i).(tasks{j}).(conditions{k}).L_power = out(1).power;
            m(i).f = out(1).f;
            
            m(i).(tasks{j}).(conditions{k}).R_peakLoc = out(2).peakLoc;
            m(i).(tasks{j}).(conditions{k}).R_peakMag = out(2).peakMag;
            m(i).(tasks{j}).(conditions{k}).R_peakDetected = out(2).peakDetected;
            m(i).(tasks{j}).(conditions{k}).R_truePeak = out(2).truePeak;
            m(i).(tasks{j}).(conditions{k}).R_bandmax = out(2).bandmax;
            m(i).(tasks{j}).(conditions{k}).R_bandavg = out(2).bandavg;
            m(i).(tasks{j}).(conditions{k}).R_offavg = out(2).offavg;
            m(i).(tasks{j}).(conditions{k}).R_power = out(2).power;
            m(i).f = out(2).f;
         else
            m(i).(tasks{j}).(conditions{k}).Fs = 0;
            m(i).(tasks{j}).(conditions{k}).origFs = 0;
            m(i).(tasks{j}).(conditions{k}).L_peakLoc = nan(1,3);
            m(i).(tasks{j}).(conditions{k}).L_peakMag = nan(1,3);
            m(i).(tasks{j}).(conditions{k}).L_peakDetected = nan(1,3);
            m(i).(tasks{j}).(conditions{k}).L_truePeak = nan(1,3);
            m(i).(tasks{j}).(conditions{k}).L_bandmax = nan(1,3);
            m(i).(tasks{j}).(conditions{k}).L_bandavg = nan(1,3);
            m(i).(tasks{j}).(conditions{k}).L_offavg = nan(1,3);
            m(i).(tasks{j}).(conditions{k}).L_power = nan(1,3);
            
            m(i).(tasks{j}).(conditions{k}).R_peakLoc = nan(1,3);
            m(i).(tasks{j}).(conditions{k}).R_peakMag = nan(1,3);
            m(i).(tasks{j}).(conditions{k}).R_peakDetected = nan(1,3);
            m(i).(tasks{j}).(conditions{k}).R_truePeak = nan(1,3);
            m(i).(tasks{j}).(conditions{k}).R_bandmax = nan(1,3);
            m(i).(tasks{j}).(conditions{k}).R_bandavg = nan(1,3);
            m(i).(tasks{j}).(conditions{k}).R_offavg = nan(1,3);
            m(i).(tasks{j}).(conditions{k}).R_power = nan(1,3);
         end
      end
   end
end


ax = {'ap' 'ml' 'dv'};
for i = 1:numel(ax)
    [groups,labels,loc] = gbmov.classement(locfile,m,'stn','D',ax{i},3);
    for j = 1:numel(m)
        m(j).R_labels = labels(i,:);
        m(j).(['R_class_' ax{i}]) = groups(j,:);
        m(j).(['R_loc_' ax{i}]) = loc(j,:);
    end
    [groups,labels,loc] = gbmov.classement(locfile,m,'stn','G',ax{i},3);
    for j = 1:numel(m)
        m(j).L_labels = labels(i,:);
        m(j).(['L_class_' ax{i}]) = groups(j,:);
        m(j).(['L_loc_' ax{i}]) = loc(j,:);
    end
end



