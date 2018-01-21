function [ braidImageCrop ] = BraidPreProcessFunction( braidImage, nCrop )
%braidImage is the input image
%nCrop is the number of side pixels that are removed from the cropped braid
%image

imThreshold = braidImage;
imThreshold(braidImage>110) = 0;

count = 1;
yIncrement = 100;
[sizeY, sizeX] = size(braidImage);
i = 100;
while i < sizeY-1000
    scanLine(count, :) = imThreshold(i,:);
    
    count = count+1;
    i = i+yIncrement;
    
end

[numScanLine, ~] = size(scanLine);

for i = 1:numScanLine
    leftBound(i) = find(scanLine(i,:),1,'first');
    rightBound(i) = find(scanLine(i,:),1,'last');
end

braidLeftBoundary = round(mean(leftBound));
braidRightBoundary = round(mean(rightBound));
braidCenterLine = (braidRightBoundary + braidLeftBoundary)/2;
braidWidth = braidRightBoundary - braidLeftBoundary;

braidImageCrop = imcrop(braidImage, [braidLeftBoundary+nCrop 0 braidWidth-2*nCrop sizeX]);


% %Show results
% % figure;
% % imshow(braidImage)
% hold on;
% plot([braidLeftBoundary, braidLeftBoundary], [1, sizeY], 'color' , 'r')
%
% plot([braidRightBoundary, braidRightBoundary], [1, sizeY], 'color', 'r')
%
% plot([braidCenterLine, braidCenterLine], [1,sizeY], 'color', 'r')
%
%braidImageCrop = imcrop(braidImage, [braidLeftBoundary+100 0 braidWidth-200 sizeX]);
%
% % figure
% % imshow(braidImageCrop)


end

