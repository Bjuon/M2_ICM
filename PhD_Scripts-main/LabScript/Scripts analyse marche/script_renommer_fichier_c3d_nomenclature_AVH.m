% script pour renommer les noms des fichiers Vicon selon la bonne
% nomenclature :
%
% Protocole_Séance_CodeSujet_ConditionMed_ConditionVitesse_numTrial
%
% EX : GBMOV_PREOP_ABBGI01_OFF_S_01.c3d
% EX : PSPMARCHE_GAIT_05P02GF05_NA_S_01.c3d

% pour l'instant, crée de nouveaux fichiers qu'il enregistre ailleurs, et
% traitement de condition de vitesse 1 a 1 (Attention à bien copier les
% fichiers de calib et de static en plus !!)

clear;clc;
dossier_ini = uigetdir(cd,'Sélectionner le dossier de la session avec les données sources'); % se placer dans le dossier de la session du patient
cd(dossier_ini);

dossier_fin = uigetdir(dossier_ini,'Sélectionner le dossier de destination des fichiers renommés');

%%
% def = {'PARKGAME','S1','RICDi','RICDI01','NA',''}; % PARKGAME
def = {'PSPMARCHE','GAIT','SA25','22T08SA25','NA',''}; % PSPMARCHE
answer = inputdlg({'Protocole','Session','Sujet initial','Sujet renommé','Traitement','Vitesse'},'Inputs',1,def);

Lbls = {'Protocole','Session','Sujet_ini','Sujet_fin','Traitement','Vitesse'};

for i=1:size(answer,1)
    eval([Lbls{i} '= answer{' num2str(i) '};']);
end

clearvars -except dossier Protocole Session Sujet_ini Sujet_fin Traitement Vitesse dossier_ini dossier_fin

A = dir('*.x1d');
B = dir();
liste_fich = {'';''};
for i = 3 : length(B)
    liste_fich{i,1} = B(i).name(1:find(B(i).name=='.',1,'first')-1);
end

for i = 1 : length(A)
    if strfind(A(i).name,['_' char(Vitesse) '_']) % correspond à la marche à vitesse spontannée
        switch ~strcmp(Vitesse,'STATIC')
            case 1
                if isnan(str2double(A(i).name(end-5)))
                    numTrial = ['_0' A(i).name(end-4)];
                elseif ~isnan(str2double(A(i).name(end-4)))
                    numTrial = ['_' A(i).name(end-5:end-4)];
                else
                    numTrial = '';
                end
        end
        if ~isempty(numTrial)
            disp(i);
            switch Protocole
                case 'PSPMARCHE'
                    nom_fich_ini = [Protocole '_' Session '_' Sujet_ini '_' Traitement '_' Vitesse numTrial];
                case 'PARKGAME'
                    nom_fich_ini = [Protocole '_' Sujet_ini '_' Session '_GAIT_' Vitesse numTrial];
            end
            nom_fich_fin = [Protocole '_' Session '_' Sujet_fin '_' Traitement '_' Vitesse numTrial];
            [a,b,c] = matchcells(liste_fich,{A(i).name(1:end-4)},'exact');
            for k = 1:b
                if isempty(matchcells({B(a(k)).name},{[nom_fich_fin B(a(k)).name(find(B(a(k)).name=='.',1,'first'):end)]},'exact'))
                    movefile([dossier_ini '\' B(a(k)).name],[dossier_fin '\' nom_fich_fin B(a(k)).name(find(B(a(k)).name=='.',1,'first'):end)])
                end
            end
        end
    end
end