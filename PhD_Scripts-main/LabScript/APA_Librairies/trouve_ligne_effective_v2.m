function l = trouve_ligne_effective_v2(j,Stps,space)
%% Faire correspondre les lignes effectives sur le tableau excel à chaque acquisition

N_total = Stps(end);

A = repmat((1:N_total)',1,2);

for i = Stps(1):N_total(1)
    if sum(i==Stops)
        A(i,2) = space*find(Stops==i)+1;
    else
        A(i,2) = A(i-1,2) + 1;
    end
end
  
l = A(j,2);
    
