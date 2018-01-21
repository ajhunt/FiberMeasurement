%the puspose of this code is to unwrap a cylindrical surface from a single,
%2D image.  This code includes a thresholding process to estimate the
%diameter of the cylindrical braid

%February 3rd, 2016
%added accumulation term to the unwrap distance.  Prior to this, unwrapping
%lengths of less than 0.5

clear all; clc
%imOriginal = imread('diamond_img1.tif');
%im = imread('45DegGridHalfInch.tif');
%imOriginal = imread('45DegDiamond_f1_6.tiff');

imOriginal = imread('55_Deg_3_Image169.tif');

im = imOriginal;
level = graythresh(im);
imbw = im2bw(im, 0.05); %binarize the braid image

imbw2 = im2bw(im, level);

[y,x] = size(im);

i = 1; %initialize variable
yInc = 10; %the number of pixels between each horizontal image cross section
count = 1; %counter variable
xVec = 1:1:x;

%Applying structuring element to reduce noise in the image
elementRadius = 20; %size of structuring element
se = strel('disk', elementRadius);
openImage = imopen(imbw, se);

%Filling any holes which are present in the braid (open regions, cross over
%regions
openImage2 = imfill(openImage, 'holes');

while i< 2000 %while scanning region lies within the image (1400 is to avoid noise at bottom of images)
    horizontalXSection(count, :) = openImage2(i,:);
    
    count = count+1;
    i = i+yInc;
end

[numXSection, ~] = size(horizontalXSection);
for i = 1:numXSection
    for j = 1:x
        k = find(horizontalXSection(i,:));
        leftBound(i) = min(k);
        rightBound(i) = max(k);
    end
end

braidDiameter = round(mean(rightBound) - mean(leftBound));

%braidDiameter = 1282; %use for the diamond braid images
%braidDiameter = 1404; %use for the square grid images

braidCenter = round((mean(leftBound)+mean(rightBound))/2);
im(:,(1:leftBound)) = 0;
im(:,(rightBound:x)) = 0;
imCrop = im(:, (leftBound:rightBound));

i = braidCenter+1;
padSize = 1000;
imMap = uint8(zeros(y,x+padSize));


%imMapPad = padarray(i, padSize);

% %Filling in center column
% imMap(:,braidCenter) = im(:,braidCenter);


%Pixel re-mapping

for i = 1:round(braidDiameter/2)
    arclength(i) = asin(i/round(braidDiameter/2))*round(braidDiameter/2);
end

%Define the amount of unwrapping as a function of distance from centerline
x = 1:round(braidDiameter/2);
unWrap = real(round(arclength-x));



%looping through the columns on the right side of the braid centerline

count = 1;
for i = braidCenter+1:1:round(mean(rightBound))
    imMap(:,i+unWrap(count)+padSize) = im(:,i);
    count = count+1;
end

count = 1;
for j = braidCenter-1:-1:round(mean(leftBound))
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

% %Using scatteredInterpolant function to fill gaps in image data
% xCoords = dataArray';
% yCoords = (1:size(imMap,1))';
% v = [];
% for i = 1:size(dataArray,2)
%     v(:,i) = imMap(:,dataArray(i));
% end

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

%Cropping square regions from imInterp and imCrop to determine effect of
%unwrapping
[y1, x1] = size(imCrop);
imCropSquare = imCrop(1:x1, 1:x1);

[y2, x2] = size(imInterp);
imInterpSquare = imInterp(1:x2, 1:x2);


