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


    % Read the original C3D file
    try
        acq = btkReadAcquisition(inputFile);
    catch ME
        error('Failed to read C3D file "%s": %s', inputFile, ME.message);
    end

      % --- Modified code to use marker (point) data ---
    freq = btkGetPointFrequency(acq);
    totalFrames = btkGetPointFrameNumber(acq);
    firstFrame = btkGetFirstFrame(acq);  % (if these refer to marker frames, they remain valid)
    lastFrame  = btkGetLastFrame(acq);

    % Debug prompt: Display acquisition details
    duration = totalFrames / freq;
    fprintf('Debug: Sampling Frequency: %.2f Hz, Total Frames: %d, Duration: %.2f seconds\n', freq, totalFrames, duration);

    % --- After converting startTime and endTime to frame indices ---
    frameStart = round(startTime * freq) + 1;
    frameEnd   = round(endTime * freq) + 1;
    fprintf('Debug: startTime = %.2f s -> computed frameStart = %d\n', startTime, frameStart);
    fprintf('Debug: endTime = %.2f s -> computed frameEnd = %d\n', endTime, frameEnd);
    disp(frameEnd)  % (if you still want to display this)

    % --- In the boundary check for frameStart ---
    if frameStart < firstFrame
        warning('Segment start frame (%d) is below the first frame (%d). Adjusting to first frame.', frameStart, firstFrame);
        fprintf('Debug: Adjusting frameStart from %d to %d\n', frameStart, firstFrame);
        frameStart = firstFrame;
    end

    % --- In the boundary check for frameEnd ---
    if frameEnd > lastFrame
        warning('Segment end frame (%d) exceeds the file''s last frame (%d). Clipping to file end.', frameEnd, lastFrame);
        fprintf('Debug: Clipping frameEnd from %d to %d\n', frameEnd, lastFrame);
        frameEnd = lastFrame;
    end

    % --- Before error if frameStart > frameEnd ---
    if frameStart > frameEnd
        fprintf('Debug: Final frame indices: frameStart = %d, frameEnd = %d\n', frameStart, frameEnd);
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

