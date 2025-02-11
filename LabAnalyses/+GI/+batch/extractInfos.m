function infos = extractInfos(seg, infos)
global segType

nb_infos = size(infos, 1);
for n = 1 : numel(seg)
    infos.patient(nb_infos + n,1)     = {seg(n).info('trial').patient};
    infos.medication(nb_infos + n,1)  = {seg(n).info('trial').medication};
    infos.run(nb_infos + n,1)         = {seg(n).info('trial').run};
    infos.nTrial(nb_infos + n,1)      = {seg(n).info('trial').nTrial};
    infos.task(nb_infos + n,1)        = {seg(n).info('trial').task};
    infos.condition(nb_infos + n,1)   = {seg(n).info('trial').condition};
    infos.segment(nb_infos + n,1)     = {seg(n).info('trial').segment};
    infos.side(nb_infos + n,1)        = {seg(n).info('trial').side};
    infos.nStep(nb_infos + n,1)       = {seg(n).info('trial').nStep};
    infos.isValid(nb_infos + n,1)     = {seg(n).info('trial').isValid};
    infos.quality(nb_infos + n,1)     = {seg(n).info('trial').quality};
    if strcmp(segType, 'trial') || strcmp({seg(n).info('trial').segment}, 'step')
        infos.FO(nb_infos + n,1)      = cellfun(@(x) [x.tStart], (linq(seg(n)).select(@(x) x.eventProcess.find('func',@(x) strcmp(x.name.name, 'FO'),'policy','all')).toList)', 'uni', 0);
    else
        infos.FO(nb_infos + n,1)      = {[]};
    end
end
