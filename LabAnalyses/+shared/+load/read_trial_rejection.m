% TODO:
% changes in excel file:
%   patID
%   cond names


function trials_table = read_trial_rejection(rejection_file)

reject_data = readtable(rejection_file, 'ReadVariableNames', 0, 'Format','auto');
pat_list    = table2cell(unique([reject_data(3:end,1)]));
pat_list    = pat_list(cellfun(@(x) ~isempty(x), pat_list));
warning('off','MATLAB:table:RowsAddedExistingVars')

trials_table = table;
t_count = 0;

for p = 1 : numel(pat_list)
    patID     = pat_list{p};
    idx_patID = find(strcmp(reject_data{:,1}, patID) == 1);

    for t = 1:numel(idx_patID)
        med     = reject_data{idx_patID(t),2};
        ntrial  = reject_data{idx_patID(t),3};
      
        for ch_cond = 4:size(reject_data,2)
            ch   = reject_data{1,ch_cond};
            cond = reject_data{2,ch_cond};
            if isempty(reject_data{idx_patID(t),ch_cond}) 
                chartotest = 'pass';
            else
                chartotest = cell2mat(reject_data{idx_patID(t),ch_cond}) ;
            end

            if strcmp(reject_data{idx_patID(t),ch_cond}, 'N')
                t_count = t_count + 1;
                trials_table.patient{t_count}       = patID;
                trials_table.Medication{t_count}    = med;
                trials_table.nTrial{t_count}        = ntrial;
                trials_table.Channel{t_count}       = ch;
                trials_table.Condition{t_count}     = cond; % APA, step, turn or FOG
                trials_table.quality{t_count}       = 0;
            elseif strcmp(reject_data{idx_patID(t),ch_cond}, 'a')
                t_count = t_count + 1;
                trials_table.patient{t_count}       = patID;
                trials_table.Medication{t_count}    = med;
                trials_table.nTrial{t_count}        = ntrial;
                trials_table.Channel{t_count}       = ch;
                trials_table.Condition{t_count}     = cond; % APA, step, turn or FOG
                trials_table.quality{t_count}       = 0;
            elseif ~isempty(chartotest) && strcmp(chartotest(1), '>')
                t_count = t_count + 1;
                trials_table.patient{t_count}       = patID;
                trials_table.Medication{t_count}    = med;
                trials_table.nTrial{t_count}        = ntrial;
                trials_table.Channel{t_count}       = ch;
                trials_table.Condition{t_count}     = cond; % APA, step, turn or FOG
                trials_table.quality{t_count}       = 0;
            end            
        end
    end
end
warning('on','MATLAB:table:RowsAddedExistingVars') 
