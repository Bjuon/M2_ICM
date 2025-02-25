% function U = meilleure_intersection_listes(L1,L2) ;
%
% ---> Fonction permettant de réaliser les plus longue associaition de point possible
%      avec aucun chevauchement ni retour en arrière
%      Première ligne : pour Rec
%      Seconde ligne  : pour Ref
%
function U = meilleure_intersection_listes(L1,L2) ;
%
% 1. Nous allons rechercher tout d'abord une direction prépondérante dans L1
%    ---> Nous souhaitons obtenir une croissance majorante plut^ot qu'une décroissance
%
dL11 = diff(L1(:,1)) ;
if sign(mean(sign(dL11))) <= 0 ;
  % ---> Nous inversons la croissance
  L1 = (1 + max(max(L1)) - L1) ;
  dL11 = -dL11 ;
end
%
% 2. Nous recherchons les différentes zones de croissance et décroissance de la liste
%
U = sign(dL11)' ;                              % ---> Nous recherchons les variations de signe
H = [1,find(diff([U(1),U,U(end)]) ~= 0) + 1] ; %      Pour localiser les débuts de zone
%
% 3. Création et utilisation des zones
%
% a) Initialisation de variables
%
cmpt = 1 ;        % ---> Compteur de zones de croissance ou de décroissance
zone_pre = [] ;   % ---> Gestion des suites de croissance
test_liste = 0 ;  % ---> Teste si une liste_ok existe
liste_ok = [] ;   % ---> Liste des noeuds ok
%
% b) Gestion des recouvrements
%
for t = 1:length(H) ;
  %
  % ---> Création de la zone courante :
  %
  if t == length(H) ;
    % ---> Pour la zone finale
    zone{cmpt} = [zone_pre,H(t):length(L1(:,1))] ;
  else
    % ---> Dans le cas général
    zone{cmpt} = [zone_pre,H(t):H(t+1)-1] ;
  end
  %
  % ---> Traitement de la zone si sa dimension est supérieure à 1
  %
  if length(zone{cmpt}) > 1 ;
    % a) incrémentation du compteur de zones et de la zone init
    cmpa = cmpt ;
    cmpt = cmpt + 1 ;
    zone_pre = [] ;
    % b) traitement des divers cas de recouvrement :
    if test_liste == 0 ; 
      if (L1(zone{cmpa}(end),1) - L1(zone{cmpa}(1),1)) > 0 ;
        % ---> Nous commençons le traitement de recouvrement
        %      si la zone courante est de type croissante.
        liste_ok(1,:) = zone{cmpa} ;
        liste_ok(2,:) = zone{cmpa} ;
        test_liste = 1 ;
      end
    elseif test_liste == 1 ;
      % ---> Initialisation de la recherche de la meilleure association ;
      while 1
        % ---> Traitement des autres cas lorsque la liste est définie
        % b-1) Détermination des limites et densités de la liste_ok 
        %      et de la zone courante + la valeur moyenne de L2 + sens
        % ___ Pour liste_ok ___
        [mil,uil] = min(L1(liste_ok(1,:),1)) ; 
        [mal,ual] = max(L1(liste_ok(1,:),1)) ;
        denl = size(liste_ok,1) * (mal - mil) ;
        % vall = mean(L2(liste_ok,2)) ;
        % ___ Pour la zone actuelle ___
        [miz,uiz] = min(L1(zone{cmpa},1)) ; 
        [maz,uaz] = max(L1(zone{cmpa},1)) ;
        denz = length(zone{cmpa}) * (maz - miz) ;
        % valz = mean(L2(zone{cmpa},2)) ;
        senz = uaz - uiz ;
        %
        % b-2) Traitement suivant les cas :
        % ---> Sens de la monotonie :
        if senz > 0 ;
          % ---> Nous avons bien affaire à une croissance ...
          if (maz <= mil) | ... 
              ... % ---> La zone actuelle se situe en amont de la liste actuelle
              ((miz < mil) & (maz > mil) & (maz < mal)) | ...
              ... % ---> La zone actuelle se situe en amont avec un recouvrement
              ((miz <= mil) & (maz >= mal)) | ...
              ... % ---> La zone actuelle englobe la liste
              ((miz > mil) & (maz < mal)) ;
            % ---> La liste englobe la zone actuelle
            % Nous gardons alors la liste de plus grande densité
            if denz > denl ;
              clear liste_ok
              liste_ok(1,:) = zone{cmpa} ;
              liste_ok(2,:) = zone{cmpa} ;                        
            end
            break
          elseif (mil < miz) & (miz < mal) & (mal < maz) ;
            % ---> Il y a un phénomène de "boucle" avec un retour en arrière
            LL = find(L1(liste_ok(1,:)) > miz) ; % ---> Nombre de recouvrement + localisation
            LZ = find(L1(zone{cmpa}) <  mal) ;   % ---> Nombre de recouvrement + localisation
            % ---> Il y a plusieurs possibilités
            if (length(LL) == 1) & (length(LZ) == 1) ;
              % ---> Dans ce cas nous inversons l'ordre des noeuds
              Temp = liste_ok ; clear liste_ok ;
              liste_ok(1,:) = [Temp(1,1:end-1),zone{cmpa}(1),Temp(1,end),zone{cmpa}(2:end)] ;
              liste_ok(2,:) = [Temp(2,:),zone{cmpa}] ;
              break
            elseif (length(LL) == 1) & (length(LZ) > 1) ;
              % ---> Ici nous autons le noeuds en trop
              Temp = liste_ok ; clear liste_ok ;
              liste_ok(1,:) = [Temp(1,1:end-1),zone{cmpa}] ;
              liste_ok(2,:) = [Temp(2,1:end-1),zone{cmpa}] ;
              break
            elseif (length(LL) > 1) & (length(LZ) == 1) ;
              % ---> Ici nous autons le noeuds en trop
              Temp = liste_ok ; clear liste_ok ;
              liste_ok(1,:) = [Temp(1,:),zone{cmpa}(2:end)] ;
              liste_ok(2,:) = [Temp(2,:),zone{cmpa}(2:end)] ;
              break
            else
              % ---> Nous recherchons la valeur permettant d'avoir le plus de points 
              %      correspondants 
              liste_ok = liste_ok(1:2,1:end-1) ; % ---> liste_ok sans le dernier terme
              zone{cmpa} = zone{cmpa}(2:end) ;   % ---> zone actuelle sans le premier
            end
          else
            % ---> Il suffit d'ajouter la nouvelle liste à l'ancienne
            liste_ok = [liste_ok,[1;1] * zone{cmpa}] ;
            break
          end
        else
          break
        end
      end  
    end
  else
    zone_pre = zone{cmpt} ;
  end
end
U = liste_ok ; 
%
% _ Fin de la fonction _