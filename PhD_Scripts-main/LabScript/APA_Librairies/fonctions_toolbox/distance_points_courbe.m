function dist = distance_points_courbe(C,Pts) ;
%
% 1) Recherche des points proches
%
D = distance_points_proches(C.coord,Pts) ; % PA0
%
% 2) Calcul des distances points segments pour chacun des Pts
%
N_Pts = size(Pts,1) ;
%
for t = 1:N_Pts ;
    % Points le plus proche :
    Pt_p = D.ou(t) ;
    % A quel tri appartient-il ?
    for y = 1:length(C.tri) ;
        ok = find(C.tri{y} == Pt_p) ;
        if ~isempty(ok) ;
            y_ok = y ;
            break
        end
    end
    % Calcul des distances entre le points et les segment contenant Pt_p :
    % a) On regarde si on a affaire à un contour fermé ou ouvert
    liste_pts = C.tri{y_ok} ;
    deb = liste_pts(1) ; 
    fin = liste_pts(end) ;
    if deb == fin ;
        % le contour est fermé
        test_f = 1 ;
    else
        % le contour est ouvert
        test_f = 0 ;
    end
    % b) création des segments
    if Pt_p == deb ;                      % Point précédant
        if test_f == 1 ;
            Ptpre = liste_pts(end-1) ;
        else
            Ptpre = Pt_p ;
        end
    else
        Ptpre = Pt_p - 1 ;
    end
    %
    if Pt_p == fin ;                      % Point suivant
        if test_f == 1 ;
            Ptsui = liste_pts(2) ;
        else
            Ptsui = Pt_p ;
        end
    else
        Ptsui = Pt_p + 1 ;
    end
    % c) calcul des distances :
    % précédant
    if Ptpre == Pt_p ;
        d_pre = D.valeurs(t) ;
    else
        d_pre = distance_point_segment(C.coord([Pt_p,Ptpre],:),Pts(t,:)) ;
    end
    % suivant
    if Ptsui == Pt_p ;
        d_sui = D.valeurs(t) ;
    else
        d_sui = distance_point_segment(C.coord([Pt_p,Ptsui],:),Pts(t,:)) ;
    end
    % d) choix de la plus petite distance
    dist(t) = min([d_pre,d_sui]) ;
end
%
% fin de la fonction