function [bw] =adaptivethreshold(IM,ws,C,tm,med)
%%
%This uses adaptive thresholding and median filtering to threshold the
%braid preform from the background. A median filtering process done to
%remove the resulting salt and pepper noise.  
%
%INPUTS
%IM = Input image
%ws = Window size of averaging filter
%C
%med = median filter window size 
%Ideal settings for collected braid images:
%ws = 40, C = 3, tm = 0, med = 11

%Function output is the binarized image, bw
%%
if tm==0
    mIM=imfilter(IM,fspecial('average',ws),'replicate');
else
    mIM=medfilt2(IM,[ws ws]);
end
sIM=mIM-IM-C;
bw=im2bw(sIM,0);
%bw=imcomplement(bw);

%median filter to remove salt and pepper noise
bw = medfilt2(bw, [med med]);
end
