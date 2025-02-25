function curr_Seg = calculs_parametres_initiationPas_v5_LabTools(curr_Seg,varargin)
%% Calcul des param�tres d'initiation du pas � partir des donn�es d�j� extraites dans la structure 'primResultats'
% Entr�e : Acq = Structure contenant les champs:(Sujet.(acq_courante) par d�faut), T_trig = temps du trigger externe num�rique (si existe)
% .tMarkers = Structure (Sujet.(acq_courant).tMarkers par d�faut) contenant les marqueurs temporels en champs
% .primResultats = Structures contenant les r�sultats pr�liminaires () du
% pr�traitement sous forme [#occurence/frame valeur] (1x2) : ces r�sultats
% sont issus de calcul_auto_APA_marker_v2.m
%              .Vy_FO1 = vitesse AP du CG lors du FO1
%              .Vm = vitesse maximale AP du CG (qnd Acc == 0)
%              .VZmin_APA = vitesse minimale verticale du CG lors des APA
%              .V1 = vitesse minimale verticale du CG lors de l'�xecution du pas
%              .V2 = vitesse verticale du CG lors du FC1 (Foot-Contact du pied oscillant)
%              .VML_abs = valeur absolue de la vitesse moyenne m�diolat�rale
%              .minAPA_AP = d�placement post�rieur max lors des APA
%              .APA_ML = valeur absolue du d�placement lat�ral max lors des APA
% .CP_AP = d�placement AP du CP
% .Trigger = temps du trigger externe correspondant � l'acquisition (si existe)
% Sorties : R = structure avec les champs correspondants aux param�tres des APAs suivants:
%                   Cote
%                   t_Reaction
%                   t_APA
%                   APA_antpost
%                   APA_lateral
%                   StepWidth
%                   t_swing1
%                   t_DA
%                   t_swing2
%                   t_cycle_marche
%                   Longueur_pas
%                   V_swing1
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

% modifs par rapport � V4 : on red�finit le terme %   TO --> FO1
% 	t_execution -> t_swing1
% 	V_exec -> V_swing1
% 	t_step2 -> t_swing2


% adaptation de alculs_parametres_initiationPas_v5 pour correspondre � LabTools toolbox

% on v�rifie au pr�alable l'ordre des samples process
switch curr_Seg.sampledProcess(1).labels(1).name
    case 'CP-MedioLat'
        % Correspond � la condition par d�faut OK
    otherwise
        error('Ordre des sampledProcess non valable pour calculs des param�tres des APA')
end
switch curr_Seg.sampledProcess(2).labels(3).name
    case 'CGSpeedVert'
        % Correspond � la condition par d�faut OK
    otherwise
        error('Ordre des sampledProcess non valable pour calculs des parma�tres des APA')
end

% calcul des �v�nements d'int�ret
GO = curr_Seg.eventProcess(1).find('func',@(x) strcmp(x.name.name,'GO'));
T0 = curr_Seg.eventProcess(1).find('func',@(x) strcmp(x.name.name,'T0'));
HO = curr_Seg.eventProcess(1).find('func',@(x) strcmp(x.name.name,'HO'));
FO1 = curr_Seg.eventProcess(1).find('func',@(x) strcmp(x.name.name,'FO1'));
FC1 = curr_Seg.eventProcess(1).find('func',@(x) strcmp(x.name.name,'FC1'));
FO2 = curr_Seg.eventProcess(1).find('func',@(x) strcmp(x.name.name,'FO2'));
FC2 = curr_Seg.eventProcess(1).find('func',@(x) strcmp(x.name.name,'FC2'));

if FO2.tStart == 0
    FO2.tStart = 2;
end

m = metadata.trial.Gait;

%% partie issue de calcul_auto_APA_marker_v2 / sauf c�t�
%% Identification du c�t�
signe = curr_Seg.sampledProcess(1).valueAt(FO1.tStart,'method','nearest')-...
    curr_Seg.sampledProcess(1).valueAt(T0.tStart,'method','nearest');
if signe(1) > 0
    m.startingfoot = 'Left';
elseif signe(1) < 0
    m.startingfoot = 'Right';
else
    m.startingfoot = '';
end

%% Valeur minimale du CP en ant�ropost�rieur (APA_antpost)
temp = curr_Seg.sampledProcess(1).subset(2);
temp.window = [T0.tStart HO.tStart];
[C,I] = min(temp.values{:});
m.APA_antpost(1) = abs(temp.values{:}(I));
m.APA_antpost(2) = temp.times{:}(I)-temp.times{:}(1);
curr_Seg.sampledProcess(1).undo; curr_Seg.sampledProcess(1).undo;
clear temp C I;
%% D�placement lat�ral max du CP lors des APA (APA_lat)
temp = curr_Seg.sampledProcess(1).subset(1);
temp.window = [T0.tStart HO.tStart];
switch m.startingfoot
    case 'Left'
        [C,I] = min(temp.values{:});
    case 'Right'
        [C,I] = max(temp.values{:});
end
m.APA_lateral(1) = abs(temp.values{:}(I));
m.APA_lateral(2) = temp.times{:}(I) - temp.times{:}(1);
curr_Seg.sampledProcess(1).undo; curr_Seg.sampledProcess(1).undo;
clear temp C I;

%% Vitesse maximale ant�ropost entre HO et FO2
temp = curr_Seg.sampledProcess(2).subset(1);
temp.window = [HO.tStart FO2.tStart];
[C,I]= max(temp.values{:});
m.Vm(1) = C;
m.Vm(2) = temp.times{:}(I); % en absolu

% Temps pour atteindre Vm
m.t_Vm = temp.times{:}(I) - temp.times{:}(1);
curr_Seg.sampledProcess(2).undo; curr_Seg.sampledProcess(2).undo;
clear temp C I;

%% Vitesse verticale minimale pendant les APA [T0-FO1]
temp = curr_Seg.sampledProcess(2).subset(3);
temp.window = [T0.tStart FO1.tStart];
[C,I]= min(temp.values{:});
m.VZmin_APA(1) = C;
m.VZmin_APA(2) = temp.times{:}(I) - temp.times{:}(1);
curr_Seg.sampledProcess(2).undo; curr_Seg.sampledProcess(2).undo;
clear temp C I;

%% Vitesse verticale minimale pendant l'�xecution du pas [FO1-FC1]
temp = curr_Seg.sampledProcess(2).subset(3);
temp.window = [FO1.tStart FC1.tStart];
[C,I]= min(temp.values{:});
m.V1(1) = C;
m.V1(2) = temp.times{:}(I);
% temps de la chute
m.t_chute = temp.times{:}(I) - temp.times{:}(1);

% Vitesse verticale lors du foot-contact
m.V2(1) = temp.values{:}(end);
m.V2(2) = range(temp.window);
curr_Seg.sampledProcess(2).undo; curr_Seg.sampledProcess(2).undo;
clear temp C I;
%% partie issue de calculs_parametres_initiationPas_v5

% Temps de r�action (entre l'instruction et le d�collement du talon) /
% si info de stim dans le Segment
try
    if strcmp(curr_Seg.info('trial').speedcondition,'GNG')
        m.t_Reaction = NaN;
    else
        m.t_Reaction = T0.tStart - GO.tStart;
    end
catch
    m.t_Reaction = T0.tStart - GO.tStart;
end

%% Dur�e des APA (pr�paration du mouvement)
m.t_APA = FO1.tStart - T0.tStart;

%% Largeur du pas
curr_Seg.sampledProcess(1).subset(1); % on s�lectionne donn�es MedioLat
m.StepWidth = range([curr_Seg.sampledProcess(1).valueAt(FC1.tStart,'method','nearest'),...
    curr_Seg.sampledProcess(1).valueAt(FO2.tStart,'method','nearest')]);
curr_Seg.sampledProcess(1).undo;

%% Dur�e du 1er pas (entre FO1 et FC1)
m.t_swing1 = FC1.tStart - FO1.tStart;

%% Dur�e du double-appui (entre FO2 et FC1)
m.t_DA = FO2.tStart - FC1.tStart;

%% Dur�e du 2�me pas (entre FO2 et FC2)
m.t_swing2 = FC2.tStart - FO2.tStart;

%% Dur�e du cycle de marche (entre FO1 et FC2)
m.t_cycle_marche = FC2.tStart - FO1.tStart;

%% Longueur du pas
curr_Seg.sampledProcess(1).subset(2); % on s�lectionne donn�es AnteroPost
m.Longueur_pas = range([curr_Seg.sampledProcess(1).valueAt(FC1.tStart,'method','nearest'),...
    curr_Seg.sampledProcess(1).valueAt(FO2.tStart,'method','nearest')]);
curr_Seg.sampledProcess(1).undo;

%% Vitesse d'�xecution du 1er pas
m.V_swing1 = m.Longueur_pas/m.t_swing1;

%% Vitesse AP � la fin des APA (t = FO1)
%     m.Vy_FO1(1,2) = (tMarkers(4)-tMarkers(1))*Fech; %% Supprim� pcq ne correspond � rien !
curr_Seg.sampledProcess(2).subset(1); % on s�lectionne donn�es AnteroPost
m.Vy_FO1(1,1) = curr_Seg.sampledProcess(2).valueAt(FO1.tStart,'method','nearest');
curr_Seg.sampledProcess(2).undo;

%
%     %% Vitesse M�diolat�ral du CG
%     m.VML_absolue = abs(mean(Trial_APA.CG_Speed.Data(2,round(tMarkers(4)*Fech):end-5)));
%
%% Fr�quence d'initiation du pas
m.Freq_InitiationPas = 1/(FC2.tStart-FO1.tStart);

%% Cadence (calculs empiriques)
m.Cadence = 60*m.Freq_InitiationPas;

%% Diff�rence des vitesses verticales
m.Diff_V = m.V1(1) - m.V2(1);

%% Force de freinage
m.Freinage = abs(m.Diff_V*1e2/m.V1(1));

%% Dur�e du freinage
m.t_freinage = FC1.tStart - FO1.tStart - m.t_chute;

try
    % on r�cup�re les infos de trial
    m.patient = curr_Seg.info('trial').patient;
    m.session = curr_Seg.info('trial').session;
    m.medcondition = curr_Seg.info('trial').medcondition;
    m.speedcondition = curr_Seg.info('trial').speedcondition;
    m.trial = curr_Seg.info('trial').trial;
    m.nTrial = curr_Seg.info('trial').nTrial;
    m.freezing = curr_Seg.info('trial').freezing;
    m.maxEMG = curr_Seg.info('trial').maxEMG;
catch
    idx_tag = strfind(varargin{1},'_');
    m.patient = varargin{1}(idx_tag(2)+1:idx_tag(3)-1);
    m.session = varargin{1}(idx_tag(1)+1:idx_tag(2)-1);
    m.medcondition = varargin{1}(idx_tag(3)+1:idx_tag(4)-1);
    m.speedcondition = varargin{1}(idx_tag(4)+1:idx_tag(5)-1);
    m.trial = varargin{1};
    m.nTrial = varargin{1}(idx_tag(5)+1:end-4);
end

% on supprime les infos stock�es auparavant dans info / si key trial existe
if ~isempty(curr_Seg.info.keys)
    remove(curr_Seg.info,'trial');
end

% on met � jour les infos dans info('trial')
curr_Seg.info('trial') = m;

