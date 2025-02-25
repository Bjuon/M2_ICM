

%% Initialize

%Load file
InputTable = readtable("\\l2export\iss02.pf-marche\02_protocoles_data\02_Protocoles_Data\MAGIC\04_Traitement\Patients\Marche_10_patients.csv") ;
Output = zeros(height(InputTable),4) ;


for row = 1:height(InputTable)

    if InputTable{row,7} >= 1
        
        %% find file
        if strcmp(InputTable{row,2}, 'GUG')
            patname = 'GUG' ;
        else
            patname = InputTable{row,2} ;
            patname = cell2mat(patname) ;
            patname = [patname(1:2) lower(patname(3))] ;
        end
    
        patdir = (['\\l2export\iss02.pf-marche\02_protocoles_data\02_Protocoles_Data\MAGIC\04_Traitement\Patients\' patname '\']);
        files = dir([patdir '\**\*' num2str(InputTable{row,5}) '.c3d']) ;
        
        matching_name = '';
        for i = 1:length(files)
            if strcmpi(files(i).name, [cell2mat(InputTable{row,1}) '.c3d'])
                matching_name = [files(i).folder filesep files(i).name];
                break;
            end
        end
        
        %% Number of FOG

        h = btkReadAcquisition(matching_name) ;
        Ev = btkGetEvents(h) ;

        %% for FOG, Where is it 
        walk = 0 ;
        beforeturn = 0 ;
        turn = 0 ;
        afterturn = 0 ;

        Start_turn = Ev.General_Start_Turn   ;
        End_turn = Ev.General_End_Turn   ;
        lastStepBeforeTurnR = NaN;
        for nstep = 1:length(Ev.Right_Foot_Off)
            if Ev.Right_Foot_Off(nstep) < Start_turn
                lastStepBeforeTurnR = Ev.Right_Foot_Off(nstep);
            else
                break;
            end
        end
        lastStepBeforeTurnL = NaN;
        for nstep = 1:length(Ev.Left_Foot_Off)
            if Ev.Left_Foot_Off(nstep) < Start_turn
                lastStepBeforeTurnL = Ev.Left_Foot_Off(nstep);
            else
                break;
            end
        end
        lastStepBeforeTurn = max(lastStepBeforeTurnL,lastStepBeforeTurnR);

        for nfog = 1:InputTable{row,7}
            Start_FOG = Ev.General_Start_FOG(nfog) ;
            End_FOG = Ev.General_End_FOG(nfog) ;

            % FOG number
            if Start_FOG > Start_turn && Start_FOG < End_turn
                turn = turn+1 ;
            elseif Start_FOG > End_turn 
                afterturn = afterturn+1 ;
            elseif Start_FOG < Start_turn && Start_FOG > lastStepBeforeTurn
                beforeturn = beforeturn+1 ;
            else
                walk = walk+1;
            end

            % Heatmap

        end

        Output(row,6) = walk ;
        Output(row,7) = beforeturn ;
        Output(row,8) = turn ;
        Output(row,9) = afterturn ;

        % Controle
        if walk+beforeturn+turn+afterturn ~= InputTable{row,7}
            warning([num2str(row) ' / ' matching_name])
        end

        %% Heatmap

    end
end

%% return nb FOG : walk, before1/2turn, 1/2turn, walkafterturn

disp('open Output variable')

%% return heatmap