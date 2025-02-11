function [HighestBetaCh, HighestBetaId] = HighBetaContact(OFF_list,StartBeta,EndBeta,PicOrBand,Type_of_Spectrum)
    HighestBetaCh = {};
    HighestBetaId = {};
    if strcmp(PicOrBand, 'AllPic')
        PicOrBand = 'Pic' ;
        AllCh = true ;
        BetaMetric = {} ;
    else
        AllCh = false ;
    end

    for element = 1:length(OFF_list)
        freq_list = OFF_list{1, element}.(Type_of_Spectrum).f ;
        [~, StartIndex] = min(abs(freq_list - StartBeta));
        [~, EndIndex  ] = min(abs(freq_list - EndBeta  ));
        valu_list = squeeze(OFF_list{1, element}.(Type_of_Spectrum).values{1, 1}(1,StartIndex:EndIndex,:)) ;
        sizelist = size(valu_list);
        
        % Left
        BestChL = NaN ;
        BestIdL = NaN ;
        BestChR = NaN ;
        BestIdR = NaN ;
        maxVChL = 0   ;
        maxVChR = 0   ;
        for ch = 1:sizelist(end)
            
            if     strcmp('D', OFF_list{1, element}.labels_(1, ch).name(end)) && max(valu_list(:,ch)) > maxVChR && strcmp(PicOrBand, 'Pic')
                    BestChR = OFF_list{1, element}.labels_(1, ch).name ;
                    BestIdR = ch ;
                    maxVChR = max(valu_list(:,ch)) ;
            elseif strcmp('G', OFF_list{1, element}.labels_(1, ch).name(end)) && max(valu_list(:,ch)) > maxVChL && strcmp(PicOrBand, 'Pic')
                    BestChL = OFF_list{1, element}.labels_(1, ch).name ;
                    BestIdL = ch ;
                    maxVChL = max(valu_list(:,ch)) ;
           
            elseif strcmp(PicOrBand, 'Band')
                if mean(valu_list(:,ch)) > maxVCh
                    BestCh = OFF_list{1, element}.labels_(1, ch).name ;
                    BestId = ch ;
                end
            end

            if AllCh
                BetaMetric{element,ch} = max(valu_list(:,ch)) ;
            end
        end
        HighestBetaCh{element,1} = BestChR ;
        HighestBetaId{element,1} = BestIdR ;
        HighestBetaCh{element,2} = BestChL ;
        HighestBetaId{element,2} = BestIdL ;

    end
    if AllCh
        HighestBetaCh = BetaMetric ;
    end
end