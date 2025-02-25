% Fonction R_Ref_Rec = changement_base_quaternion(VRef,VRec)
% _________________________________________________________________________
%
% Fonction calculant la matrice de changement de base permettant de passer
% des vecteurs VRec vers Vref
% _________________________________________________________________________
%
function R_Ref_Rec = changement_base_quaternion(VRef,VRec) ;
%
% 1. Mise en forme de la matrice des moindres carrés
%
% a) Préparation des sous matrice :
%
A = VRec' * VRef ; 
B = A - A' ;
C(1,1) = B(2,3); C(2,1) = B(3,1); C(3,1) = B(1,2) ;
D = A + A' - eye(3) * trace(A) ;
%
% b) Construction de M la matrice des moindres carrés
%
M = [trace(A),C';C,D] ;
%
% 2. Diagonalisation et vecteurs propres de M
%
[Vectp,Valp] = eigs(M) ;
%
% 3. Recherche de la valeur propre positive
%
[val,ou] = max(diag(Valp)) ;
%
% 4. Le quaternion solution est donc égale au vecteur propre associé
%
Q = Vectp(:,ou) ;
a = Q(1); b = Q(2); c = Q(3); d = Q(4);
%
% 5. Détermination de la matrice de changement de base
%
R_Ref_Rec = [a^2 + b^2 - c^2 - d^2 ,...
        2 * (b*c - a*d),...
        2 * (b*d + a*c);...
        2 * (b*c + a*d),...
        a^2 - b^2 + c^2 - d^2,...
        2 * (c*d - a*b);...
        2 * (b*d - a*c),...
        2 * (c*d + a*b),...
        a^2 - b^2 - c^2 + d^2] ;
%
% Fin de la fonction