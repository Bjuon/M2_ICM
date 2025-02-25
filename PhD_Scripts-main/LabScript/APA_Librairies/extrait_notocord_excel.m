function [Data t suggested_stop] = extrait_notocord_excel(file)
%% Extraction des donn�es utiles d'un fichier .xls (file) au format d'extraction notocord
% Data: structure contenant les champs:
%     .actmec = matrice des actions m�caniques
%       col 1-3  : d�placement ML et AP du CP (Z=0)
%       col 4-6  : position de l'origine de la PF par rappor au repere globale (coin arri�re gauche) defaut: 450 900 0
%       col 7-9  : composantes de la GRF (Fx Fy Fz)
%       col 10-12: moments par rapport � l'origine de la PF (Mx My Mz)
%     .coord = coordonn�es 3D des marqueurs reflechissants (vide par d�faut si Notocord uniquement)
%     .EMG .nom: nom des muscles/voies
%          .valeurs: valeurs par colonne/voie
%     .T_trigs: vecteur contenant le/les temps des triggers num�riques (si existent)
% t: vecteur temps
% suggested_stop : indice � partir du quel il est sugg�r� d'arr�ter l'analyse pour r�duire la complexit� des calculs et l'affichage

Data = {};
%% Donn�es PF
data_sheet = 'valeurs'; %% Nom de la feuille contenant les donn�es de la PF uniquement
% range = 'B10:J1761'; %% Etendue des donn�es correspondantes au 3,5 sec suivant chaque marqueur notocord %%%% A fixer

[NUMERIC,TXT,donnees]=xlsread(file,data_sheet);
voies = size(NUMERIC,2); % Nombre de voies NOTOCORD == 7 (d�faut, 6 + 1 Temps)

%Initialisation
t=NUMERIC(:,1); %Vecteurs temporel
taille = length(t);
actmec = NaN*ones(taille,12);

%% Calcul des offsets par voie
PF=NUMERIC(:,2:7);
Offsets = nanmean(PF(taille-100:end,:),1); %% On calcul la moyenne du signal sur les derni�res 0.2 sec de l'acquisition ou le sujet est th�oriquement en dehors de la PF

if sum(Offsets)>1e4 %Patient toujours sur la PF � la fin de l'acquisition
    Offsets = zeros(1,6);
end

PF_correct_dc = PF - repmat(Offsets,taille,1); %% Correction: soustraction de la composante continue

%% Facteurs d'�chelles (??)
 K(1,1)= 0.037352458; %Fx_conv
 K(1,2)= 0.075301205; %Fy_conv
 K(1,3)= 0.584795322; %Fz_conv
 K(1,4)= 0.207210941; %Mx_conv
 K(1,5)= 0.035801232; %My_conv
 K(1,6)= 0.023969319; %Mz_conv

PF_rescaled = PF_correct_dc.*repmat(K,taille,1);

%% Deplacement en X (ML) = -My/Fz (+ 450 si on prend comme origine le coin inf�rieure gauche de la PF) (en mm)
actmec(:,1) = (-PF_rescaled(:,5)./PF_rescaled(:,3))*1e3; %+ repmat(450,taille,1);

%% Deplacement en Y (AP) = Mx/Fz (+ 900 si on prend l'origine au d�but de la PF ds le sens du d�part de la marche) (en mm)
actmec(:,2) = (PF_rescaled(:,4)./PF_rescaled(:,3))*1e3  + repmat(900,taille,1);
suggested_stop = find(actmec(:,2)>1100,1,'first'); %Stride length moyen d'un patient ayant des troubles de la marche ~1m, donc on prend le 1er instant ou le CP est >1m
if suggested_stop<taille/10 %% Signal non offsett�
    disp('Erreur d�tection fin de 1er pas');
    suggested_stop = taille/2;
end

%% Remplissage de la matrice pour stockage
actmec(:,4:6) = repmat([450 900 0],taille,1);
actmec(:,7:12) = filtrage(PF_rescaled,'fir',50,45,500); % pr�filtrage fir � 45Hz (Fech = 500);
% On inverse le gain de Fy
actmec(:,8) = -actmec(:,8);

Data.noms={};
Data.coord=[];
Data.actmec=actmec;
Data.corner = [1 0 1800 0 900 1800 0 900 0 0 0 0 0];

%% Donn�es EMG
emg_sheet = 'EMG'; %% Nom de la feuille contenant les donn�es EMG uniquement(Fech = 5KHz)
try
    [NUMEMG,Muscles,donnees]=xlsread(file,emg_sheet);
    Data.EMG.nom = Muscles(2,:)';
    tt = round(length(NUMEMG)/taille);
    Data.EMG.valeurs = NUMEMG(1:tt:end,:); %% On r�echantillone � la m�me fr�quence que les donn�es PF
    Data.EMG.Fech = 500;
catch No_EMGs
    EMG={};
end

if voies>7 % On suppose que la derni�re colonne (si + de 7 voies) correspond au temps du trigger
    T_trigs = NUMERIC(:,end);
    T_trigs(isnan(T_trigs))=[];
    Data.T_trigs=T_trigs;
end

end