function [ leftBoundary, rightBoundary, centerLine, braidWidth ] = boundaryV2( bw )
%DESCRIPTION
%Locates braid preform from properly thresholded image, bw

count = 1;
yIncrement = 80;
[sizeY, sizeX] = size(bw);
i = 100;

while i < sizeY
    scanLine(count, 50:sizeX-50) = bw(i,50:sizeX-50);
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
end
