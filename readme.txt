### setting file format

	sensors_pos=[2,1]
	%紧急度概率分母
	urgency=[1]
	weather_radius=[3,2,1]
	speed 

### run file format

	%剩余硬盘,天气,电池,数据紧急度,小车和传感器距离
	time
	sensors=[5,4,3,2,1]
	rover_pos=[2,1]
	weather_pos=[2,1]
	
	
### train file format
	
	sensor_id
	sensors=[5,4,3,2,1]
	rover_pos=[2,1]

>矩阵中的数字表示一组列向量	
	
#### 优先级公式
priority=(max_buffer-free_buffer)/max_buffer*0.2+(weather_condition)/4*0.2+(100-battery)*0.1+urgency/5*0.3+distance/(1000^2+1000^2)^(0.5)*0.05