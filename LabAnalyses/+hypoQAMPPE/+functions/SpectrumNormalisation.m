function [List_of_Spectrum] = SpectrumNormalisation(NormalisationMethod,List_of_Spectrum)
    %SPECTRUMNORMALISATION Normalize the spectrums given as entry
    
% Internal Parameters

Alert = false ;

    if strcmp(NormalisationMethod, 'brut')
        a = 1 ;
    elseif  strcmp(NormalisationMethod, 'AUC100')
        AUCstart = 4   ; % en Hz
        AUCend   = 100 ; % en Hz
        Types_of_Spectrum = {'raw','detail'} ;

        for element = 1 : length(List_of_Spectrum)

            for T = 1:length(Types_of_Spectrum)
                Type_of_Spectrum = Types_of_Spectrum{T} ;
                
                PtFq = List_of_Spectrum{1, element}.(Type_of_Spectrum).f(2) - List_of_Spectrum{1, element}.(Type_of_Spectrum).f(1)  ;
                Sidx = find(AUCstart==List_of_Spectrum{1, element}.(Type_of_Spectrum).f,1) ;
                Eidx = find(AUCend  ==List_of_Spectrum{1, element}.(Type_of_Spectrum).f,1) ;
                
                LFP6ChanBrut = squeeze(List_of_Spectrum{1, element}.(Type_of_Spectrum).values{1, 1}  ) ;
                LFP6ChanNorm = nan(size(LFP6ChanBrut)) ;
                for ch = 1 : size(LFP6ChanBrut,2)
                    AUC = sum(LFP6ChanBrut(Sidx:Eidx,ch))         ;
                    LFP6ChanNorm(:,ch) = LFP6ChanBrut(:,ch) / AUC ;
                end
                doubleToExport = [] ;
                doubleToExport(1,:,:) = LFP6ChanNorm ;
                try 
                    List_of_Spectrum{1, element}.(Type_of_Spectrum).values{1, 1} = doubleToExport ;
                    Alert=true;
                catch 
                    fprintf(2, 'La protection de "values" dans les propriétés de la classe process doit être désactivée. Pour cela supprimer "SetAccess = protected" à la ligne 40 de Process.m \n')
                    List_of_Spectrum{1, element}.(Type_of_Spectrum).values{1, 1} = doubleToExport ;
                end
                    
            end


        end


    elseif  strcmp(NormalisationMethod, 'AUCg')
        AUCstart = 55   ; % en Hz
        AUCend   = 95 ; % en Hz
        Types_of_Spectrum = {'raw','detail'} ;

        for element = 1 : length(List_of_Spectrum)

            for T = 1:length(Types_of_Spectrum)
                Type_of_Spectrum = Types_of_Spectrum{T} ;
                
                PtFq = List_of_Spectrum{1, element}.(Type_of_Spectrum).f(2) - List_of_Spectrum{1, element}.(Type_of_Spectrum).f(1)  ;
                Sidx = find(AUCstart==List_of_Spectrum{1, element}.(Type_of_Spectrum).f,1) ;
                Eidx = find(AUCend  ==List_of_Spectrum{1, element}.(Type_of_Spectrum).f,1) ;
                
                LFP6ChanBrut = squeeze(List_of_Spectrum{1, element}.(Type_of_Spectrum).values{1, 1}  ) ;
                LFP6ChanNorm = nan(size(LFP6ChanBrut)) ;
                for ch = 1 : size(LFP6ChanBrut,2)
                    AUC = sum(LFP6ChanBrut(Sidx:Eidx,ch))         ;
                    LFP6ChanNorm(:,ch) = LFP6ChanBrut(:,ch) / AUC ;
                end
                doubleToExport = [] ;
                doubleToExport(1,:,:) = LFP6ChanNorm ;
                try 
                    List_of_Spectrum{1, element}.(Type_of_Spectrum).values{1, 1} = doubleToExport ;
                    Alert=true;
                catch 
                    fprintf(2, 'La protection de "values" dans les propriétés de la classe process doit être désactivée. Pour cela supprimer "SetAccess = protected" à la ligne 40 de Process.m \n')
                    List_of_Spectrum{1, element}.(Type_of_Spectrum).values{1, 1} = doubleToExport ;
                end
                    
            end


        end


    else  
        fprintf(2, ['Attention, ' NormalisationMethod ' n''est pas une methode de normalisation reconnue dans hypoQAMPPE.load.SpectrumNormalisation \n'])
    end

if Alert
    fprintf(2, 'ATTENTION La protection de "values" dans les propriétés de la classe process est désactivée. Cela n''est pas le comportement normal de LabTools. Réactiver dès que possible cette propriété. Pour cela remettre "SetAccess = protected" à la ligne 40 de Process.m \n')
    disp( 'C:\Users\mathieu.yeche\Desktop\GitHub\LabTools\subtrees\Process\@Process\Process.m ')
end

end

