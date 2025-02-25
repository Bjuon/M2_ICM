function ecrire_evts_ptx(S,E)
global Subject_data
%% Ecriture du fichier 'pistes techniques' (.ptx) - format Lena
% S : structure 'Sujet' avec les acquisitions et les marqueurs temporels
% E : structure 'Export' avec les evts dans la base temporelle LFP (si Triggers lfp existent)

%Initialisation
if nargin<1
    E={};
end
acqs = fieldnames(S);
N = length(acqs);

A=NaN*ones(N,1);
B=NaN*ones(N,1);
M=NaN*ones(N,1);
C=NaN*ones(N,1);

AA = repmat('A',N,1); % Triggers
BB = repmat('B',N,1); % T0
CC = repmat('C',N,1); % Foot-Contact
MM = repmat('M',N,1); % Onset_EMG

dossier = uigetdir(cd,'Choix du dossier de sauvegarde, piste technique');

%Remplissage des evts
try
    for i=1:N
        A(i) = S.(acqs{i}).Trigger;
        B(i) = S.(acqs{i}).tMarkers.T0;
        try
            M(i) = S.(acqs{i}).tMarkers.Onset_TA;
        catch ERR_noTA
            M(i) = S.(acqs{i}).tMarkers.T0 - 0.02;
        end
        C(i) = S.(acqs{i}).tMarkers.FC1;
    end
    
    %Matrice temps
    [Ts ind] = sort([A;M;B;C]);
    
    %Matrice de flags
    Flags = [AA;MM;BB;CC];
    Flags = Flags(ind);
    
    %Ecriture fichier .ptx
    save_ptx = cell2mat(inputdlg('Entrez le nom de la variable de sauvegarde','Fichier Piste Technique base PF',1,{['EEG_' Subject_data.ID '.ptx']}));
    
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
    
    for i=1:length(Ts)
        fprintf(fid,'%.2f \t %c \n',Ts(i)*1e3,Flags(i));
    end
    fclose(fid);
    
catch NO_S
    E=S;
end

if ~isempty(E)
    save_txt = cell2mat(inputdlg('Entrez le nom de la variable de sauvegarde','Fichier Piste Technique base LFP',1,{['LFP_' Subject_data.ID '.txt']}));
    A_lfp=NaN*ones(N,1);
    B_lfp=NaN*ones(N,1);
    M_lfp=NaN*ones(N,1);
    C_lfp=NaN*ones(N,1);
    %Remplissage des evts dans la base temporelle LFP
    for i=1:N
        A_lfp(i) = E.(acqs{i}).Trigger_LFP;
        B_lfp(i) = E.(acqs{i}).tTrig_T0;
        try
            M_lfp(i) = E.(acqs{i}).Onset_EMG_TA;
        catch ERR_noTA
            M_lfp(i) = E.(acqs{i}).tTrig_T0 - 0.02;
        end
        C_lfp(i) = E.(acqs{i}).tTrig_FC1;
    end
    
    %Matrice temps
    [Ts_lfp ind_lfp] = sort([A_lfp;M_lfp;B_lfp;C_lfp]);
    
    %Matrice de flags
    Flags_lfp = [AA;MM;BB;CC];
    Flags_lfp = Flags_lfp(ind_lfp);
    
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
    
    for i=1:length(Ts_lfp)
        fprintf(fid_lfp,'%.3f \t %c \n',Ts_lfp(i),Flags_lfp(i));
    end
    fclose(fid_lfp);
end
