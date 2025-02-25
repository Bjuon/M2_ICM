%% Script pour renommer les noms des fichiers Vicon selon la bonne
% nomenclature :
%
% MaladieLieuChir_DateChir_CodeSujet_Protocole_Session_Condition_Tache_TacheCondition_numeTrial
%
% EX : ParkPitie_2020_01_16_DEp_GBMOV_POSTOP_ON_GNG_GAIT_001
%

%% Initialisation
clear all; close all; clc;

cd('C:\Users\mathieu.yeche\Desktop\VICON\LETER47\M3\Old_names')

% Dossier source 
dossier_ini = uigetdir(cd,'Sélectionner le dossier de la session avec les données sources'); % se placer dans le dossier de la session du patient
cd(dossier_ini);

% Dossier d'enregistrement
dossier_fin = uigetdir("C:\Users\mathieu.yeche\Desktop\VICON\LETER47\M3\New_names",'Sélectionner le dossier de destination des fichiers renommés');

%%
% def = {'SOUDA02','MAGIC','RLMV'}; % Pour modifier le nom du protocole et la session
% answer = inputdlg({'Sujet','Protocole','Session'},'Inputs',1,def);
% 
% Lbls = {'Sujet','Protocole','Session'};
% 
% for i=1:size(answer,1)
%     eval([Lbls{i} '= answer{' num2str(i) '};']);
% end

% clearvars -except dossier Protocole Session Sujet dossier_ini dossier_fin

A = dir('*.c3d');
B = dir();
liste_fich = {'';''};

for i = 3 : length(B)
    liste_fich{i,1} = B(i).name(1:find(B(i).name=='.',1,'first')-1);
end

for i = 1 : length(A)
    liste_fich_A{i,1} = A(i).name(1:find(A(i).name=='.',1,'first')-1);
end



% PREOP
% for i = 1 : length(A)
%             debut_nom = 'ParkRouen_2020_11_30_GUG_MAGIC'; %A(i).name(1:ind_tag(6)-1);
%             Session = 'PREOP';
%             if str2num(A(i).name(end-5:end-4)) < 8
%             Condition = 'OFF';
%             elseif str2num(A(i).name(end-5:end-4)) >= 8
%             Condition = 'ON';
%             elseif strcmp(A(i).name(end-5:end-4),'ie')
%                 Condition = 'ON';
%             end
%             if strcmp(A(i).name(end-5:end-4),'ie')
%             fin_nom =  '22copie';
%             else
%             fin_nom =  A(i).name(end-5:end-4);
%             end
%             nom_fich_fin = [debut_nom '_' Session '_' Condition '_GNG_GAIT_' fin_nom];
%             [a,b,c] = matchcells(liste_fich,{A(i).name(1:end-4)},'exact');
%             for k = 1:b
%                     copyfile([dossier_ini '\' B(a(k)).name],[dossier_fin '\' nom_fich_fin B(a(k)).name(find(B(a(k)).name=='.',1,'first'):end)]) % movefile
%             end
% end



% % M6 (differentes conditions)
% for i = 1 : length(A)
%             ind_tag = find(A(i).name=='_');
%             debut_nom = 'ParkRouen_2020_11_30_GUG_MAGIC'; %A(i).name(1:ind_tag(6)-1);
%             Session = 'M6';
%             if strcmp(A(i).name(ind_tag(2)+1:ind_tag(3)-1),'V3S1')
% %             Condition = A(i).name(ind_tag(6)+1:ind_tag(7)-1);
%             Condition = 'C1';
%             elseif strcmp(A(i).name(ind_tag(2)+1:ind_tag(3)-1),'V3S2')
%             Condition = 'C2';
%             elseif strcmp(A(i).name(ind_tag(2)+1:ind_tag(3)-1),'V3S3')
%             Condition = 'C3';
%             elseif strcmp(A(i).name(ind_tag(2)+1:ind_tag(3)-1),'V3S4')
%             Condition = 'C4';
%             elseif strcmp(A(i).name(ind_tag(2)+1:ind_tag(3)-1),'V3S5')
%             Condition = 'C5';
%             elseif strcmp(A(i).name(ind_tag(2)+1:ind_tag(3)-1),'V3S6')
%             Condition = 'C6';
%             else
%                 warning ('error condition name')
%             end
%             fin_nom =  A(i).name(ind_tag(4)+1 : find(A(i).name=='.')-1);
%             nom_fich_fin = [debut_nom '_' Session '_' Condition '_' fin_nom];
%             [a,b,c] = matchcells(liste_fich,{A(i).name(1:end-4)},'exact');
%             for k = 1:b
% %                 if isempty(matchcells({B(a(k)).name},{[nom_fich_fin B(a(k)).name(find(B(a(k)).name=='.',1,'first'):end)]},'exact'))
%                     copyfile([dossier_ini '\' B(a(k)).name],[dossier_fin '\' nom_fich_fin B(a(k)).name(find(B(a(k)).name=='.',1,'first'):end)]) % movefile
% %                 end
%             end
% %         end
% end


% M7
for i = 1 : length(A)
            ind_tag = find(A(i).name=='_');
            debut_nom = 'ParkPitie_2022_02_25_LEe_GOGAIT_M3'; %A(i).name(1:ind_tag(6)-1);
%             Session = 'M7';
%             if strcmp(A(i).name(ind_tag(3)+1:ind_tag(4)-1),'OFF')
%             Condition = 'OFF';
%             elseif strcmp(A(i).name(ind_tag(3)+1:ind_tag(4)-1),'ON')
%             Condition = 'ON';
%             else
%                 warning('pb condition')
%             end
%             if strcmp(A(i).name(ind_tag(4)+1:ind_tag(6)-1),'BLEO_GNG')
%                 tache = 'GNG_GAIT';
%             elseif strcmp(A(i).name(ind_tag(4)+1:ind_tag(6)-1),'BLEC_STAND')
%                 tache = 'BLEC_STAND' ;
%             elseif strcmp(A(i).name(ind_tag(4)+1:ind_tag(6)-1),'BLEO_STAND')
%                 tache = 'BLEO_STAND' ;
%             else
%                 warning('error tache')
%             end
           
            fin_nom =  A(i).name(ind_tag(7)+1:end-4);
%             if str2double(A(i).name(end-5:end-4)) >= 10
            nom_fich_fin = [debut_nom '_' fin_nom];
            [a,b,c] = matchcells(liste_fich,{A(i).name(1:end-4)},'exact');
            for k = 1:b
                    copyfile([dossier_ini '\' B(a(k)).name],[dossier_fin '\' nom_fich_fin B(a(k)).name(find(B(a(k)).name=='.',1,'first'):end)]) % movefile
            end
%             else
%             end
end