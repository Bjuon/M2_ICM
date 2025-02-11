function [Essai_inclus_si_true, argout2] = Logs_for_multipoly5(TrialName, Trialnum, Poly5Name, argin4)
filename = Poly5Name(1:end-6) ;
Minimum_inclus_dans_LOG = 0   ;
Maximum_inclus_dans_LOG = 999 ;


    %% MAGIC
if     strcmp(filename, 'ParkPitie_2020_01_16_DEp_MAGIC_POSTOP_ON_GNG_GAIT_001_LFP') 
    Minimum_inclus_dans_LOG = 1  ;
    Maximum_inclus_dans_LOG = 30 ;
elseif strcmp(filename, 'ParkPitie_2020_01_16_DEp_MAGIC_POSTOP_ON_GNG_GAIT_002_LFP') 
    Minimum_inclus_dans_LOG = 31 ;
    Maximum_inclus_dans_LOG = 60 ;
    
elseif strcmp(filename, 'ParkPitie_2020_09_17_GAl_MAGIC_POSTOP_OFF_GNG_GAIT_001_LFP') 
    Minimum_inclus_dans_LOG = 1    ;
    Maximum_inclus_dans_LOG = 10   ;
elseif strcmp(filename, 'ParkPitie_2020_09_17_GAl_MAGIC_POSTOP_OFF_GNG_GAIT_002_LFP') 
    Minimum_inclus_dans_LOG = 11   ;
    Maximum_inclus_dans_LOG = 32   ;
    
elseif strcmp(filename, 'ParkPitie_2020_10_08_SOh_MAGIC_POSTOP_OFF_GNG_GAIT_001_LFP') 
    Maximum_inclus_dans_LOG = 0    ;
elseif strcmp(filename, 'ParkPitie_2020_10_08_SOh_MAGIC_POSTOP_OFF_GNG_GAIT_002_LFP') 
    Minimum_inclus_dans_LOG = 20   ;
    Maximum_inclus_dans_LOG = 60   ;
elseif strcmp(filename, 'ParkPitie_2020_10_08_SOh_MAGIC_POSTOP_OFF_GNG_GAIT_003_LFP') 
    Minimum_inclus_dans_LOG = 100  ;
    Maximum_inclus_dans_LOG = 120  ;

elseif strcmp(filename, 'ParkPitie_2020_07_02_GIs_GBMOV_POSTOP_OFF_GNG_GAIT_001_LFP') 
    Minimum_inclus_dans_LOG = 1  ;
    Maximum_inclus_dans_LOG = 39  ;
elseif strcmp(filename, 'ParkPitie_2020_07_02_GIs_GBMOV_POSTOP_OFF_GNG_GAIT_002_LFP') 
    Minimum_inclus_dans_LOG = 40  ;
    Maximum_inclus_dans_LOG = 60  ;

elseif strcmp(filename, 'ParkPitie_2020_01_09_REa_GBMOV_POSTOP_OFF_GNG_GAIT_001_LFP') 
    Minimum_inclus_dans_LOG = 1  ;
    Maximum_inclus_dans_LOG = 10  ;
elseif strcmp(filename, 'ParkPitie_2020_01_09_REa_GBMOV_POSTOP_OFF_GNG_GAIT_002_LFP') 
    Minimum_inclus_dans_LOG = 11  ;
    Maximum_inclus_dans_LOG = 60  ;
    
elseif strcmp(filename, 'ParkPitie_2019_10_24_COm_GBMOV_POSTOP_OFF_GNG_GAIT_001_LFP') 
    Maximum_inclus_dans_LOG = 0    ;    
elseif strcmp(filename, 'ParkPitie_2019_10_24_COm_GBMOV_POSTOP_ON_GNG_GAIT_001_LFP') 
    Maximum_inclus_dans_LOG = 0    ;   

elseif strcmp(filename, 'ParkRouen_2021_10_04_FRa_MAGIC_POSTOP_OFF_GNG_GAIT_001_LFP') 
    Minimum_inclus_dans_LOG = 1  ;
    Maximum_inclus_dans_LOG = 3  ;
elseif strcmp(filename, 'ParkRouen_2021_10_04_FRa_MAGIC_POSTOP_OFF_GNG_GAIT_002_LFP') 
    Minimum_inclus_dans_LOG = 5  ;
    Maximum_inclus_dans_LOG = 7  ;
elseif strcmp(filename, 'ParkRouen_2021_10_04_FRa_MAGIC_POSTOP_ON_GNG_GAIT_001_LFP') 
    Minimum_inclus_dans_LOG = 1  ;
    Maximum_inclus_dans_LOG = 10  ;
elseif strcmp(filename, 'ParkRouen_2021_10_04_FRa_MAGIC_POSTOP_ON_GNG_GAIT_002_LFP') 
    Minimum_inclus_dans_LOG = 51  ;
    Maximum_inclus_dans_LOG = 60  ;

elseif strcmp(TrialName(1:end-3), 'ParkRouen_2021_10_04_FRa_MAGIC_POSTOP_OFF_GNG_GAIT_') 
    liste_Bad_Trials = [] ;
    fprintf(2,'patient non inclus dans Log-ForMultiPoly5 \n Y a t il le besoin ??? \n Et bien changer poly5 name 2 lignes plus haut que ce fprintf \n')
elseif strcmp(TrialName(1:end-3), 'ParkRouen_2021_10_04_FRa_MAGIC_POSTOP_ON_GNG_GAIT_') 
    liste_Bad_Trials = [] ;
  


    





end


if Maximum_inclus_dans_LOG >= Trialnum && Trialnum >= Minimum_inclus_dans_LOG 
    Essai_inclus_si_true = true ;
else
    Essai_inclus_si_true = false ;
end


    argout2 = 0;

end


% Patient = SAs  n°7 OFF : 20 Nogo parmi 58 essais 'Essais manqués : '}    {'43'}    {'48'}
% Patient = SAs  n°7 ON : 20 Nogo parmi 59 essais 'Essais manqués : '}    {'10'}
% 
% Patient = FRa  n°10 OFF : 0 Nogo parmi 7 essais 'Essais manqués : '}    {'08' à {'60'}
% Patient = FRa  n°10 ON : 0 Nogo parmi 19 essais 'Essais manqués : '}    {'10 à '50'}
% 
% Patient = BEm  n°14 OFF : 20 Nogo parmi 60 essais
% Patient = BEm  n°14 ON : 20 Nogo parmi 60 essais
% 
% Patient = REa  n°17 OFF : 20 Nogo parmi 59 essais 'Essais manqués : '}    {'10'}
% Patient = REa  n°17 ON : 0 Nogo parmi 0 essais
% 
% Patient = GIs  n°18 OFF : 20 Nogo parmi 60 essais
% Patient = GIs  n°18 ON : 20 Nogo parmi 58 essais 'Essais manqués : '}    {'07'}    {'60'}
