function [ShouldBeIncluded] = PatientsWithPeaks(Patient, Side, PeakProminance, CategAndMore, PeakBand, PeakTable , AutoManuel)
% Fonction permetant de recuperrer les valeurs de peaks
% Possible inputs :
% Patient : char
% Side : 'D' or 'G'
% PeakProminance : Categories of Peak to include
% CategAndMore : char, if '+', use '>=' , if 'only' use '=='
% PeakBand : 'LowB' , 'HighB' , 'FTGamma' , 'Alpha' , 'HFO'
% PeakTable (opt) : table contenant les valeurs manuelles
% AutoManuel (opt) : should the calculation be automatic or manual selection of peaks

ShouldBeIncluded = false ;

if nargin < 6
    AutoManuel = 'Manuel' ;
end
if nargin < 4
    PeakTable = readtable('C:\LustreSync\hypoQAMPPE\PeakDetection.xlsx') ;
end

if strcmp(AutoManuel, 'Manuel')
    idx = find(strcmp(Patient, PeakTable.Patient)) ;
    if strcmp(PeakBand, 'LowB')
        if ~isempty(idx)
            if strcmp(Side,'D')
                if strcmp(CategAndMore, '+')
                    if PeakTable.BETARightSide(idx) >= PeakProminance
                        ShouldBeIncluded = true ;
                    end
                elseif strcmp(CategAndMore, 'only')
                    if PeakTable.BETARightSide(idx) == PeakProminance
                        ShouldBeIncluded = true ;
                    end
                end
            elseif strcmp(Side,'G')
                if strcmp(CategAndMore, '+') 
                    if PeakTable.BETALeftSide(idx) >= PeakProminance
                        ShouldBeIncluded = true ;
                    end
                elseif strcmp(CategAndMore, 'only')
                    if PeakTable.BETALeftSide(idx) == PeakProminance
                        ShouldBeIncluded = true ;
                    end
                end
            end
        end
    end
end

    

end

