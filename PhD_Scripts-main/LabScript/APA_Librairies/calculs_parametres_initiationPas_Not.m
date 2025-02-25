function Res = calculs_parametres_initiationPas_Not(Acq,Res)
%% Calcul des param�tres d'initiation du pas � partir des donn�es d�j� extraites dans la structure 'primResultats'
% Entr�es : Acq  - Structure contenant les champs:(Sujet.(acq_courante) par d�faut)
    % tMarkers = Structure (Sujet.(acq_courant).tMarkers par d�faut) contenant les marqueurs temporels en champs
    % primResultats = Structures contenant les r�sultats pr�liminaires () du pr�traitement sous forme [#occurence/frame valeur] (1x2)
    %              .Vy_TO = vitesse AP du CG lors du TO
    %              .Vm = vitesse maximale AP du CG (qnd Acc == 0)
    %              .VZmin_APA = vitesse minimale verticale du CG lors des APA
    %              .V1 = vitesse minimale verticale du CG lors de l'�xecution du pas
    %              .V2 = vitesse verticale du CG lors du FC1 (Foot-Contact du pied oscillant)
    %              .VML_abs = valeur absolue de la vitesse moyenne m�diolat�rale
    %              .minAPAy_AP = d�placement post�rieur max lors des APA
    %              .APAy_ML = valeur absolue du d�placement lat�ral max lors des APA
%          Res - Structure contenant les R�sultats d�j� calcul�s

%Sorties : Duree_Anticipation; APAy; APAx; Largeur_pas; Duree_Execution;
%          Duree_DbleAppui; Duree_1erCycle; Duree_Initiation;  
%          Longueur_pas; Vy_FO1; t_FO1; Vy_max; t_Vymax_real; Vz_min;
%          Vz_FC1; Degre_Freinage; Freinage; Temps_Freinage; t_Vzmin_real          

%% Extraction des fields d'int�r�t
tMarkers = Acq.tMarkers;
primResultats = Acq.primResultats;
Fech = Acq.Fech;


%% Identification du c�t�
try
    [bbs,stats]=robustfit(Acq.t(round(tMarkers.T0*Fech):primResultats.APAy_ML(1,1)),Acq.CP_ML(round(tMarkers.T0*Fech):primResultats.APAy_ML(1,1)));
    signe = bbs(2);
    if signe<0
        Res.Pied = 'Gauche';
    else
        Res.Pied = 'Droit';
    end
catch ERR
    Res.Pied = cell2mat(inputdlg('C�t� ?','Choix Manuelle du c�t�',1,{'D'}));
end

%% Dur�e des APA (pr�paration du mouvement)
Res.Duree_Anticipation = tMarkers.TO - tMarkers.T0;

%% Valeur minimale du CP en ant�ropost�rieur (APAy)
Res.APAy = primResultats.minAPAy_AP(1,2);

%% D�placement lat�ral max du CP lors des APA (APAy_lat) 
Res.APAx = primResultats.APAy_ML(1,2);

%% Largeur du pas
Res.Largeur_pas = primResultats.Largeur_pas;

%% Dur�e d'�xecution du pas (entre TO et FC1)
Res.Duree_Execution = tMarkers.FC1 - tMarkers.TO;

%% Dur�e du double-appui
Res.Duree_DbleAppui = tMarkers.FO2 - tMarkers.FC1;

%% Dur�e du cycle de marche (entre T0 et FO2)
Res.Duree_1erCycle = tMarkers.FO2 - tMarkers.TO;

%% Dur�e initiation (entre OnSetAcc et VyMax)
Res.Duree_Initiation = primResultats.Vm(1)/Fech - Res.t_OnsetACCy;

%% Longueur du pas
Res.Longueur_pas = primResultats.Longueur_pas;

%% Vitesse AP � la fin des APA (t = TO)
Res.Vy_FO1 = primResultats.Vy_FO1(2);

%% Temps du Toe-Off (tTO = TO)
Res.t_FO1 = tMarkers.TO - tMarkers.TR;

%% Vitesse maximale � la fin du 1er APA
Res.Vy_max = primResultats.Vm(2);

%% Temps pour atteindre Vm
Res.t_Vymax_real = primResultats.Vm(1)/Fech - tMarkers.TR;

%% Vitesse minimale pendant l'�xecution du pas
Res.Vz_min = primResultats.V1(2);

%% Vitesse verticale lors du foot-contact
Res.Vz_FC1 = primResultats.V2(2);
%% Degr� Freinage
Res.Degre_Freinage = abs(Res.Vz_min - Res.Vz_FC1);

%% Force de freinage
Res.Freinage = Res.Degre_Freinage*1e2/abs(Res.Vz_min);

%% Dur�e du freinage
Res.Temps_Freinage = tMarkers.FC1 - primResultats.V1(1)/Fech;

%% Temps pour atteindre V1
Res.t_Vzmin_real = primResultats.V1(1)/Fech - tMarkers.TR;

end