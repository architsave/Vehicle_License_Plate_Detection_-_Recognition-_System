function varargout = projectgui(varargin)
% PROJECTGUI MATLAB code for projectgui.fig
%      PROJECTGUI, by itself, creates a new PROJECTGUI or raises the existing
%      singleton*.
%
%      H = PROJECTGUI returns the handle to a new PROJECTGUI or the handle to
%      the existing singleton*.
%
%      PROJECTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROJECTGUI.M with the given input arguments.
%
%      PROJECTGUI('Property','Value',...) creates a new PROJECTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before projectgui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to projectgui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help projectgui

% Last Modified by GUIDE v2.5 21-Mar-2016 22:27:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @projectgui_OpeningFcn, ...
                   'gui_OutputFcn',  @projectgui_OutputFcn, ...
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


% --- Executes just before projectgui is made visible.
function projectgui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to projectgui (see VARARGIN)

% Choose default command line output for projectgui
handles.output = hObject;
handles.output = hObject;
ah=axes('unit','normalized','position',[0 0 1 1]);
%bg=imread('bg.png');imagesc(bg);
set(ah,'handlevisibility','off','visible','off');
uistack(ah,'top');
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes projectgui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = projectgui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global I 
[path,user_cance]=imgetfile();
if user_cance
    msgbox(sprintf('No Image selected.'),'Invalid Input','Error');
 
    a='Image Not Selected'
set(handles.edit1,'String',a);
    return
end
I=imread(path);
axes(handles.axes2);
imshow(I);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global I
Igray = rgb2gray(I);
[rows cols] = size(Igray);
%% Dilate and Erode Image in order to remove noise
Idilate = Igray;
for i = 1:rows
for j = 2:cols-1
temp = max(Igray(i,j-1), Igray(i,j));
end
end
I = Idilate;
% figure(2);
%imshow(Igray);

%figure(4);
%imshow(I);
difference = 0;
sum = 0;
total_sum = 0;
difference = uint32(difference);

%% PROCESS EDGES IN HORIZONTAL DIRECTION
%disp('Processing Edges Horizontally...');
max_horz = 0;
maximum = 0;
for i = 2:cols
sum = 0;
for j = 2:rows
if(I(j, i) > I(j-1, i))
difference = uint32(I(j, i) - I(j-1, i));
else
difference = uint32(I(j-1, i) - I(j, i));
end
if(difference > 10)
sum = sum + difference;
end
end
horz1(i) = sum;
% Find Peak Value
if(sum > maximum)
max_horz = i;
maximum = sum;
end
total_sum = total_sum + sum;
end
average = total_sum / cols;
% figure(5);
% Plot the Histogram for analysis
%subplot(3,1,1);
%plot (horz1);
%title('Horizontal Edge Processing Histogram');
%xlabel('Column Number ->');
%ylabel('Difference ->');
%% Smoothen the Horizontal Histogram by applying Low Pass Filter
%disp('Passing Horizontal Histogram through Low Pass Filter...');
sum = 0;
horz = horz1;
for i = 21:(cols-21)
sum = 0;
for j = (i-20):(i+20)
sum = sum + horz1(j);
end
horz(i) = sum / 41;
end
%subplot(3,1,2);
%plot (horz);
%title('Histogram after passing through Low Pass Filter');
%xlabel('Column Number ->');
%ylabel('Difference ->');
%% Filter out Horizontal Histogram Values by applying Dynamic Threshold
%disp('Filter out Horizontal Histogram...');
for i = 1:cols
if(horz(i) < average)
horz(i) = 0;
for j = 1:rows
I(j, i) = 0;
end
end
end
%subplot(3,1,3);
%plot (horz);
%title('Histogram after Filtering');
%xlabel('Column Number ->');
%ylabel('Difference ->');
%% PROCESS EDGES IN VERTICAL DIRECTION
difference = 0;
total_sum = 0;
difference = uint32(difference);
%disp('Processing Edges Vertically...');
maximum = 0;
max_vert = 0;
for i = 2:rows
sum = 0;
for j = 2:cols %cols
if(I(i, j) > I(i, j-1))
difference = uint32(I(i, j) - I(i, j-1));
end
if(I(i, j) <= I(i, j-1))
difference = uint32(I(i, j-1) - I(i, j));
end
if(difference > 20)
sum = sum + difference;
end
end
vert1(i) = sum;
%% Find Peak in Vertical Histogram
if(sum > maximum)
max_vert = i;
maximum = sum;
end
total_sum = total_sum + sum;
end
average = total_sum / rows;
%figure(6)
%subplot(3,1,1);
%plot (vert1);
%title('Vertical Edge Processing Histogram');
%xlabel('Row Number ->');
%ylabel('Difference ->');
%% Smoothen the Vertical Histogram by applying Low Pass Filter
%disp('Passing Vertical Histogram through Low Pass Filter...');
sum = 0;
vert = vert1;
for i = 21:(rows-21)
sum = 0;
for j = (i-20):(i+20)
sum = sum + vert1(j);
end
vert(i) = sum / 41;
end
%subplot(3,1,2);
%plot (vert);
%title('Histogram after passing through Low Pass Filter');
%xlabel('Row Number ->');
%ylabel('Difference ->');
%% Filter out Vertical Histogram Values by applying Dynamic Threshold
%disp('Filter out Vertical Histogram...');
for i = 1:rows
if(vert(i) < average)
vert(i) = 0;
for j = 1:cols
I(i, j) = 0;
end
end
end
%subplot(3,1,3);
%plot (vert);
%title('Histogram after Filtering');
%xlabel('Row Number ->');
%ylabel('Difference ->');
%figure(7), imshow(I);


