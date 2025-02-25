function [e e_multi]= ecrire_evts_ptx_v2(E,Res,flag)
% function [e e_multi]= ecrire_evts_ptx_v2(E,Res,flag)
global Subject_data
%% Ecriture du fichier 'pistes techniques' (.ptx) - format Lena
% E : structure 'Export' avec les evts dans les bases temporelle LFP (si Triggers lfp existent) et PF (comaptible uniquement si enregistrement continu des données PF, ex:Notocord)
% Res : structure 'Resultats' avec le champs .Cote
% flag : flag d'écriture 
%     0: base temps LFP/ecriture .ptx
%     1: base temps PF/ecriture .txt (non adapté si enregistrement non continu des données PF)
%     2: les 2

%Initialisation
if nargin<3
    flag = 0;
end
acqs = fieldnames(E);
N = length(acqs);

%PF
A=NaN*ones(N,1); 
M=NaN*ones(N,1);
B=NaN*ones(N,1); 
O=NaN*ones(N,1);
C=NaN*ones(N,1);
O2=NaN*ones(N,1);
C2=NaN*ones(N,1);

%LFP continu
A_lfp=NaN*ones(N,1);
M_lfp=NaN*ones(N,1);
B_lfp=NaN*ones(N,1);
O_lfp=NaN*ones(N,1);
C_lfp=NaN*ones(N,1);
O2_lfp=NaN*ones(N,1);
C2_lfp=NaN*ones(N,1);

%LFP Découpé (export Lena [-2 +6] autour du GO)
M_lfp_m=NaN*ones(N,1);
B_lfp_m=NaN*ones(N,1);
O_lfp_m=NaN*ones(N,1);
C_lfp_m=NaN*ones(N,1);
O2_lfp_m=NaN*ones(N,1);
C2_lfp_m=NaN*ones(N,1);

AD_lfp_m = NaN*ones(N,1);
AG_lfp_m = NaN*ones(N,1);

AAG = repmat('GG',N,1); % Départ PiedG
AAD = repmat('GD',N,1); % Départ PiedD
MM = repmat('TA',N,1); % M = Inihibition des muscles TA
BB = repmat('T0',N,1); % B = T0 - Début du mouvement de préparation
OO = repmat('TO',N,1); % O = Toe-Off du pied de départ
CC = repmat('FC',N,1); % F = Foot-Contact 1 - "Freinage"
OO2 = repmat('O2',N,1); % O2 = Toe-Off du pied d'appui
CC2 = repmat('C2',N,1); % C2 = Foot-Contact 2

dossier = uigetdir(cd,'Choix du dossier de sauvegarde, piste technique');

