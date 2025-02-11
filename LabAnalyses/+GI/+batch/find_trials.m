function [APA_trials,triggers_i,step_badTrials] = find_trials(protocol, patient, med, speed, condition)

step_badTrials = {};

switch protocol
    
    case 'GBMOV'
        
        switch patient
            
            case 'ParkPitie_2015_05_07_ALg'
                if strcmp(med,'OFF') && strcmp(speed,'S')
                    APA_trials     = {'02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20'};
                    step_badTrials = {'08'};
                    triggers_i  = 2:20;
                elseif strcmp(med,'OFF') && strcmp(speed,'R')
                    APA_trials = {'01','02','03','04','05','06','07','09','10','11','13','16','17','19','20'};
                    step_badTrials = {'01','04'};
                    triggers_i  = [1:7,9:12,14:17];
                    %                 elseif strcmp(med,'OFF') && strcmp(speed,'AI')
                    %                     APA_trials = {'01','04'};
                    %                     triggers_i  = [1,4];
                else
                    fprintf([' ! Trials for the condition ' med '_' speed ' for patient ' patient ' are not reported\n']);
                end
                
            case 'DESPI05'
                if strcmp(med,'OFF') && strcmp(speed,'S')
                    APA_trials = {'01','02','03','04','05','06','07','08','09','11','12','13','14','15','16'};
                    triggers_i  = [1:9,11:16];
                elseif strcmp(med,'OFF') && strcmp(speed,'R')
                    APA_trials = {'04','07','08','09','10','11','12','13','14','15','16'};
                    triggers_i  = [1,4:13];
                elseif strcmp(med,'ON') && strcmp(speed,'S')
                    APA_trials = {'01','02','04','05','06','07','08','09','10','11','12','14','15','17','18','19','20','21'};
                    triggers_i  = [1,2,4:12,14,15,17:21];
                elseif strcmp(med,'ON') && strcmp(speed,'R')
                    APA_trials = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','18','19','20','21','22','23','24'};
                    triggers_i  = [1:16,18:24];
                    %                 elseif strcmp(med,'ON') && strcmp(speed,'AI')
                    %                     APA_trials = {'05','06','07','10'};
                    %                     triggers_i  = [5,6,7,10];
                else
                    fprintf([' ! Trials for the condition ' med '_' speed ' for patient ' patient ' are not reported\n']);
                end
                
            case 'ABBGI01'
                if     strcmp(med,'ON') && strcmp(speed,'S')
                    APA_trials = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25'};
                    triggers_i  = 1:25;
                elseif strcmp(med,'ON') && strcmp(speed,'R')
                    APA_trials = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29'};
                    triggers_i  = 1:29;
                else
                    fprintf([' ! Trials for the condition ' med '_' speed ' for patient ' patient ' are not reported\n']);
                end
                
            case 'ParkPitie_2013_03_21_ROe'
                if     strcmp(med,'OFF') && strcmp(speed,'S')
                    APA_trials     = {'01','04','09','11','12','13','14','15','16','18','19','20'};
                    step_badTrials = {'01','02','04','08','09','10','12','13'};
                    triggers_i  = [1,4,9,11:16,18:20];
                elseif strcmp(med,'ON') && strcmp(speed,'S')
                    APA_trials     = {'02','03','04','05','06','07','09'};
                    step_badTrials = {'01','02','04','08','09','10','12','13'};
                    triggers_i  = 1:12;
                else
                    fprintf([' ! Trials for the condition ' med '_' speed ' for patient ' patient ' are not reported\n']);
                end
                
            
            case 'RECGE02'
                if     strcmp(med,'OFF') && strcmp(speed,'S')
                    APA_trials = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24'};
                    triggers_i  = 1:24;
                elseif strcmp(med,'OFF') && strcmp(speed,'R')
                    APA_trials = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23'};
                    triggers_i  = 1:23;
                elseif strcmp(med,'ON') && strcmp(speed,'S')
                    APA_trials = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','18','19','20','21','22','23','24','25','26'};
                    triggers_i  = [1:16,18:26];
                elseif strcmp(med,'ON') && strcmp(speed,'R')
                    APA_trials = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27'};
                    triggers_i  = 1:27;
                else
                    fprintf([' ! Trials for the condition ' med '_' speed ' for patient ' patient ' are not reported\n']);
                end
                
            case 'ParkPitie_2013_04_04_REs'
                if     strcmp(med,'OFF') && strcmp(speed,'S')
                    APA_trials  = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26'};
                    triggers_i  = 1:26;
                elseif strcmp(med,'OFF') && strcmp(speed,'R')
                    APA_trials  = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26'};
                    triggers_i  = 1:26;
                elseif strcmp(med,'ON') && strcmp(speed,'S')
                    APA_trials  = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30'};
                    triggers_i  = 1:30;
                elseif strcmp(med,'ON') && strcmp(speed,'R')
                    APA_trials  = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30'};
                    triggers_i  = 1:30;
                else
                    fprintf([' ! Trials for the condition ' med '_' speed ' for patient ' patient ' are not reported\n']);
                end
                
            case 'PASEL06'
                if     strcmp(med,'OFF') && strcmp(speed,'S')
                    APA_trials = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16'};
                    triggers_i  = 2:17;
                elseif strcmp(med,'OFF') && strcmp(speed,'R')
                    APA_trials = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15'};
                    triggers_i  = 1:15;
                elseif strcmp(med,'ON') && strcmp(speed,'S')
                    APA_trials = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15'};
                    triggers_i  = [1,3:16];
                elseif strcmp(med,'ON') && strcmp(speed,'R')
                    APA_trials = {'01','02','03','04','05','07','08','09','10','11','12','13'};
                    triggers_i  = [1:7,9:14];
                else
                    fprintf([' ! Trials for the condition ' med '_' speed ' for patient ' patient ' are not reported\n']);
                end
                
            case 'ParkPitie_2013_06_06_SOj'
                if     strcmp(med,'OFF') && strcmp(speed,'S')
                    APA_trials  = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19'};
                    step_badTrials = {'01'};
                    triggers_i  = 1:19;
                elseif strcmp(med,'OFF') && strcmp(speed,'R')
                    APA_trials  = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25'};
                    triggers_i  = 1:25;
                elseif     strcmp(med,'OFF') && strcmp(speed,'AI')
                    APA_trials  = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','16','17','18','19','21'};
                    triggers_i  = [1:14,16:19,21];
                elseif strcmp(med,'ON') && strcmp(speed,'S')
                    APA_trials  = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','16','17','18','19','21'};
                    step_badTrials = {'15','18'};
                    triggers_i  = [1:14,16:19,21];
                elseif strcmp(med,'ON') && strcmp(speed,'R')
                    APA_trials  = {'01','04','06'};
                    step_badTrials = {'05'};
                    triggers_i  = [1,4,6];
                elseif     strcmp(med,'ON') && strcmp(speed,'AI')
                    APA_trials  = {'01','04','05','07','08','09','10','13'};
                    triggers_i  = [1,4,5,7,8,9,10,13];
                else
                    fprintf([' ! Trials for the condition ' med '_' speed ' for patient ' patient ' are not reported\n']);
                end
                
            case 'ParkPitie_2013_10_10_COd'
                if     strcmp(med,'OFF') && strcmp(speed,'S')
                    APA_trials = {'01','02','03','04','05','06','07','08','09','10','11','13','14','16','17','18','19','20','21','22','23'};
                    step_badTrials = {'14'};
                    triggers_i  = [1:11,13:14,16:23];
                elseif strcmp(med,'OFF') && strcmp(speed,'R')
                    APA_trials = {'01','02','04','05','06','07','08','09','10','11','12','13','14','15'};
                    step_badTrials = {'01'};
                    triggers_i  = 1:14;
                elseif     strcmp(med,'OFF') && strcmp(speed,'AI')
                    APA_trials = {'22','23','25','27','28','30','31','32','33','34','35'};
                    triggers_i  = [1,2,4,6,7,9:14];
                elseif strcmp(med,'ON') && strcmp(speed,'S')
                    APA_trials = {'01','02','03','04','05','07','08','09','10','11','12','13','20','21','22','23','24'};
                    step_badTrials = {'15'};
                    triggers_i  = [1:5,6:12,15:19];
                elseif strcmp(med,'ON') && strcmp(speed,'R')
                    APA_trials  = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','16','17','18','19','20'};
                    triggers_i  = [1:14,16:20];
                elseif     strcmp(med,'ON') && strcmp(speed,'AI')
                    APA_trials = {'03','07','10','11','13','14','16','17','20','21'};
                    triggers_i  = [1,6,9,10,11,12,14,15,18,19];
                else
                    fprintf([' ! Trials for the condition ' med '_' speed ' for patient ' patient ' are not reported\n']);
                end
                
            case 'ParkPitie_2013_10_17_FRl'
                if     strcmp(med,'OFF') && strcmp(speed,'S')
                    APA_trials = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25'};
                    triggers_i  = 1:25;
                elseif strcmp(med,'OFF') && strcmp(speed,'R')
                    APA_trials = {'01','02','03','04','05','06','07','08','09','12','13','14','15','16','17','18','19','20','21','22','23'};
                    triggers_i  = [1:9,12:23];
                elseif strcmp(med,'ON') && strcmp(speed,'S')
                    APA_trials = {'01','02','03','04','05','06','07','09','10','11','12','13','14','15','16','18','19','20','21','22','24','25','26','27'};
                    triggers_i  = [1:7,9:25];
                elseif strcmp(med,'ON') && strcmp(speed,'R')
                    APA_trials = {'01','02','03'};
                    triggers_i  = 1:3;
                else
                    fprintf([' ! Trials for the condition ' med '_' speed ' for patient ' patient ' are not reported\n']);
                end
                
                
            case 'ParkPitie_2013_10_24_CLn'
                if strcmp(condition, 'Normal')
                    if     strcmp(med,'OFF') && strcmp(speed,'S')
                        APA_trials  = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','20','21','22','23'};
                        step_badTrials = {'24','25','26','27'};
                        triggers_i  = [1:18,20:23];
                    elseif strcmp(med,'OFF') && strcmp(speed,'R')
                        APA_trials  = {'01','04','08','09','10','11','12','13','14','15','18','20','21','22','24','25','26','27','28','29','30','31','32','33','34'};
                        step_badTrials  = {'16','17','19','23'};
                        triggers_i  = [1,4,8:15,18,20:22,24:34];
                    elseif     strcmp(med,'OFF') && strcmp(speed,'AI')
                        APA_trials = {'02','04','05','06','07'};
                        triggers_i  = [2,4,5,6,7];
                    elseif strcmp(med,'ON') && strcmp(speed,'S')
                        APA_trials  = {'01','02','03','05','06','07','08','09','10','11','12','13','14','15','16','17','18','21','22','23','24','25','27','28','29','30','31'};
                        step_badTrials = {'04','19','20','26'};
                        triggers_i  = [1:3,5:18,21:25,27:31];
                    elseif strcmp(med,'ON') && strcmp(speed,'R')
                        APA_trials  = {'01','02','03','05','06','07','08','09','10','11','12','14','15','16','18','21','22','23','24'};
                        step_badTrials = {'04','17','18','20'};
                        triggers_i  = [1:3,5:12,14:21];
                    elseif     strcmp(med,'ON') && strcmp(speed,'AI')
                        APA_trials = {'03','05','07','12','13','17','21','23','24','25'};
                        triggers_i  = [11,13,15,20,21,25,28,30,31,32];
                    else
                        fprintf([' ! Trials for the condition ' med '_' speed ' for patient ' patient ' are not reported\n']);
                    end
