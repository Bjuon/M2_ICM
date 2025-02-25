function C = matchcell(A,B)
%
% Cas A vide ...
%
if isempty(A) ;
   C = NaN ;
   return
end
%
% Nombres de strings dans les deux listes
%
N_A = max(size(A)) ; N_B = max(size(B));
%
% Recherche des concordances de A dans B
%
for ttt = 1:N_A ;
   whera = strmatch(A(ttt),B,'exact') ;
   if isempty(whera) ;
      whera = 0 ;
   end
   C(ttt,1) = whera ;
end
%
% fin de la fonction