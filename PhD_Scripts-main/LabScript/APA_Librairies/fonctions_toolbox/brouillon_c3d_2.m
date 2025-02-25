% Brouillon_C3D_2 ;

for t = 1:length(Arretes.liste) ;
    
    NN = A.Normale(Arretes.liste(t,:),:)' ;
    SAA = SA(Arretes.liste(t,:),:) ;
    T = SAA*NN ;
    
    B(1) = T(1,1) + T(2,2) - T(1,2) - T(2,1) ;
    B(2) = 2 * (T(2,2) - T(1,1)) ;
    B(3) = T(1,1) + T(2,2) + T(1,2) + T(2,1) ;
    
    Soluce = roots(B) ;
    
    if ~isreal(Soluce(1)) ;
        
        Int(t,:) = [NaN,NaN,NaN] ;
        
    else
        
        qui = find(abs(Soluce) <= 1) ;
        
        if isempty(qui) ;
            
           Int(t,:) = [NaN,NaN,NaN] ;
           
       else
           
           UU = Soluce(qui) ;
           Int(t,:) = 0.5 * ((1-UU)*A.Noeuds(Arretes.liste(t,1),:) + ...
               (1+UU)*A.Noeuds(Arretes.liste(t,2),:)) ;
       end
   end
    
end