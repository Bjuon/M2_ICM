% Créations des segments de données EMG à partir des _EMG.mat et des évènements du pas
% Tracés des figures avec recalage temporel

% Protocole :Version exemple ici, avec un seul fichier (un patient, une session, plusieurs trials)
% Auteur : A. Van Hamme
% Creation date : 11/01/2017 - modifiée le 31/08/2017 pour l'exemple

clearvars;

all_labels_string = {'T0','HO','FO1','FC1','FO2','FC2'};

i_subject = 1;
i_session = 1;

% chargement du fichier
load('PARKGAME_S1_LIECH06_NA_S_EMG');
curr_EMG =PARKGAME_S1_LIECH06_NA_S_EMG;

% on calcule le max a priori
M = zeros(4,1);
for i_trial = 1:numel(curr_EMG.Trial)
    for i_EMG = 1:4
        M(i_EMG) = max([curr_EMG.Trial(i_trial).Processed.Data(i_EMG,:) M(i_EMG)]);
    end
end
M(M==0) = NaN;


for i_trial = 1:numel(curr_EMG.Trial)
    % on récupère les évènements du pas
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
    % on crée le SampledProcess et le Segment
    EMG = SampledProcess('values',curr_EMG.Trial(i_trial).Processed.Data(EMG_order,:)'./repmat(M(EMG_order)',numel(curr_EMG.Trial(i_trial).Processed.Data(1,:)),1),'labels',{'SOLSwing','TASwing','SOLStance','TAStance'},'Fs',curr_EMG.Trial(i_trial).Processed.Fech);
    Sub(i_subject).Session(i_session).Seg(i_trial) = Segment('process',{EMG,EV},'labels',{'EMG','tMarkers'});
end

%% Pour tracer les figures à partir du Segment Sub

% Tracés des figures (une par patient)

% Echelle de 4 couleurs pour EMG
COLOR_4EMG = [27 79 53;... % SOLSwing
    119 172 48;...         % TASwing
    192 0 0;...            % SOLStance
    222 125 0]./255;       % TAStance
Lbls_EMG = {'SOLSwing','TASwing','SOLStance','TAStance'};

% sélection de la fenêtre temporelle d'intérêt / label des markers : [T0 HO FO1 FC1 FO2 FC2]
time_bounds = [3 6 4 5]; % 2 1ers : window pour découpe, 3ème pour synchro, 1er et 4ème pour tracé en pointillés
% [1 4 3] : APA et EXE, locké sur FO1
% time_bounds = [3 6 4 5]; %: EXE jusqu'à FC2, locké sur FC1

curr_seg = Sub(i_subject).Session(i_session).Seg;

figure('units','normalized','Position',[0.1 0.1 0.4 0.8]), hold on,

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
        f = fill(x,y,COLOR_4EMG(i_EMG,:),'edgecolor',COLOR_4EMG(i_EMG,:)); set(f,'faceAlpha',0.5);
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
end

% création du titre de la figure
Period = [str_rep(curr_seg(i_trial).eventProcess(1).values{:}(time_bounds(1)).name) '-' curr_seg(i_trial).eventProcess(1).values{:}(time_bounds(2)).name];
suptitle(['P ' num2str(i_subject) ' Période [' Period '] Sync sur ' str_rep(curr_seg(i_trial).eventProcess(1).values{:}(time_bounds(3)).name) ' info:' str_rep(curr_seg(i_trial).eventProcess(1).values{:}(time_bounds(4)).name)]);

