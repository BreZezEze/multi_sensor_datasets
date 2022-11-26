
%%%%%% IWR6843+DCA1000 ���ݽ��� %%%%%%%
clc
clear all
close all

%% ���ݶ�ȡ
CurrentFolder = pwd;
% ��ȡ�����ļ�
cd('bowen1115\');%       D:\sst307      D:\ADCdata\adc2pc
[filename, pathname] = uigetfile({'*.bin'}, 'File Selector');
if isequal(filename,0) || isequal(pathname,0)
    cd(CurrentFolder);
    error('�û������ȡ�����˳�');
else
    open_filename = fullfile(pathname, filename);
    disp(['��ǰ�򿪵������ļ�Ϊ��', open_filename]);
end
% �ص�m�ļ�����·��
cd(CurrentFolder);
fname = open_filename;         % ����bin�ļ�λ��
[retVal] = readDCA1000(fname); % ���ݶ�ȡ,retVal=[RX1data;RX2data;RX3data;RX4data]

period_point_numbers = 128; % һ�����ڵĲ�������
period_numbers = size(retVal,2); % ������
chirp_numbers = 64; % һ֡��������chirploops
frame_numbers = period_numbers/chirp_numbers;

frame_begin = 1;     % ���ÿ�ʼ֡��
frame_end = 7500;     % ���ý���֡��


RX1_data = retVal(period_point_numbers*0+1 : period_point_numbers*1,((frame_begin-1)*chirp_numbers+1):frame_end*chirp_numbers);
RX2_data = retVal(period_point_numbers*1+1 : period_point_numbers*2,((frame_begin-1)*chirp_numbers+1):frame_end*chirp_numbers);
RX3_data = retVal(period_point_numbers*2+1 : period_point_numbers*3,((frame_begin-1)*chirp_numbers+1):frame_end*chirp_numbers);
RX4_data = retVal(period_point_numbers*3+1 : period_point_numbers*4,((frame_begin-1)*chirp_numbers+1):frame_end*chirp_numbers);

% clear retVal
save(['adc_data'  '.mat'],'RX1_data','RX2_data','RX3_data','RX4_data','period_numbers');

% disp(['���ݽ�����ϣ���',num2str(frame_end),'֡��',num2str(frame_end*3),'���������ݣ�']);
