import numpy as np
import scipy.io as scio
import datetime
import pandas as pd
import pickle
np.set_printoptions(suppress=True)

def mmWave_data_analysis(data_file_path,time_file_path,frame_all,save_filepath):
    mmWave_original_data=scio.loadmat(data_file_path) #解析从MATLAB中处理后得到的数据

    mmwave_rx1=mmWave_original_data['RX1_data']
    mmwave_rx2=mmWave_original_data['RX2_data']
    mmwave_rx3=mmWave_original_data['RX3_data']
    mmwave_rx4=mmWave_original_data['RX4_data']
    sensor_data=np.stack((mmwave_rx1,mmwave_rx2,mmwave_rx3,mmwave_rx4),axis=2)#shape为128*28800*4

    mmwave_time=pd.read_csv(time_file_path,skiprows=5)
    Capture_start_time=datetime.datetime.strptime(((mmwave_time.index).tolist())[9][21:],'%a %b %d %H:%M:%S %Y').timestamp()
    Capture_end_time=(datetime.datetime.strptime(((mmwave_time.index).tolist())[10][19:],'%a %b %d %H:%M:%S %Y').timestamp())-2
    time_delta=Capture_end_time-Capture_start_time #获取总时长
    t_fps=time_delta/frame_all #获取采样间隔

    mmwave_data=[]

    for i in range(4500):
        frame=Capture_start_time+(i+1)*t_fps
        data=sensor_data[:,i*64:(i+1)*64,:]
        frame_data={'frame':frame,'sensor_data':data}
        mmwave_data.append(frame_data)

    with open(save_filepath, "wb") as fp:
        pickle.dump(mmwave_data,fp)
    fp.close() 

