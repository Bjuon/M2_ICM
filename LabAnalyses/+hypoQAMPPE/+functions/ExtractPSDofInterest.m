function [BestChanTableOFF, BestChanTableON, BestChanTableDlt, MeanChanTableOFF, MeanChanTableON, MeanChanTableDlt, patOFF, patON, LeftRightOFF, LeftRightON] = ExtractPSDofInterest(NameAndNum, ExportToR, Type_of_Spectrum, PtFq, OFF_list, ON_list, PlotSaveFolder, Normalisation)
    %EXTRACTPSDOFINTEREST 
    % Extract PSD of interest

    %#ok<*UDIM>
    %#ok<*AGROW>

    BestChanTableOFF = {} ;
    BestChanTableON  = {} ;
    BestChanTableDlt = {} ; % Delta
    patOFF           = {} ;
    patON            = {} ;
    LeftRightOFF     = [] ;
    LeftRightON      = [] ;

    

    cntO = 0 ;
    cntI = 0 ;
    for el = 1:length(NameAndNum)
        if OFF_list{1, el}.(Type_of_Spectrum).f(100) ~= 99 * PtFq
            fprintf(2, ['ERROR Frequency for : ' NameAndNum{el, 1} ' is bad !!!  \n'])
        end
        % OFF PSD
        if ~isnan(NameAndNum{el, 3})  
            cntO = cntO + 1 ;
            value = squeeze(OFF_list{1, el}.(Type_of_Spectrum).values{1, 1}(1,:,NameAndNum{el, 3}))' ;
            BestChanTableOFF(1:length(value),cntO) = num2cell(value) ;                                     
            value = median(squeeze(OFF_list{1, el}.(Type_of_Spectrum).values{1, 1}(1,:,1:3))') ;            
            MeanChanTableOFF(1:length(value),cntO) = num2cell(value) ;
            % ClinicsOFF(1,cntO) = ClinicalData.New{ClinIDX,16} ; % UPDRS OFF
            patOFF(1,cntO) = NameAndNum(el, 1) ;
            LeftRightOFF(1,cntO) = 0 ;
        end
        if ~isnan(NameAndNum{el, 5})
            cntO = cntO + 1 ;
            value = squeeze(OFF_list{1, el}.(Type_of_Spectrum).values{1, 1}(1,:,NameAndNum{el, 5}))' ; 
            BestChanTableOFF(1:length(value),cntO) = num2cell(value) ; 
            value = median(squeeze(OFF_list{1, el}.(Type_of_Spectrum).values{1, 1}(1,:,4:6))') ;  
            MeanChanTableOFF(1:length(value),cntO) = num2cell(value) ;
            patOFF(1,cntO) = NameAndNum(el, 1) ;
            LeftRightOFF(1,cntO) = 2 ;
        end
        % ON PSD
        if ~isnan(NameAndNum{el, 7})
            if ON_list{1, NameAndNum{el, 7}}.(Type_of_Spectrum).f(100) ~= 99 * PtFq
                fprintf(2, ['ERROR Frequency for : ' NameAndNum{el, 1} ' is bad !!!  \n'])
            end
            if ~isnan(NameAndNum{el, 3})  
                cntI = cntI + 1 ;
                valueR = squeeze(ON_list{1, NameAndNum{el, 7}}.(Type_of_Spectrum).values{1, 1}(1,:,NameAndNum{el, 3}))' ; 
                BestChanTableON(1:length(valueR),cntI) = num2cell(valueR) ;
                valueM = median(squeeze(ON_list{1, NameAndNum{el, 7}}.(Type_of_Spectrum).values{1, 1}(1,:,1:3))') ;
                MeanChanTableON(1:length(valueM),cntI) = num2cell(valueM) ;
                patON(1,cntI) = NameAndNum(el, 1) ;
                off_v = squeeze(OFF_list{1, el}.(Type_of_Spectrum).values{1, 1}(1,:,NameAndNum{el, 3}))' ;
                BestChanTableDlt(1:length(valueR),cntI) = num2cell(off_v(1:length(valueR)) - valueR) ;
                off_v = median(squeeze(OFF_list{1, el}.(Type_of_Spectrum).values{1, 1}(1,:,1:3))') ;
                MeanChanTableDlt(1:length(valueM),cntI) = num2cell(off_v(1:length(valueM)) - valueM) ;
                LeftRightON(1,cntI) = 0 ;
            end
            if ~isnan(NameAndNum{el, 5})
                cntI = cntI + 1 ;
                valueR = squeeze(ON_list{1, NameAndNum{el, 7}}.(Type_of_Spectrum).values{1, 1}(1,:,NameAndNum{el, 5}))' ; 
                BestChanTableON(1:length(valueR),cntI) = num2cell(valueR) ; 
                valueM = median(squeeze(ON_list{1, NameAndNum{el, 7}}.(Type_of_Spectrum).values{1, 1}(1,:,4:6))') ;
                MeanChanTableON(1:length(valueM),cntI) = num2cell(valueM) ;
                patON(1,cntI) = NameAndNum(el, 1) ;
                off_v = squeeze(OFF_list{1, el}.(Type_of_Spectrum).values{1, 1}(1,:,NameAndNum{el, 5}))' ;
                BestChanTableDlt(1:length(valueR),cntI) = num2cell(off_v(1:length(valueR)) - valueR) ;
                off_v = median(squeeze(OFF_list{1, el}.(Type_of_Spectrum).values{1, 1}(1,:,4:6))') ;
                MeanChanTableDlt(1:length(valueM),cntI) = num2cell(off_v(1:length(valueM)) - valueM) ;
                LeftRightON(1,cntI) = 2 ;
             end
        end
    end
    
    if isinf(BestChanTableOFF{1})
        BestChanTableOFF(1,:) = BestChanTableOFF(2,:) ;
        BestChanTableON(1,:)  = BestChanTableON(2,:)  ;
    end

    %%%%% EXPORT TO R
    if ExportToR
        writecell(BestChanTableOFF,[PlotSaveFolder filesep 'BestChanTableOFF' '_' Type_of_Spectrum '_' Normalisation '.csv'])               
        writecell(MeanChanTableOFF,[PlotSaveFolder filesep 'MeanChanTableOFF' '_' Type_of_Spectrum '_' Normalisation '.csv'])               
        writecell(BestChanTableDlt,[PlotSaveFolder filesep 'BestChanTableDlt' '_' Type_of_Spectrum '_' Normalisation '.csv'])               
        writecell(MeanChanTableDlt,[PlotSaveFolder filesep 'MeanChanTableDlt' '_' Type_of_Spectrum '_' Normalisation '.csv'])
        writecell(BestChanTableON,[PlotSaveFolder filesep 'BestChanTableON' '_' Type_of_Spectrum '_' Normalisation '.csv'])               
        writecell(MeanChanTableON,[PlotSaveFolder filesep 'MeanChanTableON' '_' Type_of_Spectrum '_' Normalisation '.csv'])
        NameAndNumExport = cell2table(NameAndNum,"VariableNames",{'Name' 'HighestBetaRightCh' 'HighestBetaRightId' 'HighestBetaLeftCh' 'HighestBetaLeftId' 'OFFidx' 'ONidx' 'U3O' 'U3I' 'U3OLeft' 'U3ILeft'}) ;
        writetable(NameAndNumExport,[PlotSaveFolder filesep 'MatchTable' '_' Type_of_Spectrum '_' Normalisation '.csv'])     
        writematrix(ON_list{1, 1}.raw.f',[PlotSaveFolder filesep 'FreqList.csv'])    
    end
end

