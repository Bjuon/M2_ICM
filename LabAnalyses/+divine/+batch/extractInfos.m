function infos = extractInfos(seg, infos)

nb_infos = size(infos, 1);
for n = 1 : numel(seg)
    infos.patient(nb_infos + n,1)       = {seg(n).info('trial').patient};
    infos.medication(nb_infos + n,1)    = {seg(n).info('trial').medication};
    infos.run(nb_infos + n,1)           = {seg(n).info('trial').run};
    infos.nTrial(nb_infos + n,1)        = {seg(n).info('trial').nTrial};
    infos.task(nb_infos + n,1)          = {seg(n).info('trial').task};
    infos.condition(nb_infos + n,1)     = {seg(n).info('trial').condition};
    infos.isValid(nb_infos + n,1)       = {seg(n).info('trial').isValid};
    infos.isBslValid(nb_infos + n,1)    = {seg(n).info('trial').isBslValid};
    infos.quality(nb_infos + n,1)       = {seg(n).info('trial').quality};
    infos.MovieQuality(nb_infos + n,1)  = {seg(n).info('trial').MovieQuality};
    infos.BslQuality(nb_infos + n,1)    = {seg(n).info('trial').BslQuality};
    FirstFrame  = seg(n).eventProcess.find('func',@(x) strcmp(x.name.name,'FIRSTFRAME'));
    infos.FirstFrame(nb_infos + n,1)    = {FirstFrame.tStart};
    Button      = seg(n).eventProcess.find('func',@(x) strcmp(x.name.name,'BUTTON'));
    infos.Button(nb_infos + n,1)        = {Button.tStart};
    MovieStart  = seg(n).eventProcess.find('func',@(x) strcmp(x.name.name,'MOVIE_S'));
    infos.MovieStart(nb_infos + n,1)    = {MovieStart.tStart};
    MvtStart    = seg(n).eventProcess.find('func',@(x) strcmp(x.name.name,'MVT_S'));
    infos.MvtStart(nb_infos + n,1)      = {MvtStart.tStart};
    GRASP       = seg(n).eventProcess.find('func',@(x) strcmp(x.name.name,'GRASP'));
    infos.GRASP(nb_infos + n,1)         = {GRASP.tStart};
    MvtEnd      = seg(n).eventProcess.find('func',@(x) strcmp(x.name.name,'MVT_E'));
    infos.MvtEnd(nb_infos + n,1)        = {MvtEnd.tStart};
    MovieEnd    = seg(n).eventProcess.find('func',@(x) strcmp(x.name.name,'MOVIE_E'));
    infos.MovieEnd(nb_infos + n,1)      = {MovieEnd.tStart};

end
