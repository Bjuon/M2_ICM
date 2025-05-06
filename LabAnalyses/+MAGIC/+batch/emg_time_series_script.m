% -------------------------------------------------------------------------
% Extract ON/OFF C3D Time Series for Selected Patients
% -------------------------------------------------------------------------

% Add BTK path (adjust as needed)
addpath(genpath('C:\Path\To\BTK'));

% === CONFIGURATION ===
rootDir = 'F:\kinematics_MAGIC';

% >>> Define which patients to include (by folder name)
patientsToInclude = {'DEp'};  % <<< EDIT THIS LIST

% === Initialize ===
dataStruct = struct();
fCount = 0;

% === Loop over each selected patient folder ===
for p = 1:length(patientsToInclude)
    patientFolder = fullfile(rootDir, patientsToInclude{p});
    if ~isfolder(patientFolder)
        warning('⚠️ Folder not found: %s (skipped)', patientFolder);
        continue;
    end

    % Get ON and OFF C3D files
    c3d_ON  = dir(fullfile(patientFolder, '*ON*.c3d'));
    c3d_OFF = dir(fullfile(patientFolder, '*OFF*.c3d'));
    c3dFiles = [c3d_ON; c3d_OFF];

    for f = 1:length(c3dFiles)
        try
            c3dPath = fullfile(c3dFiles(f).folder, c3dFiles(f).name);
            c3dName = c3dFiles(f).name;

            % ----- Medication label -----
            if contains(c3dName, 'ON', 'IgnoreCase', true)
                label = 'ON';
            elseif contains(c3dName, 'OFF', 'IgnoreCase', true)
                label = 'OFF';
            else
                label = 'UNKNOWN';
            end

            % ----- Load C3D -----
            acq = btkReadAcquisition(c3dPath);

            % ----- Get Marker Data -----
            [markers, ~] = btkGetMarkers(acq);
            markerNames = fieldnames(markers);
            if isempty(markerNames)
                warning('❌ No markers in %s (skipped)', c3dName);
                continue;
            end

            % Get time from frame info
            firstFrame = btkGetFirstFrame(acq);
            lastFrame  = btkGetLastFrame(acq);
            freq       = btkGetPointFrequency(acq);
            nFrames    = lastFrame - firstFrame + 1;
            time       = (0:nFrames-1)' / freq;

            % Build marker matrix: [nFrames x (3 * nMarkers)]
            markerData = zeros(nFrames, 3*numel(markerNames));
            for i = 1:numel(markerNames)
                markerData(:, (i-1)*3 + (1:3)) = markers.(markerNames{i});
            end

            % ----- Get Analog Data (EMG) -----
            [analogs, ~] = btkGetAnalogs(acq);
            analogNames = fieldnames(analogs);
            if isempty(analogNames)
                analogData  = [];
                analogTime  = [];
                Fs_analog   = NaN;
            else
                Fs_analog = btkGetAnalogFrequency(acq);
                nAnalog   = size(analogs.(analogNames{1}), 1);
                analogTime = (0:nAnalog-1)' / Fs_analog;
                analogData = zeros(nAnalog, numel(analogNames));
                for j = 1:numel(analogNames)
                    analogData(:, j) = analogs.(analogNames{j});
                end
            end

            % ----- Store in Struct -----
            fCount = fCount + 1;
            dataStruct(fCount).patient      = patientsToInclude{p};
            dataStruct(fCount).filename     = c3dPath;
            dataStruct(fCount).label        = label;
            dataStruct(fCount).markerNames  = markerNames;
            dataStruct(fCount).markerData   = markerData;
            dataStruct(fCount).Fs_marker    = freq;
            dataStruct(fCount).analogNames  = analogNames;
            dataStruct(fCount).analogData   = analogData;
            dataStruct(fCount).Fs_analog    = Fs_analog;

            disp(['✅ Loaded: ', c3dPath]);

        catch ME
            warning(['❌ Failed on ', c3dFiles(f).name, ' — ', ME.message]);
        end
    end
end

disp(['✅ All done. Trials processed: ', num2str(fCount)]);