%% Find Probable candidates for Number Plate
j = 1;
for i = 2:cols-2
if(horz(i) ~= 0 && horz(i-1) == 0 && horz(i+1) == 0)
column(j) = i;
column(j+1) = i;
j = j + 2;
elseif((horz(i) ~= 0 && horz(i-1) == 0) || (horz(i) ~= 0 && horz(i+1) == 0))
column(j) = i;
j = j+1;
end
end
j = 1;
for i = 2:rows-2
if(vert(i) ~= 0 && vert(i-1) == 0 && vert(i+1) == 0)
row(j) = i;
row(j+1) = i;
j = j + 2;
elseif((vert(i) ~= 0 && vert(i-1) == 0) || (vert(i) ~= 0 && vert(i+1) == 0))
row(j) = i;
j = j+1;
end
end
[temp column_size] = size (column);
if(mod(column_size, 2))
column(column_size+1) = cols;
end
[temp row_size] = size (row);
if(mod(row_size, 2))
row(row_size+1) = rows;
end
%% Region of Interest Extraction
%Check each probable candidate
for i = 1:2:row_size
for j = 1:2:column_size
% If it is not the most probable region remove it from image
if(~((max_horz >= column(j) && max_horz <= column(j+1)) && (max_vert >= row(i) && max_vert <= row(i+1))))
%This loop is only for displaying proper output to User
for m = row(i):row(i+1)
for n = column(j):column(j+1)
I(m, n) = 0;
end
end
end
end
end

imshow(I);


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global I
imagen=I;
if size(imagen,3)==3 % RGB image
    imagen=rgb2gray(imagen);
end
%% Convert to binary image
threshold = graythresh(imagen);
imagen =~im2bw(imagen,threshold);
%% Remove all object containing fewer than 30 pixels
imagen = bwareaopen(imagen,30);
pause(1)
%% Show image binary image
%figure(2)
imshow(~imagen);
%title('INPUT IMAGE WITHOUT NOISE')
%% Label connected components
[L Ne]=bwlabel(imagen);
%% Measure properties of image regions
propied=regionprops(L,'BoundingBox');
hold on
%% Plot Bounding Box
for n=1:size(propied,1)
   rectangle('Position',propied(n).BoundingBox,'EdgeColor','g','LineWidth',2)
end
hold off
pause (1)
%% Objects extraction
figure
for n=2:Ne
    [r,c] = find(L==n);
    n1=imagen(min(r):max(r),min(c):max(c));
    %figure(n+1);
    subplot(1,Ne,n-1);
    imshow(~n1);
    baseFileName = sprintf('image %d.png',n);
    fullFileName = fullfile('C:\Users\BHARAT\Desktop\segmented\images', baseFileName);
    imwrite(~n1,fullFileName)
    pause(0.5)
end


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% preprocessing of image
clear all;
close all;
clc;

path='C:\Users\BHARAT\Desktop\segmented\images\';
list=dir([path, '*.png']);
m=zeros(length(list),85)
for x=1:length(list)
    images{x}=imread([path, list(x).name]);
    
    
image =images{x};  
% by now image should be binary    
% skeletonizing image
image=bwmorph(image,'skel',inf);

%selecting the universe of discourse
image=discourser(image);

original_image=image;% just backing up the orginal image
row=size(image,1);
column=size(image,2);
% we have to ceil this no.s to the nearest multiple of 3 since
% 3x3 windowing is used

% first we have to ensure that image consists of minimum 9 rows and minimum
% 9 columns
add_rows=0; %no of additional rows to make min of 9x9 matrix
add_columns=0; % similar for columns
if row<9
    add_rows=9-row;
end
if column<9
    add_columns=9-column;
end

if mod(add_rows,2)==0
    image=[zeros(add_rows/2,column);image;zeros(add_rows/2,column)];
