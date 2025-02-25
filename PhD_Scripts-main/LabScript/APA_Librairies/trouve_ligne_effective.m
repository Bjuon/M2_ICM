function l = trouve_ligne_effective(j,Idx,space)
%% Faire correspondre les lignes effectives sur le tableau excel à chaque acquisition

N_total = sum(Idx,1);

A = repmat((1:N_total(1))',1,2);

N_Stops = N_total(2) - 1;
Idx = [0 0 0;Idx];

for i = 1:N_Stops-1
    Idx_cumul(i,:) = [Idx(i+1,3)+Idx(i,1)+1 Idx(i,1)+Idx(i+1,1)+1];
end

Stops = sort(reshape(Idx_cumul,size(Idx_cumul,1)*2,1));
Stops(end)=[];

for i = Stops(1):N_total(1)
    if sum(i==Stops)
        A(i,2) = space*find(Stops==i)+1;
    else
        A(i,2) = A(i-1,2) + 1;
    end
end
  
l = A(j,2);
    
