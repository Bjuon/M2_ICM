% Récupération des infos dans ResAPA.Trial et copie dans le metadata.trial.Gait

% 2 options :
% - Prend uniquement les données issues de ResAPA
% - Calcul les Variables d'intérêt pour S1,S2,S3
%           Si on fait cette option, inputs : SP1 (CP Pos),SP3 (CP Speed),EV (events)

function m = ResAPA_to_metadataGait(m,ResAPA_trial,varargin)

% all_fields = {'t_Reaction' 't_APA' 'APA_antpost' 'APA_lateral'...
%     'StepWidth' 't_swing1' 't_DA' 't_swing2' 't_cycle_marche' 'Longueur_pas'...
%     'V_swing1' 'Vy_FO1' 't_VyFO1' 'Vm' 't_Vm' 'VML_absolue' 'Freq_InitiationPas' 'Cadence'...
%     'VZmin_APA' 'V1' 'V2' 'Diff_V' 'Freinage' 't_chute' 't_freinage' 't_V1' 't_V2'};
all_fields = fields(ResAPA_trial);
all_fields(strcmp(all_fields,'Cote')) = [];
all_fields(strcmp(all_fields,'TrialName')) = [];
all_fields(strcmp(all_fields,'TrialNum')) = [];
all_fields(strcmp(all_fields,'Description')) = [];
all_fields(strcmp(all_fields,'t_1step')) = [];

% on supprimes les fields qui n'ont pas d'utilité : (à compléter plus tardpeut être) : t_VyFO1 t_V1 t_V2
all_fields(strcmp(all_fields,'t_VyFO1')) = [];
all_fields(strcmp(all_fields,'t_V1')) = [];
all_fields(strcmp(all_fields,'t_V2')) = [];

all_fields2 = all_fields; % all_fields2 pour la sortie dans metadata.trial.Gait. / all_fields pour l'entrée de ResAPA_trial

% on renomme les fields avec nouvelle nomenclature
all_fields2(strcmp(all_fields,'APAy')) = {'APA_antpost'};
all_fields2(strcmp(all_fields,'APAy_lateral')) = {'APA_lateral'};
all_fields2(strcmp(all_fields,'t_execution')) = {'t_swing1'};
all_fields2(strcmp(all_fields,'t_step2')) = {'t_swing2'};
all_fields2(strcmp(all_fields,'V_exec')) = {'V_swing1'};


m.startingfoot = ResAPA_trial.Cote;

for i_field = 1:numel(all_fields)
    eval(['m.' all_fields2{i_field} '= ResAPA_trial.' all_fields{i_field} ';']);
end

if ~isempty(varargin)
    % calcul des variables relatives à S1,S2,S3
    %     all_fields2 = {'DuraS1Lat' 'DuraS2Lat' 'APA_antpost_S1Lat' 'APA_lateral_S1Lat' 'APA_antpost_S2Lat' 'APA_lateral_S2Lat'...
    %     'Vmax_APA_antpost_S1Lat' 'Vmax_APA_lateral_S1Lat' 'Vmax_APA_antpost_S2Lat' 'Vmax_APA_lateral_S2Lat'...
    %     'DuraS1Post' 'DuraS2Post' 'APA_antpost_S1Post' 'APA_lateral_S1Post' 'APA_antpost_S2Post' 'APA_lateral_S2Post'...
    %     'Vmax_APA_antpost_S1Post' 'Vmax_APA_lateral_S1Post' 'Vmax_APA_antpost_S2Post' 'Vmax_APA_lateral_S2Post'...
    %     'DuraS3FC1' 'APA_antpost_S3FC1' 'APA_lateral_S3FC1' 'Vmax_APA_antpost_S3FC1' 'Vmax_APA_lateral_S3FC1'...
    %     'DuraS3FO2' 'APA_antpost_S3FO2' 'APA_lateral_S3FO2' 'Vmax_APA_antpost_S3FO2' 'Vmax_APA_lateral_S3FO2'};
    
    SP1 = varargin{1}; % CP Pos
    SP3 = varargin{2}; % CP Speed
    EV = varargin{3};  % Events
    
    all_fields2 = {'DuraS1' 'DuraS2' 'APA_antpost_S1' 'APA_lateral_S1' 'APA_antpost_S2' 'APA_lateral_S2'...
        'Vmax_APA_antpost_S1' 'Vmax_APA_lateral_S1' 'Vmax_APA_antpost_S2' 'Vmax_APA_lateral_S2'...
        'DuraS3' 'APA_antpost_S3' 'APA_lateral_S3' 'Vmax_APA_antpost_S3' 'Vmax_APA_lateral_S3'};
    
    T0 = EV.find('eventVal','T0').tStart;
    S1(1) = EV.find('eventVal','S1-ML').tStart; % Medio-lat
    S1(2) = EV.find('eventVal','S1-AP').tStart; % Antéro-post
    if isnan(EV.find('eventVal','FO1').tStart)
        FootOff = EV.find('eventVal','TO').tStart;
    else
        FootOff = EV.find('eventVal','FO1').tStart;
    end
        
    FC1 = EV.find('eventVal','FC1').tStart;
    FO2 = EV.find('eventVal','FO2').tStart;
    
    DuraS1 = S1 - T0;
    DuraS2 = FootOff - S1;
    DuraS3 = [FC1 - FootOff, FO2 - FootOff]; % [FC1 FO2]
    
    Fs = SP1.Fs;
    
    % on vérifie que longueur S1 par trop courte, sinon NaN pour les variables
    try max(DuraS1) > 1e-3;
        
    for i_S1 = 1:2
        % déplacement du CP pdt S1
