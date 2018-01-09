function [ leftBoundary, rightBoundary, centerLine, braidWidth ] = boundaryV2( bw )
%DESCRIPTION
%Locates braid preform from properly thresholded image, bw
%INPUTS
%bw = binary image
%OUTPUTS
%leftBoundary = int column index of left side of braid
%rightBoundary = int column index of right side of braid
%centerLine = int column index of center of braidWidth
%braidWidth = int mean width of braid in image
%%

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
centerLine = round((rightBoundary + leftBoundary)/2);
braidWidth = rightBoundary - leftBoundary;
end
