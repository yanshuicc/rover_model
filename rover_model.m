function varargout = rover_model(varargin)
	% rover_model MATLAB code for rover_model.fig
	%      rover_model, by itself, creates a new rover_model or raises the existing
	%      singleton*.
	%
	%      H = rover_model returns the handle to a new rover_model or the handle to
	%      the existing singleton*.
	%
	%      rover_model('CALLBACK',hObject,eventData,handles,...) calls the local
	%      function named CALLBACK in rover_model.M with the given input arguments.
	%
	%      rover_model('Property','Value',...) creates a new rover_model or raises the
	%      existing singleton*.  Starting from the left, property value pairs are
	%      applied to the GUI before untitled1_OpeningFcn gets called.  An
	%      unrecognized property name or invalid value makes property application
	%      stop.  All inputs are passed to untitled1_OpeningFcn via varargin.
	%
	%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
	%      instance to run (singleton)".
	%
	% See also: GUIDE, GUIDATA, GUIHANDLES

	% Edit the above text to modify the response to help rover_model

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


    % С������
    global rover_pos
    rover_pos = randi(1000,1,2);

    % ���������� ������ ������
    global sensors_pos
    sensors_pos = randi(1000,3,2);
    %С����ÿ������������
    dis=round(((rover_pos(1,1)-sensors_pos(:,1)).^2+(rover_pos(1,2)-sensors_pos(:,2)).^2).^0.5);

    %������������Ҳ��ѵ������������
    %ʣ��Ӳ��[0-10*1024*1024] ����[��/��/��/��4/3/2/1] ���[3-100](��ʼ����������״̬) ���ݽ�����[1-5] С���ʹ������ľ���
    global sensors 
    % ����Ӳ�̴洢�ռ�GB
    global max_buffer 
    max_buffer = 10*1024;
    sensors = [ 
        max_buffer 4 50 0;
        max_buffer 4 80 0;
        max_buffer 4 100 0;
    ];
    sensors=[sensors, dis];

    %Ӳ�������ٶ�
    global buffer_cost
    buffer_cost = 0.5;
    %����ٶ�
    global charge
    charge = 0.8;
    %�ĵ��ٶ�
    global cost
    cost = 1;
    %�����ȳ��ֵĸ��ʷ�ĸ
    global urgency
    urgency = [
        10;
        50;
        70;
        100;
        200;
    ];

    %�ٶ�������������������ƶ�
    global weather_pos
    weather_pos = randi(1000,3,2);
    %����������İ뾶���ֱ��ǲ�/��/���İ뾶
    global weather_radius
    weather_radius = [
        300, 40, 20;
        30, 20, 10;
        400, 20, 10
    ];
    %�ٶ�rover�Ͷ����������ƶ��ٶȶ���10
    global speed
    speed = 10;

    global day_count
    global hour_count
    day_count = 0;
    hour_count = 0;
    %r             ����
    %w             д�루�ļ��������ڣ��Զ�������
    %a             ����д�루�ļ��������ڣ��Զ�������
    %r+            ������д�루�ļ�Ӧ�Ѵ��ڣ�
    %w+            ����ˢ��д�룬���ļ��������ڣ��Զ�������
    %a+            ����д�루�ļ��������ڣ��Զ���������
    %w             ����д�룬�����Զ�ˢ��
    %a             ����д�룬�����Զ�ˢ��
    %���������ļ�
    global output_flag
    output_flag = 1;
    global output_setting_flag
    output_setting_flag = 1;
    global input_setting_flag
    input_setting_flag = 0;

    if output_setting_flag == 1
        filename = datestr(now,1);
        filename = [filename,'_setting.txt'];
        fid=fopen(filename,'w+');
        fprintf(fid,'%g\t',sensors_pos);
        fprintf(fid,'\n');
        fprintf(fid,'%g\t',urgency);
        fprintf(fid,'\n');
        fprintf(fid,'%g\t',weather_radius);
        fprintf(fid,'\n');
        fprintf(fid,'%g\t',speed);
        fprintf(fid,'\n');
        fclose(fid);
    end
    if input_setting_flag == 1
        filename = datestr(now,1);
        filename = [filename,'_setting.txt'];
        fid=fopen(filename,'r');
        tline=fgetl(fid); 
        sensors_pos_vector = str2num(tline);
        [~,n1] = size(sensors_pos_vector);
        sensors_pos = reshape(sensors_pos_vector,n1/2,2);
        tline=fgetl(fid); 
        urgency_vector = str2num(tline);
        urgency = reshape(urgency_vector,3,1);
        tline=fgetl(fid); 
        weather_vector = str2num(tline);
        [~,n2] = size(weather_vector);
        weather_radius = reshape(weather_vector,n2/3,3);
        tline=fgetl(fid); 
        speed = str2double(tline);
        read_last_line(n1/2,n2/3);
    end

    draw_init()
    %����һ����ʱ������ӵ�handles�ṹ���У��������ʹ��
    handles.ht=timer;  
    set(handles.ht,'ExecutionMode','FixedRate');%ExecutionMode   ִ�е�ģʽ  
    set(handles.ht,'Period',0.1); %����,��λΪ��
    set(handles.ht,'TimerFcn',{@dispNow, handles});%��ʱ����ִ�к���  
    start(handles.ht);%������ʱ��,��Ӧ��stop(handles.ht)  




