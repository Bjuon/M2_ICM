function [IdCh, Freq, Autoscore] = PeakFinder(Type_of_input, Peak_ch, BestCh, InputData, Start_range, End_range, PtFq, LeftRight)
    %PEAKFINDER Identify peak and return Ch, Freq and AutoScore
    % Type_of_input = 'AllCh1Pat' or 'OFFONlist' or 'BestChAllPat' or '1Ch'
    % Peak_ch = 'All' or 'Best' 
    % BestCh : number of the channel (basicly : HighestBetaId{element,LeftRight})
    % InputData = valeursRAW par exemple, de taille [: , 6]
    % Start_range = 12
    % End_range = 35
    % PtFq 
    % LeftRight : 2 for Left or 1 for Right
    %
    % outputs
    % IdCh 
    % Freq 
    % Autoscore : 0 to 4 scoring, 0 means no peak found, 1 = quite no peak, 2 = bad recording, 3 = quite a peak, 4= yes peak found

    if LeftRight == 1 || LeftRight == 0
        valeurs = InputData(:,1:3) ;
        ChNbrAdd = 0 ;
    elseif LeftRight == 2
        valeurs = InputData(:,4:6) ;
        ChNbrAdd = 3 ;
    end

    if strcmp(Type_of_input,'AllCh1Pat')
        if strcmp(Peak_ch,'All')
            MaxVAll = 0 ; 
            IdCh = 0 ;
            for ch = 1:length(valeurs(1,:))
                [MaxV, FreqV] = max(valeurs(Start_range/PtFq:End_range/PtFq, ch),[],1) ;  
                if MaxV > MaxVAll
                    MaxVAll = MaxV ;
                    IdCh = ch + ChNbrAdd ;
                    Freq = FreqV*PtFq + Start_range ;
                end 
            end

            % Validation
            Autoscore = NaN ;
            % WIP
        end
    end


%Attention a left right

if isempty(IdCh) && isempty(Freq)
    IdCh = NaN ;
    Freq = NaN ;
end

end

