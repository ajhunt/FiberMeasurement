%Example of processing a single image
%Select the res folder to point the script to the sample images
unwrapAngle = 70;
%locate and read in file
filepath = uigetdir;
filename = '\sample1.tif';
im = imread(strcat(filepath, filename));

%locate boundaries of image
bw = adaptivethreshold(im, 40, 3, 0, 11);
[ leftBoundary, rightBoundary, centerLine, braidWidth ] = boundaryV2( bw );

%Extract relevant portion of the image
[ unwrapIm, cropIm] = surfaceunwrapfunction( im , leftBoundary, rightBoundary, centerLine, unwrapAngle );

[ imageFrequencySpectrumOrtho ] = frequencytransform( unwrapIm, [2058 2058] );

[ imageFrequencySpectrumCrop ] = frequencytransform( cropIm, [2058 2058] );
[intensity, ~, angle, thetaRight, thetaLeft, ~, ~, braidAngle, ~, ~, ~, ~] =...
    braidanglescanBresenham_v2(imageFrequencySpectrumCrop, 0);