function bwr = BWRcolormap(ColorMapSize)

%create BlueWhiteRed colormap
%(http://meyavuz.blogspot.fr/2011/02/meep-colormap-for-matlab.html)
mincolor    = [1 0 0]; % red
mediancolor = [1 1 1]; % white   
maxcolor    = [0 0 1]; % blue      

int1 = zeros(ColorMapSize,3); int2 = zeros(ColorMapSize,3);
for k=1:3
    int1(:,k) = linspace(mincolor(k), mediancolor(k), ColorMapSize);
    int2(:,k) = linspace(mediancolor(k), maxcolor(k), ColorMapSize);
end
bwr = [int1(1:end-1,:); int2];