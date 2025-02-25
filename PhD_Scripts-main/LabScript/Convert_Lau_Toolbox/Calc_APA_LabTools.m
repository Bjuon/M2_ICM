% Script Calc_APA_LabTools
% Stockage des donn�es d'initiation de la marche pour traitement ult�rieur avec plot_LabTools_General
% Input : N fichiers c3d (pour un patient, une session, une condition de m�dication, une vitesse et/ou condition de marche)
% Output : 1 Segment

% clc

[files, dossier_c3d] = uigetfile('*.c3d; *.xls','Choix du/des fichier(s) c3d','Multiselect','on'); % Ajouter plus tard les autres file types
%%
dossier = dossier_c3d;
b_c = 'PF';

%%Lancement du chargement
wb = waitbar(0);
set(wb,'Name','Please wait... loading data');

%Cas ou selection d'un fichier unique
if iscell(files)
    nb_acq = length(files);
else
    nb_acq =1;
end
% initialisation
try
    myFile = files{1}(1:end-4);
    ind_tag = find(myFile=='_');
    myProt = myFile(1:ind_tag(1) - 1);
    mySession = myFile(ind_tag(1) + 1 : ind_tag(2) - 1);
    mySubject = myFile(ind_tag(2) + 1 : ind_tag(3) - 1);
    myTreat = myFile(ind_tag(3) + 1 : ind_tag(4) - 1);
    if size(ind_tag,2) > 4
        mySpeed = myFile(ind_tag(4) + 1 : ind_tag(5) - 1);
    else
        mySpeed = myFile(ind_tag(4) + 1 : end - 4);
    end
catch
    myProt = 'Protocol';
    mySession = 'Session';
    mySubject = 'Subject';
    myTreat = 'Treatment';
    mySpeed = 'Speed';
end

nom_fich = upper([myProt '_' mySession '_' mySubject '_' myTreat '_' mySpeed]);

% On demande si enrg commence avant trigger ou non
delay = str2num(cell2mat(inputdlg('Quel est le d�lai du trigger (en sec)?','Delay Trigger',1,{'1'})));

