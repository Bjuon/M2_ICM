function [NameAndNum] = MatchingTable(OFF_list,ON_list,ClinicalData,contact_to_use, ClinicalFileToUse, U3bilat,StartBeta,EndBeta,PicOrBand,Type_of_Spectrum, Timing_to_Use)
   

    %% Description des colonnes de la table de sortie
    % 1 : Nom du patient
    % 2 : Contact Beta le plus haut à droite
    % 3 : Id du contact Beta le plus haut à droite
    % 4 : Contact Beta le plus haut à gauche
    % 5 : Id du contact Beta le plus haut à gauche
    % 6 : Index du patient dans la liste OFF
    % 7 : Index du patient dans la liste ON
    % 8 : UPDRS OFF  (fonction de U3bilat et Timing_to_Use, Left)
    % 9 : UPDRS ON   (fonction de U3bilat et Timing_to_Use, Left)
    % 10 : UPDRS OFF (fonction de U3bilat et Timing_to_Use, Right)
    % 11 : UPDRS ON  (fonction de U3bilat et Timing_to_Use, Right)

    
    if strcmp(contact_to_use, 'HighestBeta')
        [HighestBetaCh, HighestBetaId] = hypoQAMPPE.functions.HighBetaContact(OFF_list,StartBeta,EndBeta,PicOrBand,Type_of_Spectrum) ;
    elseif strcmp(contact_to_use, 'ClinicalContact')
        CCmatrix = hypoQAMPPE.load.ClinicalContacts(ClinicalData.Old); 
        for ipat = 1:length(OFF_list)
            HighestBetaId(ipat,1) = table2cell(CCmatrix(strcmp(CCmatrix{:,1},OFF_list{1, ipat}.input(1:5)),2)) ;
            HighestBetaId(ipat,2) = table2cell(CCmatrix(strcmp(CCmatrix{:,1},OFF_list{1, ipat}.input(1:5)),3)) ;
            HighestBetaId(ipat,2) = {HighestBetaId{ipat,2} + 3} ;
        end
        HighestBetaCh = NaN ;
    end

    if ~iscell(HighestBetaCh) && isnan(HighestBetaCh)  % Cas ou contact clinique
        for el = 1:length(OFF_list) % pbm tt les contacts ne sont pas forcement nan si absent
            sizelist = size(squeeze(OFF_list{1, el}.raw.values{1, 1}(1,1:100,:)));
            if sizelist(end) ~= 6
                if     strcmp('D', OFF_list{1, el}.labels_(1, 1).name(end))
                    HighestBetaId(el,2) = {NaN} ; % C'est un droit uniquement : gauche = NaN
                elseif strcmp('G', OFF_list{1, el}.labels_(1, 1).name(end))
                    HighestBetaId(el,1) = {NaN} ;
                end
            end
            % round to have valid index
            HighestBetaId{el,1} = floor(HighestBetaId{el,1}) ;
            HighestBetaId{el,2} = floor(HighestBetaId{el,2}) ;
            if HighestBetaId{el,1} == 0
                HighestBetaId{el,1} = 1;
            end
            if HighestBetaId{el,2} == 0
                HighestBetaId{el,2} = 1;
            end
        end
        HighestBetaCh = cell(size(HighestBetaId)); % Are not named
    end
        
    
    NameAndNum = {} ;
    for element = 1:length(OFF_list)
        NameAndNum{element, 1} = extractBefore(OFF_list{1, element}.input ,'_');
        NameAndNum{element, 2} = HighestBetaCh{element,1};  % HighestBeta Right
        NameAndNum{element, 3} = HighestBetaId{element,1};
        NameAndNum{element, 4} = HighestBetaCh{element,2};  % HighestBeta Left
        NameAndNum{element, 5} = HighestBetaId{element,2};
        NameAndNum{element, 6} = element;                   % Off index
        NameAndNum{element, 7} = NaN;
        for el2 = 1:length(ON_list)
            if strcmp(extractBefore(OFF_list{1, element}.input ,'_'), extractBefore(ON_list{1, el2}.input ,'_'))
                NameAndNum{element, 7} = el2;               % On index
                break
            end
        end
        for pat = 1:length(ClinicalData.(ClinicalFileToUse){:,5})
            if strcmp(ClinicalFileToUse,'New')
                Name = cell2mat(ClinicalData.(ClinicalFileToUse){pat,5}) ;
            else
                Name = cell2mat(ClinicalData.(ClinicalFileToUse){pat,1}) ;
            end
            if strcmp(Name(1:5), 'CAMJe')
                Name(1:5) = 'CAMJa' ; % Wrong in clinics
            end
            if strcmp(Name(1:5), 'NEUDa')
                Name(1:5) = 'NEUDi' ; % Wrong in spectrum
            end
            if strcmp(Name(1:5), 'PECJe')
                Name(1:5) = 'PECJa' ; % Wrong in spectrum
            end
            if strcmp(Name(1:5), 'PINAl')
                Name(1:5) = 'PINMm' ; % Wrong in spectrum
            end
            if strcmp(Name(1:5), 'DISPi')
                Name(1:5) = 'SCIPi' ; % Wrong in spectrum
            end
            if strcmp(NameAndNum{element, 1}, Name(1:5))
                ClinIDX = pat ;
                break
            elseif pat == length(ClinicalData.(ClinicalFileToUse){:,5})
                fprintf(2, ['ERROR No clinical Data for : ' NameAndNum{el, 1} ' !!!  \n  Solve it BEFORE continue !!!\n \n'])
                ClinIDX = 1 ;
            end
        end
        if strcmp(ClinicalFileToUse,'New') 
            NameAndNum{element,8}  = ClinicalData.(ClinicalFileToUse){ClinIDX,16} ; % UPDRS OFF bilat
            NameAndNum{element,9}  = ClinicalData.(ClinicalFileToUse){ClinIDX,18} ; % UPDRS ON  bilat
            NameAndNum{element,10} = ClinicalData.(ClinicalFileToUse){ClinIDX,16} ; % UPDRS OFF bilat
            NameAndNum{element,11} = ClinicalData.(ClinicalFileToUse){ClinIDX,18} ; % UPDRS ON  bilat
            if strcmp(U3bilat, 'hemibody') 
                fprintf(2,'You selected ClinicalFileToUse = "New" and U3bilat = "hemibody" which aren''t compatibles... \n')
            end
            if strcmp('OffPreOnStim',Timing_to_Use)
                fprintf(2,'You selected Timing_to_Use = "OffPreOnStim" and ClinicalFileToUse = "New" which aren''t compatibles... \n')
            end
        elseif strcmp(ClinicalFileToUse,'Fusion') 
            NameAndNum{element,8}  = ClinicalData.(ClinicalFileToUse){ClinIDX,5} ; % UPDRS OFF bilat
            NameAndNum{element,9}  = ClinicalData.(ClinicalFileToUse){ClinIDX,6} ; % UPDRS ON  bilat
            NameAndNum{element,10} = ClinicalData.(ClinicalFileToUse){ClinIDX,5} ; % UPDRS OFF bilat
            NameAndNum{element,11} = ClinicalData.(ClinicalFileToUse){ClinIDX,6} ; % UPDRS ON  bilat
            if strcmp(U3bilat, 'hemibody') 
                fprintf(2,'You selected ClinicalFileToUse = "Fusion" and U3bilat = "hemibody" which aren''t compatibles... \n')
            end
        elseif strcmp(ClinicalFileToUse,'Old') 
            % bilat
            if strcmp(U3bilat, 'bilat')
                if strcmp('pre',Timing_to_Use)
                    NameAndNum{element,8}  = ClinicalData.(ClinicalFileToUse){ClinIDX,11} ; % UPDRS OFF bilat
                    NameAndNum{element,9}  = ClinicalData.(ClinicalFileToUse){ClinIDX,12} ; % UPDRS ON  bilat
                    NameAndNum{element,10} = ClinicalData.(ClinicalFileToUse){ClinIDX,11} ; % UPDRS OFF bilat
                    NameAndNum{element,11} = ClinicalData.(ClinicalFileToUse){ClinIDX,12} ; % UPDRS ON  bilat
                elseif strcmp('OffPreOnStim',Timing_to_Use)
                    NameAndNum{element,8}  = ClinicalData.(ClinicalFileToUse){ClinIDX,11} ; % UPDRS OFF pre bilat
                    NameAndNum{element,9}  = ClinicalData.(ClinicalFileToUse){ClinIDX,91} ; % UPDRS ON-stim OFF-dopa  bilat
                    NameAndNum{element,10} = ClinicalData.(ClinicalFileToUse){ClinIDX,11} ; % UPDRS OFF pre bilat
                    NameAndNum{element,11} = ClinicalData.(ClinicalFileToUse){ClinIDX,91} ; % UPDRS ON-stim OFF-dopa  bilat
                elseif strcmp('OffPreBestOn',Timing_to_Use)
                    NameAndNum{element,8}  = ClinicalData.(ClinicalFileToUse){ClinIDX,11} ; % UPDRS OFF pre bilat
                    NameAndNum{element,9}  = ClinicalData.(ClinicalFileToUse){ClinIDX,92} ; % UPDRS ON-stim ON-dopa  bilat
                    NameAndNum{element,10} = ClinicalData.(ClinicalFileToUse){ClinIDX,11} ; % UPDRS OFF pre bilat
                    NameAndNum{element,11} = ClinicalData.(ClinicalFileToUse){ClinIDX,92} ; % UPDRS ON-stim ON-dopa  bilat
                elseif strcmp('WorseOffBestOn',Timing_to_Use)
                    NameAndNum{element,8}  = ClinicalData.(ClinicalFileToUse){ClinIDX,90} ; % UPDRS OFF-stim OFF-dopa  bilat
                    NameAndNum{element,9}  = ClinicalData.(ClinicalFileToUse){ClinIDX,92} ; % UPDRS ON-stim ON-dopa  bilat
                    NameAndNum{element,10} = ClinicalData.(ClinicalFileToUse){ClinIDX,90} ; % UPDRS OFF-stim OFF-dopa  bilat
                    NameAndNum{element,11} = ClinicalData.(ClinicalFileToUse){ClinIDX,92} ; % UPDRS ON-stim ON-dopa  bilat
                end

            % Per Side
            elseif strcmp(U3bilat, 'hemibody')
                NameAndNum{element,10} = ClinicalData.(ClinicalFileToUse){ClinIDX,17} ; % UPDRS OFF Left
                NameAndNum{element,11} = ClinicalData.(ClinicalFileToUse){ClinIDX,18} ; % UPDRS ON  Left
                NameAndNum{element,8}  = ClinicalData.(ClinicalFileToUse){ClinIDX,14} ; % UPDRS OFF Right
                NameAndNum{element,9}  = ClinicalData.(ClinicalFileToUse){ClinIDX,15} ; % UPDRS ON  Right
                if ~strcmp('pre',Timing_to_Use)
                    fprintf(2,['You selected Timing_to_Use = "' Timing_to_Use '" and U3bilat = "hemibody" which aren''t compatibles... \n Dropping Timing parameter, All these Data are PREOPERATIVES \n'])
                end
            end
        end
    end
    % ON  only patients : RIMLa , OUTFr, DESLo
    % OFF only patients : ROYEs , REBSy , RECGe , 'CONCh , LEVDa , MOUDi , NOUFr , PECJa , PINMm'
end