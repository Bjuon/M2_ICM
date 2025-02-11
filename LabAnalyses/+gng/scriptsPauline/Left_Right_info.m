clear all
%cd('C:\Users\marion.albares\Desktop\LFP_analyses_Pauline');
perOp = true;
cd('C:\Users\marion.albares\Desktop\Marion_tache_GoNoGo\1_data_patients\Park_DBS\22_FISOl\2_perOp\2_preProcessed');
boucle = dir('FISOl_STN_R_sec7_0*.mat');

mapNameLR= containers.Map;


for nfile = 1:numel(boucle)
    clear s data valid spkName spkWF VarList
    load (boucle(nfile).name);
    if perOp
        s = data;
        VarList = whos('-file', boucle(nfile).name);
    end
    if(isKey(mapNameLR, boucle(nfile).name(1:5)))
        Left_Right= mapNameLR(boucle(nfile).name(1:5));
    else
        disp(['is the patient ' boucle(nfile).name(1:5) ' Right-handed: R or Left-handed: L ?'])
        Left_Right = input(' ', 's');
        mapNameLR(boucle(nfile).name(1:5))= Left_Right;
    end
    
    for trial=1:size(s,2)
        s(trial).info('Left_Right')= Left_Right;
    end
    
    if perOp
        data = s;
        save(boucle(nfile).name, VarList.name);
    else
        eval(['save ' boucle(nfile).name ' s'])
    end
end
