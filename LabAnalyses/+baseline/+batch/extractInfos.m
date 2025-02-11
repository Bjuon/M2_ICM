function infos = extractInfos(seg, infos)

nb_infos = size(infos, 1);
for n = 1 : numel(seg)
    infos.patient(nb_infos + n,1)     = {seg(n).info('trial').patient};
    infos.medication(nb_infos + n,1)  = {seg(n).info('trial').medication};
    infos.run(nb_infos + n,1)         = {seg(n).info('trial').run};
    infos.nTrial(nb_infos + n,1)      = {seg(n).info('trial').nTrial};
    infos.condition(nb_infos + n,1)   = {seg(n).info('trial').condition};
    infos.side(nb_infos + n,1)        = {seg(n).info('trial').side};
    infos.nStep(nb_infos + n,1)       = {seg(n).info('trial').nStep};
    infos.isValid(nb_infos + n,1)     = {seg(n).info('trial').isValid};
    infos.quality(nb_infos + n,1)     = {seg(n).info('trial').quality};
end
