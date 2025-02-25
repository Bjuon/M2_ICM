function [Succ]=ecrireAPA_xls_Claire_v3(Res,Fichier,path_template,stops,space)
%% Ecrire ds un fichier excel les resultats des tests
%Res = struct avec fields=nom des essais/conditions et pour chaque essai on a des
%paramètres

if nargin<5
    space = 20;
end

%%Extraction du nom des essais/conditions
essais=fieldnames(Res);
flag = 0;

%Chargement de la template
try
    Fichier_In = [path_template '\Template_Claire.xlsx'];
    copyfile(Fichier_In,Fichier);
    flag = 1;
catch ERR
    [Fichier_In path]= uigetfile('.xlsx','Chemin du fichier modèle?');
    Fichier_In = [path Fichier_In];
    copyfile(Fichier_In,Fichier);
    flag = 1;
end

N_total = stops(end);
A = repmat((1:N_total)',1,2);

for i = stops(1):N_total(1)
    if sum(i==stops)
        A(i,2) = space*find(stops==i)+1;
    else
        A(i,2) = A(i-1,2) + 1;
    end
end

for i=1:length(essais)
    courant=char(essais(i));
    Exc{A(i,2)+1,1}=courant;
    champs={};
    if isstruct(Res.(courant))
        champs=fieldnames(Res.(courant));
        for j=1:length(champs)
            Exc{A(i,2)+1,j}=Res.(courant).(char(champs(j)));
        end
    else
        Exc{A(i,2)+1,2}=Res.(courant);
    end
end


if flag
    [Num, Headers, Data_In] = xlsread(Fichier_In);
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