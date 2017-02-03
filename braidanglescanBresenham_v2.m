%This function will measure the braid angle from the angular intensity
%image produced from the image taken of the braided composite.
%
%To be called, the angular intensity image, Im_AngularIntensity, must be
%supplied, which is an angular intensity spectrum obtained by performing
%a 2-D fast fourier transform to the extracted edges of the braided
%composite.
%
%Written by Alexander Hunt, ajhunt@ualberta.ca
%Updated Nov 11, 2016
%Fixed angle band computation and added a radius reduction input (radiusReduction) which
%shrinks the size of the search radius of the algorithm.
%Updated Sept 7, 2016
%Corrected improper labelling of left and right spectral features.
%Updated Aug 29, 2016
%Removed intensity value normalization to allow for comparison between data
%sets.  The plot functions will plot the uncorrected values of intensity,
%and the peak width measurement will use the normalized value
%Updated May 2, 2016
%Modified segment of code which defines the angle vector.  The 0 degree
%angle was sandwiched between two positive angles which caused repeating x
%values.  Ensured that all x values are now unique.
%Updated April 14th, 2015
%Updates include defining a circle which is marched across to define the
%angle measurement vector.  This eliminates the need to have a square
%input and keeps the number of averaged pixels constant across the spectrum

%Updated June 19th 2015
%Updates include using the Bresenham line algorithm to trace the lines in
%order to make measurements in the frequency spectrum image.  This is done
%in an effort to replace the improfile.m function, which grealy increases
%run time

%Updated June 29
%Added the angle band compatibility
%Modified the pixel intensity result by subtracting the minimum value from
%the array of results.  This allows better selection of the measurement
%band

%Updated July 2nd, 2015
%Added the Bresenham circle algorithm which will properly discretize the
%circular path over which the measurement is performed.

%Updated October 30, 2015
%Added direction vector output to allow for graphical representation of
%measured angle on frequency domain output.  And for other potential uses.
%Added indRight and indLeft outputs

%Updated November 1, 2015
%Added sortedCirclePoints to the output of the function to add annotations
%to the frequency spectum

