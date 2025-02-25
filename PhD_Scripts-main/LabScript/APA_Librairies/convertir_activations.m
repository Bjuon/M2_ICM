function V = convertir_activations(SS)
%% (fonction interne) Crée un vecteur pour alimenter l'histogram des périodes d'activation EMGs
% SS : variable de sortie de la structure 'ActvationEMG_percycle' [debut;fin]

V = [];

for p = 1:size(SS,2)
    add = (SS(1,p):SS(2,p));
    V = [V add];
end

