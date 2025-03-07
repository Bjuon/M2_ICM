function emgs = extraire_emgs(M,liste_noms)

%
% Version:     7.11 (2010)
%___________________________________________________________________________
%
% Description de la fonction : extrait les entr�es analogiques des signaux dont
% les noms sont dans "liste_noms" de la matrice de valeurs de la
% structure "M"
%___________________________________________________________________________
%
% Param�tres d'entr�e  : 
%
% M: structure avec liste des noms des EMGs (M.EMG.nom) et leurs valeurs
% liste_noms : liste de cellules contenant des strings=noms des entr�es
% analogiques ou scalaire �quivalent au nombre des n premi�res entr�es
% analogiques
%
% Param�tres de sortie : 
%
% emgs : tableau m*n : contenant les n entr�es de la liste 
% pendant les m instants de l'essai consid�r�
%___________________________________________________________________________
%
% Notes : 
%___________________________________________________________________________
%
% Fichiers, Fonctions ou Sous-Programmes associ�s 
%
% Appelants :
%
% Appel�es :
% compare_liste
%___________________________________________________________________________
%
% Mots clefs : signaux EMG
%___________________________________________________________________________
%
% Exemples d'utilisation de la fonction : (si n�cessaire) 
%___________________________________________________________________________
%
% Auteurs : A. El Helou
% Date de cr�ation : 13-03-12
% Cr�� dans le cadre de : collaboration ICM
% Professeur responsable : W. Skalli
%_________________________________________________________________________
%
% Laboratoire de Biom�canique LBM
% ENSAM C.E.R. de PARIS                          email: lbm@paris.ensam.fr
% 151, bld de l'H�pital                          tel:   01.44.24.63.63
% 75013 PARIS                                    fax:   01.44.24.63.66
%___________________________________________________________________________
%
% Toutes copies ou diffusions de cette fonction ne peut �tre r�alis�e sans
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