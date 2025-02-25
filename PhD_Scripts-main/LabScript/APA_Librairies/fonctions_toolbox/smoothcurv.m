% C2 = smoothcurv(C1,Puis) ;
%
% Fonction permettant de lisser une courbe 2D ou 3D
%
function C2 = smoothcurv(C1,P) ;
%
% 1. Gestion des donn�es d'entr�e
%
if nargin == 1 ;
    % Puissance du filtre impos� � 1 ;
    P = 1 ;
end
%
% 2. Cr�ation du filtre pour la convolution
%
filtre = ones(2*P+1,1) / (2*P + 1) ;
%
% 3. Calcul de la convolution
%
Temp = conv2(C1,filtre) ;
%
% 4. Mise en forme de la courbe
% 
Sup = C1(1,:) ;   % ---> Points sup�rieurs
Inf = C1(end,:) ; % ---> Points inf�rieurs
for t = 1:P-1 ;
    Sup = [Sup;C1(1,:) + t*(Temp(1+2*P,:) - C1(1,:)) / P] ;
    Inf = [Temp(end-2*P,:) + t*(C1(end,:)-Temp(end-2*P,:)) / P;Inf] ;
end
C2 = [Sup;Temp(1+2*P:end-2*P,:);Inf] ;
%
% Fin de la fonction