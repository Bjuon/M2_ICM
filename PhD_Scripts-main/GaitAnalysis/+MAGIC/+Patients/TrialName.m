function [filename,outputArg2] = TrialName(Type, Date, Session , Patient , Cond , num_trial ,switchForFutureUpgrade)
    %TRIALNAME Summary of this function goes here
    %   Detailed explanation goes here
    

    if strcmp(Type,'GOGAIT') || strcmp(Type,'GAITPARK') || strcmp(Patient,'AUGAL37')  || strcmp(Patient,'PHIJE39') 
        if length(num_trial) == 3
            filename = [ Type '_'  Session '_'  Patient  '_'  Cond '_GNG_' num_trial(end-1:end) '.c3d'];
        elseif length(num_trial) == 2
            filename = [ Type '_'  Session '_'  Patient  '_'  Cond '_GNG_' num_trial            '.c3d'];
        end

    elseif strcmp(Type,'GBMOV_PPN')
        if length(num_trial) == 3
            filename = [ 'GAITPARK_'  Session '_'  Patient  '_'  Cond '_S_' num_trial(end-1:end) '.c3d'];
        elseif length(num_trial) == 2
            filename = [ 'GAITPARK_'  Session '_'  Patient  '_'  Cond '_S_' num_trial            '.c3d'];
        end
        
    else
        if strcmp(Patient,'GUG') || strcmp(Patient,'FRJ') || strcmp(Patient,'FRa')
            filename = ['ParkRouen_' Date '_'  Patient  '_' Type '_'  Session '_' Cond '_GNG_GAIT_' num_trial '.c3d'];
        else
            filename = ['ParkPitie_' Date '_'  Patient  '_' Type '_'  Session '_' Cond '_GNG_GAIT_' num_trial '.c3d'];
        end
    end
    
    if isstring(filename)
        filename = char(strjoin(filename,'')) ;
    end

 

    outputArg2 = switchForFutureUpgrade;
end

