function varargout = rover_model(varargin)
% UNTITLED1 MATLAB code for rover_model.fig
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

% Last Modified by GUIDE v2.5 22-Jun-2017 09:01:32

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



% --- Executes just before rover_model is made visible.
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


% 小车坐标
global rover_pos
rover_pos = randi(1000,1,2);

% 传感器坐标 横坐标 纵坐标
global sensors_pos
sensors_pos = randi(1000,3,2);
%小车到每个传感器距离
dis=((rover_pos(1,1)-sensors_pos(:,1)).^2+(rover_pos(1,2)-sensors_pos(:,2)).^2).^0.5;

%传感器向量，也是训练的输入数据
%剩余硬盘[0-10*1024*1024] 天气[优/良/中/差0/1/2/3] 电池[3-100] 数据紧急度[1-10] 小车和传感器的距离
global sensors 
sensors = [ 
    10*1024*1024 0 50 0;
    10*1024*1024 0 80 0;
    10*1024*1024 0 100 0;    
];
sensors=[sensors, dis];

%硬盘消耗速度
global buffer_cost
buffer_cost = 512;
%充电速度
global charge
charge = 0.8;
%耗电速度
global cost
cost = 1;
%紧急度出现的概率分母
global urgency
urgency = [
    50;
    80;
    100
];

%假定恶劣天气点从右往左移动
global weather_pos
weather_pos = 1000*rand(3,2);
%恶劣天气点的半径，分别是差/中/良的半径
global weather_radius
weather_radius = [
    300, 40, 20;
    30, 20, 10;
    400, 20, 10
];
draw_init()
%假定rover和恶劣天气的移动速度都是10
global speed
speed = 10;

%r             读出
%w             写入（文件若不存在，自动创建）
%a             后续写入（文件若不存在，自动创建）
%r+            读出和写入（文件应已存在）
%w+            重新刷新写入，（文件若不存在，自动创建）
%a+            后续写入（文件若不存在，自动创建））
%w             重新写入，但不自动刷新
%a             后续写入，但不自动刷新
%生成文件
global output_flag
output_flag = 1;
if output_flag == 1
    filename = datestr(now,1);
    filename = [filename,'_setting.txt'];
    fid=fopen(filename,'w+');
    fprintf(fid,'%g\t',sensors_pos);
    fprintf(fid,'\n');
    fprintf(fid,'%g\t',sensors);
    fprintf(fid,'\n');
    fprintf(fid,'%g\t',urgency);
    fprintf(fid,'\n');
    fprintf(fid,'%g\t',rover_pos);
    fprintf(fid,'\n');
    fprintf(fid,'%g\t',weather_pos);
    fprintf(fid,'\n');
    fprintf(fid,'%g\t',weather_radius);
    fprintf(fid,'\n');
    fprintf(fid,'%g\t',speed);
    fprintf(fid,'\n');
    fclose(fid);
end

%定义一个定时器，添加到handles结构体中，方便后面使用
global time 
time = 0;
handles.ht=timer;  
set(handles.ht,'ExecutionMode','FixedRate');%ExecutionMode   执行的模式  
set(handles.ht,'Period',1);%周期
set(handles.ht,'TimerFcn',{@dispNow, handles});%定时器的执行函数  
start(handles.ht);%启动定时器,对应的stop(handles.ht)  




% 初始化窗口绘图
function draw_init()
    global sensors_pos
    sensors_pos = randi(1000,3,2);
    x = sensors_pos(:,1:1);
    y = sensors_pos(:,2:2);
    global sensors_p
    sensors_p = scatter(x,y,80,'filled');

    %global weather_pos
    %global weather_p
    %global weather_radius
    %weather_p = scatter(weather_pos(1,1),weather_pos(1,2),weather_radius(1,1));
    
    global rover_pos
    rover_pos = randi(1000,1,2);
    global rover_p
    rover_p = rectangle('Position',[rover_pos(1:1,1:1),rover_pos(1:1,2:2),15,15],'FaceColor','black','EdgeColor','black');
    axis([0 1000 0 1000])

    
%计时器回调函数
function dispNow(hObject,eventdata,handles)
    global time
    time = time + 1;
    global speed
    global sensors
    sensors(:,1) = sensors(:,1)-512;
    [m,n] = size(sensors);
    global charge
    global cost
    global urgency
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
        x = randi(urgency(i,1), 1,1);
        if x==urgency
            % i行4列产生紧急度为1-10的紧急数据
            sensors(i,4)=sensors(i,4)+randi(10,1,1);
        end
    end

    
    %更新天气移动
    global weather_pos
    global weather_radius
    global sensors_pos
    weather_pos(:,1) = weather_pos(:,1)+10;
    [wm,wn] = size(weather_pos);
    for i=1:wm
        if weather_pos(i,1)-weather_radius(i,1)>1000
            weather_pos(i,1)=-weather_radius(i,1);
            weather_pos(i,2)=1000*rand(1,1);
        end
        %根据天气恶劣点，更新每个传感器的天气状态
        for j=1:m
            dis = ((weather_pos(i,1)-sensors_pos(j,1))^2+(weather_pos(i,2)-sensors_pos(j,2))^2)^0.5;
            if dis < weather_radius(i,1)
                sensors(j,2)=3;
            elseif dis < weather_radius(i,2)
                if sensors(j,2)<3
                    sensors(j,2)=2;
                end
            elseif dis < weather_radius(i,3)
                if sensors(j,2)<2
                    sensors(j,2)=1;
                end
            else
                sensors(j,2)=0;
            end
        end
    end
    
    
            
    
    %global weather_p
    %set(weather_p,'XData', weather_pos(1,1),'YData',weather_pos(1,2));
    
    % 更新小车移动
    global rover_pos
    rover_pos(1,1) = rover_pos(1,1)+10;
    global rover_p
    set(rover_p,'Position', [rover_pos(1:1,1:1),rover_pos(1:1,2:2),15,15]);
    
    % 更新时间显示
    time_text = ['time:',num2str(time),'h'];
    text = [time_text];
    set(handles.time_dis,'string',text);
    
    % 记录输出
    
    global output_flag
    output_flag = 1;
    if output_flag == 1
        filename = datestr(now,1);
        filename = [filename,'_run.txt'];
        fid=fopen(filename,'a');
        fprintf(fid,'%g\t',sensors_pos);
        fprintf(fid,'\n');
        fprintf(fid,'%g\t',sensors);
        fprintf(fid,'\n');
        fprintf(fid,'%g\t',urgency);
        fprintf(fid,'\n');
        fprintf(fid,'%g\t',rover_pos);
        fprintf(fid,'\n');
        fprintf(fid,'%g\t',weather_pos);
        fprintf(fid,'\n');
        fprintf(fid,'%g\t',weather_radius);
        fprintf(fid,'\n');
        fprintf(fid,'%g\t',speed);
        fprintf(fid,'\n');
    end
    
    
% --- Outputs from this function are returned to the command line.
% --- 命令行的输出函数
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
function start_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton5.
function pause_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton6.
function add_sensor_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in update.
function update_Callback(hObject, eventdata, handles)
% hObject    handle to update (see GCBO)
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
