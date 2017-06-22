function varargout = rover_model(varargin)
% UNTITLED1 MATLAB code for untitled1.fig
%      UNTITLED1, by itself, creates a new UNTITLED1 or raises the existing
%      singleton*.
%
%      H = UNTITLED1 returns the handle to a new UNTITLED1 or the handle to
%      the existing singleton*.
%
%      UNTITLED1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UNTITLED1.M with the given input arguments.
%
%      UNTITLED1('Property','Value',...) creates a new UNTITLED1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before untitled1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to untitled1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help untitled1

% Last Modified by GUIDE v2.5 22-Jun-2017 07:58:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @untitled1_OpeningFcn, ...
                   'gui_OutputFcn',  @untitled1_OutputFcn, ...
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



% --- Executes just before untitled1 is made visible.
function untitled1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to untitled1 (see VARARGIN)

% Choose default command line output for untitled1
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%定义一个定时器，添加到handles结构体中，方便后面使用
global time 
time = 0;
handles.ht=timer;  
set(handles.ht,'ExecutionMode','FixedRate');%ExecutionMode   执行的模式  
set(handles.ht,'Period',1);%周期
set(handles.ht,'TimerFcn',{@dispNow, handles});%定时器的执行函数  
start(handles.ht);%启动定时器,对应的stop(handles.ht)  

% 传感器坐标 横坐标 纵坐标
global sensors_pos
sensors_pos = 1000*rand(3,2);
%传感器向量
%剩余硬盘 天气 电池
global sensors 
sensors = [ 
    10*1024*1024 0 100;
    10*1024*1024 0 100;
    10*1024*1024 0 100;    
];
%硬盘消耗速度
global buffer_cost
buffer_cost = 512;
%充电速度
global charge
charge = 1;
%耗电速度
global cost
cost = 1;
%紧急度出现概率,
global urgency
urgency = [
    50;
    80;
    100
];
global rover_pos
rover_pos = 1000*rand(1,2);

draw_init()

function draw_init()
    % 初始化窗口绘图
    global sensors_pos
    sensors_pos = 1000*rand(3,2);
    x = sensors_pos(:,1:1);
    y = sensors_pos(:,2:2);
    scatter(x,y,80,'filled');

    global rover_pos
    rover_pos = 1000*rand(1,2);
    rectangle('Position',[rover_pos(1:1,1:1),rover_pos(1:1,2:2),15,15],'FaceColor','black','EdgeColor','black');
    axis([0 1000 0 1000])

%计时器回调函数
function dispNow(hObject,eventdata,handles)
    global time
    time = time + 1;
    global sensors
    sensors(:,1) = sensors(:,1)-3;
    m = size(sensors);
    global charge
    global cost
    for i=1:m
        % 充电耗电
        if time>6&&time<18
            if sensors(i,3)<100
                sensors(i, 3) = sensors(i,3)+charge;
            end 
        else
            sensors(i,3) = sensors(i,3)-cost;
        end
        % 硬盘空间消耗
        if sensors(i,2)-512>0
            sensors(i,2)=sensors(i,2)-512;
        end
        % 紧急度
    end

    set(handles.time_dis,'string',time);
    
% --- Outputs from this function are returned to the command line.
function varargout = untitled1_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in update_button.
%update 按钮 绑定更新算法的操作
function update_button_Callback(hObject, eventdata, handles)
    % hObject    handle to update_button (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    axes(handles.axes1);
    cla;

    popup_sel_index = get(handles.popupmenu1, 'Value');
    draw_init()
    switch popup_sel_index
        case 1
        case 2
            plot(sin(1:0.01:25.99));
    end


% --------------------------------------------------------------------
% 菜单栏，没啥用
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
% 菜单栏打开对话框，没啥用
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
%打印到打印机 没啥用
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'plot(rand(5))', 'plot(sin(1:0.01:25))', 'bar(1:.5:10)', 'plot(membrane)', 'surf(peaks)'});


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
