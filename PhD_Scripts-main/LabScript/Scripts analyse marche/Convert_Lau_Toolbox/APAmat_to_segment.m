% Traitement des données APA des patients GBMOV (adapté depuis le script pour les PSPMARCHE)

% Inputs :
% Fichiers *_APA.mat, *_ResAPA.mat, *_TrialParams.mat

% Outputs : Segment (1 par session et par condition de médication) et enregistrement
% Avec ajout de S1,S2,S3 (sous-phases des APA décrites) et calculs des variables d'intérêt
% pour l'instant 2 façons de calculer la fin de S1:
%   Si point le plus latéral : S1-ML
%   Si point le plus postérieur : S1-AP

%%
% Création des segments à partir des données *_APA.mat et calcul
% de S1,S2,S3
Protocol = 'GBMOV';

All_patients = {'BAUMA18'};

% All_patients = {'ABBGI01' 'ALLGE21' 'BAUMA18' 'CALVI17' 'CLANI11' 'CORDA09' 'DESMA26'...
%     'HUMCL08' 'LECCL16' 'MARDI12' 'MERPH19' 'RAYTH22' ...
%     'REBSY04' 'RECGE02'  'ROYES03' 'SALJE29' 'SOUJO07' 'VANPA23'};

All_speeds = {'S','R'};

All_stims = {'M3STIM1','M3STIM2'};

All_meds = {'OFF','ON'};

label_event = 'TO'; % pour TO ou FO1

