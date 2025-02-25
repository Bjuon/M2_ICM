function [Pr,d] = projection_points_courbe(Ref,Rec) ;
%
% fonction de projection d'un point sur une courbe
%

%
% 1. Vérification de l'existance d'un champ tangent dans le contour 1 et le contour 2
%
if ~isfield(Rec,'coord') ;
    Rec.coord = Rec ;
end
if ~isfield(Ref,'tangent') ;
    % ---> Nous calculons alors le repère de frenet
    Ref = calcul_repere_frenet(Ref) ;
end
Dim = size(Rec.coord,2) ;
%
% 2. Matrice de calcul des changement de signes vecteur tangent MiMj
%
A = Ref.tangent * Rec.coord' - sum(Ref.tangent .* Ref.coord,2) * ones(1,size(Rec.coord,1)) ;
%
% 3. Modification de A pour obtenir les changements de signes
%
A = A' ; % --> Mise en forme pour la modification de l'algorithme
A = A(:,1:end-1) .* A(:,2:end) ;
%
% 4. Recherche des changements de signes
%
[I,J] = find(A < 0) ;
%
% 5. tri et mise en forme de ce résultat
%
[I,tri] = sort(I) ;                             % tri par ordre croissant des points de C1
J = J(tri) ;                                    % J doit etre rangée dans le meme ordre
[Num_Pt,ou] = unique(I) ;                       % Numéro des points ayant des intersections
% ---> Nombre d'inetersections trouvées par point
A.Nb_int = zeros(length(Rec.coord),1) ;
A.Nb_int(Num_Pt) = diff([0;find(diff(I));length(I)]) ;  
A.localisation = zeros(length(Rec.coord),1) ;
A.dist = NaN * ones(length(Rec.coord),1) ;
A.coord = Inf * ones(length(Rec.coord),2) ;
%
% 6. Boucle de calcul des intersections suivant le nombre
%
for t = min(A.Nb_int):max(A.Nb_int) ;
    % ---> Recherche des points ayant t intersections
    qui = find(A.Nb_int == t) ;
    [Pt_Rec,qui] = intersect(Num_Pt,qui) ; % N° des points de C1 créant une intersection
    % ---> Traitement si et seulement si qui est non vide
    if ~isempty(qui) ;
        % ---> Calculons chacune des intersections
        for y = 1:t ;
            % ---> Initialisations
            Pt_pre = J(ou(qui) - (y-1) ) ; % N° des points de C2 suivant l'intersection
            Pt_post = Pt_pre + 1 ;         % et de ceux précédants celle-ci
            % ---> Calcul des points d'intersection
            % a) mise en forme des calculs.
            Na = Rec.coord(Pt_Rec,:) - Ref.coord(Pt_pre,:) ; 
            Np = Rec.coord(Pt_Rec,:) - Ref.coord(Pt_post,:) ;
            Va = Ref.tangent(Pt_pre,:) ;
            Vp = Ref.tangent(Pt_post,:) ;
            % b) Calcul des coefficient de répartion sur les segments
            [U,lU] = interp2v(Na,Np,Va,Vp) ;
            % c) calcul du point
            if ~isempty(U) ;
                A.coord(Pt_Rec(lU),2*y-1:2*y) = ((U * ones(1,2)).* Ref.coord(Pt_pre(lU),:) + ...
                    ((1 - U) * ones(1,2)) .* Ref.coord(Pt_post(lU),:));
                % d) calcul de la tangeante
                A.tangent(Pt_Rec(lU),2*y-1:2*y) = ((U * ones(1,2)).* Ref.tangent(Pt_pre(lU),:) + ...
                    ((1 - U) * ones(1,2)) .* Ref.tangent(Pt_post(lU),:)) ;
                % ---> Calcul des distances 
                A.dist(Pt_Rec,y) = norm2(A.coord(Pt_Rec,2*y-1:2*y) - Rec.coord(Pt_Rec,:)) ;
                % ---> localisation de l'intersection :
                A.localisation(Pt_Rec(lU),y) = (U .* Pt_pre(lU) + (1 - U) .* Pt_post(lU)) ;
            end
        end
    end
end
%
% 7. Tri des intersections en terme de distance points courbe
%
% ---> Nous notifions les points ne créant aucune intersection
%
I = find(A.localisation == 0) ;
A.dist(I) = NaN ;
% ---> Recherche des distances minimales
%
if size(A.localisation,2) ~= 1 ; % Il y a plusieurs intersections pour 1 point
    Temp = A.dist' ;
    [Temp,ordre] = sort(Temp) ;
    A.dist = Temp' ;
    clear Temp ;
    %
    % ---> Nous devons modifier en conséquence localisation et coordonnées
    %
    Temp1 = A.localisation' ;
    Temp2 = A.coord' ;
    for t = 1:length(A.Nb_int) ;
        Temp12(:,t) = Temp1(ordre(:,t),t) ;
        Temp22([2:2:size(Temp2,1)],t) = Temp2(2*ordre(:,t),t) ;
        Temp22([1:2:size(Temp2,1)-1],t) = Temp2(2*ordre(:,t)-1,t) ;
    end
    A.localisation = Temp12' ;
    A.coord = Temp22' ;
    clear Temp12 Temp22 Temp1 Temp2 ;
end
%
% 8. Création des intersections conservées
%
% ---> On peut d'ors et déjà suprimer les noeuds ne créant pas d'intersections
%      et ayant une distance infini
%
liste_ok = find(A.localisation(:,1) ~= 0) ;
liste_ok = liste_ok(find(A.dist(liste_ok,1) ~= Inf)) ;
%
% ---> Mise en forme des variables de sortie
%
Pr = NaN * ones(size(Rec.coord,1),2) ;
Pr(liste_ok,:) = A.coord(liste_ok,1:2) ;
d = NaN * ones(size(Rec.coord,1),1) ;
d(liste_ok,:) = A.dist(liste_ok,1) ;
%
% Fin de la fonction