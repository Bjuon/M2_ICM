% Fonction: [C1_N,C2_N] = uniformise(C1,C2)
%_______________________________________________________________________
%
% Description de la fonction :
%
% Cette fonction uniformise deux structures d'un point de vue des tailles
% par un scannage des tags ...
%_______________________________________________________________________
%
% Paramètres d'entrée :
%
% C1, C2: les deux structures à uniformiser contenant les champs suivants :
%         .tag  
%
% Paramètres de sortie :
%
% C1_N, C2_N: les deux structures structures contenant les champs suivants :
%             .tag  
%             tous les autres champs sont uniformisés
%_______________________________________________________________________
%
% Notes : cette fonction est créée dans le but d'obtenir une meilleure 
%         modularisation du programme
%_______________________________________________________________________
%
% Auteurs : David MITTON & Sébastien LAPORTE 
% Date de création : stage Montréal & Thèse
% Créé dans le cadre de : janvier 1999
%_______________________________________________________________________
%
% Modifié dans le cadre de : version 2
%_______________________________________________________________________
%
% Modifié dans le cadre de : version 3
%_______________________________________________________________________
%
% Laboratoire de Biomécanique LBM
% ENSAM C.E.R. de PARIS
% 151, bld de l'Hôpital
% 75013 PARIS
%_______________________________________________________________________
%
function [C1_N,C2_N,tag_ok1,tag_ok2] = uniformise(C1,C2) ;
%
% Nombre de tags dans les deux variables
%
L1 = size(C1.tag,1);
L2 = size(C2.tag,1);
%
% recherche des tags identiques
%
liste1 = matchcell(C1.tag,C2.tag) ;
tag_ok1 = find(liste1 ~= 0) ;
tag_ok2 = liste1(tag_ok1) ;
%
% Creation de deux structures de taille egale et comportant les memes points dans le meme ordre
% C1_N et C2_N
%
C1_N = struct('tag',[]) ;
C2_N = struct('tag',[]) ;
%
% récupération des champs des la strcuture 1 et 2
%
champs1 = fieldnames(C1) ; champs2 = fieldnames(C2) ;
%
Nfields1 = size(champs1,1) ; % nombre de champs dans 1
Nfields2 = size(champs2,1) ; % nombre de champs dans 2
%
% Aucunes correspondances entre les deux variables ....
% Les champs de 1 et 2 sont renvoyés vides 
%
if isempty(tag_ok1)&isempty(tag_ok2) ;
    for t = 1:Nfields1 ;
        setfield(C1_N,champs1{t},[]) ;
    end
    for t = 1:Nfields2 ;
        setfield(C2_N,champs2{t},[]) ;
    end
    return
end
%
% Sinon il faut créer les variables correctement
% ---> Objet 1
for t = 1:Nfields1 ;
    Temp = getfield(C1,champs1{t}) ; % Mise en temp du contenu 
    if size(Temp,1) == L1 ;  
        % cas du type d'objet ou de nombres en colonne
        C1_N = setfield(C1_N,champs1{t},Temp(tag_ok1,:)) ;
    elseif size(Temp,2) == L1 ;  
        % cas du type d'objet ou de nombres en ligne
        C1_N = setfield(C1_N,champs1{t},Temp(:,tag_ok1)) ;
    else
        C1_N = setfield(C1_N,champs1{t},Temp) ;
    end
end
% ---> Objet 2
for t = 1:Nfields2 ;
    Temp = getfield(C2,champs2{t}) ; % Mise en temp du contenu
    if size(Temp,1) == L2 ; 
        % cas du type d'objet ou de nombres en colonne
        C2_N = setfield(C2_N,champs2{t},Temp(tag_ok2,:)) ;
    elseif size(Temp,2) == L2 ;
        % cas du type d'objet ou de nombres en ligne
        C2_N = setfield(C2_N,champs2{t},Temp(:,tag_ok2)) ;
    else
        C2_N = setfield(C2_N,champs2{t},Temp) ;
    end
end
%
% fin de la fonction