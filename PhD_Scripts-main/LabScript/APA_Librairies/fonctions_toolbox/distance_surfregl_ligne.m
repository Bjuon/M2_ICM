%
% Recherche les points d'une ligne les plus proches d'une surface r�gl�e ...
%
function dist = distance_surfregl_ligne(SR,L,ortho) ;
%
% 1. Initialisation de variables de calcul ...
%
[N,dim] = size(SR.pts) ; % Nombre de droites entr�es dans la Surface R�gl�e
[M,dim2] = size(L) ;     % Nombre de points dans la Ligne
%
% 2. Cr�ation de tenseur N*M*dim 
%
for t = 1:dim ; % ---> dans chacune des directions ...
    %
    % ---> les vecteurs PjSi (points lignes points origines droite)
    %
    PjSi(:,:,t) = SR.pts(:,t) * ones(1,M) - ones(N,1) * L(:,t)' ; 
    %             {---------------------}   {------------------}
    %                |--> Tenseurs des origines des droites  |
    %                     Tenseurs des points de la ligne <--|
    %
    % ---> les vecteurs directeurs des droites � associer � chacun des points de la ligne
    %
    Ndir(:,:,t) = SR.V_dir(:,t) * ones(1,M) ; 
    %
    % ---> Cr�ation d'un tenseur ortho N*M*dim
    %
    if nargin == 3 ; % ---> Traitement de ortho si n�cessaire
        Tho(:,:,t) = ortho(1,t) * ones(N,M) ;
    end
end
%
% 3. Suivant le nombre d'entr�es :
%     - 2 entr�es : minimisation en projections orthogonales sur les droites du cone
%     - 3 entr�es : minimisation en projections orthogonales au vecteur ortho
%
if nargin == 2
    %
    % 4. Calcul des localisations des projections des points de la ligne sur les droites de la surface
    %    Orthogonalement au cone
    %
    Lambda = sum(-PjSi.*Ndir,3) ; 
    %
elseif nargin == 3 ;
    %
    % 4. Calcul des localisations des projections des points de la ligne sur les droites de la surface
    %    Orthogonalement � ortho
    Lambda = sum(-PjSi.*Tho,3)./sum(Tho.*Ndir,3) ; 
    %
end
%
% 5. Recherche du point le plus proche pour chacun des points de la ligne
% 
% ---> Calcul des distances entre chacun des points de la ligne et les droites de SR
% 
NPjmi = sum(PjSi.*PjSi,3) - Lambda ;
%
% ---> Recherche des valeurs minimales pour chacune des droites 
%
[dist.valeurs,ou] = min(NPjmi,[],2) ;
%
% 6. Cr�ation du point asssoci� � chacune des droites
%
for t = 1:N ;
    %
    % ---> Point sur la droite ... t
    %
    dist.pt_SR(t,:) = SR.pts(t,:) +  Lambda(t,ou(t)) * SR.V_dir(t,:) ;
    %
    % ---> Point de la ligne associ�
    %
    dist.pt_ligne(t,:) = L(ou(t),:) ;
end
%
% Fin de la fonction
