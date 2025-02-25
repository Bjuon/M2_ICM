function Window = sliding_average(S,w)
%% Fonction qui va calculer la moyenne de toutes les fenêtres glissantes de taille 'w' sur un signal S (1-D)
% Window = vecteur de taille w

if w>length(S)
    disp('Taille de fenêtre > signal');
    dec = w - length(S);
    fitnan = NaN*ones(1,dec);
    Window = [fitnan S];
else
    %Initialisation
    N_windows = floor(length(S)/w) + mod(length(S),w);
    
    all_windows = NaN*ones(N_windows,w);
    
    for i=1:N_windows
        all_windows(i,:) = S(i:i+w-1);
    end
    
    Window = mean(all_windows,1);
end