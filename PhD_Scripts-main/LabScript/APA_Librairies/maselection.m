function maselection(src,eventdata)

% Version:     9.2 (2007)
% Langage:     Matlab    Version: 7.0
% Plate-forme: PC 

% Auteurs : H. Goujon X. Bonnet
% Date de création : 06-04-07
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


ligne_courante=gcbo;

names = get(ligne_courante,'displayname');
set(findobj('displayname',names),'color','r');

setappdata(gcf,'select',findobj('displayname',names));



