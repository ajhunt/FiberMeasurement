function [ unwrapIm] = surfaceunwrapfunction( im, leftBoundary, rightBoundary, centerLine, maxAngle )
%applied orthographic projection to images of the tubular braid surface

%inputs: im = input image, leftBoundary, rightBoundary, centerLine =
%feature locations in image, braidDiameter = mandrel diameter of braid in
%either mm or inches, unit = 0 for imperial, 1 for metric
%maxAngle = maximum circumferential angle that is unwrapped - if this value
%is too large (>65 degrees) resulting image is becomes distorted.  

braidDiameterPX = round(rightBoundary) - round(leftBoundary);  %braid diameter in pixels
braidRadiusPX = round(braidDiameterPX/2);
[sizeY,sizeX] = size(im);

im(:,(1:leftBoundary)) = 0;
im(:,(rightBoundary:sizeX)) = 0;
imCrop = im(:, (leftBoundary:rightBoundary)); %removing background regions of image

i = centerLine+1;
padSize = 1000;
imMap = uint8(zeros(sizeY,sizeX+padSize));

%Pixel re-mapping
for i = 1:braidRadiusPX
    angle(i) = rad2deg(asin(i/braidRadiusPX));
    arclength(i) = deg2rad(angle(i))*braidRadiusPX; %arclength = theta*r
    if angle(i) < maxAngle
        maxInd = i;
    else
        continue
    end
end

%Define the amount of unwrapping as a function of distance from centerline
x = 1:maxInd;
unWrap = real(round(arclength(1:maxInd)-x));

%looping through the columns on the right side of the braid centerline

count = 1;
for i = centerLine+1:1:centerLine+maxInd %right side
    imMap(:,i+unWrap(count)+padSize) = im(:,i);
    count = count+1;
end

count = 1;
for j = centerLine-1:-1:centerLine-maxInd
    imMap(:,j-unWrap(count)+padSize) = im(:,j);
    count = count+1;
end

%Find cropped regions in the newly mapped image
%Left side

for i = padSize:size(im,2)+padSize
    if double(imMap(1,i)) == 0
        continue
    else
        leftIndex = i;
        break
    end
end

%Right side
for i = size(im,2)+padSize:-1:padSize
    if imMap(1,i)==0
        continue
    else
        rightIndex = i;
        break
    end
end

%resize mapped image
imMapResize = imMap(:,[leftIndex:rightIndex]);
%locate columns containing image data
count = 1;
dataArray = [];
for i = 1:size(imMapResize,2)
    if imMapResize(1,i) == 0
        continue
    else
       dataArray(count) = i; %stores column values which contain image data
       count = count+1;
    end
end

%interpolating gaps in unwrapped image
ind = find(imMapResize); %finding the linear indices of the non-zero pixels 
s = size(imMapResize); %defining the size of the image matrix
[I,J] = ind2sub(s,ind); %vectors containing pixel coordinates of non-zero pixels

for i = 1:length(I)
    V(i) = double(imMapResize(I(i),J(i)));
end
V = V';
F = scatteredInterpolant(J,I,V);
%defining query points

%finding locations of zero value in remapped image
indQuery = find(not(imMapResize)); %linear indices of zero locations
[Iq, Jq] = ind2sub(s,indQuery); 
queryPoints = horzcat(Jq,Iq); %making data points in form of x,y

%evaluating the query points
Vq = F(queryPoints);

%replace regions of missing data in image with interpolated values
unwrapIm = imMapResize;
for i = 1:length(Vq)
   unwrapIm(Iq(i), Jq(i)) = Vq(i); 
end

end

