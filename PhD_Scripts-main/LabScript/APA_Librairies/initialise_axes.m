function initialise_axes(varagin)
%%Nettoie et reinitialise les axes d'une figure

axess = findobj('Type','axes');
for i=1:length(axess)
    cla(axess(i));
end