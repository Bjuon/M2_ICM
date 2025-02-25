% clear
clear; close all; clc;

%set protocol
protocol = 'GOGAIT';

% set sessions
session = {'T1'};%,'POSTOP'};%,'STIM'};

% set tasks
task = {'C', 'I'};

% intiate output matrix
Res = [];

%for each sessions
for s = 1:length(session)
    
    % % Condition
if strcmp(session{s},'PREOP') | strcmp(session{s},'M7') | strcmp(session{s},'POSTOP') 
    cond = {'OFF','ON'};
elseif strcmp(session{s},'M6') 
    cond = {'C1','C2','C3','C4','C5','C6'};
end

    cd(['\\C:\Users\edward.soundaravelou\Desktop\Traitement_Gogait']);
%     cd(['C:\Users\haissam.haidar\Desktop\MAGIC\MAT\' session{s}]);
    
    for ta = 1:length(task)
        
        % find unique conditions
        files = [dir(['*' task{ta} '_*.mat'])];
        for i = 1:size(files,1)
            ind     = strfind(files(i).name, '_');
            cond(i) = {files(i).name(1:ind(end))};
        end
        cond = unique(cond);
        clear files i ind
        
        % for each condition
%         for c=cond %cond_i = 1:length(cond)
        for cond_i = 1:length(cond)
%             c=cond{cond_i}; %
            c=cond(cond_i);
            stringg = char(c);
            ind     = strfind(stringg, '_');
%             patient = stringg(ind(4)+1:ind(5)-1);
%             med = stringg(ind(6)+1:ind(7)-1);
            patient = stringg(ind(2)+1:ind(3)-1);
            med = stringg(ind(3)+1:ind(4)-1);
            clear stringg %ind
            
            % convert
            c = cell2mat(c);
            c_real = c(1:ind(5));
            if strcmp(patient,'DEP') & strcmp(session{s},'M7')
                c_real = 'PARKPITIE_2020_01_16_DEP_';
            elseif strcmp(patient,'FEP') & strcmp(session{s},'M7')
                c_real = 'PARKPITIE_2020_02_20_FEP_';
            end
            
            % load data
            load([c 'ResAPA.mat']);
            load([c 'TrialParams.mat']);
            APA      = eval([c_real 'ResAPA']);
            APAe     = eval([c_real 'TrialParams']);
            
            %initiate indx
            indx=0;
            
            for index = 1:numel(APA.Trial)
                
                ind_APA = [];
                
ind_APA = index;

                if ~isempty(ind_APA);
                    %if move
                    TR=                 APAe.Trial(ind_APA).EventsTime(1);
                    T0=                 APAe.Trial(ind_APA).EventsTime(2);
                    FO1=                APAe.Trial(ind_APA).EventsTime(4);
                    FC1=                APAe.Trial(ind_APA).EventsTime(5);
                    FO2=                APAe.Trial(ind_APA).EventsTime(6);
                    FC2=                APAe.Trial(ind_APA).EventsTime(7);
                    Cote=               APA.Trial(ind_APA).Cote;
                    t_Reaction=         APA.Trial(ind_APA).t_Reaction;
                    t_APA=              APA.Trial(ind_APA).t_APA;
                    APA_antpost=        APA.Trial(ind_APA).APA_antpost(1);
                    APA_lateral=        APA.Trial(ind_APA).APA_lateral(1);
                    StepWidth=          APA.Trial(ind_APA).StepWidth;
                    t_swing1=           APA.Trial(ind_APA).t_swing1;
                    t_DA=               APA.Trial(ind_APA).t_DA;
                    t_swing2=           APA.Trial(ind_APA).t_swing2;
                    t_cycle_marche=     APA.Trial(ind_APA).t_cycle_marche;
                    Longueur_pas=       APA.Trial(ind_APA).Longueur_pas;
                    V_swing1=           APA.Trial(ind_APA).V_swing1;
                    Vy_FO1=             APA.Trial(ind_APA).Vy_FO1(1);
                    t_VyFO1=            APA.Trial(ind_APA).t_VyFO1;
                    Vm=                 APA.Trial(ind_APA).Vm(1);
                    t_Vm=               APA.Trial(ind_APA).t_Vm;
                    VML_absolue=        APA.Trial(ind_APA).VML_absolue;
                    Freq_InitiationPas= APA.Trial(ind_APA).Freq_InitiationPas;
                    Cadence=            APA.Trial(ind_APA).Cadence;
%                     if APA.Trial(ind_APA).VZmin_APA == []
%                     VZmin_APA=          NaN;
%                     else
                    VZmin_APA=          APA.Trial(ind_APA).VZmin_APA(1);
%                     end
%                     if APA.Trial(ind_APA).V1==[]
%                     V1=                 NaN;
%                     else
                    V1=                 APA.Trial(ind_APA).V1(1);
%                     end
%                     if APA.Trial(ind_APA).V2==[]
%                     V2=                 NaN;
%                     else
                    V2=                 APA.Trial(ind_APA).V2(1);
%                     end
                    Diff_V=             APA.Trial(ind_APA).Diff_V;
                    Freinage=           APA.Trial(ind_APA).Freinage;
                    t_chute=            APA.Trial(ind_APA).t_chute;
                    t_freinage=         APA.Trial(ind_APA).t_freinage;
                    t_V1=               APA.Trial(ind_APA).t_V1;
                    t_V2=               APA.Trial(ind_APA).t_V2;
                    TrialName=          APA.Trial(ind_APA).TrialName;
                    TrialNum=           APA.Trial(ind_APA).TrialNum;
                    
                    clear ind_APA
                    
                    
                    e  = {TrialName, TrialNum, patient, med, task{ta},session{s}...
                        Cote,TR,T0,FO1,FC1,FO2,FC2,...
                        t_Reaction,t_APA,APA_antpost,APA_lateral,...
                        StepWidth,t_swing1,t_DA,t_swing2,...
                        t_cycle_marche,Longueur_pas,V_swing1,Vy_FO1,...
                        t_VyFO1,Vm,t_Vm,VML_absolue,Freq_InitiationPas,...
                        Cadence,VZmin_APA,V1,V2,Diff_V,Freinage,...
                        t_chute,t_freinage,t_V1,t_V2};
                    
                    clear TrialName TrialNum ...
                        Cote TR T0 FO1 FC1 FO2 FC2 t_Reaction ...
                        t_APA APA_antpost APA_lateral StepWidth t_swing1 t_DA ...
                        t_swing2 t_cycle_marche Longueur_pas V_swing1 Vy_FO1 ...
                        t_VyFO1 Vm t_Vm VML_absolue Freq_InitiationPas ...
                        Cadence VZmin_APA V1 V2 Diff_V Freinage ...
                        t_chute t_freinage t_V1 t_V2 rsltEMG
                    
                    Res = [Res;e];
                    clear e
                end
            end
            clear index indx
            
        end
        clear med cond
        
    end
    clear ta
    
end
clear s session task medcondition

headers = {'TrialName','TrialNum','Subject','Condition','GoNogo','Session',...
    'Cote','TR','T0','FO1','FC1','FO2','FC2',...
    't_Reaction','t_APA','APA_antpost','APA_lateral',...
    'StepWidth','t_swing1','t_DA','t_swing2',...
    't_cycle_marche','Longueur_pas','V_swing1','Vy_FO1',...
    't_VyFO1','Vm','t_Vm','VML_absolue','Freq_InitiationPas',...
    'Cadence','VZmin_APA','V1','V2','Diff_V','Freinage',...
    't_chute','t_freinage','t_V1','t_V2'};

Results = dataset({Res,headers{:}});
cd(['\\C:\Users\edward.soundaravelou\Desktop\Traitement_Gogait']);
% cd(['C:\Users\haissam.haidar\Desktop\MAGIC\MAT\']);
export(Results,'File','ResAPA_extension_GOGAITcourt_v2.csv','Delimiter',';');
clear Results Res headers