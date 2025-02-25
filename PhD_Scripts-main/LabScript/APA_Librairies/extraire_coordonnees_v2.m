function coordonnees = extraire_coordonnees_v2(M,liste_noms)

%
% Version:     9.1 (2006)
%___________________________________________________________________________
%
% Description de la fonction : extrait les coordonnées des marqueurs dont
% les noms sont dans "liste_noms" de la matrice de coordonnées de la
% structure "M"
% dans la fonction v2 les marqueurs sont en ligne alors que dans la
% version1 ils étaient en colonne
%___________________________________________________________________________
%
% Paramètres d'entrée  : 
%
% M: structure avec liste de noms, matrice de coordonnees et
% matrice d'actions meca
% liste_noms : liste de cellules contenant des strings=noms des marqueurs
% de taille n
%
% Paramètres de sortie : 
%
% coordonnees : tableau n*3*m : contenant les 3n coordonnées des marqueurs de la liste 
% pendant les m acquisitions de l'essai considéré
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
% Mots clefs : coordonnées de marqueurs
%___________________________________________________________________________
%
% Exemples d'utilisation de la fonction : (si nécessaire) 
%___________________________________________________________________________
%
% Auteurs : H. Goujon
% Date de création : 06-07-05
% Créé dans le cadre de : Thèse
% Professeur responsable : F. Lavaste
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


coordonnees = [];
% si la matrice de coordonnees est nulle on renvoie une matrice de 0
if M.coord == 0
    taille1=size(liste_noms,2);
    taille2=size(M.coord,1);
    coordonnees=NaN*ones(taille1,3,taille2);
else
    % comparaison des 2 listes
    T = compare_liste(liste_noms,M.noms);

    %modif du 12 février 2007 par H Goujon pour mettre des Nan quand le
    %l'élément de liste noms n'est pas trouvés dans M.noms
    for j=1:size(liste_noms,2)
        indice_colonne = find(T(j,:)==1);
        if isempty(indice_colonne)
           coordonnees_permutees = NaN*ones(1,3,size(M.coord,1));
             coordonnees = [coordonnees;coordonnees_permutees];
        else
           coordonnees_permutees = permute(M.coord(:,3*indice_colonne-2:3*indice_colonne),[3,2,1]);
            coordonnees = [coordonnees;coordonnees_permutees];
        end;
    end;
end;