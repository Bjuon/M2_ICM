function [Succ]=ecrireAPA_xls_Claire(Res,Fichier,path_template)
%% Ecrire ds un fichier excel les resultats des tests
%Res = struct avec fields=nom des essais/conditions et pour chaque essai on a des
%paramètres
%%Extraction du nom des essais/conditions
essais=fieldnames(Res);
flag = 0;

%Chargement de la template
try
    Fichier_in = [path_template '\Template_Claire.xlsx'];
    copyfile(Fichier_in,Fichier);
    flag = 1;
catch ERR
    [path Fichier_In]= uigetfile('.xlsx','Chemin du fichier modèle?');
    copyfile(Fichier_In,Fichier);
    flag = 1;
end

for i=1:length(essais)
    courant=char(essais(i));
    Exc{i+1,1}=courant;
    champs={};
    if isstruct(Res.(courant))
        champs=fieldnames(Res.(courant));
        for j=1:length(champs)
            Exc{i+1,j}=Res.(courant).(char(champs(j)));
        end
    else
        Exc{i+1,2}=Res.(courant);
    end
end


if flag
    [Num, Headers, Data_In] = xlsread(Fichier_in);
    Exc(1,:) = Headers(1,:);
else
    if ~isempty(champs)
        for k=1:length(champs)
            Exc{1,k}=char(champs(k));
        end
    end
end
Succ=xlswrite(Fichier,Exc);

end 