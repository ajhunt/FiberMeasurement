%Main piece of code to run the quality control braid measurement system.  

%Update log%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%October 30, 2015
%Eliminated the presence of repeat hanning coefficient calculations.  This
%was done by keeping track of image size in the program's handles
%structure.  The hanning calculation sequence is only run if upon
%initlaization, or if the image size is changed.  
%November 1, 2015
%Added annotations to the frequency spectrum which shows a visual 
%representation of the locations of highest mean intensity.  The direction
%vector and indRight/indLeft outputs from braidangleBresenham.m are used to
%accomplish this task

function varargout = BraidMeasureGUI(varargin)
% BRAIDMEASUREGUI MATLAB code for BraidMeasureGUI.fig
%      BRAIDMEASUREGUI, by itself, creates a new BRAIDMEASUREGUI or raises the existing
%      singleton*.
%
%      H = BRAIDMEASUREGUI returns the handle to a new BRAIDMEASUREGUI or the handle to
%      the existing singleton*.
%
%      BRAIDMEASUREGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BRAIDMEASUREGUI.M with the given input arguments.
%
%      BRAIDMEASUREGUI('Property','Value',...) creates a new BRAIDMEASUREGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BraidMeasureGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BraidMeasureGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BraidMeasureGUI

% Last Modified by GUIDE v2.5 24-Feb-2016 10:44:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @BraidMeasureGUI_OpeningFcn, ...
    'gui_OutputFcn',  @BraidMeasureGUI_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before BraidMeasureGUI is made visible.
function BraidMeasureGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BraidMeasureGUI (see VARARGIN)

% Choose default command line output for BraidMeasureGUI
handles.output = hObject;

%Initialization size identifiers
handles.sizeX = 0;
handles.sizeY = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes BraidMeasureGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = BraidMeasureGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in uploadbutton.
function uploadbutton_Callback(hObject, eventdata, handles)
% hObject    handle to uploadbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[imageFileName, imagePathname, ~] = uigetfile({'*.jpg; *.tif; *.tiff; *.bmp; *.gif; *.jpeg',...
    'Image Files (*.jpg, *.tif, *.bmp, *.gif, *jpeg)'}); %Defining all image files
if imageFileName == 0
    msgbox('Image was not selected')
else
    
    set(handles.statustextbox, 'String', imageFileName);
    
    %reading in selected image file as variable
    handles.image = imread(strcat(imagePathname,imageFileName));
    
    %Size of image
    [sizeY, sizeX] = size(handles.image);
    
        
    if handles.sizeX == 0 && handles.sizeY == 0%no image file has been read into program
        %obtain size of image and write to handles structure
        [handles.sizeY, handles.sizeX] = size(handles.image);
        %run hanning window algorithm
        handles.hanningWindowCoefficients = hanningwindowcalculation(handles.sizeY, handles.sizeX);
        
    else handles.sizeX~=0 && handles.sizeY~=0 && sizeX~=handles.sizeX && sizeY~=handles.sizeY
        %image size has changed
        
        %update handles structure with new iage size
        [handles.sizeY, handles.sizeX] = size(handles.image);
        %obtain new haning window coefficients
        handles.hanningWindowCoefficients = hanningwindowcalculation(sizeY, sizeX);
        
        %if the image size stays the same, nothing will happen.  This
        %eliminates the need to recalculate the hanning window coefficients
    end
    
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in startcamerabutton.
function startcamerabutton_Callback(hObject, eventdata, handles)
% hObject    handle to startcamerabutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file, path] = uiputfile({'.log'});
logFilePath = strcat(path, file);
logFileName = strtok(file, '.'); %separate file name from file extension
realVideoBraid(logFilePath, logFileName);


% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in measureanglebutton.
function measureanglebutton_Callback(hObject, eventdata, handles)
% hObject    handle to measureanglebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Spatially windows the image which removes discontinuities when using the
%discrete Fourier transform
[ windowImage ] = spatialhanningwindow( handles.image );

%Brings the image into the frequency domain using the FFT algorithm
[ imageFrequencySpectrum ] = frequencytransform( windowImage );

%Scans for the primary high frequency data directions - these are the tow
%directions
[intensity, directionVector, angle, thetaRight, thetaLeft, indRight, indLeft, braidAngle, ~, ~, averageAngleDistribution, sortedCirclePoints] = braidanglescanBresenham(imageFrequencySpectrum);

braidAngleResultString = strcat(sprintf('%0.2f',  braidAngle), char(176), char(177), sprintf('%0.2f', averageAngleDistribution), char(176));

set(handles.braidangletext, 'string', braidAngleResultString)

%Write angle scan outputs to handle structure
handles.sortedCirclePoints = sortedCirclePoints;
handles.intensity = intensity;
handles.angle = angle;
handles.imageFrequencySpectrum = imageFrequencySpectrum;
handles.directionVector = directionVector;
handles.indRight = indRight;
handles.indLeft = indLeft;

%Write angle scan outputs to workspace
assignin('base', 'thetaRight', thetaRight)
assignin('base', 'thetaLeft', thetaLeft)
assignin('base', 'windowImage', windowImage)

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in dispfrequencybutton.
function dispfrequencybutton_Callback(hObject, eventdata, handles)
% hObject    handle to dispfrequencybutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hFreqSpectrum = figure;

%Scaling the 2D frequency transform to allow for proper display as an
%image.  This process allows the figure to be displayed over the full
%dynamic range of the image
logImageFreqSpec = log(1+handles.imageFrequencySpectrum);
maxValue = max(max(logImageFreqSpec));
c = 255/maxValue;
scaledImageFreqSpec = uint8(c*logImageFreqSpec);
imshow(uint8(scaledImageFreqSpec))

% %graphically show lines of max intensity overtop of the frequency spectrum
%axis(hFreqSpectrum,'equal')
hold on

% %for the "right" angle
% line1 = plot([handles.sizeX/2, handles.sortedCirclePoints(handles.indRight,2)], [handles.sizeY/2, handles.sortedCirclePoints(handles.indRight,1)], 'r');
% 
% %for the "left" angle
% line2 = plot([handles.sizeX/2, handles.sortedCirclePoints(handles.indLeft,2)], [handles.sizeY/2, handles.sortedCirclePoints(handles.indLeft,1)], 'r');


% --- Executes on button press in plotbutton.
function plotbutton_Callback(hObject, eventdata, handles)
% hObject    handle to plotbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Defining font style and size variables
Fstyle = 'Times';
Fsize = 18;

figure;
plot(handles.angle, handles.intensity)
ylabel('Mean Pixel Intensity', 'fontname', Fstyle, 'fontsize', Fsize)
xlabel('Angle', 'fontname', Fstyle, 'fontsize', Fsize)

% --- Executes on button press in dispimagebutton.
function dispimagebutton_Callback(hObject, eventdata, handles)
% hObject    handle to dispimagebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure;
imshow(handles.image)


% --- Executes on button press in logfilecheckbox.
function logfilecheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to logfilecheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of logfilecheckbox
