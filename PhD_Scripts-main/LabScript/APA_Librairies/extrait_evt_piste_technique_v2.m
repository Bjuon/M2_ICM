function T = extrait_evt_piste_technique_v2(E,e)
%% Extrait les timings d'un evenement 'e' d'une structure piste technique E
% E = structure avec les champs 'tags' des evts et 'Temps' pour les valeurs dans le temps de chqaue evènement
% e = string de l'évènement à identifier

try
    indx = E.tags==e;
catch String_cells
    indx = logical(compare_liste(e,E.tags));
end

T = E.Temps(indx);