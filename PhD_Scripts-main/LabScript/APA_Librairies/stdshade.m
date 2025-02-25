function f_handl=stdshade(amatrix,alpha,acolor,F,smth,haxis,width_mean,flag,k)
% usage: stdshading(amatrix,alpha,acolor,F,smth,haxis,width_mean,flag,k)
% plot mean and sem/std coming from a matrix of data, at which each row is an
% observation. sem/std is shown as shading.
% - acolor defines the used color (default is red) 
% - F assignes the used x axis (default is steps of 1).
% - alpha defines transparency of the shading (default is no shading and black mean line)
% - smth defines the smoothing factor (default is no smooth)
% - haxis defines the handle of the axis where the plot should be plotted
% - width_mean defines the width of the mean line
% - flag is a flag variables which if exists resets ths haxis nextplot property to 'replace'
% - k : facteur de réduction du corridor (entre 0 et 1)
% smusall 2010/4/23

if exist('k','var')==0 || isempty(k)
    k=1; 
end

if exist('acolor','var')==0 || isempty(acolor)
    acolor='r'; 
end

if exist('F','var')==0 || isempty(F); 
    F=1:size(amatrix,2);
end

if exist('smth','var')
    if isempty(smth)
        smth=1;
    end
else
    smth=1;
end  

if ne(size(F,1),1)
    F=F';
end

if exist('haxis','var')
    if isempty(haxis) 
        haxis=gca;
    end
else
    haxis=gca;
end

if ~exist('width_mean','var')
    width_mean=2;
elseif isempty(width_mean)
    width_mean=2;
end

try
    amean=smooth(nanmean(amatrix),smth)';
catch ERR
    amean=nanmean(amatrix);
end

astd=nanstd(amatrix)*k; % to get std shading
astd(isnan(astd)) = 0;
% astd=nanstd(amatrix)/sqrt(size(amatrix,1)); % to get sem shading

plot(haxis,F,amean,'Color',acolor,'linewidth',width_mean); %% change color or linewidth to adjust mean line
amean(isnan(amean)) = 0;
set(haxis,'NextPlot','add'); %hold on;
if exist('alpha','var')==0 || isempty(alpha) 
    f_handl=fill([F fliplr(F)],[amean+astd fliplr(amean-astd)],acolor,'linestyle','none','Parent',haxis);
    acolor='k';
else f_handl=fill([F fliplr(F)],[amean+astd fliplr(amean-astd)],acolor, 'FaceAlpha', alpha,'linestyle','none','Parent',haxis);    
end

% if ~ishold
%     hold off;
% end
if exist('flag','var') 
    if ~isempty(flag)
        set(haxis,'NextPlot','replace');
    end
end

end
