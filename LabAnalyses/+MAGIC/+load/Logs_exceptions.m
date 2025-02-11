function [Essai_inclus_si_true, argout2] = Logs_exceptions(TrialName, Trialnum, argin3)

liste_Bad_Trials = [] ;

    %% MAGIC
if     strcmp(TrialName(1:end-3), 'ParkPitie_2020_06_25_ALb_MAGIC_POSTOP_ON_GNG_GAIT_') 
    liste_Bad_Trials = [3,7,10,12,20,23,27,30,35,39,46,48,50,53,54,55,56,57,58,59,60] ;
elseif strcmp(TrialName(1:end-3), 'ParkPitie_2020_06_25_ALb_MAGIC_POSTOP_OFF_GNG_GAIT_') 
    liste_Bad_Trials = [25,37,49,50,57,58,59,60] ;

elseif strcmp(TrialName(1:end-3), 'ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_') 
    liste_Bad_Trials = [38,39,40] ;
elseif strcmp(TrialName(1:end-3), 'ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_ON_GNG_GAIT_') 
    liste_Bad_Trials = [45] ;

elseif strcmp(TrialName(1:end-3), 'ParkPitie_2020_02_20_FEp_MAGIC_POSTOP_ON_GNG_GAIT_') 
    liste_Bad_Trials = [14,25,37,45] ;
elseif strcmp(TrialName(1:end-3), 'ParkPitie_2020_02_20_FEp_MAGIC_POSTOP_OFF_GNG_GAIT_') 
    liste_Bad_Trials = [] ;

elseif strcmp(TrialName(1:end-3), 'ParkPitie_2020_01_16_DEp_MAGIC_POSTOP_OFF_GNG_GAIT_') 
    liste_Bad_Trials = [41] ;
elseif strcmp(TrialName(1:end-3), 'ParkPitie_2020_01_16_DEp_MAGIC_POSTOP_ON_GNG_GAIT_') 
    liste_Bad_Trials = [43,47] ;
    
elseif strcmp(TrialName(1:end-3), 'ParkPitie_2020_09_17_GAl_MAGIC_POSTOP_OFF_GNG_GAIT_') 
    liste_Bad_Trials = [] ;
elseif strcmp(TrialName(1:end-3), 'ParkPitie_2020_09_17_GAl_MAGIC_POSTOP_ON_GNG_GAIT_') 
    liste_Bad_Trials = [] ;
    
elseif strcmp(TrialName(1:end-3), 'ParkPitie_2020_10_08_SOh_MAGIC_POSTOP_OFF_GNG_GAIT_') 
    liste_Bad_Trials = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,111,112,118,119,21] ;
elseif strcmp(TrialName(1:end-3), 'ParkPitie_2020_10_08_SOh_MAGIC_POSTOP_ON_GNG_GAIT_') 
    liste_Bad_Trials = [] ;
    
elseif strcmp(TrialName(1:end-3), 'ParkPitie_2020_10_21_SAs_MAGIC_POSTOP_OFF_GNG_GAIT_') 
    liste_Bad_Trials = [] ;
elseif strcmp(TrialName(1:end-3), 'ParkPitie_2020_10_21_SAs_MAGIC_POSTOP_ON_GNG_GAIT_') 
    liste_Bad_Trials = [] ;
    
    %% MAGIC ROUEN

elseif strcmp(TrialName(1:end-3), 'ParkRouen_2020_11_30_GUG_MAGIC_POSTOP_OFF_GNG_GAIT_') 
    liste_Bad_Trials = [6, 20] ;
elseif strcmp(TrialName(1:end-3), 'ParkRouen_2020_11_30_GUG_MAGIC_POSTOP_ON_GNG_GAIT_') 
    liste_Bad_Trials = [10, 53] ;
    
elseif strcmp(TrialName(1:end-3), 'ParkRouen_2021_02_08_FRJ_MAGIC_POSTOP_OFF_GNG_GAIT_') 
    liste_Bad_Trials = [56,4,11,33,46] ;
