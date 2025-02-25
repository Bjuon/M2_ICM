function h = afficheY_v2(k,Donnees,axe_courant)
%% Afficher N droite(s) de type Y=k
%h  = afficheY_v2(k,Donnees,axe_courant)
% h = handle du plot
% Donnees = style(s) d'affichage [N x n] matrice de charactères
% axe_courant = handle de l'axe sur lequel on desire afficher

K=length(k);
if nargin<3
    Donnees(1:K,:)=repmat('k-',K,1);
    axe_courant = gca;
end

for i=1:K
    xlim = get(axe_courant,'xlim');
    axee = [xlim(1) k(i); xlim(2) k(i)] ;
    set(axe_courant,'NextPlot','add');
    h(i)=plot(axe_courant,axee(:,1),axee(:,2),Donnees(i,:),'Linewidth',1);
    set(h,'Xdata',axee(:,1),'Ydata',axee(:,2));
    set(axe_courant,'NextPlot','new');
end

end