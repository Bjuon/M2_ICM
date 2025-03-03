function extractC3DSegment(inputFile, outputFile, startTime, endTime)
% EXTRACTC3DSEGMENT Extracts a segment from a C3D file between startTime and endTime (in seconds).
%
%   extractC3DSegment(inputFile, outputFile, startTime, endTime)
%
%   Reads the C3D file specified by inputFile, extracts marker and analog data between 
%   startTime and endTime (in seconds), and writes the segmented data to outputFile.
%
%   Example:
%       extractC3DSegment('trial.c3d', 'trial_seg1.c3d', 30, 45);
%
%   Note: If the computed segment end frame exceeds the total number of frames in the file,
%         the segment end is clipped to the file's last frame and a warning is displayed.
%
    acq = btkReadAcquisition(inputFile);
    freq = btkGetAnalogFrequency(acq);
    totalFrames = btkGetAnalogFrameNumber(acq);
    totalDuration = totalFrames / freq;
    fprintf('Total Duration: %.2f seconds\n', totalDuration);
    btkCloseAcquisition(acq);


    % Read the original C3D file
    try
        acq = btkReadAcquisition(inputFile);
    catch ME
        error('Failed to read C3D file "%s": %s', inputFile, ME.message);
    end

    % Get sampling frequency and frame boundaries
    freq = btkGetAnalogFrequency(acq);
    totalFrames = btkGetAnalogFrameNumber(acq);
    firstFrame = btkGetFirstFrame(acq);
    lastFrame  = btkGetLastFrame(acq);

    % Convert startTime and endTime (in seconds) to frame indices (assuming time 0 corresponds to frame 1)
    frameStart = round(startTime * freq) + 1;
    frameEnd   = round(endTime * freq) + 1;
    disp(frameEnd)

    % Adjust frameStart if it is below the first frame
    if frameStart < firstFrame
        warning('Segment start frame (%d) is below the first frame (%d). Adjusting to first frame.', frameStart, firstFrame);
        frameStart = firstFrame;
    end

    % Adjust frameEnd if it exceeds the file's last frame
    if frameEnd > lastFrame
        warning('Segment end frame (%d) exceeds the file''s last frame (%d). Clipping to file end.', frameEnd, lastFrame);
        frameEnd = lastFrame;
    end

    % Ensure the adjusted frame range is valid
    if frameStart > frameEnd
        btkCloseAcquisition(acq);
        error('Adjusted frame range is invalid: start frame %d is after end frame %d.', frameStart, frameEnd);
    end

    numFrames = frameEnd - frameStart + 1;

    % Crop the acquisition to the specified segment
    try
        btkCropAcquisition(acq, frameStart, numFrames);
    catch ME
        btkCloseAcquisition(acq);
        error('Error cropping acquisition: %s', ME.message);
    end

    % Write the segmented acquisition to the new C3D file
    try
        btkWriteAcquisition(acq, outputFile);
    catch ME
        btkCloseAcquisition(acq);
        error('Failed to write segmented acquisition to "%s": %s', outputFile, ME.message);
    end

    btkCloseAcquisition(acq);
end

