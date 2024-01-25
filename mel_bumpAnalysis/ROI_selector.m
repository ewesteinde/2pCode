%ROI selector that Jenny developed and I modified to include a PB midline

function varargout = ROI_selector(varargin)
% ROI_selector MATLAB code for ROI_selector.fig
%      ROI_selector, by itself, creates a new ROI_selector or raises the existing
%      singleton*.
%
%      H = ROI_selector returns the handle to a new ROI_selector or the handle to
%      the existing singleton*.
%
%      ROI_selector('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ROI_selector.M with the given input arguments.
%
%      ROI_selector('Property','Value',...) creates a new ROI_selector or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ROI_selector_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ROI_selector_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ROI_selector

% Last Modified by GUIDE v2.5 25-May-2021 10:57:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ROI_selector_OpeningFcn, ...
                   'gui_OutputFcn',  @ROI_selector_OutputFcn, ...
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

% --- Executes just before ROI_selector is made visible.
function ROI_selector_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ROI_selector (see VARARGIN)


global slash;
if isunix() == 1
    slash = '/';
else
    slash = '\';
end

% Choose default command line output for ROI_selector
handles.output = hObject;

%open a directory
dname = uigetdir(['E:' slash 'Dropbox (HMS)' slash 'Wilson_Lab_Data' slash 'NO_gall_data'], 'Please chose an experiment directory (Enter the specific sid and tid folder).');
handles.experiment_dir = dname; %get its name
ghandles = guihandles(hObject);
set(ghandles.filename, 'String', dname);
%sid_k = strfind(dname, 'sid_');
%tid_k = strfind(dname, 'tid_');
%handles.sid = str2num(dname(sid_k+4:tid_k-2));
%handles.tid = str2num(dname(tid_k+4:end));
handles.counter = 0;

%get the file name in the corresponding sid and tid folder that has the
%'reg_channel' expression. This has some reference images for the full
%experiment
expression2 = ['*refImages_reg_ch*'];
imagingFile = dir(fullfile(dname, 'registration_001', expression2));
numChannels = size(imagingFile, 1);

% initialize rois saved
handles.roi_all = [];

% display the z-stacks so I can decide which z-stacks to pull from
% update the z-plane drop down menu
if numChannels == 1 % GCAMP ONLY
    %load the file
    load(fullfile(handles.experiment_dir, imagingFile.name));
    handles.refImages = refImages;
    numSlices = size(refImages, 3);
    handles.numSlices = numSlices;
    handles.height = size(refImages,1);
    handles.width = size(refImages,2);
    zplanes = [];
    for j = 1:numSlices
        zplanes = [zplanes; num2str(j, '%02d')];
    end
    set(ghandles.zplane, 'String', zplanes);
    set(ghandles.tdTomato, 'visible', 'off');
else % numChannels == 2 % SHOW GCAMP
    load(fullfile(handles.experiment_dir, 'registration_001', imagingFile(1).name));
    handles.refImages = refImages;
    load(fullfile(handles.experiment_dir, 'registration_001', imagingFile(2).name));
    handles.tdTomato = refImages;
    numSlices = size(refImages, 3);
    handles.numSlices = numSlices;
    handles.height = size(refImages,1);
    handles.width = size(refImages,2);
    zplanes = [];
    for j = 1:numSlices
        zplanes = [zplanes; num2str(j, '%02d')];
    end
    set(ghandles.zplane, 'String', zplanes);
    set(ghandles.tdTomato, 'visible', 'on');
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ROI_selector wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ROI_selector_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function filename_Callback(hObject, eventdata, handles)
% hObject    handle to filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filename as text
%        str2double(get(hObject,'String')) returns contents of filename as a double


% --- Executes during object creation, after setting all properties.
function filename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in sharpen.
function sharpen_Callback(hObject, eventdata, handles)
% hObject    handle to sharpen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sharpen
ghandles = guihandles(hObject);
displayImage(hObject, ghandles, handles);

% --- Executes on button press in MIP.
function MIP_Callback(hObject, eventdata, handles)
% hObject    handle to MIP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ghandles = guihandles(hObject);
displayImage(hObject, ghandles, handles);

% --- Executes on button press in tdTomato.
function tdTomato_Callback(hObject, eventdata, handles)
% hObject    handle to tdTomato (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tdTomato
ghandles = guihandles(hObject);
displayImage(hObject, ghandles, handles);

% --- Executes on selection change in roi_list.
function roi_list_Callback(hObject, eventdata, handles)
% hObject    handle to roi_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function roi_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roi_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in add.
function add_Callback(hObject, eventdata, handles)
% hObject    handle to add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ghandles = guihandles(hObject);
ax = handles.axes1;
h = imfreehand(ax);
position = getPosition(h);

%leftPB = get(ghandles.leftPB, 'Value');
%glomerulus = str2num(get(ghandles.glomerulus_number, 'String'));
zplane = get(ghandles.zplane, 'Value');
name = get(ghandles.roi_name, 'String');

roi_i.name = name;
roi_i.z = zplane;
roi_i.positions = position;
roi_i.xi = position(:,1);
roi_i.yi = position(:,2);
roi_i.BW = poly2mask(roi_i.xi,roi_i.yi,handles.height,handles.width);
roi_i.id = handles.counter;
roi_i.handle = h;
handles.counter = handles.counter + 1;
handles.roi_all = [handles.roi_all roi_i];

addROI(hObject, ghandles, handles, roi_i);

% --- Executes on button press in pushbutton7.
function addmidline_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ghandles = guihandles(hObject);
ax = handles.axes1;
h = drawpolyline(ax);
position = h.Position;

%leftPB = get(ghandles.leftPB, 'Value');
%glomerulus = str2num(get(ghandles.glomerulus_number, 'String'));
zplane = get(ghandles.zplane, 'Value');
name = get(ghandles.roi_name, 'String');

roi_i.name = name;
roi_i.z = zplane;
roi_i.positions = position;
roi_i.xi = position(:,1);
roi_i.yi = position(:,2);
roi_i.BW = [];
roi_i.id = handles.counter;
roi_i.handle = h;
handles.counter = handles.counter + 1;
handles.roi_all = [handles.roi_all roi_i];

addROI(hObject, ghandles, handles, roi_i);


% --- Executes on button press in save_all.
function save_all_Callback(hObject, eventdata, handles)
% hObject    handle to save_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% handles save directory
ghandles = guihandles(hObject);
guidata(hObject, handles);

global slash;
if isunix() == 1
    slash = '/';
else
    slash = '\';
end
datapath = handles.experiment_dir;
k = strfind(datapath, [slash '2p' slash]);
roi_path = [datapath(1:k+3) 'ROI'];
if(~exist(roi_path, 'dir'))
    mkdir(roi_path);
end
filename = [roi_path slash ['ROI_midline_sid_' num2str(handles.sid) '_tid_' num2str(handles.tid) '.mat']];
roi = handles.roi_all;
save(filename, 'roi');
disp('ROIs saved!');

% --- Executes on selection change in zplane.
function zplane_Callback(hObject, eventdata, handles)
% hObject    handle to zplane (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ghandles = guihandles(hObject);
displayImage(hObject, ghandles, handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function zplane_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zplane (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in gcamp.
function gcamp_Callback(hObject, eventdata, handles)
% hObject    handle to gcamp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ghandles = guihandles(hObject);
displayImage(hObject, ghandles, handles);

% --- Executes on button press in original.
function original_Callback(hObject, eventdata, handles)
% hObject    handle to original (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of original
ghandles = guihandles(hObject);
displayImage(hObject, ghandles, handles);

function glomerulus_number_Callback(hObject, eventdata, handles)
% hObject    handle to glomerulus_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ghandles = guihandles(hObject);
guidata(hObject, handles);

function displayImage(hObject, ghandles, handles)
sharpenOn = get(ghandles.sharpen, 'Value');
MIPOn = get(ghandles.MIP, 'Value');
gcampOn = get(ghandles.gcamp, 'Value');
if gcampOn
    stack = handles.refImages;
else
    stack = handles.tdTomato;
end
if (sharpenOn)
    zplane = get(ghandles.zplane, 'Value');
    ax = handles.axes1;
    image = imsharpen(squeeze(stack(:,:,zplane)));
    max_range = prctile(image(:), 98);
    imshow(image, [0 max_range], 'Parent', ax);
elseif MIPOn
    ax = handles.axes1;
    image = max(stack, [], 3);
    max_range = prctile(image(:), 98);
    imshow(image, [0 max_range], 'Parent', ax);
else
    zplane = get(ghandles.zplane, 'Value');
    ax = handles.axes1;
    image = squeeze(stack(:,:,zplane));
    max_range = prctile(image(:), 98);
    imshow(image, [0 max_range], 'Parent', ax);
end

function addROI(hObject, ghandles, handles, roi)
    ROI_list_current = get(ghandles.roi_list, 'String');
    ROI_list_current{end+1} = ['ID = ' num2str(roi.id,'%02d') ' | Name: ' roi.name];
    currentVal = size(ROI_list_current,1);
    set(handles.roi_list,'Value',currentVal,'String',ROI_list_current)
    guidata(hObject, handles);
    refreshROI(hObject, ghandles, handles);
    
function refreshROI(hObject, ghandles, handles)
% refresh display of all ROIs
ax = handles.axes1;
cla;
displayImage(hObject, ghandles, handles);
roi_data = handles.roi_all;
for i = 1:length(handles.roi_all)
    cmap = hsv(21);
    color = cmap(i, :);
    %plot(roi_data(i).xi, roi_data(i).yi,'k','linewidth',2, 'FaceAlpha', 0)
    if (contains(handles.roi_name.String,'mid')==0)
        patch('XData', roi_data(i).xi, 'YData', roi_data(i).yi, 'FaceAlpha', 0, 'EdgeColor', color, 'LineWidth', 1);
    else
        hold on
        plot(roi_data(i).xi, roi_data(i).yi)
    end
    text(mean(roi_data(i).xi), mean(roi_data(i).yi), num2str(roi_data(i).id), 'Color', color, 'FontSize', 20);
    hold on;
end

% --- Executes on button press in remove.
function remove_Callback(hObject, eventdata, handles)
% hObject    handle to remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ghandles = guihandles(hObject);
currentVal = get(handles.roi_list,'Value');
ROI_list_current = get(handles.roi_list,'String');
numResults = size(ROI_list_current,1);
% Remove the data and list entry for the selected value
id = str2num(ROI_list_current{currentVal}(6:7));
ROI_list_current(currentVal) =[];
index = find([handles.roi_all.id]== id);
handles.roi_all(index) = [];
% Ensure that list box Value is valid, then reset Value and String
currentVal = min(currentVal,size(ROI_list_current,1));
set(handles.roi_list,'Value',currentVal,'String',ROI_list_current)
% Store the new ResultsData
guidata(hObject, handles)
refreshROI(hObject, ghandles, handles);

% --- Executes on button press in dir_button.
function dir_button_Callback(hObject, eventdata, handles)
% hObject    handle to dir_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global slash;
if isunix() == 1
    slash = '/';
else
    slash = '\';
end

datapath = handles.experiment_dir;
k = strfind(datapath, [slash '2p' slash]);
originalfile = [datapath(1:k+3)];
%['E:' slash 'Dropbox (HMS)' slash 'Wilson_Lab_Data' slash 'EB_Data']
dname = uigetdir(originalfile, 'Please chose an experiment directory (Enter the specific sid and tid folder).');
handles.experiment_dir = dname;
ghandles = guihandles(hObject);
set(ghandles.filename, 'String', dname);
sid_k = strfind(dname, 'sid_');
tid_k = strfind(dname, 'tid_');
handles.sid = str2num(dname(sid_k+4:tid_k-2));
handles.tid = str2num(dname(tid_k+4:end));
handles.counter = 0;
set(handles.roi_list, 'String', []);
set(handles.roi_list, 'Value', 1);
expression2 = ['*reg_channel_*'];
imagingFile = dir(fullfile(dname, expression2));

numChannels = size(imagingFile, 1);

% initialize rois saved
handles.roi_all = [];

% display the z-stacks so I can decide which z-stacks to pull from
% update the z-plane drop down menu
if numChannels == 1 % GCAMP ONLY
    load(fullfile(handles.experiment_dir, imagingFile.name));
    handles.refImages = refImages;
    numSlices = size(refImages, 3);
    handles.numSlices = numSlices;
    handles.width = size(refImages,2);
    handles.height = size(refImages,1);
    zplanes = [];
    for j = 1:numSlices
        zplanes = [zplanes; num2str(j, '%02d')];
    end
    set(ghandles.zplane, 'String', zplanes);
    set(ghandles.zplane, 'Value', 1);
    set(ghandles.tdTomato, 'visible', 'off');
else % numChannels == 2 % SHOW GCAMP
    load(fullfile(handles.experiment_dir, imagingFile(1).name));
    handles.refImages = refImages;
    load(fullfile(handles.experiment_dir, imagingFile(2).name));
    handles.tdTomato = refImages;
    numSlices = size(refImages, 3);
    handles.numSlices = numSlices;
    handles.width = size(refImages,2);
    handles.height = size(refImages,1);
    zplanes = [];
    for j = 1:numSlices
        zplanes = [zplanes; num2str(j, '%02d')];
    end
    set(ghandles.zplane, 'String', zplanes);
    set(ghandles.zplane, 'Value', 1);
    set(ghandles.tdTomato, 'visible', 'on');
end

% Update handles structure
guidata(hObject, handles);
refreshROI(hObject, ghandles, handles);

% --- Executes on button press in import.
function import_Callback(hObject, eventdata, handles)
% hObject    handle to import (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ghandles = guihandles(hObject);
global slash;
if isunix() == 1
    slash = '/';
else
    slash = '\';
end
datapath = handles.experiment_dir;
k = strfind(datapath, [slash '2p' slash]);
roi_path = [datapath(1:k+3) 'ROI'];

[file, path] = uigetfile([roi_path slash '*.mat'], 'Choose ROI .mat file');
if isequal(file,0)
   disp('User selected Cancel')
else
   set(handles.roi_list, 'String', []);
   set(handles.roi_list, 'Value', 1);
   load(fullfile(path, file));
   handles.roi_all = roi;
   handles.counter = max([handles.roi_all.id])+1;
   for i = 1:length(handles.roi_all)
       addROI(hObject, ghandles, handles, handles.roi_all(i));
   end
end

% Update handles structure


% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
ghandles = guihandles(hObject);
switch eventdata.Key
    case 'a'
        add_Callback(hObject, eventdata, handles);
    case 'e'
        remove_Callback(hObject, eventdata, handles);
    case 'n'
        uicontrol(ghandles.glomerulus_number);
%     case 'l'
%         set(ghandles.leftPB, 'Value', 1);
%         guidata(hObject, handles);
%     case 'r'
%         set(ghandles.rightPB, 'Value', 1);
%         guidata(hObject, handles);
    case 's'
        save_all_Callback(hObject, eventdata, handles);
    case 'z'
        uicontrol(ghandles.zplane);
end
        

% --- Executes on key press with focus on zplane and none of its controls.
function zplane_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to zplane (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
ghandles = guihandles(hObject);
switch eventdata.Key
    case 'return'  
        set(gco, 'Enable', 'off');
        drawnow;
        set(gco, 'Enable', 'on');
        guidata(hObject, handles);
        set(ghandles.figure1, 'CurrentObject', ghandles.figure1);
        gco;
end



% --- Executes during object creation, after setting all properties.
function roi_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roi_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
