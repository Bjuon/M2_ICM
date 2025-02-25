function emgs = extraire_emgs(M,liste_noms)

%
% Version:     7.11 (2010)
%___________________________________________________________________________
%
% Description de la fonction : extrait les entrées analogiques des signaux dont
% les noms sont dans "liste_noms" de la matrice de valeurs de la
% structure "M"
%___________________________________________________________________________
%
% Paramètres d'entrée  : 
%
% M: structure avec liste des noms des EMGs (M.EMG.nom) et leurs valeurs
% liste_noms : liste de cellules contenant des strings=noms des entrées
% analogiques ou scalaire équivalent au nombre des n premières entrées
% analogiques
%
% Paramètres de sortie : 
%
% emgs : tableau m*n : contenant les n entrées de la liste 
% pendant les m instants de l'essai considéré
%___________________________________________________________________________
%
% Notes : 
%___________________________________________________________________________
%
% Fichiers, Fonctions ou Sous-Programmes associés 
%
% Appelants :
%
% Appelées :
% compare_liste
%___________________________________________________________________________
%
% Mots clefs : signaux EMG
%___________________________________________________________________________
%
% Exemples d'utilisation de la fonction : (si nécessaire) 
%___________________________________________________________________________
%
% Auteurs : A. El Helou
% Date de création : 13-03-12
% Créé dans le cadre de : collaboration ICM
% Professeur responsable : W. Skalli
%_________________________________________________________________________
%
% Laboratoire de Biomécanique LBM
% ENSAM C.E.R. de PARIS                          email: lbm@paris.ensam.fr
% 151, bld de l'Hôpital                          tel:   01.44.24.63.63
% 75013 PARIS                                    fax:   01.44.24.63.66
%___________________________________________________________________________
%
% Toutes copies ou diffusions de cette fonction ne peut être réalisée sans
% l'accord du LBM
%___________________________________________________________________________
%


emgs = [];
% si la matrice de coordonnees est nulle on renvoie NaN
if ~isfield(M,'EMG')
    emgs = NaN;
else if iscellstr(liste_noms)
    % comparaison des 2 listes
    T = compare_liste(liste_noms,M.EMG.nom);
    for j=1:size(liste_noms,2)
        indice_colonne = find(T(j,:)==1);
        if isempty(indice_colonne)
           emgs(:,j) = NaN*ones(size(M.EMG.valeurs,2),1);
        else
            emgs(:,j) = M.EMG.valeurs(:,indice_colonne);
        end;
    end;
    else
        for k=1:liste_noms
            emgs(:,k) = M.EMG.valeurs(:,k);
        end
    end
end;