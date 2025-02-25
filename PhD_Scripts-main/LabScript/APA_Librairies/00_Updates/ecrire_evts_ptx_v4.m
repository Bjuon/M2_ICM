function [e e_multi]= ecrire_evts_ptx_v4(E,Liste_evts)
% function [e e_multi]= ecrire_evts_ptx_v3(E,Liste_evts)
%% Fonction qui va exporter l'ensemble des évènements enregistrés dans une structure évènement .lena et un fichier piste technique (.ptx)
% E : structure 'Export' avec les evts dans les bases temporelle LFP (si Triggers lfp existent) et PF (comaptible uniquement si enregistrement continu des données PF, ex:Notocord)
% Liste_evts : cellule contenant la liste des évènements relevés

global Subject_data

%% Initialisation
if nargin<3
    flag = 0;
end
acqs = fieldnames(E);
N = length(acqs);

for i=1:length(Liste_evts)
    eval([Liste_evts{i} '= repmat({NaN},N,1);']); % Base PF (utile uniquement si enregistrement continu sous VICON (ou NOTOCORD)
    eval([Liste_evts{i} '_lfp = repmat({NaN},N,1);']); % Base LFP
    eval([Liste_evts{i} '_lfp_m = repmat({NaN},N,1);']); % Base LFP découpé (relatif)
    eval([Liste_evts{i} '_tag = repmat(Liste_evts(i),N,1);']); % Tags des evts
end

dossier = uigetdir(cd,'Choix du dossier de sauvegarde, piste technique');

%% Remplissage des evts dans les 2 bases temporelles
try
    for i=1:N
        for e=1:length(Liste_evts)
            %PF
            try
                eval([Liste_evts{e} '{i} = E.(acqs{i}).tPF.' Liste_evts{e}]);
            catch ERR_noTA
                disp(['PF: Evenement ' Liste_evts{e} ' absent acquisition ' acqs{i}]);
            end
            
            %LFP continu
            try
                eval([Liste_evts{e} '_lfp{i} = E.(acqs{i}).tLFP.' Liste_evts{e}]);
            catch ERR_noTA
                disp(['LFP: Evenement ' Liste_evts{e} ' absent acquisition ' acqs{i}]);
            end
            
            %LFP découpé
            try
                eval([Liste_evts{e} '_lfp_m{i} = E.(acqs{i}).tLFP_dec.' Liste_evts{e}]);
            catch ERR_noTA
                disp(['LFP_dec: Evenement ' Liste_evts{e} ' absent acquisition ' acqs{i}]);
            end
        end
    end
    
    %Matrice temps continu
    command_pf=[];
    command_lfp=[];
    command_lfp_dec=[];
    command_tags=[];
    for e=1:length(Liste_evts)
        command_pf = [command_pf Liste_evts{e} ';'];
        command_lfp = [command_lfp Liste_evts{e} '_lfp;'];
        command_lfp_dec = [command_lfp_dec Liste_evts{e} '_lfp_m;'];
        command_tags = [command_tags Liste_evts{e} '_tag;'];
    end
    eval(['Flags_lfp_m = [' command_tags(1:end-1) '];']);
    eval(['[Ts Flags_pf] = rearrange_cells2mat([' command_pf(1:end-1) '],Flags_lfp_m);']);
    eval(['[Ts_lfp Flags_lfp] = rearrange_cells2mat([' command_lfp(1:end-1) '],Flags_lfp_m);']);
    eval(['Ts_lfp_m = [' command_lfp_dec(1:end-1) '];']);
        
    %% Ecriture fichier .ptx
    save_ptx = cell2mat(inputdlg('Entrez le nom de la variable de sauvegarde','Fichier Piste Technique base Temps LFP',1,{[Subject_data.ID '.ptx']}));
    try
        if exist([dossier filesep save_ptx],'file')
            button = questdlg('Choix d''écriture ?','Fichier technique déjà existant','Ecraser','Fusionner','Ecraser');
            if strcmp(button,'Fusionner') %OUvrir en mode 'append'
                fid=fopen([dossier filesep save_ptx],'a');
            else
                fid=fopen([dossier filesep save_ptx],'w');
            end
        else
            fid=fopen([dossier filesep save_ptx],'w');
        end
        
        for i=1:length(Ts_lfp)
            fprintf(fid,'%.2f \t %s \n',Ts_lfp(i),Flags_lfp{i});
        end
        fclose(fid);
    catch err_ptx_write
        disp('Pas d''écriture .ptx!');
    end
    
    %% Création de la structure Evènements pour le fichier .lena (e_lena)
    try
        e={};
        e_multi = {};
        e.bad_channels = []; %% Mettre le nom des mauvaises channels (si besoin)
        e_multi.bad_channels = [];

        Evts.tags = Flags_lfp;
        Evts.Temps = Ts_lfp;

        Evts_multi.tags = Flags_lfp_m;
        Evts_multi.Temps = Ts_lfp_m;

        %Extraction pour chaque Evt
        for evts=1:length(Liste_evts)
            times = extrait_evt_piste_technique_v2(Evts,Liste_evts(evts));
            try
                times(isnan(times)) = [];
            catch
            end
            
            % Fichier Continu
            times_m = extrait_evt_piste_technique_v2(Evts_multi,Liste_evts(evts));
            e.events(evts).label= Liste_evts{evts};
            [e.events(evts).comments e.events(evts).color] = add_comment_lena(Liste_evts{evts});            
            e.events(evts).epochs = zeros(1,length(times));
            e.events(evts).times = times';
            e.events(evts).duration = zeros(1,length(times)); %% pour l'instant on laisse à 0
            e.events(evts).offset = zeros(1,length(times)); %% pour l'instant on laisse à 0

            % Fichier Essais découpés
            e_multi.events(evts).label= Liste_evts{evts};
            [e_multi.events(evts).comments e_multi.events(evts).color] = add_comment_lena(Liste_evts{evts});
            [times_m e_multi.events(evts).epochs] = find_epochs(times_m); 
            times_m(isnan(times_m)) = [];
            e_multi.events(evts).times = times_m';
            e_multi.events(evts).duration = zeros(1,length(times_m)); %% pour l'instant on laisse à 0 (A voir pour le FOG)
            e_multi.events(evts).offset = zeros(1,length(times_m)); %% pour l'instant on laisse à 0

        end
        e.classfiles = [];
        e_multi.classfiles = [];
    catch Err_lena
        disp('Erreur ecriture structure lena!');
        e_multi = {};
    end
catch NO_S
    disp('Erreur ecriture pistes techniques');
    e_multi = {};
    e = {};
end
