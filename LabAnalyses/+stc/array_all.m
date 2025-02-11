function array = array_all
%creates an array of:
% 1)patient name        2)pathology         3)side
% BURST
% 4)burst rate          5)Burst index       6)firing rate      7) spikes in bursts
% PAUSE
% 8)number of pauses    9)pause duration    10)pause rate        
% REGULARITY
% 11)cv value           12)lvr value        13)cv2              14)lv

import spk.*

%title row
array = [cellstr('patient') cellstr('pathology') cellstr('side')...
    cellstr('burst rate') cellstr('burst index') cellstr('firing rate') cellstr('percent spike')...
    cellstr('num pause') cellstr('pause duration') cellstr('pause rate')...
    cellstr('cv') cellstr('lvr') cellstr('cv2') cellstr('lv')];

file1 = dir('*Right*.mat');
file2 = dir('*Left*.mat');
files = [file2; file1];

% files = dir('*.mat')
%uncomment if new point process files from batch_spikeana1_Stacie are
%in separated folder from original dat structures

for numfiles = 1:numel(files)
    fileName = files(numfiles).name;
    load(fileName);
    %disp(fileName);
    
    % 1)patient
    patient = cellstr(p.info('patient'));
    
    % 2)pathology
    patho = cellstr(p.info('pathology'));
    
    % 3)side
        side = cellstr(p.info('side'));
    
    % 4)burst rate
    rate = num2cell((p.info('total_burstLS').num_bursts)/(p.tEnd));
    burst_rate = cell2mat(rate);
    
    % 5)burst index
    ISI = p.intervals{1};
    burst_index = mean(ISI)/mode(ISI);
    
    % 6)firing rate
    firing_rate = p.count / p.tEnd;
    
    % 7)spike in burst
    a = p.info('total_burstLS');
    b = struct2cell(a);
    b = cell2mat(b(8));
    percent_spk = b*100;
    
    % 8)num pauses
    times = p.times;
    pauses = spk.detectPause(times);
    pause_times = pauses.times2;
    num_pause = size(pause_times,1);
    
    % 9)pause duration
    duration = [];
    if num_pause == 0
        duration = 0;
    else
        for i = 1:num_pause
            dur = pause_times(i,2)- pause_times(i,1);
            newDur = [duration,dur];
            duration = mean(newDur);
        end
    end
    
    % 10pause rate
    rate = num2cell((num_pause)/(p.tEnd));
    pause_rate = cell2mat(rate);
    
    % 11-14)regularity
    x = p.apply(@(x) spk.regularity(x,'method',{'cv' 'lvr' 'cv2' 'lv'}));
    y = struct2cell(x);
    y = cell2mat(y);
   
    newArray = [array;[patient patho side burst_rate burst_index firing_rate percent_spk...
        num_pause duration pause_rate y(1) y(2) y(3) y(4)]];
    %add new a row to the existing arraw
    array = newArray;
     
end
%return array
array
end




