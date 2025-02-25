function [Succ]=ecrireQR_xls(Res,Fichier,sheet)
%% Ecrire ds un fichier excel les resultats des tests
%Res = struct avec fields=nom des essais/conditions et pour chaque essai on a des
%paramètres
%%Extraction du nom des essais/conditions
essais=fieldnames(Res);
Exc={};
for i=1:length(essais)
    courant=char(essais(i));
    Exc{i+1,1}=courant;
    champs={};
    if isstruct(Res.(courant))
        champs=fieldnames(Res.(courant));
        for j=1:length(champs)
            Exc{1,j+1}=char(champs(j));
            Exc{i+1,j+1}=Res.(courant).(char(champs(j)));
        end
    else
        Exc{i+1,2}=Res.(courant);
    end
end

Exc{1,1}=Fichier(1:end-4); 
% if ~isempty(champs)
%     for k=1:length(champs)
%         Exc{1,k+1}=char(champs(k));
%     end
% end

if nargin==2
    sheet = 'Sheet1';
end

%% Ecriture du fichier .xls
if ismac %% Si MAC; alors on localise les classes (.jar) et les ajoute au path java
    loc_jxl = which('jxl.jar');
    loc_mxl = which('MXL.jar');
    javaaddpath(loc_jxl);
    javaaddpath(loc_mxl);
    Succ=xlwrite(Fichier,Exc,sheet);
else
    Succ=xlswrite(Fichier,Exc,sheet);
end

end 