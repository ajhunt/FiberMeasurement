function [ scaledFreqSpectrum] = frequencytransform( im,  imageScaleSize )
%This function will perform the 2D discrete Fourier transform and rescale the output to a desired 2D size
%INPUT
%im = input grayscale image
%imageScaleSize = desired output size of frequnecy transform, set to image size
%OUTPUT
%scaledFreqSpectrum = 2D frequency spectrum with dimensions [imageScaleSize imageScaleSize]
%   Detailed explanation goes here

[nRow, nCol] = size(im);

%Performs the DFT using the fast Fourier transform algorithm
F = fft2(double(im));
F = abs(F);

%Shifts the zero frequency components of the spectrum to the center
F = abs(fftshift(F));
F = log(1+F);

%Scaling result between 0 and 1
F = mat2gray(F);

%Resizing the frequency spectrum to ensure that it is square
scaledFreqSpectrum = imresize(F, imageScaleSize);

end

