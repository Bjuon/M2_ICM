function donnees_derivees = derive_MH_VAH(donnees,freq)

% Version:     9.2 (2007)
% Langage:     Matlab    Version: 7.0
% Plate-forme: PC 

% Auteurs : H. Goujon X. Bonnet
% Date de création : 06-04-07

% Créé dans le cadre de : Thèse
% Professeur responsable : F. Lavaste

% ***************************************
% Modif J. Bascou le 10/12/2009 : optimisation du temps de traitement en
% supprimant les conditions "if"
% Modif A. El Helou le 9/02/2010 : adaptation a un vecteur colonne ou ligne
% ****************************************
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
%% en entrée
%   - Matrice de données, avec le temps en 3e dimension
%   - frequ: fréquence de mesure

%% en sortie
%     - Matrice dérivée, avec le temps en 3e dimension

%% Cas d'un vecteur colonne
nb_pts = length(donnees);
    
%% Traitement des données

% Dérivés au degré 3: prise en compte des 4 points temporels entourant le
% point considéré
for i = 3:nb_pts-2
    donnees_derivees(i,:)     =   (-donnees(i+2,:)+8*donnees(i+1,:)-8*donnees(i-1,:)+donnees(i-2,:))/(12*(1/freq));
end

% Traitement des points aux extremes temporels: dérivés à un degré moindre
    donnees_derivees(1,:)         =   (donnees(2,:)-donnees(1,:))/(1/freq);
    donnees_derivees(2,:)         =   (donnees(3,:)-donnees(1,:))/(2*(1/freq));
    donnees_derivees(nb_pts-1,:)  =   (donnees(end,:)-donnees(end-2,:))/(2*(1/freq));
    donnees_derivees(nb_pts,:)    =   (donnees(end)-donnees(end-1,:))/((1/freq));
    
