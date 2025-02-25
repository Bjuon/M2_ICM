function anlgs = extraire_anlg(M,liste_noms)

%
% Version:     7.13 (R2011b)
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
% Mots clefs : signaux analogiques
%___________________________________________________________________________
%
% Exemples d'utilisation de la fonction : (si nécessaire) 
%___________________________________________________________________________
%
% Auteurs : A. El Helou
% Date de création : 21-02-12
% Créé dans le cadre de : collaboration ICM
% Professeur responsable : ML Welter
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


anlgs = [];
% si la matrice de coordonnees est nulle on renvoie NaN
if ~isfield(M,'Analogs')
    anlgs = NaN;
else if iscellstr(liste_noms)
    % comparaison des 2 listes
    T = compare_liste(liste_noms,M.Analogs.nom);
    for j=1:size(liste_noms,2)
        indice_colonne = find(T(j,:)==1);
        if isempty(indice_colonne)
           anlgs(:,j) = NaN*ones(length(liste_noms),1);
        else
            anlgs(:,j) = M.Analogs.valeurs(:,indice_colonne);
        end;
    end;
    else
        for k=1:liste_noms
            anlgs(:,k) = M.Analogs.valeurs(:,k);
        end
    end
end;