% Fonction, sous-programme ou programme sous la forme :
% [ind,varargout] = matchcells(A,B,varargin)
%
% Version:     1.0 (année de la version)  
% Langage:     Matlab    Version: R2008b
% Plate-forme: PC windows XP
%___________________________________________________________________________
%
% Niveau de Validation : 1
%
% 0 : en cours de développement, ne fonctionne pas encore 
% 1 : fonctionne dans le cadre d'une utilisation precise par le programmeur
%     (risque de disfonctionnement pour une utilisation exterieure)
% 2 : fonctionne dans le cadre d'une utilisation plus ouverte par plusieurs
%     utilisateurs (quelques erreurs possibles mais résultats valides)
% 3 : fonctionne dans tous les cas et donne des résultats valides
%___________________________________________________________________________
%
% Description de la fonction : Searches the item of B cell in the items of
%                              A cell and returns indices of occurences. If
%                              varargin = 'exact', searches for exact
%                              occurence of B in A, if not, returns all
%                              occurence of B being subset of A
%___________________________________________________________________________
%
% Paramètres d'entrée  : 
%
% Nom, description
% Structure de la variable
% A,        cells in which the search is done
% B,        cells searched in A cells
% varargin, switch between exact and inexact search
%
% Paramètres de sortie : 
%
% Nom, description
% Structure de la variable
% ind, vector of indices of B cells in A cells
% varargout(1), vector with number of occurences of B in A
% varargout(1), logical, if 1, all B objects were found in A, 0 otherwise
%___________________________________________________________________________
%
% Notes : 
%         
%___________________________________________________________________________
%
% Fichiers, Fonctions ou Sous-Programmes associés 
%
% Appelants :
% nom, type de fichier
%
% Appelées :
% nom, type de fichier
% indexation.m, matlab function
%___________________________________________________________________________
%
% Mots clefs : Eléments Finis, Cage Thoracique
%___________________________________________________________________________
%
% Exemples d'utilisation de la fonction : (si nécessaire) 
% A = {'AA' 'BB' 'CC' 'DD' 'EE'}
% b = {'C' 'BB'}
% matchcells(A,b)
% ans =
%      3     2
% [i,j,k] = matchcells(A,b)
% i =
%      3     2
% j =
%      1     1
% k =
%      1
% [i,j,k] = matchcells(A,b,'exact')
% i =
%      2
% j =
%      0     1
% k =
%      0
%___________________________________________________________________________
%
% Auteurs : Vit NOVACEK
% Date de création : 17-12-2009
% Créé dans le cadre de : post-doc
% Professeur responsable : Wafa SKALLI
%___________________________________________________________________________
%
% Modifié par : 
% le :          
% Pour :        signaler le professeur responsable entre paranthèses    
% Modif N°1   : description de la modification
%___________________________________________________________________________
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
function [ind,varargout] = matchcells(A,B,varargin)
    if isempty(A)||isempty(B)
        ind = [];
        varargout(1) = { 0 };
        varargout(2) = { 0 };
    else
        nA  = max(size(A));
        nB  = max(size(B));
        ind = zeros(1,nA);
        cnt = zeros(1,nB);
        opt = 0;
        if size(varargin,2) > 0
            if strmatch(varargin{1},'exact','exact')
                opt = 1;
            end
        end
        if opt
            for j = 1:nB
                for i = 1:nA
                    pos = strmatch(B(j),A(i),'exact');
                    if pos > 0
                        cnt(j) = cnt(j) + 1;
                        ind(sum(cnt)) = i;
                    end
                end
            end
        else
            for j = 1:nB
                for i = 1:nA
                    pos = strmatch(B(j),A(i));
                    if pos > 0
                        cnt(j) = cnt(j) + 1;
                        ind(sum(cnt)) = i;
                    end
                end
            end
        end
        ind = ind(ind ~= 0);
        varargout(1) = { cnt };
        varargout(2) = { sum(cnt == 0) == 0 };
    end
end