function C = smoothcontour(C) ;
%
%
%

for t = 1:length(C.tri) ;
    % 1. Extraction du contour
    Temp = C.coord(C.tri{t},:) ;
    % 2. Gestion : contour ouvert ou contour ferme
    if C.tri{t}(1) == C.tri{t}(end) ;
        % ---> C'est un contour fermé 
        Temp = [Temp(end,:);Temp;Temp(1,:)] ;
        Temp = smoothcurv(Temp) ;
        C.coord(C.tri{t},:) = Temp(2:end-1,:) ;
    else
        % ---> c'est un contour ouvert
        C.coord(C.tri{t},:) = smoothcurv(Temp) ;
    end
end