% TODO:
% changes in excel file:
%   patID
%   cond names


function trials_table = read_trial_rejection(rejection_file)

reject_data = readtable(rejection_file, 'ReadVariableNames', 0, 'Format','auto');
pat_list    = table2cell(unique([reject_data(3:end,1)]));
pat_list    = pat_list(cellfun(@(x) ~isempty(x), pat_list));

trials_table = table;
t_count = 0;

for p = 1 : numel(pat_list)
    patID     = pat_list{p};
    idx_patID = find(strcmp(reject_data{:,1}, patID) == 1);

    for t = 1:numel(idx_patID)
        med     = reject_data{idx_patID(t),2};
        run     = reject_data{idx_patID(t),3};
        ntrial  = reject_data{idx_patID(t),4}; %{1}(2:end);
        
        for ch_cond = 5:size(reject_data,2)
            ch   = reject_data{1,ch_cond};
            sgt  = reject_data{2,ch_cond};
%             if strcmp(reject_data{idx_patID(t),ch_cond}, 'N') || strcmp(reject_data{idx_patID(t),ch_cond}, '1')
            if strcmp(reject_data{idx_patID(t),ch_cond}, 'X')
                t_count = t_count + 1;
                trials_table.patient{t_count}       = patID;
                trials_table.Medication{t_count}    = med;
                trials_table.run{t_count}           = run;
                trials_table.nTrial{t_count}        = ntrial;
                trials_table.Channel{t_count}       = ch;
                trials_table.Segment{t_count}       = sgt; % rest, door, gait or end
                trials_table.quality{t_count}       = 0;
            end            
        end
    end
    
end
