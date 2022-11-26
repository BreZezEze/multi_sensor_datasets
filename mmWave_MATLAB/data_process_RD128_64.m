%%%%%% 数据处理脉压、距离像 %%%%%%%
clc
clear all
close all
%%参数设置
c = 3.0e8;
k= 2.9982e13;  % 调频斜率
%k=2.9796e13;
fs = 1e7; %采样频率
FFTN = 128;%FFT点数
FFTM = 64;
FFTQ = 180;
rangPoint= 128; %采样点数
Chirp_loops=64;
B=1798.92e6;
%B=1798.92e6%对应带宽:1798.92 MHz
f0=6e10+B/2;
T=0.05/Chirp_loops;%脉冲宽度
wavelength=c/f0;
d=wavelength/2;

% % pulse_num=12800; % Chirp loops（128）* frames（100）
% %%性能
% Rmax=fs*c/(2*k);  %最大距离
% Rres=c/(2*B);     %距离分辨率
% Vmax=wavelength/(4*T);  %最大无模糊速度
% Vres=wavelength/(2*T*Chirp_loops);  %速度分辨率

% vlabel=-Vmax:2*Vmax/Chirp_loops:Vmax-2*Vmax/Chirp_loops;
% rlabel=(0:FFTN-1)*fs*c/(2*k)/FFTN;
%D:\hr1102 E:\ADCdata\RadarData_Process_mat\307hrsst\hr_sst_watch_1_Raw_0  E:\ADCdata\RadarData_Process_mat\59_240watch1_Raw_0
load(['test3_Raw_0'  '.mat'],'RX1_data','RX2_data','RX3_data','RX4_data','period_numbers');
TX_numbers=1;
RX_numbers=4;  %设置发射和接收天线
Num_Channel = TX_numbers*RX_numbers;% 通道数

x=2; %使用第x帧的数据

RX1Channe_data = RX1_data';
RX2Channe_data = RX2_data';
RX3Channe_data = RX3_data';
RX4Channe_data = RX4_data';

%% 通道数据获取

Distance(:,:,1) = RX1Channe_data(1:3:end,:); % T0发R0收
Distance(:,:,2) = RX2Channe_data(1:3:end,:); % T0发R1收
Distance(:,:,3) = RX3Channe_data(1:3:end,:); % T0发R2收
Distance(:,:,4) = RX4Channe_data(1:3:end,:); % T0发R3收

% Distance(:,:,5) = RX1Channe_data(2:3:end,:); % T1发R0收
% Distance(:,:,6) = RX2Channe_data(2:3:end,:); % T1发R1收
% Distance(:,:,7) = RX3Channe_data(2:3:end,:); % T1发R2收
% Distance(:,:,8) = RX4Channe_data(2:3:end,:); % T1发R3收
% 
% Distance(:,:,9) = RX1Channe_data(3:3:end,:); % T2发R0收
% Distance(:,:,10) = RX2Channe_data(3:3:end,:); % T2发R1收
% Distance(:,:,11) = RX3Channe_data(3:3:end,:); % T2发R2收
% Distance(:,:,12) = RX4Channe_data(3:3:end,:); % T2发R3收

%% 雷达3维FFT处理
radar_data(:,:,1)=Distance(:,:,1)';
radar_data(:,:,2)=Distance(:,:,2)';
radar_data(:,:,3)=Distance(:,:,3)';
radar_data(:,:,4)=Distance(:,:,4)';
% radar_data(:,:,5)=Distance(:,:,5)';
% radar_data(:,:,6)=Distance(:,:,6)';
% radar_data(:,:,7)=Distance(:,:,7)';
% radar_data(:,:,8)=Distance(:,:,8)';
% radar_data(:,:,9)=Distance(:,:,9)';
% radar_data(:,:,10)=Distance(:,:,10)';
% radar_data(:,:,11)=Distance(:,:,11)';
% radar_data(:,:,12)=Distance(:,:,12)';

range_win = hamming(rangPoint);   %加海明窗
doppler_win = hamming(Chirp_loops);
range_profile = [];

%% 消除静态分量(距离仓减慢时间维的均值)
for u=1:Num_Channel
    for w=1:rangPoint
        mm(w)=mean(radar_data(:,64*(x-1)+w,u));
    end

    for jj=1:rangPoint/2
        radar_data(jj,Chirp_loops*(x-1)+1:Chirp_loops*(x-1)+Chirp_loops,u)=radar_data(jj,Chirp_loops*(x-1)+w,u)-mm(w);
    end
