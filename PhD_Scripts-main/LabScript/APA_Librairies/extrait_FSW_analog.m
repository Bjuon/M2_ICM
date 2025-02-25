function s = extrait_FSW_analog(S_data)
%% Extraction des signaux provenant du(des) Foot-Switch
% s : vecteur(s) [n x N] [N footswitch, n échantillons(temps) ]

channels=S_data.nom;

anlg_3={};

for c=1:length(channels)
    channel = cell2mat(channels(c));
    anlg_3{c } = channel(1:3); % On extrait les 3 premières lettres
end

if length(anlg_3)>1 % Si plusieurs entrées on prend la 2ème
    isfsw = logical(compare_liste({'FSW_B11'},channels));
else
    isfsw = 1;
end

s = S_data.valeurs(:,isfsw); %Extraction des bonnes colonnes

% % Filtrage
% s = filtrage(s,'l',2,100,S_data.Fech);