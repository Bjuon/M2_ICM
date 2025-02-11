[p,trial,ep,hdr] = monk.load.session('Flocky_GNG_08022018_S.pl2','Flocky_GNG_data-2018-02-08_04-10-35.txt');
cells = {'SPK_FILT_AD09_a' 'SPK_FILT_AD12_a' 'SPK_FILT_AD13_a' 'SPK_FILT_AD14_a'}

[p,trial,ep,hdr] = monk.load.session('Flocky_GNG_18072018_S.pl2','Flocky_GNG_18072018_16-38.txt');
cells = {'SPK_FILT_AD04_a'}

[p,trial,ep,hdr] = monk.load.session('Flocky_GNG_26072018_S.pl2','Flocky_GNG_26072018_16-02.txt');
cells = {'SPK_FILT_AD01_a' 'SPK_FILT_AD11_a'}

[p,trial,ep,hdr] = monk.load.session('Flocky_GNG_13082018_S.pl2','Flocky_GNG_13082018_15-34.txt');
cells = {'SPK_FILT_AD01_a' 'SPK_FILT_AD03_a' 'SPK_FILT_AD11_a'}


% [p,trial,ep,hdr] = monk.load.session('Flocky_GNG_13082018_S.pl2','Flocky_GNG_13082018_15-34.txt');
% monk.plot.GNG(hdr,p,trial,ep,'alignTo','Cue','name',{'SPK_FILT_AD01_a' 'SPK_FILT_AD03_a' 'SPK_FILT_AD11_a'})
% 
% [p,trial,ep,hdr] = monk.load.session('Flocky_GNG_08022018_S.pl2','Flocky_GNG_data-2018-02-08_04-10-35.txt');
% monk.plot.GNG(hdr,p,trial,ep,'alignTo','Cue','name',{'SPK_FILT_AD09_a' 'SPK_FILT_AD12_a' 'SPK_FILT_AD13_a' 'SPK_FILT_AD14_a'})

[p,trial,ep,hdr] = monk.load.session('Flocky_GNG_26072018_S.pl2','Flocky_GNG_26072018_16-02.txt');
cells = {'SPK_FILT_AD01_a' 'SPK_FILT_AD11_a'};


monk.plot.GNG(hdr,p,trial,ep,'alignTo','Cue','name',cells)
monk.plot.GNG(hdr,p,trial,ep,'alignTo','Cue','name',cells,'splitByCueSet',true,'plotNogo',false)

monk.plot.GNG(hdr,p,trial,ep,'alignTo','Liftoff','name',cells)
monk.plot.GNG(hdr,p,trial,ep,'alignTo','Liftoff','name',cells,'splitByDirection',true,'plotNogo',false)

'/Volumes/Data/Monkey/Electrophysiology data/SortingFH'
'/Volumes/Data/Monkey/TEMP'

[p,trial,ep,hdr] = monk.load.session('/Volumes/Data/Monkey/Electrophysiology data/SortingFH/Flocky_GNG_02072018_S.pl2','/Volumes/Data/Monkey/TEMP/Flocky_GNG_02072018_16-49.txt');
