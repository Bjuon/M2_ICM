
function AllPatMat = AddInfoInAllPatMat(AllPatMat, todo)

eventOfInterest     = {'CueOnSet', 'Reaction'}; % events of interest
conditions          = {'GoControl', 'GoMixte', 'NoGoMixte'};


for eV = 1:numel(eventOfInterest)
    idxCellNamesRow = find(strcmp(AllPatMat(eV).EvMat(1,:), 'CellName') == 1);
    AllCells = unique(AllPatMat(1).EvMat(2:end, idxCellNamesRow));
    idxCondition   =  find(strcmp(AllPatMat(eV).EvMat(1,:), 'Condition') == 1);
    
    %stats NoGo versus Go for GoNoGo condition
    if todo.StatNoGovsGoMix && eV == 1
        idxWinCueOnSet = find(strcmp(AllPatMat(eV).EvMat(1,:), 'mWinCueOnSet') == 1);
        idxWinCueOnSet = idxWinCueOnSet(3);
        
        
        for cell_count = 1 : numel(AllCells)
            idxCell      = find(strcmp(AllPatMat(eV).EvMat(:,idxCellNamesRow), AllCells(cell_count)) == 1);
            idxGoMixte   = find(strcmp(AllPatMat(eV).EvMat(idxCell,idxCondition), 'GoMixte') == 1); 
            idxNoGoMixte = find(strcmp(AllPatMat(eV).EvMat(idxCell,idxCondition), 'NoGoMixte') == 1); 
            
            if ~isempty(idxGoMixte) && ~isempty(idxNoGoMixte)
                p_ranksum = ranksum([AllPatMat(eV).EvMat{idxCell(idxGoMixte),idxWinCueOnSet}],[AllPatMat(eV).EvMat{idxCell(idxNoGoMixte),idxWinCueOnSet}]);
            else
                p_ranksum = NaN;
            end
            
            for c = 1 : numel(conditions)
                idxP_GoVsNoGo = find(strcmp(AllPatMat(eV).cond(c).infos(1,:), 'p_GoVsNoGo') == 1);
                if isempty(idxP_GoVsNoGo)
                    idxP_GoVsNoGo = numel(AllPatMat(eV).cond(c).infos(1,:)) + 1;
                    AllPatMat(eV).cond(c).infos{1,idxP_GoVsNoGo} = 'p_GoVsNoGo';
                end
                idxCellNamesRowCond = find(strcmp(AllPatMat(eV).cond(c).infos(1,:), 'CellName') == 1);
                idxCellCond         = find(strcmp(AllPatMat(eV).cond(c).infos(:,idxCellNamesRowCond), AllCells(cell_count)) == 1);
                
                if ~isempty(idxCellCond)
                    AllPatMat(eV).cond(c).infos{idxCellCond,idxP_GoVsNoGo} = p_ranksum;
                end
                
            end
        end
    end
    
    
    if todo.addBkOrder
        %%%%%trial/trial
        idxNbTrialreal = find(strcmp(AllPatMat(eV).EvMat(1,:), 'nbTrialReal') == 1);
        idxBlock = find(strcmp(AllPatMat(eV).EvMat(1,:), 'Block') == 1);
        if isempty(idxBlock)
            idxBlock = numel(AllPatMat(eV).EvMat(1,:)) + 1;
            AllPatMat(eV).EvMat{1,idxBlock} = 'Block';
        end
        
        %GoControl
        idxGoControl = find(strcmp(AllPatMat(eV).EvMat(:,idxCondition), 'GoControl') == 1);
        idxCtl1      = idxGoControl([AllPatMat(eV).EvMat{idxGoControl,idxNbTrialreal}] <= 10);
        idxCtl2      = idxGoControl([AllPatMat(eV).EvMat{idxGoControl,idxNbTrialreal}] >= 51);
        AllPatMat(eV).EvMat(idxCtl1,idxBlock) = num2cell(1 * ones(numel(idxCtl1),1));
        AllPatMat(eV).EvMat(idxCtl2,idxBlock) = num2cell(3 * ones(numel(idxCtl2),1));
        
        %GoMixte
        idxGoNoGo   = find(strcmp(AllPatMat(eV).EvMat(:,idxCondition), 'GoMixte')...
            | strcmp(AllPatMat(eV).EvMat(:,idxCondition), 'NoGoMixte') == 1);
        AllPatMat(eV).EvMat(idxGoNoGo,idxBlock) = num2cell(2 * ones(numel(idxGoNoGo),1));
        
        %exception
        %'ETIAl_STN_R_sec4_0.3'
        IdxExcept  = strcmpi(AllPatMat(eV).EvMat(:,2), 'ETIAl') & strcmp(AllPatMat(eV).EvMat(:,3), 'STN') ...
            & strcmp(AllPatMat(eV).EvMat(:,4), 'R') & strcmp(AllPatMat(eV).EvMat(:,5), 'sec4') ...
            & strcmp(AllPatMat(eV).EvMat(:,6), '0.3');
        
        idxExCtl2   = find(IdxExcept & strcmp(AllPatMat(eV).EvMat(:,idxCondition), 'GoControl') & ([NaN; [AllPatMat(eV).EvMat{2:end,idxNbTrialreal}]'] >= 11) == 1);
        AllPatMat(eV).EvMat(idxExCtl2,idxBlock) = num2cell(2 * ones(numel(idxExCtl2),1));
        
        idxExGoNoGo = find(IdxExcept & (strcmp(AllPatMat(eV).EvMat(:,idxCondition), 'GoMixte') | strcmp(AllPatMat(eV).EvMat(:,idxCondition), 'NoGoMixte'))== 1);
        AllPatMat(eV).EvMat(idxExGoNoGo,idxBlock) = num2cell(3 * ones(numel(idxExGoNoGo),1));
        
        %'FISOl_STN_L_sec12_0.77'
        IdxExcept  = strcmpi(AllPatMat(eV).EvMat(:,2), 'FISOl') & strcmp(AllPatMat(eV).EvMat(:,3), 'STN') ...
            & strcmp(AllPatMat(eV).EvMat(:,4), 'L') & strcmp(AllPatMat(eV).EvMat(:,5), 'sec12') ...
            & strcmp(AllPatMat(eV).EvMat(:,6), '0.77');

        idxExCtl1    = find(IdxExcept & strcmp(AllPatMat(eV).EvMat(:,idxCondition), 'GoControl') & ([NaN; [AllPatMat(eV).EvMat{2:end,idxNbTrialreal}]'] <= 20) == 1); %& ([AllPatMat(eV).EvMat{idxGoControl,idxNbTrialreal}] <= 20) == 1);
        AllPatMat(eV).EvMat(idxExCtl1,idxBlock) = num2cell(1 * ones(numel(idxExCtl1),1));
        
        idxExCtl2    = find(IdxExcept & strcmp(AllPatMat(eV).EvMat(:,idxCondition), 'GoControl') & ([NaN; [AllPatMat(eV).EvMat{2:end,idxNbTrialreal}]'] >= 61) == 1); %& ([AllPatMat(eV).EvMat{idxGoControl,idxNbTrialreal}] >= 61) == 1);
        AllPatMat(eV).EvMat(idxExCtl2,idxBlock) = num2cell(3 * ones(numel(idxExCtl2),1));
             

        %%%%%cell/cell 
        %GoControl
        c = 1;
        idxBlockCtl1 = find(strcmp(AllPatMat(eV).cond(c).infos(1,:), 'BlockCtl1') == 1);
        if isempty(idxBlockCtl1)
            idxBlockCtl1 = numel(AllPatMat(eV).cond(c).infos(1,:)) + 1;
            AllPatMat(eV).cond(c).infos{1,idxBlockCtl1} = 'BlockCtl1';
        end
        AllPatMat(eV).cond(c).infos(2:end,idxBlockCtl1) = num2cell(1 * ones(numel(idxBlockCtl1),1));        
       
        idxBlockCtl2 = find(strcmp(AllPatMat(eV).cond(c).infos(1,:), 'BlockCtl2') == 1);
        if isempty(idxBlockCtl2)
            idxBlockCtl2 = numel(AllPatMat(eV).cond(c).infos(1,:)) + 1;
            AllPatMat(eV).cond(c).infos{1,idxBlockCtl2} = 'BlockCtl2';
        end
        AllPatMat(eV).cond(c).infos(2:end,idxBlockCtl2) = num2cell(3 * ones(numel(idxBlockCtl1),1));
        
        %exception
        %'ETIAl_STN_R_sec4_0.3'
        IdxExcept  = strcmpi(AllPatMat(eV).cond(c).infos(:,2), 'ETIAl') & strcmp(AllPatMat(eV).cond(c).infos(:,3), 'STN') ...
            & strcmp(AllPatMat(eV).cond(c).infos(:,4), 'R') & strcmp(AllPatMat(eV).cond(c).infos(:,5), 'sec4') ...
            & strcmp(AllPatMat(eV).cond(c).infos(:,6), '0.3');
        
        AllPatMat(eV).cond(c).infos(IdxExcept,idxBlockCtl2) = num2cell(2 * ones(numel(idxBlockCtl1),1));
               
        %GoNoGoMixte
        for c = 2:3
            if eV == 2 && c == 3
                continue
            end
            idxGoNoGo = find(strcmp(AllPatMat(eV).cond(c).infos(1,:), 'Block') == 1);
            if isempty(idxGoNoGo)
                idxGoNoGo = numel(AllPatMat(eV).cond(c).infos(1,:)) + 1;
                AllPatMat(eV).cond(c).infos{1,idxGoNoGo} = 'Block';
            end
            AllPatMat(eV).cond(c).infos(2:end,idxGoNoGo) = num2cell(2 * ones(numel(idxBlockCtl1),1));
            
            %exception
            %'ETIAl_STN_R_sec4_0.3'
            IdxExcept  = strcmpi(AllPatMat(eV).cond(c).infos(:,2), 'ETIAl') & strcmp(AllPatMat(eV).cond(c).infos(:,3), 'STN') ...
                & strcmp(AllPatMat(eV).cond(c).infos(:,4), 'R') & strcmp(AllPatMat(eV).cond(c).infos(:,5), 'sec4') ...
                & strcmp(AllPatMat(eV).cond(c).infos(:,6), '0.3');
            
            AllPatMat(eV).cond(c).infos(IdxExcept,idxGoNoGo) = num2cell(3 * ones(numel(idxBlockCtl1),1));            
        end
    end
    
    
    
    %stats Ctl1 versus Ctl2 for GoControl condition
    if todo.StatCtl1vsCtl2 && eV == 1
        idxBlock = find(strcmp(AllPatMat(eV).EvMat(1,:), 'Block') == 1);
        idxGoControl = find(strcmp(AllPatMat(eV).EvMat(:,idxCondition), 'GoControl') == 1);
        idxmTrial = find(strcmp(AllPatMat(eV).EvMat(1,:), 'mTrial') == 1);

        for cell_count = 1 : numel(AllCells)
            idxCellCtl   = idxGoControl(strcmp(AllPatMat(eV).EvMat(idxGoControl,idxCellNamesRow), AllCells(cell_count)) == 1);
            nbBlockCtl   = sort(unique([AllPatMat(eV).EvMat{idxCellCtl,idxBlock}]));

            if numel(nbBlockCtl) == 2
                idxCtl1      = idxCellCtl([AllPatMat(eV).EvMat{idxCellCtl,idxBlock}] == nbBlockCtl(1));
                idxCtl2      = idxCellCtl([AllPatMat(eV).EvMat{idxCellCtl,idxBlock}] == nbBlockCtl(2));
                p_ranksum = ranksum([AllPatMat(eV).EvMat{idxCtl1,idxmTrial}],[AllPatMat(eV).EvMat{idxCtl2,idxmTrial}]);
            else
                p_ranksum = NaN;
            end
            
            for c = 1 : numel(conditions)
                idxP_Ctl1vsCtl2 = find(strcmp(AllPatMat(eV).cond(c).infos(1,:), 'p_Ctl1vsCtl2') == 1);
                if isempty(idxP_Ctl1vsCtl2)
                    idxP_Ctl1vsCtl2 = numel(AllPatMat(eV).cond(c).infos(1,:)) + 1;
                    AllPatMat(eV).cond(c).infos{1,idxP_Ctl1vsCtl2} = 'p_Ctl1vsCtl2';
                end
                idxCellNamesRowCond = find(strcmp(AllPatMat(eV).cond(c).infos(1,:), 'CellName') == 1);
                idxCellCond         = find(strcmp(AllPatMat(eV).cond(c).infos(:,idxCellNamesRowCond), AllCells(cell_count)) == 1);
                
                if ~isempty(idxCellCond)
                    AllPatMat(eV).cond(c).infos{idxCellCond,idxP_Ctl1vsCtl2} = p_ranksum;
                end
                
            end
        end
    end    
    
    
end

