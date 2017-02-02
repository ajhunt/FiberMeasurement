function [ unwrapIm, imInterp] = surfaceunwrapfunction( im, leftBoundary, rightBoundary, centerLine )
%applied orthographic projection to images of the tubular braid surface

%inputs: im = input image, leftBoundary, rightBoundary, centerLine =
%feature locations in image, braidDiameter = mandrel diameter of braid in
%either mm or inches, unit = 0 for imperial, 1 for metric

braidDiameterPX = rightBoundary - leftBoundary;  %braid diameter in pixels

[sizeY,sizeX] = size(im);

im(:,(1:leftBoundary)) = 0;
im(:,(rightBoundary:sizeX)) = 0;
imCrop = im(:, (leftBoundary:rightBoundary)); %removing background regions of image

i = centerLine+1;
padSize = 1000;
imMap = uint8(zeros(sizeY,sizeX+padSize));

%Pixel re-mapping
for i = 1:round(braidDiameterPX/2)
    arclength(i) = asin(i/round(braidDiameterPX/2))*round(braidDiameterPX/2);
end

%Define the amount of unwrapping as a function of distance from centerline
x = 1:round(braidDiameterPX/2);
unWrap = real(round(arclength-x));


%looping through the columns on the right side of the braid centerline

count = 1;
for i = round(centerLine+1):1:round(mean(rightBoundary))
    imMap(:,i+unWrap(count)+padSize) = im(:,i);
    count = count+1;
end

count = 1;
for j = round(centerLine-1):-1:round(mean(leftBoundary))
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
imMap2 = imMap(:,[leftIndex:rightIndex]);
%locate columns containing image data
count = 1;
dataArray = [];
for i = 1:size(imMap2,2)
    if imMap2(1,i) == 0
        continue
    else
       dataArray(count) = i; %stores column values which contain image data
       count = count+1;
    end
end

%interpolating gaps in unwrapped image
ind = find(imMap2); %finding the linear indices of the non-zero pixels 
s = size(imMap2); %defining the size of the image matrix
[I,J] = ind2sub(s,ind); %vectors containing pixel coordinates of non-zero pixels

for i = 1:length(I)
    V(i) = double(imMap2(I(i),J(i)));
end
V = V';
F = scatteredInterpolant(J,I,V);
%defining query points

%finding locations of zero value in remapped image
indQuery = find(not(imMap2)); %linear indices of zero locations
[Iq, Jq] = ind2sub(s,indQuery); 
queryPoints = horzcat(Jq,Iq); %making data points in form of x,y

%evaluating the query points
Vq = F(queryPoints);

%replace regions of missing data in image with interpolated values
imInterp = imMap2;
for i = 1:length(Vq)
   imInterp(Iq(i), Jq(i)) = Vq(i); 
end

unwrapIm = imMap2;

end

