function ver = compare_liste(liste1,liste2)

% ver = compare_liste(liste1,liste2) 
%
% Version:     8.0 (2005)  
% Langage:     Matlab    Version: 7.0
% Plate-forme: PC 
%
%___________________________________________________________________________
%
% Niveau de Validation : 3
%___________________________________________________________________________
%
% Description de la fonction : compare les éléments de la liste 1 et la liste 2 et renvoie
% un tableau contenant des 1 et des 0. ver(i,j) =1 quand les caracteres du ieme element 
% de la premiere liste sont commun avec les caracteres du jeme element de la seconde  
%___________________________________________________________________________
%
% Paramètres d'entrée  : 
%
% liste1 et liste2 : 2 listes de cellules contenant des strings en ligne (n,1) et (m,1) ou
% en colonne (1,n) ou (1,m)
%
% Paramètres de sortie : 
%
% ver : tableau n*m- ver(i,j) =1 quand le ieme element 
% de la premiere liste correspond au jeme element de la seconde
%___________________________________________________________________________
%
% Notes : Documents, Articles, Cours associés s'ils existent ... ou remarques
%         Toolbox nécessaire au fonctionnement
%___________________________________________________________________________
%
% Fichiers, Fonctions ou Sous-Programmes associés 
%
% Appelants :
% extraire_coordonnees
%
%___________________________________________________________________________
%
% Mots clefs : comparaison liste
%___________________________________________________________________________
%
% Exemples d'utilisation de la fonction : liste1 = {'ATHT','A1','CEXT'}
% liste2={'ATHT1','ATHT2','CEXT','CINT'}
%ver = [1 1 0 0
%       0 0 0 0
%       0 0 1 0]        
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



% on met la liste 2 sous forme de tableau de string
tab_liste2 = strvcat(liste2);

% cette fonction fonctionne avec des listes dans les 2 sens (en ligne ou en
% colonne), on determine pour cela la taille principale
[tailles] = size(liste1);
[taille_princ,direction_princ] = max(tailles);
ver=zeros(taille_princ,size(tab_liste2,1));
% les elements de la premiere liste sont compares a la 2eme liste
for i=1:taille_princ
    indices=strmatch(liste1{i},tab_liste2,'exact');
    ver(i,indices) = ones(1,size(indices,2));
end;
