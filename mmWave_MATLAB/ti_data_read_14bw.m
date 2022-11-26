
%%%%%% IWR6843+DCA1000 数据解析 %%%%%%%
clc
clear all
close all

%% 数据读取
CurrentFolder = pwd;
% 读取数据文件
cd('bowen1115\');%       D:\sst307      D:\ADCdata\adc2pc
[filename, pathname] = uigetfile({'*.bin'}, 'File Selector');
if isequal(filename,0) || isequal(pathname,0)
    cd(CurrentFolder);
    error('用户点击了取消，退出');
else
    open_filename = fullfile(pathname, filename);
    disp(['当前打开的数据文件为：', open_filename]);
end
% 回到m文件所在路径
cd(CurrentFolder);
fname = open_filename;         % 数据bin文件位置
[retVal] = readDCA1000(fname); % 数据读取,retVal=[RX1data;RX2data;RX3data;RX4data]

period_point_numbers = 128; % 一个周期的采样点数
period_numbers = size(retVal,2); % 周期数
chirp_numbers = 64; % 一帧的周期数chirploops
frame_numbers = period_numbers/chirp_numbers;

frame_begin = 1;     % 设置开始帧数
frame_end = 7500;     % 设置结束帧数


RX1_data = retVal(period_point_numbers*0+1 : period_point_numbers*1,((frame_begin-1)*chirp_numbers+1):frame_end*chirp_numbers);
RX2_data = retVal(period_point_numbers*1+1 : period_point_numbers*2,((frame_begin-1)*chirp_numbers+1):frame_end*chirp_numbers);
RX3_data = retVal(period_point_numbers*2+1 : period_point_numbers*3,((frame_begin-1)*chirp_numbers+1):frame_end*chirp_numbers);
RX4_data = retVal(period_point_numbers*3+1 : period_point_numbers*4,((frame_begin-1)*chirp_numbers+1):frame_end*chirp_numbers);

% clear retVal
save(['adc_data'  '.mat'],'RX1_data','RX2_data','RX3_data','RX4_data','period_numbers');

% disp(['数据解析完毕！共',num2str(frame_end),'帧，',num2str(frame_end*3),'个周期数据！']);
