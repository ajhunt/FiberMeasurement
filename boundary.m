function [ leftBoundary, rightBoundary, centerLine, braidWidth ] = boundary( image )
%the function boundary locates the braid boundaries through an image
%thresholding operation. The function returns the image column coordinates
%of the left and right boundaries, the cenerline, and the width of the
%tubular braid (in pixels)

imThreshold = image;
imThreshold(image>170) = 0;

count = 1;
yIncrement = 130;
[sizeY, sizeX] = size(image);
i = 100;
while i < sizeY-1500
    scanLine(count, :) = imThreshold(i,:);
    
    count = count+1;
    i = i+yIncrement;
    
end

[numScanLine, ~] = size(scanLine);

for i = 1:numScanLine
    leftBound(i) = find(scanLine(i,:),1,'first');
    rightBound(i) = find(scanLine(i,:),1,'last');
end

leftBoundary = round(mean(leftBound));
rightBoundary = round(mean(rightBound));
centerLine = (rightBoundary + leftBoundary)/2;
braidWidth = rightBoundary - leftBoundary;

%Show results
figure;
imshow(image)
hold on;
plot([leftBoundary, leftBoundary], [1, sizeY], 'color' , 'r')

plot([rightBoundary, rightBoundary], [1, sizeY], 'color', 'r')

plot([centerLine, centerLine], [1,sizeY], 'color', 'r')

end

