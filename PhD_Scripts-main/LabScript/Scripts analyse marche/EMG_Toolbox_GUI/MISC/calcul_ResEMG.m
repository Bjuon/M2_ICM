clear;clc;

%% mise en forme des données

path = uigetdir();
cd(path)
A = dir('*_EMG.mat');

liste_fich = {A(:).name};

ind_fich = matchcells2(liste_fich,{'EMG'});

cpt_fich = 0;
cpt_total = 0;
for i_fich = 1 : length(ind_fich)
    clear ResEMG EMG APA TrialParams Sujet list_acq_EMG list_acq_APA list_acq_TrialParams
    disp(A(ind_fich(i_fich)).name)
    myFileEMG = A(ind_fich(i_fich)).name;
    myFileAPA = strrep(A(ind_fich(i_fich)).name,'EMG','APA');
    myFileTrialParams = strrep(A(ind_fich(i_fich)).name,'EMG','TrialParams');
    if exist(upper(fullfile(path,myFileAPA)),'file') && exist(upper(fullfile(path,myFileTrialParams)),'file')
        load(fullfile(path,myFileEMG))
        load(fullfile(path,myFileAPA));
        load(fullfile(path,myFileTrialParams));
        eval(['APA = ' myFileAPA(1:end-4) ';'])
        eval(['clear ' myFileAPA(1:end-4) ';'])
        eval(['EMG = ' myFileEMG(1:end-4) ';'])
        eval(['clear ' myFileEMG(1:end-4) ';'])
        eval(['TrialParams = ' myFileTrialParams(1:end-4) ';'])
        eval(['clear ' myFileTrialParams(1:end-4) ';'])
        
        ResEMG.Infos = APA.Infos;
        ResEMG.Infos.FileName = upper(ResEMG.Infos.FileName);
        
        list_acq_EMG = arrayfun(@(i) upper(EMG.Trial(i).RAW.TrialName),1:length(EMG.Trial),'uni',0);
        champs = fieldnames(APA.Trial(1));
        ind = find(arrayfun(@(i) isa(APA.Trial(1).(champs{i}),'Signal'),1:length(champs)),1);
        list_acq_APA = arrayfun(@(i) upper(APA.Trial(i).(champs{ind}).TrialName),1:length(APA.Trial),'uni',0);
        list_acq_TrialParams = arrayfun(@(i) upper(TrialParams.Trial(i).TrialName),1:length(TrialParams.Trial),'uni',0);
        list_EMG = EMG.Trial(1).RAW.Tag;
        
        ind_txt = find(myFileEMG=='_');
        session = myFileEMG(ind_txt(1)+1:ind_txt(2)-1);
        tag_sujet = myFileEMG(ind_txt(2)+1:ind_txt(3)-1);
        tag_traitement = myFileEMG(ind_txt(3)+1:ind_txt(4)-1);
        tag_vitesse = myFileEMG(ind_txt(4)+1:ind_txt(5)-1);
        cpt_fich = cpt_fich + 1;
        cpt_acq = 0;
        cpt_rem = 0;
        for j_acq = 1 : length(list_acq_EMG)
            
            clear FechAPA FechEMG ind_acq_APA ind_intersect tag_acq events cycle x x1
            
            ind_acq_APA = matchcells(list_acq_APA,list_acq_EMG(j_acq),'exact');
            ind_acq_TrialParams = matchcells(list_acq_TrialParams,list_acq_EMG(j_acq),'exact');
            
            if ~isempty(ind_acq_APA)
                numTrial = list_acq_EMG{j_acq}(end-1:end);

                if isfield(TrialParams.Trial(ind_acq_TrialParams),'StartingFoot')
                    Cote = TrialParams.Trial(ind_acq_TrialParams).StartingFoot;
                else
                    Cote = '';
                end
                events = TrialParams.Trial(ind_acq_TrialParams).EventsTime;
                FechAPA = APA.Trial(ind_acq_APA).CP_Position.Fech;
                FechEMG = EMG.Trial(j_acq).RAW.Fech;
                cycle1 = round(events(2)*FechEMG) : round(events(7)*FechEMG); % T0 - FC2 : cycle "complet"
                cycle2 = round(events(2)*FechEMG) : round(events(4)*FechEMG); % T0 - TO : APA
                cycle3 = round(events(4)*FechEMG) : round(events(7)*FechEMG); % TO - FC2 : EXE
                
                if all(~isnan(events(2:7))) && ~isempty(Cote)
                    cpt_total = cpt_total + 1;
                    tag(cpt_total,1:7) = [myFileEMG,list_acq_EMG(j_acq), tag_sujet, {session},  tag_traitement, tag_vitesse,{numTrial}];
                    
                    coact(cpt_total,1:2) = NaN;
                    cocon(cpt_total,1:2) = NaN;
                    activite_APA(cpt_total,1:4) = NaN;
                    activite_INI(cpt_total,1:4) = NaN;
                    Act_anormale(cpt_total,1:4) = NaN;
                    
                    evnts(cpt_total,:) = events(2:7);
                    
                    
                    clear Vcoact x1 x2
                    tag_RTA = matchcells(EMG.Trial(j_acq).Activite.Tag,{'RTA'},'exact');
                    tag_LTA = matchcells(EMG.Trial(j_acq).Activite.Tag,{'LTA'},'exact');
                    tag_RSOL = matchcells(EMG.Trial(j_acq).Activite.Tag,{'RSOL'},'exact');
                    tag_LSOL = matchcells(EMG.Trial(j_acq).Activite.Tag,{'LSOL'},'exact');
                    
                    % coactivation
                    Vcoact = EMG.Trial(j_acq).Activite.Data(tag_RTA,cycle2) + EMG.Trial(j_acq).Activite.Data(tag_RSOL,cycle2);
                    Vcoact(Vcoact~=2)=NaN;
                    coact(cpt_total,1) = sum(~isnan(Vcoact))/length(cycle1) * 100;
                    
                    Vcoact = EMG.Trial(j_acq).Activite.Data(tag_LTA,cycle2) + EMG.Trial(j_acq).Activite.Data(tag_LSOL,cycle2);
                    Vcoact(Vcoact~=2)=NaN;
                    coact(cpt_total,2) = sum(~isnan(Vcoact))/length(cycle1) * 100;
                    
                    Vcoact = EMG.Trial(j_acq).Activite.Data(tag_RTA,cycle3) + EMG.Trial(j_acq).Activite.Data(tag_RSOL,cycle3);
                    Vcoact(Vcoact~=2)=NaN;
                    coact(cpt_total,3) = sum(~isnan(Vcoact))/length(cycle1) * 100;
                    
                    Vcoact = EMG.Trial(j_acq).Activite.Data(tag_LTA,cycle3) + EMG.Trial(j_acq).Activite.Data(tag_LSOL,cycle3);
                    Vcoact(Vcoact~=2)=NaN;
                    coact(cpt_total,4) = sum(~isnan(Vcoact))/length(cycle1) * 100;
                    
                    % cocontraction selon Hallal et al 2013
                    Vcoact = EMG.Trial(j_acq).Activite.Data(tag_RTA,cycle2) + EMG.Trial(j_acq).Activite.Data(tag_RSOL,cycle2);
                    Vcoact(Vcoact~=2)=NaN;
                    x1 = Signal(EMG.Trial(j_acq).RAW.Data(tag_RTA,:),FechEMG);
                    x1 = x1.MeanRemoval;
                    x1 = x1.BandPassFilter(20,400,4);
                    x1 = Signal(abs(x1.Data),x1.Fech);
                    x1 = x1.LowPassFilter(10,4);
                    x1.Data = x1.Data/mean(x1.Data(round(evnts(cpt_total,1)*x1.Fech):round(evnts(cpt_total,6)*x1.Fech)));
                    x2 = Signal(EMG.Trial(j_acq).RAW.Data(tag_RSOL,:),FechEMG);
                    x2 = x2.MeanRemoval;
                    x2 = x2.BandPassFilter(20,400,4);
                    x2 = Signal(abs(x2.Data),x2.Fech);
                    x2 = x2.LowPassFilter(10,4);
                    x2.Data = x2.Data/mean(x2.Data(round(evnts(cpt_total,1)*x2.Fech):round(evnts(cpt_total,6)*x2.Fech)));
                    cocon(cpt_total,1) = 200 * (trapz(x1.Data(~isnan(Vcoact))) + trapz(x2.Data(~isnan(Vcoact))))/ (trapz(x1.Data) + trapz(x2.Data));
                    
                    Vcoact = EMG.Trial(j_acq).Activite.Data(tag_LTA,cycle2) + EMG.Trial(j_acq).Activite.Data(tag_LSOL,cycle2);
                    Vcoact(Vcoact~=2)=NaN;
                    x1 = Signal(EMG.Trial(j_acq).RAW.Data(tag_LTA,:),FechEMG);
                    x1 = x1.MeanRemoval;
                    x1 = x1.BandPassFilter(20,400,4);
                    x1 = Signal(abs(x1.Data),x1.Fech);
                    x1 = x1.LowPassFilter(10,4);
                    x1.Data = x1.Data/mean(x1.Data(round(evnts(cpt_total,1)*x1.Fech):round(evnts(cpt_total,6)*x1.Fech)));
                    x2 = Signal(EMG.Trial(j_acq).RAW.Data(tag_LSOL,:),FechEMG);
                    x2 = x2.MeanRemoval;
                    x2 = x2.BandPassFilter(20,400,4);
                    x2 = Signal(abs(x2.Data),x2.Fech);
                    x2 = x2.LowPassFilter(10,4);
                    x2.Data = x2.Data/mean(x2.Data(round(evnts(cpt_total,1)*x2.Fech):round(evnts(cpt_total,2)*x2.Fech)));
                    cocon(cpt_total,2) = 200 * (trapz(x1.Data(~isnan(Vcoact))) + trapz(x2.Data(~isnan(Vcoact))))/ (trapz(x1.Data) + trapz(x2.Data));
                    
                    Vcoact = EMG.Trial(j_acq).Activite.Data(tag_RTA,cycle3) + EMG.Trial(j_acq).Activite.Data(tag_RSOL,cycle3);
                    Vcoact(Vcoact~=2)=NaN;
                    x1 = Signal(EMG.Trial(j_acq).RAW.Data(tag_RTA,:),FechEMG);
                    x1 = x1.MeanRemoval;
                    x1 = x1.BandPassFilter(20,400,4);
                    x1 = Signal(abs(x1.Data),x1.Fech);
                    x1 = x1.LowPassFilter(10,4);
                    x1.Data = x1.Data/mean(x1.Data(round(evnts(cpt_total,1)*x1.Fech):round(evnts(cpt_total,6)*x1.Fech)));
                    x2 = Signal(EMG.Trial(j_acq).RAW.Data(tag_RSOL,:),FechEMG);
                    x2 = x2.MeanRemoval;
                    x2 = x2.BandPassFilter(20,400,4);
                    x2 = Signal(abs(x2.Data),x2.Fech);
                    x2 = x2.LowPassFilter(10,4);
                    x2.Data = x2.Data/mean(x2.Data(round(evnts(cpt_total,1)*x2.Fech):round(evnts(cpt_total,6)*x2.Fech)));
                    cocon(cpt_total,3) = 200 * (trapz(x1.Data(~isnan(Vcoact))) + trapz(x2.Data(~isnan(Vcoact))))/ (trapz(x1.Data) + trapz(x2.Data));
                    
                    Vcoact = EMG.Trial(j_acq).Activite.Data(tag_LTA,cycle3) + EMG.Trial(j_acq).Activite.Data(tag_LSOL,cycle3);
                    Vcoact(Vcoact~=2)=NaN;
                    x1 = Signal(EMG.Trial(j_acq).RAW.Data(tag_LTA,:),FechEMG);
                    x1 = x1.MeanRemoval;
                    x1 = x1.BandPassFilter(20,400,4);
                    x1 = Signal(abs(x1.Data),x1.Fech);
                    x1 = x1.LowPassFilter(10,4);
                    x1.Data = x1.Data/mean(x1.Data(round(evnts(cpt_total,1)*x1.Fech):round(evnts(cpt_total,6)*x1.Fech)));
                    x2 = Signal(EMG.Trial(j_acq).RAW.Data(tag_LSOL,:),FechEMG);
                    x2 = x2.MeanRemoval;
                    x2 = x2.BandPassFilter(20,400,4);
                    x2 = Signal(abs(x2.Data),x2.Fech);
                    x2 = x2.LowPassFilter(10,4);
                    x2.Data = x2.Data/mean(x2.Data(round(evnts(cpt_total,1)*x2.Fech):round(evnts(cpt_total,2)*x2.Fech)));
                    cocon(cpt_total,4) = 200 * (trapz(x1.Data(~isnan(Vcoact))) + trapz(x2.Data(~isnan(Vcoact))))/ (trapz(x1.Data) + trapz(x2.Data));
                    
                    switch lower(Cote)
                        case 'right'
                            ind_list_EMG = [1 2 3 4];
                        case 'left'
                            ind_list_EMG = [3 4 1 2];
                            coact(cpt_total,:) = coact(cpt_total,[3 4 1 2]);
                            cocon(cpt_total,:) = cocon(cpt_total,[3 4 1 2]);
                        otherwise
                            ind_list_EMG = [1 2 3 4];
                    end
                    
                    
                    for k_EMG = 1 : length(list_EMG)
                        clear x x1 aON aOFF
                        
                        x = Signal(EMG.Trial(j_acq).RAW.Data(k_EMG,:),FechEMG);
                        x = x.MeanRemoval;
                        x = x.BandPassFilter(20,400,4);
                        x = Signal(abs(x.Data),x.Fech);
                        x1 = x.LowPassFilter(10,4);
                        x.Data = x.Data/max(x.Data(round(evnts(cpt_total,1)*x1.Fech):round(evnts(cpt_total,6)*x1.Fech)));
                        x1.Data = x1.Data/max(x1.Data(round(evnts(cpt_total,1)*x1.Fech):round(evnts(cpt_total,6)*x1.Fech)));
                        
                        switch upper(list_EMG{k_EMG})
                            case {'TAD','RTA','EMG_1'}
                                k_EMG_modif = 1;
                                
                                switch lower(Cote)
                                    case 'right'
                                        % activation anormale :
                                        aON = trapz(x1.Data(round(evnts(cpt_total,3)*x1.Fech):round(evnts(cpt_total,5)*x1.Fech)));  % HO-FC1
                                        aOFF = trapz(x1.Data(round(evnts(cpt_total,5)*x1.Fech):round(evnts(cpt_total,6)*x1.Fech))); % FC1-FO2 
                                        
                                        % quantité d'activité (rms
                                        % sur des epochs précis
                                        % T0-TO
                                        activite_APA(cpt_total,ind_list_EMG(k_EMG_modif)) = sqrt(trapz(x.Data(round(evnts(cpt_total,1)*x.Fech):round(evnts(cpt_total,3)*x.Fech)).^2)...
                                            /((round(evnts(cpt_total,3)*x.Fech)-round(evnts(cpt_total,1)*x.Fech)+1)/x.Fech));
                                        % TO - FO2
                                        activite_INI(cpt_total,ind_list_EMG(k_EMG_modif)) = sqrt(trapz(x.Data(round(evnts(cpt_total,3)*x.Fech):round(evnts(cpt_total,5)*x.Fech)).^2)...
                                            /((round(evnts(cpt_total,5)*x.Fech)-round(evnts(cpt_total,3)*x.Fech)+1)/x.Fech));
                                        
                                    case 'left'
                                        % activation anormale
                                        aON = trapz(x1.Data(round(evnts(cpt_total,5)*x1.Fech):round(evnts(cpt_total,6)*x1.Fech)));
                                        aOFF = trapz(x1.Data(round(evnts(cpt_total,3)*x1.Fech):round(evnts(cpt_total,5)*x1.Fech)));
                                        
                                        % quantité d'activité (rms
                                        % sur des epochs précis
                                        % T0-TO
                                        activite_APA(cpt_total,ind_list_EMG(k_EMG_modif)) = sqrt(trapz(x.Data(round(evnts(cpt_total,1)*x.Fech):round(evnts(cpt_total,3)*x.Fech)).^2)...
                                            /((round(evnts(cpt_total,3)*x.Fech)-round(evnts(cpt_total,1)*x.Fech)+1)/x.Fech));
                                        % FO2 - FC2
                                        activite_INI(cpt_total,ind_list_EMG(k_EMG_modif)) = sqrt(trapz(x.Data(round(evnts(cpt_total,5)*x.Fech):round(evnts(cpt_total,6)*x.Fech)).^2)...
                                            /((round(evnts(cpt_total,6)*x.Fech)-round(evnts(cpt_total,5)*x.Fech)+1)/x.Fech));
                                    otherwise
                                        aON = NaN;
                                        aOFF = NaN;
                                end
                            case {'SOLD','RSOL','EMG_4'}
                                k_EMG_modif = 2;
                                
                                switch lower(Cote)
                                    case 'right'
                                        % activation anormale
                                        aON = trapz(x1.Data(round(evnts(cpt_total,5)*x1.Fech):round(evnts(cpt_total,6)*x1.Fech)));
                                        aOFF = trapz(x1.Data(round(evnts(cpt_total,3)*x1.Fech):round(evnts(cpt_total,5)*x1.Fech)));
                                        
                                        % quantité d'activité (rms
                                        % sur des epochs précis
                                        % T0-TO
                                        activite_APA(cpt_total,ind_list_EMG(k_EMG_modif)) = sqrt(trapz(x.Data(round(evnts(cpt_total,1)*x.Fech):round(evnts(cpt_total,3)*x.Fech)).^2)...
                                            /((round(evnts(cpt_total,3)*x.Fech)-round(evnts(cpt_total,1)*x.Fech)+1)/x.Fech));
                                        % FO2 - FC2
                                        activite_INI(cpt_total,ind_list_EMG(k_EMG_modif)) = sqrt(trapz(x.Data(round(evnts(cpt_total,5)*x.Fech):round(evnts(cpt_total,6)*x.Fech)).^2)...
                                            /((round(evnts(cpt_total,6)*x.Fech)-round(evnts(cpt_total,5)*x.Fech)+1)/x.Fech));
                                    case 'left'
                                        % activation anormale
                                        aON = trapz(x1.Data(round(evnts(cpt_total,3)*x1.Fech):round(evnts(cpt_total,5)*x1.Fech)));
                                        aOFF = trapz(x1.Data(round(evnts(cpt_total,5)*x1.Fech):round(evnts(cpt_total,6)*x1.Fech)));
                                        
                                        % quantité d'activité (rms
                                        % sur des epochs précis
                                        % T0-TO
                                        activite_APA(cpt_total,ind_list_EMG(k_EMG_modif)) = sqrt(trapz(x.Data(round(evnts(cpt_total,1)*x.Fech):round(evnts(cpt_total,3)*x.Fech)).^2)...
                                            /((round(evnts(cpt_total,3)*x.Fech)-round(evnts(cpt_total,1)*x.Fech)+1)/x.Fech));
                                        % TO - FO2
                                        activite_INI(cpt_total,ind_list_EMG(k_EMG_modif)) = sqrt(trapz(x.Data(round(evnts(cpt_total,3)*x.Fech):round(evnts(cpt_total,5)*x.Fech)).^2)...
                                            /((round(evnts(cpt_total,5)*x.Fech)-round(evnts(cpt_total,3)*x.Fech)+1)/x.Fech));
                                    otherwise
                                        aON = NaN;
                                        aOFF = NaN;
                                end
                            case {'TAG','LTA','EMG_2'}
                                k_EMG_modif = 3;
                                
                                switch lower(Cote)
                                    case 'left'
                                        % activation anormale
                                        aON = trapz(x1.Data(round(evnts(cpt_total,3)*x1.Fech):round(evnts(cpt_total,5)*x1.Fech)));
                                        aOFF = trapz(x1.Data(round(evnts(cpt_total,5)*x1.Fech):round(evnts(cpt_total,6)*x1.Fech)));
                                        
                                        % quantité d'activité (rms
                                        % sur des epochs précis
                                        % T0-TO
                                        activite_APA(cpt_total,ind_list_EMG(k_EMG_modif)) = sqrt(trapz(x.Data(round(evnts(cpt_total,1)*x.Fech):round(evnts(cpt_total,3)*x.Fech)).^2)...
                                            /((round(evnts(cpt_total,3)*x.Fech)-round(evnts(cpt_total,1)*x.Fech)+1)/x.Fech));
                                        % TO - FO2
                                        activite_INI(cpt_total,ind_list_EMG(k_EMG_modif)) = sqrt(trapz(x.Data(round(evnts(cpt_total,3)*x.Fech):round(evnts(cpt_total,5)*x.Fech)).^2)...
                                            /((round(evnts(cpt_total,5)*x.Fech)-round(evnts(cpt_total,3)*x.Fech)+1)/x.Fech));
                                        
                                    case 'right'
                                        % activation anormale
                                        aON = trapz(x1.Data(round(evnts(cpt_total,5)*x1.Fech):round(evnts(cpt_total,6)*x1.Fech)));
                                        aOFF = trapz(x1.Data(round(evnts(cpt_total,3)*x1.Fech):round(evnts(cpt_total,5)*x1.Fech)));
                                        
                                        % quantité d'activité (rms
                                        % sur des epochs précis
                                        % T0-TO
                                        activite_APA(cpt_total,ind_list_EMG(k_EMG_modif)) = sqrt(trapz(x.Data(round(evnts(cpt_total,1)*x.Fech):round(evnts(cpt_total,3)*x.Fech)).^2)...
                                            /((round(evnts(cpt_total,3)*x.Fech)-round(evnts(cpt_total,1)*x.Fech)+1)/x.Fech));
                                        % FO2 - FC2
                                        activite_INI(cpt_total,ind_list_EMG(k_EMG_modif)) = sqrt(trapz(x.Data(round(evnts(cpt_total,5)*x.Fech):round(evnts(cpt_total,6)*x.Fech)).^2)...
                                            /((round(evnts(cpt_total,6)*x.Fech)-round(evnts(cpt_total,5)*x.Fech)+1)/x.Fech));
                                    otherwise
                                        aON = NaN;
                                        aOFF = NaN;
                                end
                            case {'SOLG','LSOL','EMG_3'}
                                k_EMG_modif = 4;
                                
                                switch lower(Cote)
                                    case 'left'
                                        % activation anormale
                                        aON = trapz(x1.Data(round(evnts(cpt_total,5)*x1.Fech):round(evnts(cpt_total,6)*x1.Fech)));
                                        aOFF = trapz(x1.Data(round(evnts(cpt_total,3)*x1.Fech):round(evnts(cpt_total,5)*x1.Fech)));
                                        
                                        % quantité d'activité (rms
                                        % sur des epochs précis
                                        % T0-TO
                                        activite_APA(cpt_total,ind_list_EMG(k_EMG_modif)) = sqrt(trapz(x.Data(round(evnts(cpt_total,1)*x.Fech):round(evnts(cpt_total,3)*x.Fech)).^2)...
                                            /((round(evnts(cpt_total,3)*x.Fech)-round(evnts(cpt_total,1)*x.Fech)+1)/x.Fech));
                                        % FO2 - FC2
                                        activite_INI(cpt_total,ind_list_EMG(k_EMG_modif)) = sqrt(trapz(x.Data(round(evnts(cpt_total,5)*x.Fech):round(evnts(cpt_total,6)*x.Fech)).^2)...
                                            /((round(evnts(cpt_total,6)*x.Fech)-round(evnts(cpt_total,5)*x.Fech)+1)/x.Fech));
                                    case 'right'
                                        % activation anormale
                                        aON = trapz(x1.Data(round(evnts(cpt_total,3)*x1.Fech):round(evnts(cpt_total,5)*x1.Fech)));
                                        aOFF = trapz(x1.Data(round(evnts(cpt_total,5)*x1.Fech):round(evnts(cpt_total,6)*x1.Fech)));
                                        
                                        % quantité d'activité (rms
                                        % sur des epochs précis
                                        % T0-TO
                                        activite_APA(cpt_total,ind_list_EMG(k_EMG_modif)) = sqrt(trapz(x.Data(round(evnts(cpt_total,1)*x.Fech):round(evnts(cpt_total,3)*x.Fech)).^2)...
                                            /((round(evnts(cpt_total,3)*x.Fech)-round(evnts(cpt_total,1)*x.Fech)+1)/x.Fech));
                                        % TO - FO2
                                        activite_INI(cpt_total,ind_list_EMG(k_EMG_modif)) = sqrt(trapz(x.Data(round(evnts(cpt_total,3)*x.Fech):round(evnts(cpt_total,5)*x.Fech)).^2)...
                                            /((round(evnts(cpt_total,5)*x.Fech)-round(evnts(cpt_total,3)*x.Fech)+1)/x.Fech));
                                    otherwise
                                        aON = NaN;
                                        aOFF = NaN;
                                end
                            otherwise
                                break
                        end
                        % activation anormale
                        Act_anormale(cpt_total,ind_list_EMG(k_EMG_modif)) = aOFF/aON * 100;
                        
                        
                    end
                    cpt_acq = cpt_acq +1;
                    ResEMG.Trial(cpt_acq).Act_APA_TA1 = activite_APA(cpt_total,1);
                    ResEMG.Trial(cpt_acq).Act_APA_SOL1 = activite_APA(cpt_total,2);
                    ResEMG.Trial(cpt_acq).Act_APA_TA2 = activite_APA(cpt_total,3);
                    ResEMG.Trial(cpt_acq).Act_APA_SOL2 = activite_APA(cpt_total,4);
                    ResEMG.Trial(cpt_acq).Act_EXE_TA1 = activite_INI(cpt_total,1);
                    ResEMG.Trial(cpt_acq).Act_EXE_SOL1 = activite_INI(cpt_total,2);
                    ResEMG.Trial(cpt_acq).Act_EXE_TA2 = activite_INI(cpt_total,3);
                    ResEMG.Trial(cpt_acq).Act_EXE_SOL2 = activite_INI(cpt_total,4);
                    ResEMG.Trial(cpt_acq).Coact_APA_1 = coact(cpt_total,1);
                    ResEMG.Trial(cpt_acq).Coact_APA_2 = coact(cpt_total,2);
                    ResEMG.Trial(cpt_acq).Coact_EXE_1 = coact(cpt_total,3);
                    ResEMG.Trial(cpt_acq).Coact_EXE_2 = coact(cpt_total,4);
                    ResEMG.Trial(cpt_acq).Cocon_APA_1 = cocon(cpt_total,1);
                    ResEMG.Trial(cpt_acq).Cocon_APA_2 = cocon(cpt_total,2);
                    ResEMG.Trial(cpt_acq).Cocon_EXE_1 = cocon(cpt_total,3);
                    ResEMG.Trial(cpt_acq).Cocon_EXE_2 = cocon(cpt_total,4);
                    ResEMG.Trial(cpt_acq).Act_anorm_TA1 = Act_anormale(cpt_total,1);
                    ResEMG.Trial(cpt_acq).Act_anorm_SOL1 = Act_anormale(cpt_total,2);
                    ResEMG.Trial(cpt_acq).Act_anorm_TA2 = Act_anormale(cpt_total,3);
                    ResEMG.Trial(cpt_acq).Act_anorm_SOL2 = Act_anormale(cpt_total,4);
                    ResEMG.Trial(cpt_acq).TrialName = EMG.Trial(j_acq).RAW.TrialName;
                    ResEMG.Trial(cpt_acq).TrialNum = EMG.Trial(j_acq).RAW.TrialNum;
                    ResEMG.Trial(cpt_acq).Description = '';
                    
                else
                    cpt_rem = cpt_rem + 1;
                    ResEMG.removedTrials(cpt_rem).Act_APA_TA1 = [];
                    ResEMG.removedTrials(cpt_rem).Act_APA_SOL1 = [];
                    ResEMG.removedTrials(cpt_rem).Act_APA_TA2 = [];
                    ResEMG.removedTrials(cpt_rem).Act_APA_SOL2 = [];
                    ResEMG.removedTrials(cpt_rem).Act_EXE_TA1 = [];
                    ResEMG.removedTrials(cpt_rem).Act_EXE_SOL1 = [];
                    ResEMG.removedTrials(cpt_rem).Act_EXE_TA2 = [];
                    ResEMG.removedTrials(cpt_rem).Act_EXE_SOL2 = [];
                    ResEMG.removedTrials(cpt_rem).Coact_APA_1 = [];
                    ResEMG.removedTrials(cpt_rem).Coact_APA_2 = [];
                    ResEMG.removedTrials(cpt_rem).Coact_EXE_1 = [];
                    ResEMG.removedTrials(cpt_rem).Coact_EXE_2 = [];
                    ResEMG.removedTrials(cpt_rem).Cocon_APA_1 = [];
                    ResEMG.removedTrials(cpt_rem).Cocon_APA_2 = [];
                    ResEMG.removedTrials(cpt_rem).Cocon_EXE_1 = [];
                    ResEMG.removedTrials(cpt_rem).Cocon_EXE_2 = [];
                    ResEMG.removedTrials(cpt_rem).Act_anorm_TA1 = [];
                    ResEMG.removedTrials(cpt_rem).Act_anorm_SOL1 = [];
                    ResEMG.removedTrials(cpt_rem).Act_anorm_TA2 = [];
                    ResEMG.removedTrials(cpt_rem).Act_anorm_SOL2 = [];
                    ResEMG.removedTrials(cpt_rem).TrialName = EMG.Trial(j_acq).RAW.TrialName;
                    ResEMG.removedTrials(cpt_rem).TrialNum = EMG.Trial(j_acq).RAW.TrialNum;
                    ResEMG.removedTrials(cpt_rem).Description = '';
                end
            else
                disp(['erreur1 ' list_acq_EMG{j_acq}])
            end
        end
        
        eval([ ResEMG.Infos.FileName '_ResEMG = ResEMG;']);
        nom_fich = fullfile('D:\01_GBMOV\02_MAT',[ ResEMG.Infos.FileName '_ResEMG.mat']);
        eval(['save(''' nom_fich ''','''  ResEMG.Infos.FileName '_ResEMG'');']);
        eval(['clear ''' ResEMG.Infos.FileName '_ResEMG''']);
        clear APA EMG TrialParams
    else
        warning('Pas de fichier APA/ TrialParams');
    end
