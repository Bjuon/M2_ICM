function [Max,Min]=MaxMin(X)

%Trouver les maximas et minima d'une fonction f(x) 1-D

try
    spline=csaps([1:length(X)]',double(X));
    fprime=fnder(spline);
    ind=fnzeros(fprime);
    signe=fnval(fprime,ind(1,:)+1);

    Max=floor(ind(1,find(signe<0)));
    Min=floor(ind(1,find(signe>0)));
catch ERR
    Max = find(X==max(X));
    Min = find(X==min(X));
end
    
end