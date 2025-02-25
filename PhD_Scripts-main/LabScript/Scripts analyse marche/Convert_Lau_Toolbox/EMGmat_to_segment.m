% Créations des segments de données EMG à partir des _EMG.mat et des évènements du pas
% Tracés des figures avec recalage temporel

% Inputs : Fichier *_EMG.mat issu du script Traitement_EMG_v3.m (doit
% contenir un champ .Ev et .Processed)

% Outputs :
%   - Création de segments temporaires à partir des données d'EMG
%   - Graphe des 4 muscles (1 figure par patient) sur une fenêtre temporelle définie (et modifiable)
%       Possibilité de tracer l'enveloppe ou d'utiliser la fonction fill
%       pour jouer sur la transparence et avoir une idée de la variabilité
%       des signaux
%   * Possibilité d'enregistrer les figures, mais lignes en commentaires pour l'instant

% Pour le tracé des figures, on peut paramétrer la fenêtre temporelle
% d'intérêt. Voir lignes 122 (time_bounds)

% NB : Nécessite la LabTools de B. LAU

% Protocoles : PARKGAME et PSPMARCHE (quelques bugs d'affichage figure pour
% PARKGAME) / A modifier
% Auteur : A. Van Hamme
% Creation date : 01/2017
% Modifications : 09/2017

%% Création du segment regroupant toutes les données des patients d'un même protocole
clearvars;

Protocol = 'PSPMARCHE';

switch Protocol
    case 'PARKGAME'
        dir_input = 'D:\11_PARKGAME\DonnesC3DpourEMG\';
        All_subjects = {'RICDI01';'VIOEV02';'MORGE03';'KONCA04';'LECCL05';'LIECH06';'PASEL07';'REBSY08';'CATVE09';'BRUJE10'};
        All_sessions = {'S1','S2','S3','S4'};
        All_speeds = {'S'};
    case 'PSPMARCHE'
        dir_input = 'D:\09_PSPMARCHE\Matlab\MAT\EMG_MAT';
        All_subjects = {'01T01TV01','02T02PT02','03T03TM03','04P01AS04','05P02GF05','06P03MM06','07T04TJ07','08P04DP08','09P05IM09',...
            '10T05BC10','11P06BG11','12P07GH13','13P08TA15','14P09RF16','15P10NL17','16P12CG18','17T06BM19','18P11DA20','19P13BO21',...
            '20T07SM22','21P14LB24','22T08SA25','23T09PL26','24P15LS27','25P16CM28','26P17RA29','27T10BL30','28P18MF31','29T11BM32',...
            '30P19JC33','31T12RC34','32P20RJ35','33P21CJ36','34P22MH38','35P23SP39','36T13SC40','37T14DL43','38P24AM44','39P25SL45',...
            '40T15SC46','41P26MA47','42T16MJ48','43P27HE49','44T17HM50','45P28LB51','46P29DM52','47P30PB53'};
        All_sessions = {'GAIT'};
        All_speeds = {'S','R'};
end

curr_med = 'NA';

all_labels_string = {'T0','HO','FO1','FC1','FO2','FC2'};

for i_subject = 1:numel(All_subjects) % EMG OK pour PSPMARCHE : [11 12 15 19 22 23 27 34 35 36 37 38 39 40 46 47]
    disp(i_subject);
    curr_subject = All_subjects{i_subject};
    
    
