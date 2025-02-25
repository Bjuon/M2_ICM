function segmentViconRecording(APA)
% SEGMENTVICONRECORDING Segments a Vicon recording based on timestamps
% provided in a CSV file and saves each trial in the subfolder 'segment_vicon'.
%
% Usage:
%   segmentViconRecording(APA)
%
% The CSV file should have columns 'StartTime' and 'EndTime' indicating the
% beginning and ending times (in seconds) of each trial.

    % Ask user to select the CSV file with timestamps.
    [csvFile, csvPath] = uigetfile('*.csv', 'Select CSV file with timestamps');
    if isequal(csvFile, 0)
        disp('CSV file selection canceled.');
        return;
    end
    csvFilePath = fullfile(csvPath, csvFile);
    
    % Read the CSV file into a table.
    timestampsTable = readtable(csvFilePath);
    
    % Validate that required columns exist.
    if ~all(ismember({'StartTime','EndTime'}, timestampsTable.Properties.VariableNames))
        error('CSV file must contain columns "StartTime" and "EndTime".');
    end
    
    % Create the output folder 'segment_vicon' if it does not exist.
    outputDir = fullfile(pwd, 'segment_vicon');
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end
    
    % Check that APA structure has the expected Vicon data.
    if ~isfield(APA, 'Vicon') || ~isfield(APA.Vicon, 'Time')
        error('The APA structure must contain Vicon data with a Time field.');
    end
    viconData = APA.Vicon;
    timeVec = viconData.Time;
    
    % Loop through each timestamp row to segment the recording.
    for i = 1:height(timestampsTable)
        startTime = timestampsTable.StartTime(i);
        endTime   = timestampsTable.EndTime(i);
        
        % Find indices corresponding to the segment.
        idx = find(timeVec >= startTime & timeVec <= endTime);
        if isempty(idx)
            warning('No data found between %f and %f seconds.', startTime, endTime);
            continue;
        end
        
        % Create a new structure for the segmented data.
        segmentData = struct();
        segmentData.Time = timeVec(idx);
        
        % Loop through each field in viconData to segment them if time-dimension matches.
        fields = fieldnames(viconData);
        for j = 1:length(fields)
            fieldName = fields{j};
            if strcmp(fieldName, 'Time')
                continue;
            end
            fieldData = viconData.(fieldName);
            % Assume the time dimension is along columns.
            if isnumeric(fieldData) && size(fieldData,2) == length(timeVec)
                segmentData.(fieldName) = fieldData(:,idx);
            else
                % Otherwise, copy the field unchanged.
                segmentData.(fieldName) = fieldData;
            end
        end
        
        % Save the segmented trial in the output folder.
        segmentFileName = fullfile(outputDir, sprintf('trial_%d.mat', i));
        save(segmentFileName, 'segmentData');
        fprintf('Segment %d saved to: %s\n', i, segmentFileName);
    end
end

