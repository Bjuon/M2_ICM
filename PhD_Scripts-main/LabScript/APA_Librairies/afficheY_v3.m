function h = afficheY_v3(k,Donnees,axe_courant,w)
%% Afficher N droite(s) de type Y=k
%h  = afficheY_v2(k,Donnees,axe_courant)
% h = handle du plot
% Donnees = style(s) d'affichage [N x n] matrice de charactères
% axe_courant = handle de l'axe sur lequel on desire afficher
% w = epaisseur de la ligne

K=length(k);
if nargin<2
    Donnees(1:K,:)=repmat('k-',K,1);
    axe_courant = gca;
    w= 1;
end
if nargin<3
    axe_courant = gca;
    w= 1;
end
if nargin<4   
    w= 1;
end

for i=1:K
    xlim = get(axe_courant,'xlim');
    axee = [xlim(1) k(i); xlim(2) k(i)] ;
    set(axe_courant,'NextPlot','add');
    h(i)=plot(axe_courant,axee(:,1),axee(:,2),'Color',[0.8 0.8 0.8],'Linewidth',w);%%%
    set(h,'Xdata',axee(:,1),'Ydata',axee(:,2));
    set(axe_courant,'NextPlot','new');
end

end