%Remplissage des evts dans les 2 bases temporelles
try
    for i=1:N
        %PF
        A(i) = E.(acqs{i}).Trigger;
        B(i) = E.(acqs{i}).T0;
        try
            M(i) = E.(acqs{i}).Onset_TA;
        catch ERR_noTA
            M(i) = E.(acqs{i}).T0 - 0.02;
        end
        O(i) = E.(acqs{i}).TO;
        C(i) = E.(acqs{i}).FC1;
        O2(i) = E.(acqs{i}).FO2;
        C2(i) = E.(acqs{i}).FC2;
        
        %LFP continu
        A_lfp(i) = E.(acqs{i}).Trigger_LFP;
        
        if strcmp(Res.(acqs{i}).Cote,'D') || strcmp(Res.(acqs{i}).Cote,'Droit')
            AA(i,:) = 'GD'; %  TOP/Triggers côté D
            AD_lfp_m(i) = 0; % ou 2!!
        else
            AA(i,:) = 'GG'; % TOP/Triggers côté D
            AG_lfp_m(i) = 0; % ou 2!!
        end
    
        try
            M_lfp(i) = E.(acqs{i}).tTrig_Onset_TA;
        catch ERR_noTA
            M_lfp(i) = E.(acqs{i}).tTrig_T0 - 0.02;
        end
        
        try
            B_lfp(i) = E.(acqs{i}).tTrig_T0;
            O_lfp(i) = E.(acqs{i}).tTrig_TO;
            C_lfp(i) = E.(acqs{i}).tTrig_FC1;
            O2_lfp(i) = E.(acqs{i}).tTrig_FO2;
            C2_lfp(i) = E.(acqs{i}).tTrig_FC2;
        catch err_Trig
            disp(['Synchro non résussi pour acquisition: ' acqs{i}]);
        end
        
    end
    
    %LFP découpé
    M_lfp_m = M - A;
    B_lfp_m = B - A;
    O_lfp_m = O - A;
    C_lfp_m = C - A;
    O2_lfp_m = O2 - A;
    C2_lfp_m = C2 - A;

    %Matrice temps continu
    [Ts ind] = sort([A;M;B;O;C;O2;C2]);
    [Ts_lfp ind_lfp] = sort([A_lfp;M_lfp;B_lfp;O_lfp;C_lfp;O2_lfp;C2_lfp]);
    Ts_lfp_m = [AD_lfp_m;AG_lfp_m;M_lfp_m;B_lfp_m;O_lfp_m;C_lfp_m;O2_lfp_m;C2_lfp_m];
    
    %Matrice de flags
    Flags = [AA;MM;BB;OO;CC;OO2;CC2];
    
    Flags_pf = Flags(ind);
    Flags_lfp = Flags(ind_lfp,:);
    Flags_lfp_m = [AAD;AAG;MM;BB;OO;CC;OO2;CC2];
    
    if flag==0 || flag==2
        %Ecriture fichier .ptx
        save_ptx = cell2mat(inputdlg('Entrez le nom de la variable de sauvegarde','Fichier Piste Technique base LFP',1,{[Subject_data.ID '.ptx']}));
        
        if exist([dossier '\' save_ptx],'file')
            button = questdlg('Choix d''écriture ?','Fichier technique déjà existant','Ecraser','Fusionner','Ecraser');
            if strcmp(button,'Fusionner') %OUvrir en mode 'append'
                fid=fopen([dossier '\' save_ptx],'a');
            else
                fid=fopen([dossier '\' save_ptx],'w');
            end
        else
            fid=fopen([dossier '\' save_ptx],'w');
        end
        
        for i=1:length(Ts_lfp)
            fprintf(fid,'%.2f \t %s \n',Ts_lfp(i),Flags_lfp(i,:));
        end
        fclose(fid);

    elseif flag==1
        save_txt = cell2mat(inputdlg('Entrez le nom de la variable de sauvegarde','Fichier Piste Technique base PF',1,{['EEG_' Subject_data.ID '.txt']}));
        
        if exist([dossier '\' save_txt],'file')
            button = questdlg('Choix d''écriture ?','Fichier technique déjà existant','Ecraser','Fusionner','Ecraser');
            if strcmp(button,'Fusionner') %OUvrir en mode 'append'
                fid_lfp=fopen([dossier '\' save_txt],'a');
            else
                fid_lfp=fopen([dossier '\' save_txt],'w');
            end
        else
            fid_lfp=fopen([dossier '\' save_txt],'w');
        end
        
        for i=1:length(Ts)
            fprintf(fid_lfp,'%.3f \t %c \n',Ts(i)*1e3,Flags_pf(i,:));
        end
        fclose(fid_lfp);
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
        
        Evt = unique(Evts.tags,'rows');
        
        if length(Evt)==7 % Départ tjs du même pied
            comments = {'Fin cycle Initiation' 'Foot-Contact1' 'Trigger Sonore' 'Décollement du 2ème pied' 'Début du mouvement' 'Inhibition muscles TA' 'Décollement Orteil'}; %celon l'ordre de Evt
            colors = {'#000000' '#000001' '#000010' '#000100' '#001000' '#010000' '#100000'};
        else % Départ alternés
            comments = {'Fin cycle Initiation' 'Foot-Contact1' 'Trigger Sonore - Départ Droit' 'Trigger Sonore - Départ Gauche' 'Décollement du 2ème pied' 'Début du mouvement' 'Inhibition muscles TA' 'Décollement Orteil'}; %celon l'ordre de Evt
            colors = {'#000000' '#000001' '#000010' '#000011' '#000100' '#001000' '#010000' '#100000'};
        end
        
        %Extraction pour chaque Evt
        for evts=1:length(Evt)
            times = extrait_evt_piste_technique(Evts,{Evt(evts,:)});
            times(isnan(times)) = [];
            
            times_m = extrait_evt_piste_technique(Evts_multi,{Evt(evts,:)});
            
            e.events(evts).label= Evt(evts,:);
            e_multi.events(evts).label= Evt(evts,:);
            try
                e.events(evts).comments = comments{evts};
                e.events(evts).color = colors{evts};
                
                e_multi.events(evts).comments = comments{evts};
                e_multi.events(evts).color = colors{evts};
            catch ERR
                e.events(evts).comments = Evt(evts,:);
                e.events(evts).color = '#000000';
                
                e_multi.events(evts).comments = Evt(evts,:);
                e_multi.events(evts).color = '#000000';
            end
            
            e.events(evts).epochs = zeros(1,length(times));
            e.events(evts).times = times';
            e.events(evts).duration = zeros(1,length(times)); %% pour l'instant on laisse à 0
            e.events(evts).offset = zeros(1,length(times)); %% pour l'instant on laisse à 0
            
            e_multi.events(evts).epochs = find(~isnan(times_m))' - 1;
            times_m(isnan(times_m)) = [];
            e_multi.events(evts).times = times_m';
            e_multi.events(evts).duration = zeros(1,length(times_m)); %% pour l'instant on laisse à 0
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
