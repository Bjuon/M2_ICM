function infos = extractInfos(seg, infos)

nb_infos = size(infos, 1);
for n = 1 : numel(seg)
    infos.patient(nb_infos + n,1)     = {seg(n).info('trial').patient};
    infos.medication(nb_infos + n,1)  = {seg(n).info('trial').medication};
    infos.run(nb_infos + n,1)         = {seg(n).info('trial').run};
    infos.nTrial(nb_infos + n,1)      = {seg(n).info('trial').nTrial};
    infos.condition(nb_infos + n,1)   = {seg(n).info('trial').condition};
    infos.speed(nb_infos + n,1)       = {seg(n).info('trial').speed};
    infos.isRest(nb_infos + n,1)      = {seg(n).info('trial').isRest};
    infos.isRestValid(nb_infos + n,1) = {seg(n).info('trial').isRestValid};
    infos.isDoor(nb_infos + n,1)      = {seg(n).info('trial').isDoor};
    infos.distDoor(nb_infos + n,1)    = {seg(n).info('trial').distDoor};
    infos.DoorCond(nb_infos + n,1)    = {seg(n).info('trial').DoorCond};
    infos.isGaitValid(nb_infos + n,1) = {seg(n).info('trial').isGaitValid};
    infos.quality(nb_infos + n,1)     = {seg(n).info('trial').quality};
    infos.RestQuality(nb_infos + n,1) = {seg(n).info('trial').RestQuality};
    infos.GaitQuality(nb_infos + n,1) = {seg(n).info('trial').GaitQuality};
    ButtonTimes = seg(n).eventProcess.find('func',@(x) strcmp(x.name.name,'BUTTON'));
    infos.ButtonStart(nb_infos + n,1) = {ButtonTimes.tStart};
    RestTimes = seg(n).eventProcess.find('func',@(x) strcmp(x.name.name,'REST'));
    infos.RestStart(nb_infos + n,1)   = {RestTimes.tStart};
    infos.RestEnd(nb_infos + n,1)     = {RestTimes.tEnd};
    GaitTimes = seg(n).eventProcess.find('func',@(x) strcmp(x.name.name,'GAIT'));
    infos.GaitStart(nb_infos + n,1)   = {GaitTimes.tStart};
    infos.GaitEnd(nb_infos + n,1)     = {GaitTimes.tEnd};
    DoorTimes = seg(n).eventProcess.find('func',@(x) strcmp(x.name.name,'DOOR'));
    infos.DoorStart(nb_infos + n,1)   = {DoorTimes.tStart};
    
end