else
    image=[zeros((add_rows-1)/2,column);image;zeros((add_rows+1)/2,column)];
end
%appending rows of zeros
%after above op, no.of rows changes so it should be updated
%equal no of rows should be added on top and bottom
row=size(image,1);
if mod(add_columns,2)==0
    image=[zeros(row,(add_columns)/2),image,zeros(row,(add_columns)/2)];
else
    image=[zeros(row,(add_columns-1)/2),image,zeros(row,(add_columns+1)/2)];
end
column=size(image,2); %updating the column value


n_rows=ceil(row/3)*3-row; % no of rows of zeros to be added
n_columns=ceil(column/3)*3-column; % no of columns of zeros to be added
% assume row=4, so 2 rows of zeros should be added. ceil(4/3)*3 will return
% 6 which is nearest multiple of 3 to 4 from right side. So n_rows will
% contain no.of rows to be added to the image.

if mod(n_rows,2)==0
    image=[zeros(n_rows/2,column);image;zeros(n_rows/2,column)];
else
    image=[zeros((n_rows-1)/2,column);image;zeros((n_rows+1)/2,column)];
end
%appending rows of zeros
%after above op, no.of rows changes so it should be updated
%equal no of rows should be added on top and bottom
row=size(image,1);
if mod(n_columns,2)==0
    image=[zeros(row,(n_columns)/2),image,zeros(row,(n_columns)/2)];
else
    image=[zeros(row,(n_columns-1)/2),image,zeros(row,(n_columns+1)/2)];
end
column=size(image,2); %updating the column value
% so now the image can be divided into 3x3 zones
% here in above code some more features are to be added, like if two rows
% of zeros are to be added then one on either side of the image and
% similarily for columns.

zone_height=row/3;
zone_width=column/3;
%say at this point image is 12x9, so no.of rows in each zone should be
%12/3=4, whereas columns should be 9/3=3. This is stored in variables zone
%height and width
zone11=image(1:zone_height,1:zone_width);
zone12=image(1:zone_height,(zone_width+1):2*zone_width);
zone13=image(1:zone_height,(2*zone_width+1):end);

zone21=image((zone_height+1):2*zone_height,1:zone_width);
zone22=image((zone_height+1):2*zone_height,(zone_width+1):2*zone_width);
zone23=image((zone_height+1):2*zone_height,(2*zone_width+1):end);

zone31=image((2*zone_height+1):end,1:zone_width);
zone32=image((2*zone_height+1):end,(zone_width+1):2*zone_width);
zone33=image((2*zone_height+1):end,(2*zone_width+1):end);

% feature_vectors
zone11_features=lineclassifier(zone11);
zone12_features=lineclassifier(zone12);
zone13_features=lineclassifier(zone13);

zone21_features=lineclassifier(zone21);
zone22_features=lineclassifier(zone22);
zone23_features=lineclassifier(zone23);

zone31_features=lineclassifier(zone31);
zone32_features=lineclassifier(zone32);
zone33_features=lineclassifier(zone33);

% this is a feature called euler no...euler no. is diff between no.of
% objects and holes in that image
euler=bweuler(image);
features=[zone11_features;zone12_features;zone13_features;zone21_features;zone22_features;zone23_features;zone31_features;zone32_features;zone33_features];
features=[reshape(features',numel(features),1);euler];

% here the region properties of the image are going to be considered
stats=regionprops(bwlabel(image),'all');

skel_size=numel(image);

%convexarea=(stats.ConvexArea)/skel_size;

eccentricity=stats.Eccentricity;

extent=stats.Extent;

%filledarea=(stats.FilledArea)/skel_size;

%majoraxislength=(stats.MajorAxisLength)/skel_size;

%minoraxislength=(stats.MinorAxisLength)/skel_size;

orientation =stats.Orientation;

% this are the regional features
regional_features=[eccentricity;extent;orientation];

features=[features;regional_features];                      % I CHANGED HERE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
m(x,:)=features
B= m.'

csvwrite('C:\Users\BHARAT\Desktop\BE\feature_extraction\feature_extraction\featuresgui.csv',B);
%input{x-1}=features
% now the previous geometric and this regional features have to be combined
%features=[features;regional_features];
end
load 'featuresgui.csv'
load 'neuraltamilnadu.mat'
y = sim(network1,featuresgui)
% [C I]=max(y);
 % disp(I)
 %disp(C)
A = round(y)
ans = char(A)
fid  = fopen('C:\Users\BHARAT\Desktop\BE\feature_extraction\feature_extraction\out.txt', 'wt','n','ans');
fprintf(fid,'%s\n',ans)
fclose(fid);
winopen('C:\Users\BHARAT\Desktop\BE\feature_extraction\feature_extraction\out.txt')