switch Protocol
    case  'PARKGAME'
        cd([dir_input curr_subject '\Detect_bursts\']);
    case 'PSPMARCHE'
        cd(dir_input);
end
    
    for i_session = 1:numel(All_sessions)
        curr_session = All_sessions{i_session};
        
        for i_speed = 1:numel(All_speeds)
            curr_speed = All_speeds{i_speed};
            try
                eval(['load(''' Protocol '_' curr_session '_' curr_subject '_' curr_med '_' curr_speed '_EMG.mat'');' ]);
                eval(['curr_EMG = ' Protocol '_' curr_session '_' curr_subject '_' curr_med '_' curr_speed '_EMG;']);
                
                % on calcule le max a priori / pour normaliser par cette valeur les EMG
                M = zeros(4,1);
                for i_trial = 1:numel(curr_EMG.Trial)
                    for i_EMG = 1:4
                        M(i_EMG) = max([curr_EMG.Trial(i_trial).Processed.Data(i_EMG,:) M(i_EMG)]);
                    end
                end
                M(M==0) = NaN;
                
                for i_trial = 1:numel(curr_EMG.Trial)
                    for i_ev = 1:numel(curr_EMG.Trial(i_trial).Ev{2})
                        e(i_ev) = metadata.event.Stimulus('tStart',curr_EMG.Trial(i_trial).Ev{1}(i_ev),'tEnd',curr_EMG.Trial(i_trial).Ev{1}(i_ev),'name',all_labels_string{i_ev});
                    end
                    EV = EventProcess('events',e,'tStart',0);
                    
                    if strcmp([curr_EMG.Trial(i_trial).Processed.Tag{:}],'RTARSOLLTALSOL') == 1
                        switch curr_EMG.Trial(i_trial).Ev{2}{3}
                            case 'L_FO'
                                EMG_order = [4 3 2 1];
                            case 'R_FO'
                                EMG_order = [2 1 4 3];
                        end
                    else
                        error('Tags EMG do not correspond to classical order');
                    end
                    EMG = SampledProcess('values',curr_EMG.Trial(i_trial).Processed.Data(EMG_order,:)'./repmat(M(EMG_order)',numel(curr_EMG.Trial(i_trial).Processed.Data(1,:)),1),'labels',{'SOLSwing','TASwing','SOLStance','TAStance'},'Fs',curr_EMG.Trial(i_trial).Processed.Fech);
                    Sub(i_subject).Session(i_session).Speed(i_speed).Seg(i_trial) = Segment('process',{EMG,EV},'labels',{'EMG','tMarkers'});
                end
            catch
                warning(['file ' Protocol '_' curr_session '_' curr_subject '_' curr_med '_' curr_speed '_EMG.mat not processed'])
            end
        end
    end
end

%% Tracés des figures de visualisation (une par patient et  par vitesse)
% Echelle de 4 couleurs pour EMG
COLOR_4EMG = [27 79 53;... % SOLSwing
    119 172 48;...         % TASwing
    192 0 0;...            % SOLStance
    222 125 0]./255;       % TAStance
Lbls_EMG = {'SOLSwing','TASwing','SOLStance','TAStance'};

% sélection de la fenêtre temporelle d'intérêt / ordre des labels des markers : [T0 HO FO1 FC1 FO2 FC2]
time_bounds = [1 4 3 4]; % 2 1ers : window pour découpe, 3ème pour synchro, 1er et 4ème pour tracé en pointillés
% [1 4 3 4] : APA et EXE, synchro sur FO1
% time_bounds = [3 6 4 5]; %: EXE jusqu'à FC2, synchro sur FC1

for i_subject = 1:2%1:numel(All_subjects) % EMG OK pour PSPMARCHE : [[11 12 15 19 22 23 27 34 35 36 37 38 39 40 46 47]
    for i_session = 1:numel(All_sessions)
        for i_speed = 1:numel(All_speeds)
            curr_speed = All_speeds{i_speed};
            switch Protocol
                case 'PARKGAME'
                    figure(i_subject); 
                    set(gcf,'Position',[-1896 98 1853 1007]), hold on,
                case 'PSPMARCHE'
                    figure('Position',[-1361 99 519 1007]), hold on,
            end
            try
                curr_seg = Sub(i_subject).Session(i_session).Speed(i_speed).Seg;
                
                for i_trial = 1:numel(curr_seg)
                    
                    % on définit la fenêtre temporelle d'intéret
                    win = [curr_seg(i_trial).eventProcess(1).values{:}(time_bounds(1)).tStart curr_seg(i_trial).eventProcess(1).values{:}(time_bounds(2)).tStart];
                    curr_seg(i_trial).processes{1}.window = win;
                    % on synchronise le trial
                    curr_seg(i_trial).processes{1}.sync(curr_seg(i_trial).eventProcess(1).values{:}(time_bounds(3)).tStart);
                    
                    % on définit les vecteurs nécessaires à l'utilisation de la fonction "fill" par la suite
                    wind = curr_seg(i_trial).processes{1}.relWindow;
                    x = [wind(1):1/curr_seg(i_trial).processes{1}.Fs:wind(2) wind(2):-1/curr_seg(i_trial).processes{1}.Fs:wind(1)];
                    Z = zeros(length(x) - curr_seg(i_trial).processes{1}.dim{:}(1),1);
                    
                    % tracer des EMG, avec un niveau de transparence
                    for i_EMG = 1:4
                        subplot(4,1,i_EMG), hold on,
                        
                        y = [curr_seg(i_trial).processes{1}.values{:}(:,i_EMG);Z(end:-1:1)];
                        f = fill(x,y,COLOR_4EMG(i_EMG,:),'edgecolor',COLOR_4EMG(i_EMG,:)); set(f,'faceAlpha',0.1);
                        
                        % tracé "classique" de l'enveloppe uniquement
                        %        plot(curr_seg(i_trial).processes{1}.times{:},curr_seg(i_trial).processes{1}.values{:}(:,i_EMG),'color',COLOR_4EMG(i_EMG,:));
                        
                        title(Lbls_EMG{i_EMG});
                        clear y f;
                        axis([-Inf Inf 0 1]);
                        plot([0 0],[0 1],'k--');
                        % tracés des évènements temporels
                        plot([curr_seg(i_trial).eventProcess(1).values{:}(time_bounds(4)).tStart-curr_seg(i_trial).eventProcess(1).values{:}(time_bounds(3)).tStart...
                            curr_seg(i_trial).eventProcess(1).values{:}(time_bounds(4)).tStart-curr_seg(i_trial).eventProcess(1).values{:}(time_bounds(3)).tStart],[0 1],'color',[0.5 0.5 0.5],'linestyle','--');
                        plot([curr_seg(i_trial).eventProcess(1).values{:}(time_bounds(1)).tStart-curr_seg(i_trial).eventProcess(1).values{:}(time_bounds(3)).tStart...
                            curr_seg(i_trial).eventProcess(1).values{:}(time_bounds(1)).tStart-curr_seg(i_trial).eventProcess(1).values{:}(time_bounds(3)).tStart],[0 1],'color',[0.5 0.5 0.5],'linestyle','--');
                    end
                    
                    clear wind x Z;
                    curr_seg(i_trial).reset;
                    %             pause;
                end
                
                xlabel('Time (s)');
                Period = [str_rep(curr_seg(i_trial).eventProcess(1).values{:}(time_bounds(1)).name) '-' curr_seg(i_trial).eventProcess(1).values{:}(time_bounds(2)).name];
                suptitle(['Sujet ' num2str(i_subject) ' Vt ' curr_speed ' - [' Period '] Sync sur ' str_rep(curr_seg(i_trial).eventProcess(1).values{:}(time_bounds(3)).name) ' infos:' str_rep(curr_seg(i_trial).eventProcess(1).values{:}(time_bounds(1)).name) ' et ' str_rep(curr_seg(i_trial).eventProcess(1).values{:}(time_bounds(4)).name)]);
                clear curr_seg;
            
        % Sauvegarde des figures
        cd('D:\09_PSPMARCHE\Matlab\Figures\EMG');
%         saveas(gcf,[Protocol ' EMG S' num2str(i_subject) ' Vt ' curr_speed ' ' Period],'fig');
%         saveas(gcf,[Protocol ' EMG S' num2str(i_subject) ' Vt ' curr_speed ' A' Period],'png');
%         close;
        catch
                warning(['Sub(' num2str(i_subject) ').Session(' num2str(i_session) ').Speed(' num2str(i_speed) ').Seg not processed']);
            end
        end
    end
end

%%
% Tracés des boxplot des paramètres calculés des différentes sessions, par patient pour comparaison

i_line = 1;
for i_subject = [1 3 5 6 8]
    %     try
    for i_session = 1:4
        
        curr_subject = All_subjects{i_subject};
        curr_session = All_sessions{i_session};
        
        cd([dir_input curr_subject '\Detect_bursts\']);
        eval(['load(''' Protocol '_' curr_session '_' curr_subject '_' curr_med '_' curr_speed '_EMG.mat'');' ]);
        eval(['curr_EMG = ' Protocol '_' curr_session '_' curr_subject '_' curr_med '_' curr_speed '_EMG;']);
        
        all_fields = fields(curr_EMG.Trial(1).ExploitVar2);
        
        for i_trial = 1:numel(curr_EMG.Trial)
            data(i_line,1) = i_subject;
            data(i_line,2) = i_session;
            data(i_line,3) = i_trial;
            data(i_line,4) = curr_EMG.Trial(i_trial).ExploitVar2.SOL1_AF_FC1;
            data(i_line,5) = curr_EMG.Trial(i_trial).ExploitVar2.SOL2_BF_FC1;
            data(i_line,6) = curr_EMG.Trial(i_trial).ExploitVar2.SOL2_AF_FC1;
            data(i_line,7) = curr_EMG.Trial(i_trial).ExploitVar2.SOL2_FC1_RMS;
            data(i_line,8) = curr_EMG.Trial(i_trial).ExploitVar2.TA1_BF_FO1;
            data(i_line,9) = curr_EMG.Trial(i_trial).ExploitVar2.TA2_BF_FO1_start;
            data(i_line,10) = curr_EMG.Trial(i_trial).ExploitVar2.TA2_BF_FO1_stop;
            data(i_line,11) = curr_EMG.Trial(i_trial).ExploitVar2.TA2_BF_FO1_RMS;
            i_line = i_line+1;
        end
    end
    %     i_var = 7;
    % figure,
    % boxplot(data(:,i_var),data(:,2)); title(num2str(i_subject));
    % clear data;
    %     end
end

Lbls = {'Patient','Session','Trial','SOL1_AF_FC1','SOL2_BF_FC1','SOL2_AF_FC1','SOL2_FC1_RMS',...
    'TA1_BF_FO1','TA2_BF_FO1_start','TA2_BF_FO1_stop','TA2_BF_FO1_RMS'};

DS = mat2dataset(data,'VarNames',Lbls); %DS(:,[1 4 5 49 51 52 6:48 50 53]);


%%
cd('D:\11_PARKGAME\EMG Graphes');
export(DS,'file','PARKGAME_EMG_5patients.csv');

% i_var = 7;
% figure,
% boxplot(data(:,i_var),data(:,2)); title(num2str(i_subject));
i_var = 3;
figure,
boxplot(data(:,i_var),data(:,2));