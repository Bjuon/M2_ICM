function h_marks=affiche_marqueurs(k,color)
%%Affichage des marqueurs k en style color sur les axes existants
% k = marqueurs temporel
% Color = chaine de caractère
% h_marks = handle des markeurs

axess = findobj('Type','axes');
for i=1:length(axess)
    h_marks(i)=afficheX_v2(k,color,axess(i));
end