end






%% mise en forme des données dans Xcel
%
% coact(coact==0) = NaN;
% cocon(cocon==0) = NaN;
% activite_APA(activite_APA==0) = NaN;
% activite_INI(activite_INI==0) = NaN;
% Act_anormale(Act_anormale==0) = NaN;
% %
% clear tab
% tab.tag(1,:) = {'Nom_fichier','Nom_acq','Sujet','Session','Traitement','Vitesse','NumTrial',...
%     'Act. APA TA1','Act. APA SOL1','Act. APA TA2','Act. APA SOL2',...
%     'Act. EXE TA1','Act. EXE SOL1','Act. EXE TA2','Act. EXE SOL2',...
%     'Coact APA 1','Coact APA 2','Coact EXE 1','Coact EXE 2',...
%     'Cocon APA 1','Cocon APA 2','Cocon EXE 1','Cocon EXE 2',...
%     '%Act. anormale TA1','%Act. anormale SOL1','%Act. anormale TA2','%Act. anormale SOL2'};
% tab.tag(2:length(tag)+1,1:7) = tag;
% 
% tab.data = [activite_APA,activite_INI,coact,cocon,Act_anormale];
% 
% cd('D:\01_GBMOV\01_Traitement\04_EMG\Stat');
% xlswrite('GBMOV_Data_EMG.xlsx',tab.tag,1,'A1')
% xlswrite('GBMOV_Data_EMG.xlsx',tab.data,1,'H2')