end

%% 二脉冲对消
for u=1:Num_Channel
    for q=1:Chirp_loops-1
        radar_data(:,Chirp_loops*(x-1)+q,u)=radar_data(:,Chirp_loops*(x-1)+q+1,u)-radar_data(:,Chirp_loops*(x-1)+q,u);
    end
end
%距离FFT
for l=1:Num_Channel
   for m=1:Chirp_loops
       temp=radar_data(:,Chirp_loops*(x-1)+m,l).*range_win;    %加窗函数
      temp_fft=fft(temp,FFTN);    %对每个chirp做N点FFT
      range_profile(:,m,l)=temp_fft;
   end
end
%多普勒FFT
speed_profile = [];
for l=1:Num_Channel
    for n=1:FFTN
      temp=range_profile(n,:,l).*(doppler_win)';    
      temp_fft=fftshift(fft(temp,FFTM));    %对rangeFFT结果进行M点FFT
      speed_profile(n,:,l)=temp_fft;  
    end
end
%角度FFT
angle_profile = [];
for n=1:FFTN   %range
    for m=1:FFTM   %chirp
      temp=speed_profile(n,m,:);    
      temp_fft=fftshift(fft(temp,FFTQ));    %对2D FFT结果进行Q点FFT
      angle_profile(n,m,:)=temp_fft;  
    end
end

%% 雷达绘制2维FFT处理三维视图
figure(1);
speed_profile_temp = reshape(speed_profile(:,:,3),FFTN,FFTM);   
speed_profile_Temp = speed_profile_temp';
[X,Y]=meshgrid((0:FFTN-1)*fs*c/FFTN/2/k,(-FFTM/2:FFTM/2-1)*wavelength/T/FFTM/2);
mesh(X,Y,(abs(speed_profile_Temp))); 
xlabel('距离(m)');ylabel('速度(m/s)');zlabel('信号幅值');
title('2D-FFT处理三维视图');
xlim([0 (FFTN-1)*fs*c/FFTN/2/k]); ylim([(-FFTM/2)*wavelength/T/FFTM/2 (FFTM/2-1)*wavelength/T/FFTM/2]);

figure(2);
XX=(0:FFTN-1)*fs*c/FFTN/2/k;
YY=(-FFTM/2:FFTM/2-1)*wavelength/T/FFTM/2;
D=speed_profile_Temp;
%D(64:66,:)=0;
% D(find(20*log10(abs(D))>105))=0;   %将功率小于x的滤除
 D(find(20*log10(abs(D))<20))=0; 
imagesc(XX,YY,20*log10(abs(D)));
shading interp;
shading flat;
%imagesc(20*log10(abs(D)));
set(gca, 'YDir', 'normal')
xlabel('Distance (m)')
ylabel('Velocity(m/s)');
title('RD')
 colorbar;
 colormap jet;
caxis([20 160]);

figure(3);
% D=speed_profile_Temp(:,:);
pcolor(20*log10(abs(D(:,:))));%切区域测试

set(gca, 'YDir', 'normal')
shading interp;
shading flat;
colorbar;
colormap jet;

% figure(4);
% % D=speed_profile_Temp(:,:);
% pcolor(20*log10(abs(D(:,:))));%切区域测试
% 
% set(gca, 'YDir', 'normal')
% shading interp;
% shading flat;
% colorbar;
% colormap jet;

%% 计算峰值位置
angle_profile=abs(angle_profile);
pink=max(angle_profile(:));
[row,col,pag]=ind2sub(size(angle_profile),find(angle_profile==pink));
%% 计算目标距离、速度、角度
fb = ((row-1)*fs)/FFTN;           %差拍频率
fd = (col-FFTM/2-1)/(FFTM*T);     %多普勒频率
fw = (pag-FFTQ/2-1)/FFTQ;         %空间频率
R = c*(fb-fd)/2/k;                %距离公式
v = wavelength*fd/2;              %速度公式
theta = asin(fw*wavelength/d);    %角度公式
angle = theta*180/pi;
fprintf('目标距离： %f m\n',R);
fprintf('目标速度： %f m/s\n',v);
fprintf('目标角度： %f°\n',angle);
