function [R E]= calculs_parametres_initiationPas_v3(Acq)
%% Calcul des paramètres d'initiation du pas à partir des données déjà extraites dans la structure 'primResultats' + si présence d'un trigger: Temps des evts par rapport au Trigger
% Entrée : Acq = Structure contenant les champs:(Sujet.(acq_courante) par défaut), T_trig = temps du trigger externe numérique (si existe)
    % .tMarkers = Structure (Sujet.(acq_courant).tMarkers par défaut) contenant les marqueurs temporels en champs
    % .primResultats = Structures contenant les résultats préliminaires () du prétraitement sous forme [#occurence/frame valeur] (1x2)
    %              .Vy_FO1 = vitesse AP du CG lors du FO1
    %              .Vm = vitesse maximale AP du CG (qnd Acc == 0)
    %              .VZmin_APA = vitesse minimale verticale du CG lors des APA
    %              .V1 = vitesse minimale verticale du CG lors de l'éxecution du pas
    %              .V2 = vitesse verticale du CG lors du FC1 (Foot-Contact du pied oscillant)
    %              .VML_abs = valeur absolue de la vitesse moyenne médiolatérale
    %              .minAPAy_AP = déplacement postérieur max lors des APA
    %              .APAy_ML = valeur absolue du déplacement latéral max lors des APA
    % .CP_AP = déplacement AP du CP
    % .Trigger = temps du trigger externe correspondant à l'acquisition (si existe)
% Sorties : R.()= structure avec les champs correspondants aux paramètres des APAs suivants:
%                   Cote
%                   t_Reaction
%                   t_APA
%                   APAy
%                   APAy_lateral
%                   StepWidth
%                   t_execution
%                   t_1step
%                   t_DA
%                   t_step2
%                   t_cycle_marche
%                   Longueur_pas
%                   V_exec
%                   Vy_FO1
%                   t_VyFO1
%                   Vm
%                   VML_absolue
%                   Cadence
%                   Freq_InitiationPas
%                   VZmin_APA
%                   V1
%                   V2
%                   Diff_V
%                   Freinage
%                   t_chute
%                   t_freinage
%                   t_V1
%                   t_V2
%           E.() = structure contenant les évènements identifiés sur la base temporelle du fichier LFP
%                   t_LFP_dec.xx (temps relatifs des évènements par rapport au temps du trigger (si exsite)
%                   t_LFP.xx (temps des évènements sur la base temporelle du fichier LFP)
%                   t_PF.xx (temps des évènements sur la base temporelle de la PF - non adapté/utilisé pour VICON)

%% Extraction des fields d'intérêt
tMarkers = Acq.tMarkers;
primResultats = Acq.primResultats;
Fech = Acq.Fech;
t_0 = Acq.t(1);
CP_AP = Acq.CP_AP;

%% Identification du côté
try
    [bbs,stats]=robustfit(Acq.t(round((tMarkers.T0-t_0)*Fech):primResultats.APAy_ML(1,1)),Acq.CP_ML(round((tMarkers.T0-t_0)*Fech):primResultats.APAy_ML(1,1)));
    signe = bbs(2);
    if signe<0
        R.Cote = 'Gauche';
    else
        R.Cote = 'Droit';
    end
catch ERR
    R.Cote = cell2mat(inputdlg('Côté ?','Choix Manuelle du côté',1,{'D'}));
end
    

%% Temps de réaction (entre l'instruction et le décollement du talon)
R.t_Reaction = tMarkers.HO - tMarkers.TR;

%% Durée des APA (préparation du mouvement)
R.t_APA = tMarkers.HO - tMarkers.T0;

%% Valeur minimale du CP en antéropostérieur (APAy)
R.APAy = primResultats.minAPAy_AP(2);

%% Déplacement latéral max du CP lors des APA (APAy_lat) 
R.APAy_lateral = primResultats.APAy_ML(2);

%% Largeur du pas
% R.StepWidth = R.APAy_lateral*2;
R.StepWidth = primResultats.Largeur_pas;

%% Durée d'éxecution du pas (entre TO et FC1)
R.t_execution = tMarkers.FC1 - tMarkers.TO;

%% Durée du 1er pas (entre T0 et FC1)
R.t_1step = tMarkers.FC1 - tMarkers.T0;

%% Durée du double-appui
R.t_DA = tMarkers.FO2 - tMarkers.FC1;

%% Durée du 2ème pas (entre FO2 et FC2)
R.t_step2 = tMarkers.FC2 - tMarkers.FO2;

%% Durée du cycle de marche (entre T0 et FO2)
R.t_cycle_marche = tMarkers.FO2 - tMarkers.T0;

%% Longueur du pas
if ~isempty(primResultats.Longueur_pas)
    R.Longueur_pas = primResultats.Longueur_pas;
else
    base = mean(CP_AP(1:round((tMarkers.T0-t_0)*Fech)));
    FO2 = CP_AP(round((tMarkers.FO2 - t_0)*Fech));
    R.Longueur_pas = abs(FO2-base);
end

%% Vitesse d'éxectuion du pas
R.V_exec = R.Longueur_pas/R.t_execution;

%% Vitesse AP à la fin des APA (t = TO)
R.Vy_FO1 = primResultats.Vy_FO1(2);

%% Temps du Toe-Off (tFO1 = TO)
R.t_VyFO1 = tMarkers.TO - t_0;

%% Vitesse maximale à la fin du 1er APA
R.Vm = primResultats.Vm(2);

%% Temps pour atteindre Vm
R.t_Vm = (t_0 + primResultats.Vm(1)/Fech) - tMarkers.TR;

%% Vitesse Médiolatéral du CG
R.VML_absolue = primResultats.VML_abs;

%% Fréquence d'initiation du pas
R.Freq_InitiationPas = (tMarkers.FO2 - tMarkers.TO)^-1;

%% Cadence (calculs empiriques)
% R.Cadence = 2*60/(tMarkers.FC2-tMarkers.HO);
R.Cadence = 60*R.Freq_InitiationPas;

%% Vitesse verticale minimale pendant les APA
R.VZmin_APA = primResultats.VZmin_APA(2);

%% Vitesse minimale pendant l'éxecution du pas
R.V1 = primResultats.V1(2);

%% Vitesse verticale lors du foot-contact
R.V2 = primResultats.V2(2);

%% Différence des vitesses verticales
R.Diff_V = R.V1 - R.V2;

%% Force de freinage
R.Freinage = abs(R.Diff_V*1e2/R.V1);

%% Durée de la chute du CG
R.t_chute = (t_0 + primResultats.V1(1)/Fech) - tMarkers.TO;

%% Durée du freinage
R.t_freinage = tMarkers.FC1 - (t_0 + primResultats.V1(1)/Fech);

%% Temps pour atteindre V1
R.t_V1 = primResultats.V1(1)/Fech;

%% Temps pour atteindre V2
R.t_V2 = primResultats.V2(1)/Fech;

%% Calculs des temps des évènements du pas sur la base de temps LFP
E={};
if isfield(Acq,'Trigger')
    T_trig = Acq.Trigger;
    if isfield(Acq,'Trigger_LFP') %% POur export des evts dans la base temporelle des signaux LFP
        t_0_lfp = Acq.Trigger_LFP;
        
        % Gestion des GO sonores (par coté)
        if strcmp(R.Cote,'Droit')
            E.tLFP.GD = t_0_lfp;
            E.tPF.GD = T_trig;
            E.tLFP_dec.GD = 0;
        else
            E.tLFP.GG = t_0_lfp;
            E.tPF.GG = T_trig;
            E.tLFP_dec.GG = 0;
        end

        % Gestion des autres évènements
        evts = fieldnames(tMarkers);
        for i=1:length(evts)
            if ~sum(strcmp(evts{i},{'TR' 'Onset_TA'}))
                xx = evts{i};
                eval(['E.tLFP.' xx '= t_0_lfp + (tMarkers.' xx '- T_trig);']);
                eval(['E.tPF.' xx '= tMarkers.' xx ';']);
                eval(['E.tLFP_dec.' xx '= tMarkers.' xx ' - T_trig;']);
            end
        end
    end 
end
        