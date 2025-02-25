function s=efface_marqueur_test(s)
%%Efface le hande graphique du marqueur temporel si il existe
% s = [1 x n] matrices des handles sur les n axes d'affichage

if ishandle(s)
    delete(s);
else
    try
        eval(['clear ' s]);
    catch error
        s=[];
    end
end