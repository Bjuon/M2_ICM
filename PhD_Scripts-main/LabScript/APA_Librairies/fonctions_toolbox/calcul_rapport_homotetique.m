% fonction k = Calcul_rapport_homotetique(Ref,Rec) ;
%
% Fonction de calcul d'un rapport homotétique entre deux objets : Ref et Rec
% tel que kRec = Ref
%
function k = Calcul_rapport_homotetique(Ref,Rec) ;
%
% Calcul des barycntres des deux nuages de points :
%
GRef = barycentre(Ref) ;
GRec = barycentre(Rec) ;
%
% Création des vecteurs entre les points d'un nuage et son barycentre
%
VRef = Ref - ones(length(Ref),1) * GRef ;
VRec = Rec - ones(length(Rec),1) * GRec ;
%
% Calcul des normes des vecteurs :
%
NVRef = norm2(VRef) ;
NVRec = norm2(VRec) ;
%
% Calcul du coefficient homotétique pour chacun des points :
%
liste_k = NVRef ./ NVRec ;
%
% Calcul du coefficient global
%
k = mean(liste_k) ;
%
% Fin de la fonction