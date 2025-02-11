% function data_temp = step2_spectral(protocol, subject, data, e, norm)
function dataTF = spectral_normalize(dataCO, dataCO_BSL, norm)

global tBlock

TF  = [dataCO.dataCO.spectralProcess];
BSL = [dataCO_BSL.dataCO.spectralProcess];
Bsl.ntrial     = arrayfun(@(x) x.info('trial').nTrial, dataCO_BSL.dataCO, 'uni', 0)';
Bsl.med        = arrayfun(@(x) x.info('trial').medication, dataCO_BSL.dataCO, 'uni', 0)';

winBsl  = [0  0.5 + tBlock] -tBlock/2;
trials    = arrayfun(@(x) x.info('trial').nTrial, dataCO.dataCO);
for t = 1:numel(trials)
    med    = dataCO.dataCO(t).info('trial').medication;
    nTrial = dataCO.dataCO(t).info('trial').nTrial;
    idx_t  = find((strcmp(Bsl.med, med) & [Bsl.ntrial{:}]' == nTrial) == 1);
    if isempty(idx_t)
        error ('idx_t is empty')
    end
    bslTFadd(t) = BSL(idx_t);
end


% normalize
if norm == 1
    TF.normalize(0,'method','z-score','Process', bslTFadd,'window',winBsl); 
elseif norm == 2
    TF.normalize(0,'method','subtract','Process', bslTFadd,'window',winBsl);
elseif norm == 3 || norm == 4
    TF.normalize(0,'method','divide','Process', bslTFadd,'window',winBsl);
end
TF.fix();


% Exctract Event Process
EVTs = [dataCO.dataCO.eventProcess];

%% Recreate segment

for trial = 1:numel(TF)
    if ~exist('dataTF')
        dataTF(1) = Segment('process',{...
            TF(trial),...
            EVTs(trial)},...
            'labels',{'CO' 'Evt'});
        dataTF(1).info('trial') = dataCO.dataCO(trial).info('trial');
    else
        dataTF(end+1) = Segment('process',{...
            TF(trial),...
            EVTs(trial)},...
            'labels',{'CO' 'Evt'});
        dataTF(end).info('trial') = dataCO.dataCO(trial).info('trial');
    end
    
    
    %TF(1).plot('log', false)
end