for i_patient = 1%:numel(All_patients)
    curr_patient = All_patients{i_patient};
    for i_stim = 1%:2
        curr_stim = All_stims{i_stim};
        for i_med = 1
            curr_med = All_meds{i_med};
            for i_speed = 1:2
                curr_speed = All_speeds{i_speed};
                cd(['D:\01_GBMOV\02_MAT\STIM1et2Juin2016\' curr_stim]);
                
                rawfile_to_load = [Protocol '_' curr_stim '_' curr_patient '_' curr_med '_' curr_speed '_'];
                disp(['Current file : ' rawfile_to_load(1:end-1)]);
                load ([rawfile_to_load 'APA']); load ([rawfile_to_load 'ResAPA']); load ([rawfile_to_load 'TrialParams']);
                eval(['APA = ' rawfile_to_load 'APA;']); eval(['ResAPA = ' rawfile_to_load 'ResAPA;']); eval(['TrialParams = ' rawfile_to_load 'TrialParams;']);
                clearvars -except Protocol All_patients All_speeds All_stims All_meds label_event i_patient curr_patient i_stim curr_stim i_med curr_med i_speed curr_speed rawfile_to_load APA ResAPA TrialParams
                
                all_labels_string = {'TR','T0','HO',label_event,'FC1','FO2','FC2'};
                
                for i_trial = 1:numel(APA.Trial)
                    clear SP1 SP2 SP3 t SP3_temp coeff win a1 b1 psg0 a2 b2 e EV m
                    SP1 = SampledProcess('values',[APA.Trial(i_trial).CP_Position.Data]','labels',{'CP-AP','CP-ML'},'Fs',APA.Trial(i_trial).CP_Position.Fech);
                    SP2 = SampledProcess('values',[APA.Trial(i_trial).CG_Speed.Data]','labels',{'CG-Speed-X','CG-Speed-Y','CG-Speed-Z'},'Fs',APA.Trial(i_trial).CP_Position.Fech);
                    
                    % on calcule la vitesse du centre de pression
                    t = 0:1/SP1.Fs:length(SP1.values{:})/SP1.Fs;
                    for i_dir = 1:2
                        SP3_temp(:,i_dir) = diff(SP1.values{:}(:,i_dir))'./diff(t(1:end-1));
                    end
                    SP3_temp(end+1,:) = SP3_temp(end,:);
                    SP3 = SampledProcess('values',SP3_temp,'labels',{'CP-AP-Speed','CP-ML-Speed'},'Fs',SP1.Fs);
                    
                    % on identifie la fin de S1 : en ML et en AP (on choisira a posteriori ce qu'il faut garder)
                    switch strcmp(ResAPA.Trial(i_trial).Cote,'Right') % si on a un 1er pied gauche, on fait *-1 pour les valeurs en ML pour pouvoir effectuer le même traitement ensuite
                        case 1
                            coeff = 1;
                        case 0
                            coeff = -1;
                    end
                    
                    % on prend juste la fenêtre des APA : entre T0 et FO1 (EventsTime(2) et EventsTime(4))
                    win = [TrialParams.Trial(i_trial).EventsTime(2) TrialParams.Trial(i_trial).EventsTime(4)];
                    SP1.window = win; SP3.window = win;
                    
                    % Fin de S1 : point le plus lateral
                    [a1,b1] = max(coeff*(SP1.values{:}(:,2)));
                    
                    % on cherche l'instant où on passe par 0
                    psg0 = min(find(SP1.values{:}(b1:end,2) < 0)) + b1;
                    
                    % on calcule la fin de S1 : point le plus postérieur (avant le passage par 0 en ML du CoP)
                    [a2,b2] = min(SP1.values{:}(1:psg0,1));
                    
                    SP1.reset;
                    
                    % on crée les events correspondants à S1
                    e(8) = metadata.event.Stimulus('tStart',win(1)+b1/SP1.Fs,'tEnd',win(1)+b1/SP1.Fs,'name','S1-ML');
                    e(9) = metadata.event.Stimulus('tStart',win(1)+b2/SP1.Fs,'tEnd',win(1)+b2/SP1.Fs,'name','S1-AP');
                    
                    % on récupère les events
                    for i_ev = 1:7
                        eval([all_labels_string{i_ev} ' = metadata.Label(''name'',''' all_labels_string{i_ev} ''');']);  % TR
                        e(i_ev) = metadata.event.Stimulus('tStart',TrialParams.Trial(i_trial).EventsTime(i_ev),'tEnd',TrialParams.Trial(i_trial).EventsTime(i_ev),'name',all_labels_string{i_ev});
                    end
                    EV = EventProcess('events',e,'tStart',0);
                    
                    m = metadata.trial.Gait;
                    m.patient = curr_patient;
                    m.session = curr_stim;
                    m.speedcondition = curr_speed;
                    m.medcondition = curr_med;
                    disp(i_trial);
                    m = ResAPA_to_metadataGait(m,ResAPA.Trial(i_trial),SP1,SP3,EV);
                    Seg(i_trial) = Segment('process',{SP1,SP2,SP3,EV},'labels',{'CP_Pos','CG_Speed','CP_Speed','tMarkers'});
                    Seg(i_trial).info('trial') = m;
                    clear SP EV m;
                end
                cd(['D:\01_GBMOV\02_MAT\STIM1et2Juin2016\Segments\']);
                eval(['save ' rawfile_to_load(1:end-1) ' Seg;'])
                disp ([rawfile_to_load(1:end-1) ' saved']);
                clear Seg;
            end
        end
    end
end

%%
All_sujets = {'ABBGI01' 'ALLGE21' 'BAUMA18' 'CALVI17' 'CLANI11' 'CORDA09' 'DESMA26'...
    'HUMCL08' 'LECCL16' 'MARDI12' 'MERPH19' 'RAYTH22' ...
    'REBSY04' 'RECGE02'  'ROUDO14'  'SALJE29' 'SOUJO07' 'VANPA23'};

%'ROYES03'

All_speeds = {'S','R'};

All_stims = {'M3STIM1','M3STIM2'};

label_event = 'TO'; % pour TO ou FO1

TAB = table;
i_tab = 1;

for i_patient = 1:numel(All_sujets)
    ref_patient = All_sujets{i_patient};
    for i_stim = 1:2
        cond_stim = All_stims{i_stim};
        for i_speed = 1:2
            cond_vt = All_speeds{i_speed};
            cd('D:\01_GBMOV\02_MAT\STIM1et2Juin2016\Segments');
            rawfile_to_load = ['GBMOV_' cond_stim '_' ref_patient '_OFF_' cond_vt];
            load(rawfile_to_load);
            for i_trial = 1:numel(Seg)
                all_fields = fields(Seg(i_trial).info('trial'));
                % on supprime les fields sans intérêt
                all_fields(strcmp(all_fields,'medcondition')) = [];
                all_fields(strcmp(all_fields,'freezing')) = [];
                all_fields(strcmp(all_fields,'maxEMG')) = [];
                all_fields(strcmp(all_fields,'version')) = [];
                all_fields(strcmp(all_fields,'experiment')) = [];
                all_fields(strcmp(all_fields,'protocol')) = [];
                all_fields(strcmp(all_fields,'type')) = [];
                all_fields(strcmp(all_fields,'dateFormat')) = [];
                
                for i_field = 1:numel(all_fields)
                    %          Seg(i_trial).info('trial')
                    switch strcmp(all_fields(i_field),'startingfoot')
                        case 1
                            TAB(i_tab,6) = {Seg(i_trial).info('trial').startingfoot(1)};
                        case 0
                            eval(['TAB(' num2str(i_tab) ',' num2str(i_field) ') = {Seg(' num2str(i_trial) ').info(''trial'').' all_fields{i_field} '};']);
                    end
                end
                i_tab = i_tab+1;
            end
            clear Seg;
            disp([rawfile_to_load ' done']);
        end
    end
end

TAB.Properties.VariableNames = all_fields;
% TAB_ROY = TAB;

cd('D:\01_GBMOV\02_MAT\STIM1et2Juin2016');
save TAB_ROY TAB_ROY;


%% on exporte la table vers un csv pour ouverture dans R
cd('D:\01_GBMOV\02_MAT\STIM1et2Juin2016');
load('TAB.mat'); load('TAB_ROY.mat');
TAB_ROY.trial(:,1:30) = [TAB_ROY.trial(:,1:22),repmat('OFF_',size(TAB_ROY,1),1),TAB_ROY.trial(:,23:26)];
DS_temp = table2dataset(TAB); DS_temp(:,[7:33]) = [];
DS_ROY = table2dataset(TAB_ROY); DS_ROY(:,[7:33]) = [];

DS = [DS_temp;DS_ROY];

cd('D:\01_GBMOV\02_MAT\STIM1et2Juin2016');
export(DS,'file','GBMOV_STIM12_S123.csv');