%         temp = [valueAt(SP1,S1(i_S1))'-valueAt(SP1,T0)'];
        temp = [max(abs(SP1.values{:}(round(T0*Fs):round(S1(i_S1)*Fs),:)))'-abs(valueAt(SP1,T0,'nearest'))'];
        APA_antpost_S1(i_S1) = temp(1);
        APA_lateral_S1(i_S1) = temp(2);
        clear temp sgn;
        % déplacement du CP pdt S2
%         temp = [valueAt(SP1,FO1)'-valueAt(SP1,S1(i_S1))'];
        temp = [range(abs(SP1.values{:}(round(S1(i_S1)*Fs):round(FootOff*Fs),:)))'];
        sgn = sign(min(SP1.values{:}(round(S1(i_S1)*Fs):round(FootOff*Fs),1))-SP1.values{:}(round(S1(i_S1)*Fs),1));
        APA_antpost_S2(i_S1) = sgn * temp(1);
        APA_lateral_S2(i_S1) = temp(2);
        clear temp sgn;
        
        % Vitesse max du CP pdt S1
        win = [T0 S1(i_S1)];
        SP3.window = win;
        temp = max(abs(SP3.values{:}));
        Vmax_APA_antpost_S1(i_S1) = temp(1);
        Vmax_APA_lateral_S1(i_S1) = temp(2);
        clear temp; SP3.reset;
        % Vitesse max du CP pdt S2
        win = [S1(i_S1) FootOff];
        SP3.window = win;
        temp = max(abs(SP3.values{:}));
        Vmax_APA_antpost_S2(i_S1) = temp(1);
        Vmax_APA_lateral_S2(i_S1) = temp(2);
        clear temp;
        SP3.reset;
    end
    catch
        APA_antpost_S1(1:2) = NaN; APA_lateral_S1(1:2) = NaN;
        APA_antpost_S2(1:2) = NaN; APA_lateral_S2(1:2) = NaN;
        Vmax_APA_antpost_S1(1:2) = NaN; Vmax_APA_lateral_S1(1:2) = NaN;
        Vmax_APA_antpost_S2(1:2) = NaN; Vmax_APA_lateral_S2(1:2) = NaN;
    end
    
    end_S3 = [FC1 FO2]; % pour pouvoir boucler ensuite
    for i_S3 = 1:2
        % déplacement du CP pdt S3
        temp = [valueAt(SP1,end_S3(i_S3),'nearest')'-valueAt(SP1,FootOff,'nearest')'];
        APA_antpost_S3(i_S3) = temp(1);
        APA_lateral_S3(i_S3) = temp(2);
        clear temp;
        % Vitesse max du CP pdt S3
        win = [FootOff end_S3(i_S3)];
        SP3.window = win;
        temp = max(SP3.values{:});
        if isempty(temp)
            temp = [NaN NaN]; % pour éviter bug si pb window
        end
        Vmax_APA_antpost_S3(i_S3) = temp(1);
        Vmax_APA_lateral_S3(i_S3) = temp(2);
        clear temp; SP3.reset;
    end
    
    for i_field = 1:numel(all_fields2)
        eval(['m.' all_fields2{i_field} '= ' all_fields2{i_field} ';']);
    end
    
end

m.trial = ResAPA_trial.TrialName;
m.nTrial = ResAPA_trial.TrialNum';