% ��ʼ�����ڻ�ͼ
function draw_init()
    global sensors_pos
    x = sensors_pos(:,1:1);
    y = sensors_pos(:,2:2);
    global sensors_p
    sensors_p = scatter(x,y,80,'filled');

    %global weather_pos
    %global weather_p
    %global weather_radius
    %weather_p = scatter(weather_pos(1,1),weather_pos(1,2),weather_radius(1,1));
    
    global rover_pos
    global rover_p
    rover_p = rectangle('Position',[rover_pos(1:1,1:1),rover_pos(1:1,2:2),15,15],'FaceColor','black','EdgeColor','black');
    axis([0 1000 0 1000])

    
%��ʱ���ص�����
function dispNow(hObject,eventdata,handles)
    global hour_count
    global day_count
    hour_count = hour_count + 1;
    if hour_count == 24
        hour_count = 0;
        day_count = day_count+1;
    end
    global sensors
    [m,n] = size(sensors);
    global charge
    global cost
    global urgency
    for i=1:m
        % ���ĵ�
        if hour_count>6&&hour_count<18
            if sensors(i,3)<100
                sensors(i, 3) = sensors(i,3)+charge;
            end 
        else
            sensors(i,3) = sensors(i,3)-cost;
        end
        % Ӳ�̿ռ�����
        if sensors(i,1)-1>0
            sensors(i,1)=sensors(i,1)-1;
        end
        % ������
        x = randi(urgency(i,1), 1,1);
        if x==urgency(i,1)
            % i��4�в���������Ϊ1-5�Ľ�������
            sensors(i,4)=sensors(i,4)+randi(5,1,1);
        end
    end

    
    %���������ƶ�
    global weather_pos
    global weather_radius
    global sensors_pos
    weather_pos(:,1) = weather_pos(:,1)+10;
    [wm,~] = size(weather_pos);
    for i=1:wm
        if weather_pos(i,1)-weather_radius(i,1)>1000
            weather_pos(i,1)=-weather_radius(i,1);
            weather_pos(i,2)=1000*rand(1,1);
        end
        %�����������ӵ㣬����ÿ��������������״̬
        for j=1:m
            dis = round(((weather_pos(i,1)-sensors_pos(j,1))^2+(weather_pos(i,2)-sensors_pos(j,2))^2)^0.5);
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
    
    
    % ����С���ƶ�
    sensor_id = judge_sensor();
    direction = judge_direction(sensor_id);
    global rover_pos
    global speed
    if direction == 1
        rover_pos = rover_pos+[-1,0]*speed;
    elseif direction ==2
        rover_pos = rover_pos+[1,0]*speed;
    elseif direction ==3
        rover_pos = rover_pos+[0,-1]*speed;
    elseif direction ==4
        rover_pos = rover_pos+[0,1]*speed;
    end
    global max_buffer
    %���С����Ŀ�괫��������ܽ��������ݻ���һСʱ�ڴ�����ɣ�Ӳ�̿ռ���գ����ݽ����ȹ�0
    dis = round(((rover_pos(1,1)-sensors_pos(sensor_id,1))^2+(rover_pos(1,2)-sensors_pos(sensor_id,2))^2)^0.5);
    if dis <= 10
        sensors(sensor_id,1)=max_buffer;
        sensors(sensor_id,4)=0;
    end
    global rover_p
    set(rover_p,'Position', [rover_pos(1:1,1:1),rover_pos(1:1,2:2),15,15]);
    
    % �����ı���ʾ
    time_text = ['day:',num2str(day_count),'hour:',num2str(hour_count),'h'];
    global priority
    [pm,~] = size(priority);
    priority_text = 'priority:';
    for i=1:pm
        priority_text = [priority_text, num2str(priority(i,1)),10];
    end
    text = [time_text,10,priority_text];
    set(handles.time_dis,'string',text);
    
    % ���������־�������¼��������ʱ�仯������
    global output_flag
    if output_flag == 1
        filename = datestr(now,1);
        filename = [filename,'_run.txt'];
        fid=fopen(filename,'a');
        fprintf(fid,'%g\t',day_count);
        fprintf(fid,'%g\t',hour_count);
        fprintf(fid,'%g\t',sensors);
        fprintf(fid,'%g\t',rover_pos);
        fprintf(fid,'%g\t',weather_pos);
        fprintf(fid,'\n');
        fclose(fid);
    end
    % ���ѵ��ģ��,�����ѵ���õ�������
    if output_flag == 1
        filename = datestr(now,1);
        filename = [filename,'_train_model.txt'];
        fid=fopen(filename,'a');
        fprintf(fid,'%g\t',sensors);
        fprintf(fid,'%g\t',rover_pos);
        fprintf(fid,'%g\t',sensor_id);
        fclose(fid);
    end
    