%                 elseif strcmp(condition, 'Freezing')
%                     if   strcmp(med,'OFF') && strcmp(speed,'S')
%                         APA_trials  = {'19','25','27'};
%                         triggers_i  = [19,25,27];
%                     elseif strcmp(med,'OFF') && strcmp(speed,'R')
%                         APA_trials  = {'03','05','06','07'};
%                         triggers_i  = [3,5:7];
%                     elseif strcmp(med,'OFF') && strcmp(speed,'AI')
%                         APA_trials  = {'01','08','09'};
%                         triggers_i  = [1,8,9];
%                     elseif strcmp(med,'ON') && strcmp(speed,'S')
%                         APA_trials  = {};
%                         triggers_i  = [];
%                     elseif strcmp(med,'ON') && strcmp(speed,'R')
%                         APA_trials  = {};
%                         triggers_i  = [];
%                     else
%                         fprintf([' ! Trials for the condition ' med '_' speed ' for patient ' patient ' are not reported\n']);
%                     end
                elseif strcmp(condition, 'Freezing')
                    if     strcmp(med,'OFF') && strcmp(speed,'S')
                        APA_trials  = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','25','27'};
                        triggers_i  = [1:23,25,27];
                    elseif strcmp(med,'OFF') && strcmp(speed,'R')
                        APA_trials  = {'01','03','04','05','06','07','08','09','10','11','12','13','14','15','18','20','21','22','24','25','26','27','28','29','30','31','32','33','34'};
                        triggers_i  = [1,3:15,18,20:22,24:34];
                    elseif     strcmp(med,'OFF') && strcmp(speed,'AI')
                        APA_trials = {'02','04','05','06','07'};
                        triggers_i  = [2,4,5,6,7];
                    elseif strcmp(med,'ON') && strcmp(speed,'S')
                        APA_trials  = {'01','02','03','05','06','07','08','09','10','11','12','13','14','15','16','17','18','21','22','23','24','25','27','28','29','30','31'};
                        triggers_i  = [1:3,5:18,21:25,27:31];
                    elseif strcmp(med,'ON') && strcmp(speed,'R')
                        APA_trials  = {'01','02','03','05','06','07','08','09','10','11','12','14','15','16','18','21','22','23','24'};
                        triggers_i  = [1:3,5:12,14:21];
                    elseif     strcmp(med,'ON') && strcmp(speed,'AI')
                        APA_trials = {'03','05','07','12','13','17','21','23','24','25'};
                        triggers_i  = [11,13,15,20,21,25,28,30,31,32];
                    else
                        fprintf([' ! Trials for the condition ' med '_' speed ' for patient ' patient ' are not reported\n']);
                    end
                end
                
            case 'ParkPitie_2014_04_18_MAd'
                if     strcmp(med,'OFF') && strcmp(speed,'S')
                    APA_trials  = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21'};
                    triggers_i  = 1:21;
                elseif strcmp(med,'OFF') && strcmp(speed,'R')
                    APA_trials  = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21'};
                    triggers_i  = 1:21;
                elseif strcmp(med,'ON') && strcmp(speed,'S')
                    APA_trials  = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22'};
                    step_badTrials = {'21'};
                    triggers_i  = 1:22;
                elseif strcmp(med,'ON') && strcmp(speed,'R')
                    APA_trials  = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22'};
                    triggers_i  = 1:22;
                else
                    fprintf([' ! Trials for the condition ' med '_' speed ' for patient ' patient ' are not reported\n']);
                end
                
            case 'ROUDO14'
                if strcmp (condition, 'Normal')
                    if     strcmp(med,'OFF') && strcmp(speed,'S')
                        APA_trials  = {'02','03','04','05','06','07','08','09','10','11','13','14','15','17','18','19','20'};
                        triggers_i  = [2:11,13:15,17:20];
                    elseif strcmp(med,'OFF') && strcmp(speed,'R')
                        APA_trials = {'01','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22'};
                        triggers_i  = 1:21;
                    elseif strcmp(med,'ON') && strcmp(speed,'S')
                        APA_trials = {'02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24'};
                        triggers_i  = 2:24;
                    elseif strcmp(med,'ON') && strcmp(speed,'R')
                        APA_trials = {'01','02','03','05','06','07','08','10','11','12','13','14','15','16','17','19','20','22','23','24','25'};
                        triggers_i  = [1:3,5:8,10:23];
                    else
                        fprintf([' ! Trials for the condition ' med '_' speed ' for patient ' patient ' are not reported\n']);
                    end
                elseif strcmp(condition, 'Freezing')
                    if strcmp(med,'OFF') && strcmp(speed,'S')
                        APA_trials  = {'01','08','11','12','13','16'};
                        triggers_i  = [1,8,11,12,13,16];
                    elseif strcmp(med,'OFF') && strcmp(speed,'R')
                        APA_trials  = {'06','07','08'};
                        triggers_i  = [5,6,7];
                    else
                        fprintf([' ! Trials for the condition ' med '_' speed ' for patient ' patient ' are not reported\n']);
                    end
                end
                
            case 'ParkPitie_2014_06_19_LEc'
                if     strcmp(med,'OFF') && strcmp(speed,'S')
                    APA_trials  = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25'};
                    step_badTrials = {'01','06','07','08'};
                    triggers_i  = 1:25;
                elseif strcmp(med,'OFF') && strcmp(speed,'R')
                    APA_trials  = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','21','22'};
                    triggers_i  = 1:21;
                elseif strcmp(med,'ON') && strcmp(speed,'S')
                    APA_trials  = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23'};
                    triggers_i  = 1:23;
                elseif strcmp(med,'ON') && strcmp(speed,'R')
                    APA_trials  = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19'};
                    triggers_i  = 1:19;
                else
                    fprintf([' ! Trials for the condition ' med '_' speed ' for patient ' patient ' are not reported\n']);
                end
                
            case 'CALVI17'
                if     strcmp(med,'OFF') && strcmp(speed,'S')
                    APA_trials  = {'03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25'};
                    triggers_i  = 1:23;
                elseif strcmp(med,'OFF') && strcmp(speed,'R')
                    APA_trials  = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24'};
                    triggers_i  = 1:24;
                elseif strcmp(med,'ON') && strcmp(speed,'S')
                    APA_trials  = {'01','02','04','05','06','07','08','09','10','13','15','16','17','18','19','20','21','22','24','25','26'};
                    triggers_i  = 1:21;
                elseif strcmp(med,'ON') && strcmp(speed,'R')
                    APA_trials  = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24'};
                    triggers_i  = 1:24;
                else
                    fprintf([' ! Trials for the condition ' med '_' speed ' for patient ' patient ' are not reported\n']);
                end
                
            case 'BAUMA18'
                if     strcmp(med,'OFF') && strcmp(speed,'S')
                    APA_trials  = {'01','02','03','04','05','06','07','08','09','10','13','14','15','16','17','18','19','20','21','22'};
                    triggers_i  = 1:20;
                elseif strcmp(med,'OFF') && strcmp(speed,'R')
                    APA_trials  = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20'};
                    triggers_i  = 1:20;
                elseif strcmp(med,'ON') && strcmp(speed,'S')
                    APA_trials  = {'01','03','05','06','07','08','09','10','11','12','13','14','15','17','18','19','20'};
                    triggers_i  = [1,2,4:14,16:19];
                elseif strcmp(med,'ON') && strcmp(speed,'R')
                    APA_trials  = {'01','02','03','06','08','10','12','13','14','15','16','17','18','19','20'};
                    triggers_i  = [1:4,6,8,10:18];
                else
                    fprintf([' ! Trials for the condition ' med '_' speed ' for patient ' patient ' are not reported\n']);
                end
                
            case 'ParkPitie_2015_01_15_MEp'
                if     strcmp(med,'OFF') && strcmp(speed,'S')
                    APA_trials = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20'};
                    triggers_i  = 1:20;
                elseif strcmp(med,'OFF') && strcmp(speed,'R')
                    APA_trials = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20'};
                    triggers_i  = 1:20;
                elseif strcmp(med,'ON') && strcmp(speed,'S')
                    APA_trials = {'22','23','24','25','26','27','28','29','30','31','32','33','34','35','36','38','39','40'};
                    triggers_i  = [2:19];
                elseif strcmp(med,'ON') && strcmp(speed,'R')
                    APA_trials = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20'};
                    triggers_i  = [1:20];
                else
                    fprintf([' ! Trials for the condition ' med '_' speed ' for patient ' patient ' are not reported\n']);
                end
                
            case 'ARDSY20'
                if     strcmp(med,'OFF') && strcmp(speed,'S')
                    APA_trials = {'01','02','03','04','05','06','07','08','09','10','12','13','14','15','16','17','18','19','20','21','22','23','24','25'};
                    triggers_i  = [1:10,12:25];
                elseif strcmp(med,'OFF') && strcmp(speed,'R')
                    APA_trials = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20'};
                    triggers_i  = 1:20;
                elseif strcmp(med,'ON') && strcmp(speed,'S')
                    APA_trials = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14'};
                    triggers_i  = 1:14;
                else
                    fprintf([' ! Trials for the condition ' med '_' speed ' for patient ' patient ' are not reported\n']);
                end
                
            case 'ParkPitie_2015_03_05_RAt'
                if     strcmp(med,'OFF') && strcmp(speed,'S')
                    APA_trials = {'01','02','03','04','05','06','07','08','10','11','12','13','14','15','16','17','18','19','20'};
                    step_badTrials = {'06','07','08','09','11'};
                    triggers_i  = [1:8,10:20];
                elseif strcmp(med,'OFF') && strcmp(speed,'R')
                    APA_trials = {'01','02','03','04','05','06','07','08','10','11','12','13','14','15','16','17','18','19','20'};
                    step_badTrials = {'04','08','19','20'};
                    triggers_i  = 1:19;
                elseif strcmp(med,'OFF') && strcmp(speed,'AI')
                    APA_trials = {'04','05','07','08','09','13','14','15'};
                    triggers_i  = [5,6,8,9,10,14,15,16];
                elseif strcmp(med,'OFF') && strcmp(speed,'CLOCHE')
                    APA_trials = {'02','03','04','05','06','07','08','09','10'};
                    triggers_i  = 2:10;
                elseif strcmp(med,'ON') && strcmp(speed,'S')
                    APA_trials = {'01','02','03','04','05','06','07','08','10','11','12','13','14','15','16','17','18','19','20'};
                    step_badTrials = {'02','03','04','05','06','08'};
                    triggers_i  = [1:8,10:20];
                elseif strcmp(med,'ON') && strcmp(speed,'R')
                    APA_trials = {'02','03','04','05','06','07','09','10','11','12','13','14','15','17','19'};
                    step_badTrials = {'05','08','10','14','16','18'};
                    triggers_i  = [2:14,16,18];
                elseif strcmp(med,'ON') && strcmp(speed,'CLOCHE')
                    APA_trials = {'01','02','03','04','05','06','07','08','09','10'};
                    triggers_i  = 1:10;
                else
                    fprintf([' ! Trials for the condition ' med '_' speed ' for patient ' patient ' are not reported\n']);
                end
                
            case 'ParkPitie_2015_04_30_VAp'
                if     strcmp(med,'OFF') && strcmp(speed,'S')
                    APA_trials  = {'02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22'};
                    step_badTrials = {'01'};
                    triggers_i  = 2:22;
                elseif strcmp(med,'OFF') && strcmp(speed,'R')
                    APA_trials  = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20'};
                    triggers_i  = 1:20;
                elseif strcmp(med,'OFF') && strcmp(speed,'AI')
                    APA_trials  = {'03','04','06','07','09'};
                    triggers_i  = [5,6,8,9,11];
                elseif strcmp(med,'OFF') && strcmp(speed,'CLOCHE')
                    APA_trials = {'01','02','03','04','05','06','07','08','09','10'};
                    triggers_i  = 1:10;
                elseif strcmp(med,'ON') && strcmp(speed,'S')
                    APA_trials  = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','19','20'};
                    step_badTrials = {'01','02','04','05','06','07','08','10','11','12'};
                    triggers_i  = 1:19;
                elseif strcmp(med,'ON') && strcmp(speed,'R')
                    APA_trials  = {'01','02','03','04','05','06','07','08','09','10','11','12','14','15','16','17','18','20'};
                    step_badTrials = {'13'};
                    triggers_i  = 1:18;
                elseif strcmp(med,'ON') && strcmp(speed,'CLOCHE')
                    APA_trials = {'01','02','03','04','05','06','07','09'};
                    triggers_i  = 1:8;
                else
                    fprintf([' ! Trials for the condition ' med '_' speed ' for patient ' patient ' are not reported\n']);
                end
                
            case 'ParkPitie_2015_05_28_DEm'
                if     strcmp(med,'OFF') && strcmp(speed,'S')
                    APA_trials  = {'01','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20'};
                    step_badTrials = {'01'};
                    triggers_i  = [1,3:20];
                elseif strcmp(med,'OFF') && strcmp(speed,'R')
                    APA_trials  = {'01','02','03','04','05','06','08','09','10','11','12','13','14','15','16','17','18','19'};
                    triggers_i  = 1:18;
                elseif strcmp(med,'OFF') && strcmp(speed,'AI')
                    APA_trials  = {'07','09','10'};
                    triggers_i  = [1,3,4];
                elseif strcmp(med,'ON') && strcmp(speed,'S')
                    APA_trials  = {'02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20'};
                    triggers_i  = 2:20;
                elseif strcmp(med,'ON') && strcmp(speed,'R')
                    APA_trials  = {'01','02','03','04','05','06','07','08','09'};
                    triggers_i  = 21:29;
                else
                    fprintf([' ! Trials for the condition ' med '_' speed ' for patient ' patient ' are not reported\n']);
                end
                
            case 'ParkPitie_2015_10_01_SAj'
                if strcmp(condition, 'Normal')
                    if     strcmp(med,'OFF') && strcmp(speed,'S')
                        APA_trials  = {'01','02','03','05','06','07','08','09','10','11','12','13','14','15'};
                        triggers_i  = [1:3,5:15];
                    elseif strcmp(med,'OFF') && strcmp(speed,'R')
                        APA_trials  = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20'};
                        step_badTrials = {'13'};
                        triggers_i  = 1:20;
                    elseif strcmp(med,'OFF') && strcmp(speed,'AI')
                        APA_trials  = {'02','04','05','06','09'};
                        triggers_i  = [2,4:6,8];
                    elseif strcmp(med,'ON') && strcmp(speed,'S')
                        APA_trials  = {'01','02','03','04','05','06','07','08','09','10','11','13','14','15','16','17','18','19','20'};
                        step_badTrials = {'12'};
                        triggers_i  = [1:11,13:20];
                    elseif strcmp(med,'ON') && strcmp(speed,'R')
                        APA_trials  = {'02','03','04','05','07','08','09','10','11','12','13','14','15','16','17','18','19','20'};
                        triggers_i  = 2:19;
                    else
                        fprintf([' ! Trials for the condition ' med '_' speed ' for patient ' patient ' are not reported\n']);
                    end
