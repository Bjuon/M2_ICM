function S_norm = normalise_APA_v2(GD)
%% Si une structure contient les m�mes champs � +ieurs reprises alors on normalise la dimension des donn�es vecteurs � la m�me taille
% Entr� : GD structure contenant un group de donn�es r�p�t�es � plusieurs reprises (par acquisition == 1er champ de la structure)
% Sortie: S_norm strcuture dont tous les vecteurs d'un m�me champ contiennent la m�me taille

acquisitions = fieldnames(GD); %Extraction des noms des acqs choisies
datas = fieldnames(GD.(acquisitions{1})); %Extraction des donn�es stock�es

%Initialisation
S_norm = GD;
dim = NaN*ones(length(acquisitions),1);
debut = ones(length(acquisitions),1);
fin = ones(length(acquisitions),1);
%% Extraction et normalisation des donn�es vecteurs
for i = 1:length(acquisitions)
    try
        t_0 = GD.(acquisitions{i}).t(1);
        debut(i) = round((GD.(acquisitions{i}).tMarkers.T0-t_0)*GD.(acquisitions{i}).Fech)-10; %On prend syst�matiquement 10 points (ou 20ms) avant T0
        if debut(i)<=0
            debut(i) = 1;
        end
    catch ERr
        debut(i) = 1;
    end
%     fin(i) = round((GD.(acquisitions{i}).tMarkers.FC2-t_0)*GD.(acquisitions{i}).Fech)+100; %On prend syst�matiquement 10 points apr�s le FC2 
  
%     try
%         dim(i) = length(GD.(acquisitions{i}).t(1,debut(i):fin(i)));
%     catch
        dim(i) = length(GD.(acquisitions{i}).t(1,debut(i):end));
%     end
end
dim_min = min(dim);
for i = 1:length(acquisitions)
    for j = 1:length(datas)
        if ~isstruct(GD.(acquisitions{i}).(datas{j})) && ~strcmp(datas{j},'Fech')
            try
                S_norm.(acquisitions{i}).(datas{j}) = GD.(acquisitions{i}).(datas{j})(:,debut(i):debut(i)+dim_min-1) - nanmean(GD.(acquisitions{i}).(datas{j})(:,1:10));
            catch Errt
                S_norm.(acquisitions{i}).(datas{j}) = GD.(acquisitions{i}).(datas{j})(debut(i):debut(i)+dim_min-1) - nanmean(GD.(acquisitions{i}).(datas{j})(1:10));
            end
        end
    end
end

end