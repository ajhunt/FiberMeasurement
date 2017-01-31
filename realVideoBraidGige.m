function [] = realVideoBraidGige(logFilePath, logFileName)

% Define frame rate
NumberFrameDisplayPerSecond=4;

% Open figure
hFigure=figure;

% Set-up camera input
g = gigecam;

%File names for the log file and the video file
fileName = logFilePath;
videoFileName = logFileName;

diskLogger = VideoWriter(strcat(videoFileName, '.avi'), 'Grayscale AVI');
diskLogger.FrameRate = NumberFrameDisplayPerSecond;
open(diskLogger)

tic %start counter

% set up timer object
TimerData=timer('TimerFcn', @(~,~)FrameRateDisplay(g, fileName, diskLogger),...
'Period',1/NumberFrameDisplayPerSecond,'ExecutionMode','fixedRate','BusyMode','queue');


start(TimerData);

% We go on until the figure is closed
uiwait(hFigure);

% Clean up everything
stop(TimerData);
delete(TimerData);

% clear persistent variables
clear functions;
close(diskLogger)
OldValues;


% This function is called by the timer to display one frame of the figure
function [ ] = FrameRateDisplay( obj, event, vid, fileName, diskLogger)

persistent img
persistent handlesImage;
persistent handlesPlot;
persistent handlesFreqSpec;
persistent counter;
%BraidImage = getdata(vid,1,'uint8');
img = snapshot(g);
time = toc;
writeVideo(diskLogger, img)

if isempty(handlesImage)
    
    %initialize counter
    counter = 1;
    
    subplot(3,1,1);
    handlesImage = imagesc(img);
    title('Current Image')
    
    %Plot first value
    [ windowImage ] = spatialhanningwindow( img );
    [ imageFrequencySpectrum ] = frequencytransform( windowImage );
    [intensity, directionVector, angle, thetaRight, thetaLeft, indRight, indLeft, braidAngle, ~, ~, averageAngleDistribution, sortedCirclePoints] = braidanglescanBresenham(imageFrequencySpectrum);
    Values = braidAngle;
    
    subplot(3,1,2);
    handlesPlot = plot(Values);
    xlabel('Frame number');
    ylabel('Braid Angle [deg]');
    
    subplot(3,1,3)
    handlesFreqSpec = imagesc(imageFrequencySpectrum);
    
    %Start .txt file for logging results
    t = datestr(datetime('now'));
    fid = fopen(fileName, 'wt');
    fprintf(fid, 'Braid Angle Results- %s \n \n', t);
    fprintf(fid, 'Measurement No. \t Time \t Braid Angle \n');
    fprintf(fid, '%i \t %f \t %f \n', counter, time, Values);
    
    
    
else
    % We only update what is needed
    set(handlesImage,'CData',img);
    
    [ windowImage ] = spatialhanningwindow( img );
    
    %Brings the image into the frequency domain using the FFT algorithm
    [ imageFrequencySpectrum ] = frequencytransform( windowImage );
    
    %Scans for the primary high frequency data directions - these are the tow
    %directions
    [intensity, directionVector, angle, thetaRight, thetaLeft, indRight, indLeft, braidAngle, ~, ~, averageAngleDistribution, sortedCirclePoints] = braidanglescanBresenham(imageFrequencySpectrum);
    
    Values=braidAngle;
    
    OldValues=get(handlesPlot,'YData');
    
    set(handlesPlot,'YData',[OldValues Values])
    
    set(handlesFreqSpec, 'CData', imageFrequencySpectrum)
    
    counter = counter+1;
    fid = fopen(fileName, 'at');
    fprintf(fid, '%i \t %f \t %f \n', counter, time, Values);
    
    
end
