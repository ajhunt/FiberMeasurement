%This script reads in a video file, splits it into individual frames and
%saves them as individual images.  The file name of the images is decided
%will increment for each frame

videoFileName = '45_Deg_2.avi';

rootName = strtok(videoFileName, '.');
v = VideoReader(videoFileName);

vidLength = v.Duration;
vidFrameRate = v.FrameRate;
Frames = vidLength*vidFrameRate;
i = 1;
while hasFrame(v)

    thisFrame = (readFrame(v));
    
    fileName = strcat(rootName, '_Image', num2str(i), '.tif');
    imwrite(thisFrame, fileName, 'Compression', 'none')
    i = i+1;
end