elseif strcmp(TrialName(1:end-3), 'ParkRouen_2021_02_08_FRJ_MAGIC_POSTOP_ON_GNG_GAIT_') 
    liste_Bad_Trials = [5,60] ;
    
elseif strcmp(TrialName(1:end-3), 'ParkRouen_2021_10_04_FRa_MAGIC_POSTOP_OFF_GNG_GAIT_') 
    liste_Bad_Trials = [] ;
elseif strcmp(TrialName(1:end-3), 'ParkRouen_2021_10_04_FRa_MAGIC_POSTOP_ON_GNG_GAIT_') 
    liste_Bad_Trials = [] ;
    
    %% GOGAIT

elseif strcmp(TrialName(1:end-3), 'GOGAIT_POSTOP_BARGU14_OFF_GNG') 
    liste_Bad_Trials = [36] ;
elseif strcmp(TrialName(1:end-3), 'GOGAIT_POSTOP_BARGU14_ON_GNG') 
    liste_Bad_Trials = [15,50,59] ;
    
elseif strcmp(TrialName(1:end-3), 'GAITPARK_POSTOP_DROCA16_OFF_GNG') 
    liste_Bad_Trials = [6,24,47] ;
elseif strcmp(TrialName(1:end-3), 'GOGAIT_POSTOP_DROCA16_ON_GNG') 
    liste_Bad_Trials = [] ;
    
elseif strcmp(TrialName(1:end-3), 'GOGAIT_POSTOP_DESJO20_OFF_GNG') 
    liste_Bad_Trials = [] ;
elseif strcmp(TrialName(1:end-3), 'GOGAIT_POSTOP_DESJO20_ON_GNG') 
    liste_Bad_Trials = [] ;
    
elseif strcmp(TrialName(1:end-3), 'ParkPitie_2019_10_03_BEm_GBMOV_POSTOP_OFF_GNG_GAIT_') 
    liste_Bad_Trials = [39] ;
elseif strcmp(TrialName(1:end-3), 'ParkPitie_2019_10_03_BEm_GBMOV_POSTOP_ON_GNG_GAIT_') 
    liste_Bad_Trials = [44] ;
    
elseif strcmp(TrialName(1:end-3), 'ParkPitie_2019_10_24_COm_GBMOV_POSTOP_OFF_GNG_GAIT_') 
    liste_Bad_Trials = [] ;
elseif strcmp(TrialName(1:end-3), 'ParkPitie_2019_10_24_COm_GBMOV_POSTOP_ON_GNG_GAIT_') 
    liste_Bad_Trials = [] ;
    
elseif strcmp(TrialName(1:end-3), 'ParkPitie_2019_11_28_LOp_GBMOV_POSTOP_OFF_GNG_GAIT_') 
    liste_Bad_Trials = [26,27,28,29,30,31,32,33,34,35,36,38,60] ;
elseif strcmp(TrialName(1:end-3), 'ParkPitie_2019_11_28_LOp_GBMOV_POSTOP_ON_GNG_GAIT_') 
    liste_Bad_Trials = [1] ;
    
elseif strcmp(TrialName(1:end-3), 'ParkPitie_2020_01_09_REa_GBMOV_POSTOP_OFF_GNG_GAIT_') 
    liste_Bad_Trials = [] ;
    
elseif strcmp(TrialName(1:end-3), 'ParkPitie_2020_07_02_GIs_GBMOV_POSTOP_OFF_GNG_GAIT_') 
    liste_Bad_Trials = [58] ;
elseif strcmp(TrialName(1:end-3), 'ParkPitie_2020_07_02_GIs_GBMOV_POSTOP_ON_GNG_GAIT_') 
    liste_Bad_Trials = [10,31,35,36,37,38,39,56] ;
    

else
    fprintf(2,'patient non inclus dans Log-Exeption \n')
end


 if ismember(Trialnum,liste_Bad_Trials) 
    Essai_inclus_si_true = false ;
else
    Essai_inclus_si_true = true ;
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
