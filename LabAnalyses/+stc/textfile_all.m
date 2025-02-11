function textfile_all(array)
%converts array from function array_all into text file to read with R:
% 1)patient name        2)pathology         3)side
% BURST
% 4)burst rate          5)Burst index       6)firing rate      7) spikes in bursts
% PAUSE
% 8)number of pauses    9)pause duration    10)pause rate        
% REGULARITY
% 11)cv value           12)lvr value        13)cv2              14)lv

array = stc.array_all;
%update burstpausereg.txt with new data
fileID = fopen('burstpausereg.txt','w');
formatSpec = '%s,%s,%s,%6.4f,%6.4f,%6.4f,%6.4f,%6.4f,%6.4f,%6.4f,%6.4f,%6.4f,%6.4f,%6.4f\n';
nrows = length(array);
for row = 1
    %title row
    fprintf(fileID,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n',array{row,:});
for row = 2:nrows
    fprintf(fileID,formatSpec,array{row,:});
end
fclose(fileID);
end