% Change log:
% April 19, 2016
% Added section of code that will scale the frequency spectrum to a square.  
% This allows non square input images to be used, namely when using the ROI cropping 
% June 22, 2016
% Rebuilt function in a much simpler way.  Removed useless function
% outputs.  Added image resize size function inputs

function [ scaledBraidFreqSpectrum] = frequencytransform( BraidImage,  imageScaleSize )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

[nRow, nCol] = size(BraidImage);

%Performs the DFT using the fast Fourier transform algorithm
F = fft2(double(BraidImage));
F = abs(F);

%Shifts the zero frequency components of the spectrum to the center
F = abs(fftshift(F));
F = log(1+F);

%Scaling result between 0 and 1
F = mat2gray(F);

%Resizing the frequency spectrum to ensure that it is square
scaledBraidFreqSpectrum = imresize(F, imageScaleSize);

end

