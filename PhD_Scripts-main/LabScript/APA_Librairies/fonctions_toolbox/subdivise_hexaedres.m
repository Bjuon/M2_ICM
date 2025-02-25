% function [Nn,Pn] = subdivise_hexaedres(Na,Pa,Nsub) ;
%
% Fonction permettant de subdiviser en 8 des hexaedres.
% _________________________________________________________________________
% Entreés :
% Na : coordonnées des noeuds des hexaedres à subdiviser [N,3]
% Pa : définition des huits noeuds sommets de ces hexaedres [M,8] ;
% Nsub : nombre de subdivisions à réaliser, par défaut 1
% _________________________________________________________________________
% Sorties :
% Nn : coordonnées des noeuds des hexaedres calculés [N+19*N,3]
% Pn : définition des huits noeuds sommets de ces hexaedres [M+8*N,8] ;
% _________________________________________________________________________
%
function [Nn,Pn] = subdivise_hexaedres(Na,Pa,Nsub) ;
%
% 1. Gestion des données d'entrée :
%
if nargin == 2 ;
    % Le nombre de subdivisions est limité à 1
    Nsub = 1 ;
end
%
% 2. Création des subdvisions
% ---> Attention 2 Cas à traiter Nsub = 1 et Nsub > 1
% CAS D'UNE SEULE SUBDIVISION
if Nsub == 1 ;
    % a) longueurs des matrices
    N_pre = size(Na,1) ; % Nombre de noeuds d'entrée
    BS = size(Pa,1) ;    % Nombre d'hexaedre d'entré
    % b) Calcul des nouveaux noeuds
    % ---> Milieux des aretes
    Nn = [Na ; 0.5 * (Na(Pa(:,1),:) + Na(Pa(:,2),:))] ; % 9
    Nn = [Nn ; 0.5 * (Na(Pa(:,2),:) + Na(Pa(:,3),:))] ; % 
    Nn = [Nn ; 0.5 * (Na(Pa(:,3),:) + Na(Pa(:,4),:))] ; %
    Nn = [Nn ; 0.5 * (Na(Pa(:,1),:) + Na(Pa(:,4),:))] ; % 12
    Nn = [Nn ; 0.5 * (Na(Pa(:,5),:) + Na(Pa(:,6),:))] ; %
    Nn = [Nn ; 0.5 * (Na(Pa(:,6),:) + Na(Pa(:,7),:))] ; %
    Nn = [Nn ; 0.5 * (Na(Pa(:,7),:) + Na(Pa(:,8),:))] ; % 
    Nn = [Nn ; 0.5 * (Na(Pa(:,8),:) + Na(Pa(:,5),:))] ; % 16
    Nn = [Nn ; 0.5 * (Na(Pa(:,1),:) + Na(Pa(:,5),:))] ; %
    Nn = [Nn ; 0.5 * (Na(Pa(:,2),:) + Na(Pa(:,6),:))] ; %
    Nn = [Nn ; 0.5 * (Na(Pa(:,3),:) + Na(Pa(:,7),:))] ; % 
    Nn = [Nn ; 0.5 * (Na(Pa(:,4),:) + Na(Pa(:,8),:))] ; % 20
    % ---> Milieux des faces
    Nn = [Nn ; 0.25 * (Na(Pa(:,1),:) + Na(Pa(:,2),:) + Na(Pa(:,5),:) + Na(Pa(:,6),:))] ; % 21
    Nn = [Nn ; 0.25 * (Na(Pa(:,2),:) + Na(Pa(:,3),:) + Na(Pa(:,7),:) + Na(Pa(:,6),:))] ; % 22
    Nn = [Nn ; 0.25 * (Na(Pa(:,3),:) + Na(Pa(:,4),:) + Na(Pa(:,8),:) + Na(Pa(:,7),:))] ; % 23
    Nn = [Nn ; 0.25 * (Na(Pa(:,1),:) + Na(Pa(:,4),:) + Na(Pa(:,8),:) + Na(Pa(:,5),:))] ; % 24
    Nn = [Nn ; 0.25 * (Na(Pa(:,1),:) + Na(Pa(:,2),:) + Na(Pa(:,3),:) + Na(Pa(:,4),:))] ; % 25
    Nn = [Nn ; 0.25 * (Na(Pa(:,5),:) + Na(Pa(:,6),:) + Na(Pa(:,7),:) + Na(Pa(:,8),:))] ; % 26   
    % ---> Centre des boites
    Nn = [Nn ; 0.125 * (Na(Pa(:,1),:) + Na(Pa(:,2),:) + Na(Pa(:,3),:) + Na(Pa(:,4),:) + ...
            Na(Pa(:,5),:) + Na(Pa(:,6),:) + Na(Pa(:,7),:) + Na(Pa(:,8),:))] ; % 27
    % b) Définition des nouveaux hexaedres   
    Lt = [1:BS]' ; % Largeur du nombre d'hexaedres
    BS = BS * ones(length(Lt),1) ;
    Pn = [Pa(:,1),N_pre+Lt*ones(1,7)+BS*[0,16,3,8,12,18,15]] ;
    Pn = [Pn ; [N_pre+Lt,Pa(:,2),N_pre+Lt*ones(1,6)+BS*[1,16,12,9,13,18]]] ;
    Pn = [Pn ; [N_pre+Lt*ones(1,2)+BS*[16,1],Pa(:,3),N_pre+Lt*ones(1,5)+BS*[2,18,13,10,14]]] ;
    Pn = [Pn ; [N_pre+Lt*ones(1,3)+BS*[3,16,2],Pa(:,4),N_pre+Lt*ones(1,4)+BS*[15,18,14,11]]] ;
    Pn = [Pn ; [N_pre+Lt*ones(1,4)+BS*[8,12,18,15],Pa(:,5),N_pre+Lt*ones(1,3)+BS*[4,17,7]]] ;
    Pn = [Pn ; [N_pre+Lt*ones(1,5)+BS*[12,9,13,18,4],Pa(:,6),N_pre+Lt*ones(1,2)+BS*[5,17]]] ;
    Pn = [Pn ; [N_pre+Lt*ones(1,6)+BS*[18,13,10,14,17,5],Pa(:,7),N_pre+Lt+BS*[6]]] ;
    Pn = [Pn ; [N_pre+Lt*ones(1,7)+BS*[15,18,14,11,7,17,6],Pa(:,8)]] ;
else
    % CAS DE PLUSIEURS SUBDIVISIONS
    Nn = Na ; Pn = Pa ;
    for t = 1:Nsub ;
        [Nn,Pn] = subdivise_hexaedres(Nn,Pn) ;
    end
end
%
% Fin de la fonction