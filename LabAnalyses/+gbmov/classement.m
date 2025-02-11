% Sara's file locantion
% fname = 'C:\Users\gbmov\Desktop\NormaInterPlot2\coordinatesInterPlots.txt';
% ax = 'ap';
% nbins = 3;
% side = 'D';
% coord = 'stn'; %or ACPC

function [groups,labels,loc,ids] = classement(fname,m,coord,side,ax,nbins)

% read electrode localizations
labels = {'01D'    '12D'    '23D'    '01G'    '12G'    '23G'};
for i = 1:numel(m)
    Patient = m(i).PATIENTID;
%    fprintf('%s,',Patient);
    for j = 1:numel(labels)
        [ml(i,j),ap(i,j),dv(i,j)] = getDBSloc(fname,Patient(1:4),coord,labels{j});
%         fprintf('%1.2f,%1.2f,%1.2f',ml(i,j),ap(i,j),dv(i,j));
    end
    fprintf('\n')
end

eval(['dat = ' ax ';']);

% replicate array to match number of contacts
for i = 1:3
    ids(:,i) = {m.PATIENTID}';
end
labels = repmat({'01' '12' '23'},size(ids,1),1);

if strcmp(side,'D')
    ind = 1:3;
else
    ind = 4:6;
end

temp = dat(:,ind);
cuts = prctile(temp(:),(1:nbins-1)*(100/nbins));

groups = temp;
minVal = min(min(temp));
maxVal = max(max(temp));
cuts = [minVal , cuts , maxVal+1];
for i = 1:nbins
   ind = (temp>=cuts(i)) & (temp<cuts(i+1));
   groups(ind) = i;
end
loc = temp;
