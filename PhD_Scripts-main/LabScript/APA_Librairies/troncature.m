function r=troncature(x,n)
%% Fonction qui permet de tronquer � n chiffres apr�s la virgule

multi=10^n;
a=round(x*multi);

r=a/multi;
end