cpt = 0;
for i = 1:nb_acq
    
    myTrialName = upper(files{i}(1:end-4));
    myNum = str2double(files{i}(end-5:end-4));
    myFile = files{i};
    waitbar(i/nb_acq,wb,['Lecture fichier:' ,strrep(myFile,'_','-')]);
    try
        %======================================================================
        % initialisation des structures
        %======================================================================
        %Lecture du fichier
        DATA = lire_donnees_c3d_all(fullfile(dossier,myFile));
        h = btkReadAcquisition(fullfile(dossier,myFile));
        Freq_ana = btkGetAnalogFrequency(h); %% Modif' v6, on conserve les donn�es PF � la fr�quence de base pour export .lena
        Freq_kin = btkGetPointFrequency(h); % on r�cup�re la fq d'acquisition des cam�ras
        t_all = (0:btkGetAnalogFrameNumber(h)-1)*1/Freq_ana;
        Fin = round(find(DATA.actmec(:,9)<70,1,'first'));  %%%% Choix ou on coupe l'acquisition!!! (defaut = PF)
        if isempty(Fin) || strcmp(b_c,'Oui')
            Fin = length(t_all);
        end
        
        %======================================================================
        % Extraction des efforts sur la PF
        if Fin<10 %% On a des 0 sur les donn�es PF en d�but d'acquisitions
            Fin = length(t_all);
        end
        
        % traitement des efforts au sol
        [forceplates, ~] = btkGetForcePlatforms(h) ;
        av = btkGetAnalogs(h);
        channels=fieldnames(forceplates(1).channels);
        analog_RPLATEFORME=nan(size(av.(channels{1}),1),length(channels));
        for kk=1:length(channels)
            analog_RPLATEFORME(:,kk) = av.(channels{kk});
        end;
        RES=Analog_2_forces_plates(analog_RPLATEFORME,forceplates(1).corners',forceplates(1).origin');
        RES=double(RES);
        
        clear Data
        Data = RES(1:Fin,7:12)'; % Donn�es analog_SURFACE
        
        GroundWrench = Data;
        
        % traitement de la position du CP
        t = t_all(1:Fin);
        CP = RES(1:Fin,1:3);
        CP_filt = NaN*ones(size(CP));
        l = ~isnan(CP(:,1));
        CP_pre = CP(l,:);
        %Filtrage des donn�es PF: filtre � r�ponse impulsionnel finie d'ordre 50 et de fr�quence de coupure 45Hz
        CP_post = filtrage(CP_pre,'fir',50,35,Freq_ana); %%%% 35 si jumper ampli 1000
        try
            CP_filt(l,:) = CP_post;
            % On compl�te le vecteur CP par la derni�re valeur lue sur la PF
            CP0 = CP_post(end,:);
            dim_buff = Fin-sum(l);
            CP_filt(~l,:) = repmat(CP0,dim_buff,1); 
        catch empty_CP
            warning(empty_CP.identifier,empty_CP.message)
            CP_filt = CP;
        end
        
        clear Data
        Data = CP_filt(:,[2 1])';
        % stockage de la position du CP en Segment
        sCP = SampledProcess(Data([2 1],:)','labels',{'CP-MedioLat','CP-AntPost'},'Fs',Freq_ana);
        
        %======================================================================
        % Extraction des marqueurs temporels d'inititation du pas
        % Extraction du temps de l'instruction (� partir du FSW) pour le calcul du temps de r�action
        
        Trial_TrialParams.EventsTime = NaN(1,7);
        Trial_TrialParams.EventsNames = {'TR','T0','HO','FO1','FC1','FO2','FC2'};
        Trial_TrialParams.TrialName = myTrialName;
        Trial_TrialParams.TrialNum = myNum;
        Trial_TrialParams.Description = '';
        
        if isfield(DATA,'ANLG')
            signal = btkGetAnalog(h,'GO');
            if any(isnan(signal))
                signal = btkGetAnalog(h,'FSW'); %% Le trigger est sur un canal nomm� 'FSW'
            end
            
            if ~any(isnan(signal))
                signal = signal - nanmean(signal);
                try
                    TR_ind = find(signal>0.2,1,'first');
                    Trial_TrialParams.EventsTime(1) = TR_ind/DATA.ANLG.Fech;
                catch GO_start
                    warning(GO_start.identifier,GO_start.message)
                    Trial_TrialParams.EventsTime(1) = t(1);
                end
            else
                disp('Pas de go sonore!');
                Trial_TrialParams.EventsTime(1) = t(1);
            end
        elseif delay >0
            Trial_TrialParams.EventsTime(1) = delay;
        else
            disp('Pas de go sonore!');
            Trial_TrialParams.EventsTime(1) = t(1);
        end
        
        try
            % extraction des evts du pas not�s sur Nexus (VICON)
            ev = btkGetEvents(h);
            evts = sort(struct2array(btkGetEvents(h)));
            Trial_TrialParams.EventsTime(2:7) = evts(1:6);
            
        catch ERR % D�tection automatique
            warning(ERR.identifier,ERR.message)
            disp(['Pas d''�v�nements du pas ' myFile]);
            disp('...D�tection automatique des �v�nements');
            evts = calcul_APA_all(CP_filt,t);
            Trial_TrialParams.EventsTime(2:7) = [evts(1)+Trial_TrialParams.EventsTime(1), evts(2)-0.03, evts(2:5)]; % 1er evt biom�canique
            disp('...Termin�!');
        end
        
        
        %======================================================================
        % Calcul des vitesses du CG
        waitbar(i/length(files),wb,['Calculs pr�liminaires vitesses et APA, marche' num2str(i) '/' num2str(nb_acq)]);
        
        V_CG = [];
        Fres = GroundWrench(1:3,:)';
        
        % Extraction du poids
        P = mean(Fres(20:Freq_ana/2,:),1); % on prend la moyenne de la composante Z sur la 1�re demi-seconde de l'acquisition
        if ~exist('Fin','var')
            Fin = round(find(Fres(:,3)<10,1,'first')); % Derni�re frame sur la PF
            if isempty(Fin)
                Fin = length(Fres);
            end
        end
        
        gravite = 9.80928; % observatoire gravim�trique de strasbourg
        M = P/gravite;
        Acc = (Fres-repmat(P,length(Fres),1))./repmat(M,length(Fres),1); % Acc�leration = GRF/m
        
        %Pr�conditionnement du vecteur r�action sur la bonne dur�e (pour l'int�gration)
        Fin_pf = find(Fres(:,3)<15,1,'first');
        if  isempty(Fin_pf)
            Fin_pf = length(Fres);
        end
        Fres = (Fres - repmat(P,length(Fres),1))./(P(3)/gravite); % Vecteur (GRF - P) � integr�
        
        % Int�gration
        t_PF=(0:Fin-1).*1/Freq_ana; % on ajoute la variable temporelle
        V_new=zeros(length(t_PF),3);
        for ii=1:3
            y=Fres(:,ii);
            try % via la toolbox 'Curve Fitting'
                y_t = csaps(t_PF,y);  % on cr�� une spline
                intgrf = fnint(y_t); % on int�gre
                V_new(:,ii)= fnval(intgrf,t_PF);
            catch ERR % sinon par int�gration num�rique par la m�thode des trap�zes
                disp(ERR)
                V_new(:,ii) = cumtrapz(t_PF,y); %Int�gration grossi�re par la m�thode des trap�zes
            end
        end
        
        % Pour la visu, on remplace toutes les valeurs suivant la PF par la derni�re valeure
        V0 = V_new(Fin_pf,:);
        dim_end = length(V_new)-Fin_pf;
        V_new(Fin_pf+1:end,:) = repmat(V0,dim_end,1);
        
        % stockage
        clear Data
        Data = V_new(:,[2 1 3])';
        sCGSpeed = SampledProcess(Data','labels',{'CGSpeedAntPost','CGSpeedMedioLat','CGSpeedVert'},'Fs',Freq_ana); %% A voir pour mettre en segment d�s le code pr�c�dent
        
        % on ajoute les donn�es de trajectoires des marqueurs talons (si donn�es cin�m dispos)
        try
            cellfind = @(string)(@(cell_contents)(strcmp(string,cell_contents)));
            indx = 1:length(DATA.noms);
            Fin_cin = floor(Fin/(Freq_ana/Freq_kin)); % pour savoir o� on coupe les donn�es cin�matiques
            % R_HEE
            idx_RHEE = indx(cellfun(cellfind('RHEE'),DATA.noms));
            DataRight = DATA.coord(1:Fin_cin,(idx_RHEE-1)*3+1:idx_RHEE*3)';
            % L_HEE
            idx_LHEE = indx(cellfun(cellfind('LHEE'),DATA.noms));
            DataLeft = DATA.coord(1:Fin_cin,(idx_LHEE-1)*3+1:idx_LHEE*3)';
            
            sHeels = SampledProcess([DataRight(3,:)',DataLeft(3,:)'],'labels',{'Z-LHeel','Z-RHeel'},'Fs',Freq_kin); %% A voir pour mettre en segment d�s le code pr�c�dent
        catch
            sHeels = SampledProcess([nan(round(sCGSpeed.dim{:}(1)./(Freq_ana/Freq_kin)),1),nan(round(sCGSpeed.dim{:}(1)./(Freq_ana/Freq_kin)),1)],'labels',{'No-marker','No-marker'},'Fs',Freq_kin); 
        end
        
        % si on a un NaN dans les events, on prend l'event pr�c�dent auquel
        % on ajoute 0.1 sec (pour avoir fen�tre temporelle de 0.1 sec entre 2 events)
        while nnz(isnan(Trial_TrialParams.EventsTime)) > 0
        ev_curr = min(find(isnan(Trial_TrialParams.EventsTime)));
        Trial_TrialParams.EventsTime(ev_curr) = Trial_TrialParams.EventsTime(ev_curr-1) + 0.1;
        end
        
        % on s'assure que l'ordre chronologique des events est OK (peut poser probl�me pour les essais NoGo)
        Trial_TrialParams.EventsTime(2:7) = sort(abs(Trial_TrialParams.EventsTime(2:7)));

        GO_lbl = metadata.Label('name','GO','color',[0 0 0]);
        T0_lbl = metadata.Label('name','T0','color',[1 0 0]);
        HO_lbl = metadata.Label('name','HO','color',[0 0 0]);
        FO1_lbl = metadata.Label('name','FO1','color',[0 0 1]);
        FC1_lbl = metadata.Label('name','FC1','color',[1 0 0]);
        FO2_lbl = metadata.Label('name','FO2','color',[0 1 0]);
        FC2_lbl = metadata.Label('name','FC2','color',[0 1 1]);
        
        e(1) = metadata.event.Response('tStart',Trial_TrialParams.EventsTime(1),'tEnd',Trial_TrialParams.EventsTime(1),'name',GO_lbl);
        e(2) = metadata.event.Response('tStart',Trial_TrialParams.EventsTime(2),'tEnd',Trial_TrialParams.EventsTime(2),'name',T0_lbl);
        e(3) = metadata.event.Response('tStart',Trial_TrialParams.EventsTime(3),'tEnd',Trial_TrialParams.EventsTime(3),'name',HO_lbl);
        e(4) = metadata.event.Response('tStart',Trial_TrialParams.EventsTime(4),'tEnd',Trial_TrialParams.EventsTime(4),'name',FO1_lbl);
        e(5) = metadata.event.Response('tStart',Trial_TrialParams.EventsTime(5),'tEnd',Trial_TrialParams.EventsTime(5),'name',FC1_lbl);
        e(6) = metadata.event.Response('tStart',Trial_TrialParams.EventsTime(6),'tEnd',Trial_TrialParams.EventsTime(6),'name',FO2_lbl);
        e(7) = metadata.event.Response('tStart',Trial_TrialParams.EventsTime(7),'tEnd',Trial_TrialParams.EventsTime(7),'name',FC2_lbl);
        
        events = EventProcess('events',e,'tStart',0,'tEnd',sCP.tEnd);
        
        currSeg = Segment('process',{sCP,sCGSpeed,sHeels,events},'labels',{'sCP','sCGSpeed','sHeels','events'});
        
        Seg(i) = calculs_parametres_initiationPas_v5_LabTools(currSeg,myFile);
        
    catch Err_load
        warning(Err_load.identifier,Err_load.message)
        disp(['Erreur de chargement pour ' myFile])
    end
    
end
close(wb);

%% pour exporter et enregistrer les donn�es
file_export = [Seg(1).info('trial').patient '_' Seg(1).info('trial').session '_' Seg(1).info('trial').medcondition '_' Seg(1).info('trial').speedcondition '_Seg'];
[FileName,PathName] = uiputfile('*.mat','S�lectionner le dossier de destination du Segment � enregistrer',file_export);
save([PathName FileName],'Seg');
disp([char(FileName) ' saved to ' char(PathName)]);
