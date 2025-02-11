% create the output to be saved to Res_APA.csv file from a liste of files
% input : list pathes to all ResAPA.mat files to include -> cell(n,1)
% output : strcutures wilth all fileds to save to the csv file


function Results = Extract_APA(fileList)

% intiate output matrix
Res = [];

for f = 1:length(fileList)
    clear APA APAe  
    [~, filename] = fileparts(fileList{f});
    filesplit     = strsplit(filename, '_');
    patient       = filesplit{3};
    med           = filesplit{4};
    task          = filesplit{5};
    session       = filesplit{2};

    APA      = importdata(fileList{f});
    APAe     = importdata([fileList{f}(1:end-10) 'TrialParams.mat']);
    
    %initiate indx
    indx=0;
    
    for index = 1:numel(APA.Trial)
        
        ind_APA = [];
        
        ind_APA = index;
        
        if ~isempty(ind_APA)
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
            
            
%             e  = {TrialName, TrialNum, patient, med, task{ta},session{s}...
            e  = {TrialName, TrialNum, patient, med, task, session...
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

headers = {'TrialName','TrialNum','Subject','Condition','GoNogo','Session',...
    'Cote','TR','T0','FO1','FC1','FO2','FC2',...
    't_Reaction','t_APA','APA_antpost','APA_lateral',...
    'StepWidth','t_swing1','t_DA','t_swing2',...
    't_cycle_marche','Longueur_pas','V_swing1','Vy_FO1',...
    't_VyFO1','Vm','t_Vm','VML_absolue','Freq_InitiationPas',...
    'Cadence','VZmin_APA','V1','V2','Diff_V','Freinage',...
    't_chute','t_freinage','t_V1','t_V2'};

Results = dataset({Res,headers{:}});

