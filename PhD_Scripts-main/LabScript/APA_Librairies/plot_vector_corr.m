function plot_vector_corr(X,f,plt,Xerr,c,w)
% Function to plot a frequency dependent vector X. If error bars are specified in Xerr,
% it also plots them. Xerr can either contain upper and lower confidence intervals 
% on X, or simply a theoretical confidence level (for the coherence). Used
% to plot the spectrum and coherency.
% Usage: plot_vector(X,f,plt,Xerr,c)
% Inputs:
% X: input vector as a function of frequency (f), see third argument
% f: f axis grid for plot. Default. [1:length(X)]
% plt: 'l' for log, 'n' for no log.
% Xerr: flag to plot corridors. Defauult 0
% c: controls the color of the plot - input 'b','g','r' etc. Default 'b'
% w: controls the width of the lines - input 1, 1.5, 2 etc Default 1

if nargin < 1; error('Need data'); end;
N=length(X); 
if nargin < 2 || isempty(f);
    f=1:N;
end;
if length(f)~=N; error('frequencies and data have incompatible lengths'); end;
if nargin < 3 || isempty(plt) ;
    plt='l';
end;
if nargin < 4 || isempty(Xerr);
    Xerr=[];
end;
if nargin < 5 || isempty(c)
    c='b';
end;
if nargin < 6 || isempty(w);
    w=1;
end;

if strcmp(plt,'l');
    X=10*log10(X);
    if nargin >=4 && ~isempty(Xerr); Xerr=10*log10(Xerr); end;
end;

if nargin < 4 || isempty(Xerr);
    plot(f,X,c,'Linewidth',w);
else
    stdshade(X,0.25,c,f,1,[],2,[],0.5);
end

xlabel('Hz');
if strcmp(plt,'l'); ylabel('10*log10(P) (dB)'); else ylabel('uV�/Hz'); end;
axis tight