%Updated January 27, 2016
%Added contraints to angle scan region.  The reflection from the mandrel
%when I was imaging open mesh braids caused a strong responce in the
%horizontal direction
%
%Angular resolution of 0.1248 degrees for a 2058x2058 image (see excel
%spreadsheet titled AngularResolution.xlxs


function [intensity, directionVector, angle, thetaRight, thetaLeft, indRight, indLeft, braidAngle, rightBand, leftBand, averageAngleDistribution, sortedCirclePoints]...
    = braidanglescanBresenham_v2(edgeBraidFreqSpectrum, radiusReduction)
% The size of the FFT angular intensity spectrum must be determined to
% determine the center of the image and the relevant vectors for the angle
% measurement

[nCol,nRow] = size(edgeBraidFreqSpectrum);
center = [0,0];

%Defines the center point accordingly depending on the initial size of the
%input data
if mod(nCol,2)== 0
    %number is even
    center(1) = nCol/2+1;
else
    %number is odd
    center(1) = nCol/2+0.5;
end

if mod(nRow,2)== 0
    %number is even
    center(2) = nRow/2+1;
else
    %number is odd
    center(2) = nRow/2+0.5;
end

% Reference vector used for the angle measurement.
ref = [nRow,center(1)] - [center(2), center(1)];

%NEW CIRCLEPOINT CODE-----------------------------------------------
%Circle coordinates are ordered from the top center of the image to the
%bottom center of the image
radiusMax = center(1)-2-radiusReduction;

circleArray = MidpointCircle(0, radiusMax, center(1)-1, center(2)-1, 1); %Function will populate the array with circle points using the Bresenham circle algorithm

%locate the coordinates of the circle points
[i,j] = find(circleArray == 1);
circPoints = [i,j];

%sort the array of points in ascending row coordinate
[value, order] = sort(circPoints(:,1));
sortedCirclePoints = circPoints(order,:);
%% plot circle points on frequency spectrum
% circlePlotFreqSpectrum = edgeBraidFreqSpectrum;
% circlePlotFreqSpectrum(sub2ind(size(circlePlotFreqSpectrum), sortedCirclePoints(:,1), sortedCirclePoints(:,2)))=1;
%
% imshow(circlePlotFreqSpectrum)
%%
%determine the number of circle points and remove the bottom half of the
%circle points as they have to be re-ordered
halfSize = round(size(sortedCirclePoints, 1)/2);
ascendingCircArrayBottom = sortedCirclePoints(halfSize:end, :);

%Sort the second half of the values by descending column coordinate
[value2, order2]  = sort(ascendingCircArrayBottom(:,2), 'descend');
descendingCircArrayBottom = ascendingCircArrayBottom(order2,:);

%Replace the removed second half of the values
sortedCirclePoints(halfSize:end, :) = descendingCircArrayBottom;
%------------------------------------------------------------------------

%END OF OLD CIRCLEPOINT CODE--------------------------------------------

%Allocating space for storing the resulting mean pixel intensities and
%angle increments
% intensity = zeros(1,nRow);
% angle = zeros(1,nRow);
intensity = [];
angle = [];
count = 0; %counter variable initialization

%ANGLE MEASUREMENT AND LINE DISCRETIZATION ---------------------
%In this section of code, lines are drawn from the center of the image to
%pixels lying on the perimeter of the discretized semi-circle.  The average
%pixel intensity of the entries along the line is computer.  The
%orientation of the line corresponding to the greatest intensity value is
%saved as the braid angle.

%Marching along the circle points
for j = 1:size(sortedCirclePoints, 1)
    
    %increment counter variable
    count = count+1;
    
    %Define first endpoint of the line (the center point)
    xa = center(2)-1;
    ya = center(1)-1;
    
    %Define second end point from the discretized circle points
    xb = sortedCirclePoints(count,2);
    yb = sortedCirclePoints(count,1);
    
    %Calculate slope of the line spanning from the center of the image to
    %the circle perimeter
    m = (yb-ya)/(xb-xa);
    
    %Defines line sections for non-sensible slope values (infinity and 0)
    if m == inf
        rowCoordinates = center(1):-1:radiusMax; %row coordinates
        colCoordinates = center(2)*ones(size(rowCoordinates,2));
        coordinateVector = vertcat(rowCoordinates, colCoordinates);
        
    elseif m == 0
        colCoordinates = center(1):center(1)+radiusMax-2;
        rowCoordinates = center(2)*ones(1, size(colCoordinates,2));
        coordinateVector = vertcat(rowCoordinates, colCoordinates);
        
    else %Run main line drawing algorithm which is diveded into cases of large, small, positve and negative slopes
        
        [ xLine, yLine ] = discretelinefunction( center, m, xa, ya, xb, yb );
        
    end
    pixelValues = zeros([1,size(xLine,2)]);
    for q = 1:size(xLine, 2)
        pixelValues(q) =  edgeBraidFreqSpectrum(yLine(q), xLine(q));
    end
    %Loops through the coordinateVector obtained from generating the
    %discretized lines and determines the coresponding pixel values
    %assicoated with the x,y coordinates
    
    
    
    %Defines the mean pixel intensity and the angle for each vector
    
    intensity(count) = mean(pixelValues);
    directionVector = [sortedCirclePoints(j,2), sortedCirclePoints(j,1)] - [center(2), center(1)];
    angle(count) = (180/pi)*acos(dot(ref, directionVector)/(norm(ref)*norm(directionVector)));
    
end

%Normalize the array of mean pixel intensities by subtracting the minimum
%value
%intensity = intensity - min(intensity);



for i = ((count)+3)/2:count
    angle(i) = angle(i)*-1;
end


% Initialize variables
thetaRight = 0;
thetaLeft = 0;
intensityLeft = 0;
intensityRight = 0;

% Scanning for the LEFT braid angle
for i = 1:count/2
    if intensity(i) > intensityLeft && 20 < angle(i) && angle(i) < 70
        intensityLeft = intensity(i);
        thetaLeft = angle(i);
        indLeft = i;
    else
        continue
    end
end

%Scanning for Right braid angle
for i = ((count)+1)/2:count-1
    if intensity(i)>intensityRight && angle(i)> -70 && angle(i) < -20
        intensityRight = intensity(i);
        thetaRight = -1*angle(i);
        indRight = i;
    else
        continue
        
    end
end

%Taking the average of the left and right angles
braidAngle = (abs(thetaLeft)+abs(thetaRight))/2;

% %graphically show lines of max intensity overtop of the frequency spectrum
% h = figure;
% %axis(h,'equal')
% imshow(edgeBraidFreqSpectrum, [])
% hold on
%
% %for the "right" angle
% line1 = plot([center(2), sortedCirclePoints(indRight,2)], [center(1), sortedCirclePoints(indRight,1)], 'r');
%
% %for the "left" angle
% line2 = plot([center(2), sortedCirclePoints(indLeft,2)], [center(1), sortedCirclePoints(indLeft,1)], 'r');
%
% %line3 = plot([nRow,center(1)],  [center(2), center(1)]);
%% finding width of peaks
angleBand = 0.8; % the percentage that the peak intensity must decrease before the directions are not included in the angular span

% Angular distribution of the Left braid angle
for j = indLeft:size(intensity, 2)/2
    if intensity(j)-min(intensity)<= (intensityLeft-min(intensity))*angleBand %uses the normalized values of intensity in this calculation
        leftBand(1) = -1*angle(j);
        break
    end
end

% for j = indLeft:-1:1
%    if intensity(j)-min(intensity)<= (intensityLeft-min(intensity))*angleBand
%        leftBand(2) = -1*angle(j);
%        break
%    end
% end

leftAngleDistribution = abs(abs(leftBand(1))-abs(thetaLeft));


%Angular distribution of the right braid angle
% for j = indRight:size(intensity, 2)
%     if intensity(j)-min(intensity)<= (intensityRight-min(intensity))*angleBand
%         rightBand(1) = angle(j);
%         break
%     end
% end

for j = indRight:-1:size(intensity, 2)/2
    if intensity(j)-min(intensity)<= (intensityRight-min(intensity))*angleBand
        rightBand(1) = angle(j);
        break
    end
end


rightAngleDistribution = abs(abs(rightBand(1)) - abs(thetaRight));

% Finding average distribution size
averageAngleDistribution = (rightAngleDistribution+leftAngleDistribution)/2;

% rightBand = [];
% leftBand = [];
% averageAngleDistribution = [];
