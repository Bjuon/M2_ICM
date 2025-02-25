function h_marks=affiche_marqueurs(k,color)
%%Affichage des marqueurs k en style color sur les axes existants % Sauf
%%sur la trajectoire PF (axes7)
% k = marqueurs temporel
% Color = chaine de caract�re
% h_marks = handle des markeurs

axess = findobj('Type','axes');
for i=1:length(axess)
     if round(axess(i).Position(1)*100) ~= 76 % correspond � la position de axes7
    h_marks(i)=afficheX_v2(k,color,axess(i));
     end
end
