function seg = labelCorrection(seg)

% temp  = [seg.sampledProcess];
% uLabels = unique(cat(2,temp.labels),'stable');

labels     = seg(1).sampledProcess.labels;
LabelNames = {labels.name};


for t = 2:numel(seg)
    tmpNames = {seg(t).sampledProcess.labels.name};
    if isempty(setdiff(LabelNames, tmpNames))
        seg(t).sampledProcess.labels = labels;
    else
        error(['labels of segment ' num2str(t) ' differs from 1st segment'])
    end
end