% ����ʣ����� �������Ӷ� ���ݽ����� ���� �������ȼ���ߵ�sensor���
function sensor_id = judge_sensor()
    global max_buffer
    global sensors
    [m,~] = size(sensors);
    % m��sensor�����ȼ����㣬�洢Ϊ������
    global priority
    priority = zeros(m,1);
    for i=1:m
        % ������Ȩ��Ϊ0.3
        priority(i,1) = priority(i,1)+(max_buffer-sensors(i,1))/max_buffer*0.3;
        % ����Ȩ��Ϊ0.2
        priority(i,1) = priority(i,1)+sensors(i,2)/4*0.2;
        % ����Ȩ��Ϊ0.1
        priority(i,1) = priority(i,1)+(100-sensors(i,3))/100*0.1;
        % 5����Ľ����¼��ٶ�Ϊ�ؼ��¼������ȼ�Ϊ1�������¼�Ȩ��Ϊ0.3
        if sensors(i,4) == 5
            priority(i,1) = priority(i,1)+1;
        else        
            priority(i,1) = priority(i,1)+sensors(i,4)/5*0.3;
        end
        % ����Ȩ��Ϊ0.05
        priority(i,1) = priority(i,1)+sensors(i,5)/(1000^2+1000^2)^0.5*0.05;
    end
    [~,sensor_id] = max(priority);

% ����sensor��λ�ú�rover��λ���ж��ƶ�����
function direction = judge_direction(sensor_id)
    global rover_pos
    global sensors_pos
    sensor_pos = sensors_pos(sensor_id,:);
    dis_vec = rover_pos - sensor_pos;
    if abs(dis_vec(1,1))>abs(dis_vec(1,2))
        if dis_vec(1,1) > 0
            %[-1, 0]
            direction = 1;
        else
            %[1, 0]
            direction = 2;
        end
    else
        if dis_vec(1,2) > 0
            %[0, -1]
            direction = 3;
        else
            %[0, 1]
            direction = 4;
        end        
    end
    
function read_last_line(m1,m2)
        filename = datestr(now,1);
        filename = [filename,'_run.txt'];
        fid=fopen(filename,'r');
        row=0;
        while ~feof(fid) % �Ƿ��ȡ���ļ���β
            line=fgetl(fid); % ����fgetl
            row=row+1; % �����ۼ�
        end
        global hour_count 
        S = regexp(line, '\t', 'split');
        [~,sn] = size(S);
        vector = zeros(1,sn-1);
        for i=1:sn-1
            vector(1,i) = str2double(S(1,i));
        end
        hour_count = vector(1,1);
        global sensors
        sensors = reshape(vector(1,2:2+m1*5),m1,5);
        global rover_pos
        rover_pos = reshape(vector(1,2+m1*5+1:2+m1*5+2),1,2);
        global weather_pos
        weather_pos = reshape(1,vector(2+m1*5+2:2+m1*5+2+m2*2),m2,2);
        fclose(fid);

    
% --- Outputs from this function are returned to the command line.
% --- �����е��������
function varargout = untitled1_OutputFcn(hObject, eventdata, handles)
	% varargout  cell array for returning output args (see VARARGOUT);
	% hObject    handle to figure
	% eventdata  reserved - to be defined in a future version of MATLAB
	% handles    structure with handles and user data (see GUIDATA)

	% Get default command line output from handles structure
	varargout{1} = handles.output;

% --- Executes on button press in update_button.
%update ��ť �󶨸����㷨�Ĳ���
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
    end


% --------------------------------------------------------------------
% �˵�����ûɶ��
function FileMenu_Callback(hObject, eventdata, handles)
	% hObject    handle to FileMenu (see GCBO)
	% eventdata  reserved - to be defined in a future version of MATLAB
	% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
% �˵����򿪶Ի���ûɶ��
function OpenMenuItem_Callback(hObject, eventdata, handles)
	% hObject    handle to OpenMenuItem (see GCBO)
	% eventdata  reserved - to be defined in a future version of MATLAB
	% handles    structure with handles and user data (see GUIDATA)
	file = uigetfile('*.fig');
	if ~isequal(file, 0)
		open(file);
	end

% --------------------------------------------------------------------
%��ӡ����ӡ�� ûɶ��
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