%                 elseif strcmp(condition,'Freezing')
%                     if strcmp(med,'OFF') && strcmp(speed,'S')
%                         APA_trials  = {};
%                         triggers_i  = [];
%                     elseif strcmp(med,'OFF') && strcmp(speed,'R')
%                         APA_trials  = {'11','13','14','15','16','17'};
%                         triggers_i  = [11,13:17];
%                     elseif strcmp(med,'OFF') && strcmp(speed,'AI')
%                         APA_trials  = {'03'};
%                         triggers_i  = 3;
%                     elseif strcmp(med,'ON') && strcmp(speed,'S')
%                         APA_trials  = {};
%                         triggers_i  = [];
%                     elseif strcmp(med,'ON') && strcmp(speed,'R')
%                         APA_trials  = {};
%                         triggers_i  = [];
%                     else
%                         fprintf([' ! Trials for the condition ' med '_' speed ' for patient ' patient ' are not reported\n']);
%                     end
%                 end
                elseif strcmp(condition,'Freezing')
                    if     strcmp(med,'OFF') && strcmp(speed,'S')
                        APA_trials  = {'01','02','03','05','06','07','08','09','10','11','12','13','14','15'};
                        triggers_i  = [1:3,5:15];
                    elseif strcmp(med,'OFF') && strcmp(speed,'R')
                        APA_trials  = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20'};
                        triggers_i  = 1:20;
                    elseif strcmp(med,'OFF') && strcmp(speed,'AI')
                        APA_trials  = {'02','04','05','06','09'};
                        triggers_i  = [2,4:6,8];
                    elseif strcmp(med,'ON') && strcmp(speed,'S')
                        APA_trials  = {'02','03','04','05','06','07','08','09','10','11','13','14','15','16','17','18','19','20'};
                        triggers_i  = [2:11,13:20];
                    elseif strcmp(med,'ON') && strcmp(speed,'R')
                        APA_trials  = {'02','03','04','05','07','08','09','10','11','12','13','14','15','16','17','18','19','20'};
                        triggers_i  = 2:19;
                    else
                        fprintf([' ! Trials for the condition ' med '_' speed ' for patient ' patient ' are not reported\n']);
                    end
                end
            otherwise
                error([patient ' is an unknown patient']);
                
        end
        
    case 'STOC2'
        
        switch patient
            
            case 'LAHFR01'
                if     strcmp(med,'OFF') && strcmp(speed,'S')
                    APA_trials  = {'01','02','03','04','05','06','07','08','09','11','12','13','14','15','16','18','19','20'};
                    triggers_i  = 1:18;
                elseif strcmp(med,'OFF') && strcmp(speed,'R')
                    APA_trials  = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20'};
                    triggers_i  = 1:20;
                else
                    fprintf([' ! Trials for the condition ' med '_' speed ' for patient ' patient ' are not reported\n']);
                end
                
            case 'PIRDI05'
                if     strcmp(med,'OFF') && strcmp(speed,'S')
                    APA_trials  = {'02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20'};
                    triggers_i  = 2:20;
                elseif strcmp(med,'OFF') && strcmp(speed,'R')
                    APA_trials  = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20'};
                    triggers_i  = 1:20;
                else
                    fprintf([' ! Trials for the condition ' med '_' speed ' for patient ' patient ' are not reported\n']);
                end
                
            case 'BALBR06'
                if     strcmp(med,'OFF') && strcmp(speed,'S')
                    APA_trials  = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20'};
                    triggers_i  = 1:20;
                elseif strcmp(med,'OFF') && strcmp(speed,'R')
                    APA_trials  = {'03','04','05','06','07','08','09','10','12','13','14','16','17','18','19','20','21','22'};
                    triggers_i  = 3:20;
                else
                    fprintf([' ! Trials for the condition ' med '_' speed ' for patient ' patient ' are not reported\n']);
                end
                
            case 'BENKA06'
                if     strcmp(med,'OFF') && strcmp(speed,'S')
                    APA_trials  = {'01','02','03','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20'};
                    triggers_i  = 1:19;
                elseif strcmp(med,'OFF') && strcmp(speed,'R')
                    APA_trials  = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20'};
                    triggers_i  = 1:20;
                elseif strcmp(med,'OFF') && strcmp(speed,'cloche')
                    APA_trials  = {'01','02','03','04','05','06','07','08','09','10','11','12','14','15','16','17','18','19','20','21'};
                    triggers_i  = 1:20;
                else
                    fprintf([' ! Trials for the condition ' med '_' speed ' for patient ' patient ' are not reported\n']);
                end
                
            otherwise
                error([patient ' is an unknown patient']);
                
        end
        
    case 'TCMOV'
        
        switch patient
            
            case 'LOUST01'
                if     strcmp(speed,'S')
                    APA_trials  = {'02','03','05','06','08','09','10','13','15','18','19','20'};
                    triggers_i  = [2,3,5,6,8,9,10,13,15,18,19,20];
                elseif strcmp(speed,'R')
                    APA_trials  = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','21'};
                    triggers_i  = [1:19,21];
                else
                    fprintf([' ! Trials for the condition ' med '_' speed ' for patient ' patient ' are not reported\n']);
                end
                
            case 'MORLO02'
                if     strcmp(speed,'S')
                    APA_trials  = {'01','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25'};
                    triggers_i  = [1,3:25];
                elseif strcmp(speed,'R')
                    APA_trials  = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25'};
                    triggers_i  = 1:25;
                else
                    fprintf([' ! Trials for the condition ' med '_' speed ' for patient ' patient ' are not reported\n']);
                end
                
            case 'MUSSI03'
                if     strcmp(speed,'S')
                    APA_trials  = {'01','02','03','05','06','07','08','09','10','11','12','13','15','16','17','18','20'};
                    triggers_i  = [1:3,5:13,15:18,20];
                elseif strcmp(speed,'R')
                    APA_trials  = {'05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27'};
                    triggers_i  = 5:27;
                else
                    fprintf([' ! Trials for the condition ' med '_' speed ' for patient ' patient ' are not reported\n']);
                end
                
            case 'SEBBA04'
                if     strcmp(speed,'S')
                    APA_trials  = {'01','02','03','04','05','06'};
                    triggers_i  = 1:6;
                else
                    fprintf([' ! Trials for the condition ' med '_' speed ' for patient ' patient ' are not reported\n']);
                end
        end
        
    otherwise
        error([protocol ' is an unknown protocol']);
        
end
