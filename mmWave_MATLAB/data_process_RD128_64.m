%%%%%% ���ݴ�����ѹ�������� %%%%%%%
clc
clear all
close all
%%��������
c = 3.0e8;
k= 2.9982e13;  % ��Ƶб��
%k=2.9796e13;
fs = 1e7; %����Ƶ��
FFTN = 128;%FFT����
FFTM = 64;
FFTQ = 180;
rangPoint= 128; %��������
Chirp_loops=64;
B=1798.92e6;
%B=1798.92e6%��Ӧ����:1798.92 MHz
f0=6e10+B/2;
T=0.05/Chirp_loops;%������
wavelength=c/f0;
d=wavelength/2;

% % pulse_num=12800; % Chirp loops��128��* frames��100��
% %%����
% Rmax=fs*c/(2*k);  %������
% Rres=c/(2*B);     %����ֱ���
% Vmax=wavelength/(4*T);  %�����ģ���ٶ�
% Vres=wavelength/(2*T*Chirp_loops);  %�ٶȷֱ���

% vlabel=-Vmax:2*Vmax/Chirp_loops:Vmax-2*Vmax/Chirp_loops;
% rlabel=(0:FFTN-1)*fs*c/(2*k)/FFTN;
%D:\hr1102 E:\ADCdata\RadarData_Process_mat\307hrsst\hr_sst_watch_1_Raw_0  E:\ADCdata\RadarData_Process_mat\59_240watch1_Raw_0
load(['test3_Raw_0'  '.mat'],'RX1_data','RX2_data','RX3_data','RX4_data','period_numbers');
TX_numbers=1;
RX_numbers=4;  %���÷���ͽ�������
Num_Channel = TX_numbers*RX_numbers;% ͨ����

x=2; %ʹ�õ�x֡������

RX1Channe_data = RX1_data';
RX2Channe_data = RX2_data';
RX3Channe_data = RX3_data';
RX4Channe_data = RX4_data';

%% ͨ�����ݻ�ȡ

Distance(:,:,1) = RX1Channe_data(1:3:end,:); % T0��R0��
Distance(:,:,2) = RX2Channe_data(1:3:end,:); % T0��R1��
Distance(:,:,3) = RX3Channe_data(1:3:end,:); % T0��R2��
Distance(:,:,4) = RX4Channe_data(1:3:end,:); % T0��R3��

% Distance(:,:,5) = RX1Channe_data(2:3:end,:); % T1��R0��
% Distance(:,:,6) = RX2Channe_data(2:3:end,:); % T1��R1��
% Distance(:,:,7) = RX3Channe_data(2:3:end,:); % T1��R2��
% Distance(:,:,8) = RX4Channe_data(2:3:end,:); % T1��R3��
% 
% Distance(:,:,9) = RX1Channe_data(3:3:end,:); % T2��R0��
% Distance(:,:,10) = RX2Channe_data(3:3:end,:); % T2��R1��
% Distance(:,:,11) = RX3Channe_data(3:3:end,:); % T2��R2��
% Distance(:,:,12) = RX4Channe_data(3:3:end,:); % T2��R3��

%% �״�3άFFT����
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

range_win = hamming(rangPoint);   %�Ӻ�����
doppler_win = hamming(Chirp_loops);
range_profile = [];

%% ������̬����(����ּ���ʱ��ά�ľ�ֵ)
for u=1:Num_Channel
    for w=1:rangPoint
        mm(w)=mean(radar_data(:,64*(x-1)+w,u));
    end

    for jj=1:rangPoint/2
        radar_data(jj,Chirp_loops*(x-1)+1:Chirp_loops*(x-1)+Chirp_loops,u)=radar_data(jj,Chirp_loops*(x-1)+w,u)-mm(w);
    end
end

%% ���������
for u=1:Num_Channel
    for q=1:Chirp_loops-1
        radar_data(:,Chirp_loops*(x-1)+q,u)=radar_data(:,Chirp_loops*(x-1)+q+1,u)-radar_data(:,Chirp_loops*(x-1)+q,u);
    end
end
%����FFT
for l=1:Num_Channel
   for m=1:Chirp_loops
       temp=radar_data(:,Chirp_loops*(x-1)+m,l).*range_win;    %�Ӵ�����
      temp_fft=fft(temp,FFTN);    %��ÿ��chirp��N��FFT
      range_profile(:,m,l)=temp_fft;
   end
end
%������FFT
speed_profile = [];
for l=1:Num_Channel
    for n=1:FFTN
      temp=range_profile(n,:,l).*(doppler_win)';    
      temp_fft=fftshift(fft(temp,FFTM));    %��rangeFFT�������M��FFT
      speed_profile(n,:,l)=temp_fft;  
    end
end
%�Ƕ�FFT
angle_profile = [];
for n=1:FFTN   %range
    for m=1:FFTM   %chirp
      temp=speed_profile(n,m,:);    
      temp_fft=fftshift(fft(temp,FFTQ));    %��2D FFT�������Q��FFT
      angle_profile(n,m,:)=temp_fft;  
    end
end

%% �״����2άFFT������ά��ͼ
figure(1);
speed_profile_temp = reshape(speed_profile(:,:,3),FFTN,FFTM);   
speed_profile_Temp = speed_profile_temp';
[X,Y]=meshgrid((0:FFTN-1)*fs*c/FFTN/2/k,(-FFTM/2:FFTM/2-1)*wavelength/T/FFTM/2);
mesh(X,Y,(abs(speed_profile_Temp))); 
xlabel('����(m)');ylabel('�ٶ�(m/s)');zlabel('�źŷ�ֵ');
title('2D-FFT������ά��ͼ');
xlim([0 (FFTN-1)*fs*c/FFTN/2/k]); ylim([(-FFTM/2)*wavelength/T/FFTM/2 (FFTM/2-1)*wavelength/T/FFTM/2]);

figure(2);
XX=(0:FFTN-1)*fs*c/FFTN/2/k;
YY=(-FFTM/2:FFTM/2-1)*wavelength/T/FFTM/2;
D=speed_profile_Temp;
%D(64:66,:)=0;
% D(find(20*log10(abs(D))>105))=0;   %������С��x���˳�
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
pcolor(20*log10(abs(D(:,:))));%���������

set(gca, 'YDir', 'normal')
shading interp;
shading flat;
colorbar;
colormap jet;

% figure(4);
% % D=speed_profile_Temp(:,:);
% pcolor(20*log10(abs(D(:,:))));%���������
% 
% set(gca, 'YDir', 'normal')
% shading interp;
% shading flat;
% colorbar;
% colormap jet;

%% �����ֵλ��
angle_profile=abs(angle_profile);
pink=max(angle_profile(:));
[row,col,pag]=ind2sub(size(angle_profile),find(angle_profile==pink));
%% ����Ŀ����롢�ٶȡ��Ƕ�
fb = ((row-1)*fs)/FFTN;           %����Ƶ��
fd = (col-FFTM/2-1)/(FFTM*T);     %������Ƶ��
fw = (pag-FFTQ/2-1)/FFTQ;         %�ռ�Ƶ��
R = c*(fb-fd)/2/k;                %���빫ʽ
v = wavelength*fd/2;              %�ٶȹ�ʽ
theta = asin(fw*wavelength/d);    %�Ƕȹ�ʽ
angle = theta*180/pi;
fprintf('Ŀ����룺 %f m\n',R);
fprintf('Ŀ���ٶȣ� %f m/s\n',v);
fprintf('Ŀ��Ƕȣ� %f��\n',angle);
