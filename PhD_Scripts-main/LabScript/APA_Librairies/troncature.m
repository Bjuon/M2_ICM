function r=troncature(x,n)
%% Fonction qui permet de tronquer à n chiffres après la virgule

multi=10^n;
a=round(x*multi);

r=a/multi;
end
