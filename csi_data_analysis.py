import numpy as np
import matplotlib.pyplot as plt
import scipy.io as scio
import datetime
from scipy.interpolate import interp1d
from tqdm import tqdm
import pickle

def csi_data_analysis(csi_fp,csi_save_fp):
    csi_file = scio.loadmat(csi_fp)  

    csi_struct=csi_file['rx_2_221116_181510'][0][0][0][0]

    csi_data=csi_struct[3][0][0][13] #采集的CSI数据
    csi_tx1=csi_data[:,0:int(csi_data.shape[1]/3)]
    csi_tx2=csi_data[:,int(csi_data.shape[1]/3):2*int(csi_data.shape[1]/3)]
    csi_tx3=csi_data[:,2*int(csi_data.shape[1]/3):]
    csi_data=np.stack((csi_tx1,csi_tx2,csi_tx3),axis=2)

    # csi_systemtime=csi_struct[1][0][0][2] #采集的系统时间戳
    csi_systemtime=np.zeros([csi_data.shape[0]])
    for i in range(len(csi_struct[1][0][0][2])):
        csi_systemtime[i]=np.float64(csi_struct[1][0][0][2][i]/1000000000)

    timesamp_datetime1 = []

    for i in range(len(csi_systemtime)):
        x=csi_systemtime[i]
        xxx=datetime.datetime.strftime(datetime.datetime.fromtimestamp(csi_systemtime[i]),"%Y-%m-%d %H:%M:%S.%f")
        timesamp_datetime1.append(xxx)

    timesamp_org=[] #创建原始时间戳
    csi_systemtime_len=csi_systemtime.shape[0]

    t_fps=0.002 #设置采样间隔

    timesamp_org.append(csi_systemtime[0])


    timesamp_org_idx=0
    for timesamp_idx in range(1,csi_systemtime_len):
        t_1=csi_systemtime[timesamp_idx-1]
        t_2=csi_systemtime[timesamp_idx]

        t_delta=(t_2-t_1)
        duble_t_fps=2*t_fps

        if t_delta< duble_t_fps:
            timesamp_org.append(t_1)
            timesamp_org.append(t_2)
            timesamp_org_idx=timesamp_org_idx+2


        else:
            #将t_1、t_2的值赋给原始时间戳索引timesamp_org_idx和timesamp_org_idx+1
            if timesamp_org_idx >1:
                t_5=timesamp_org[timesamp_org_idx]
                if t_5 != t_1:
                    timesamp_org.append(t_1)
                    timesamp_org_idx=timesamp_org_idx+1

            n=int(np.floor(t_delta/t_fps))
            for i in range(n):
                t_4=t_1+t_fps*i
                timesamp_org.append(t_4)
                timesamp_org_idx=timesamp_org_idx+1

            t_6=timesamp_org[timesamp_org_idx]

            if t_6 != t_2:
                timesamp_org.append(t_2)
                timesamp_org_idx=timesamp_org_idx+1

    timesamp_org=list(set(timesamp_org))
    timesamp_org.sort()
    drop_index=[] #创建丢包后的时间戳在原始时间戳的索引

    for drop_idx in tqdm(range(csi_systemtime_len)):
        x=timesamp_org.index(csi_systemtime[drop_idx])
    
        drop_index.append(x)
        timesamp_org_len=len(timesamp_org)

        Number_of_subcarriers = csi_data.shape[1]
        Txs=csi_data.shape[2]

        csi_systemtime_list=csi_systemtime.tolist()

        csi_org_data = np.zeros([timesamp_org_len, csi_data.shape[1], csi_data.shape[2]], dtype=complex)  # 创建存放插值后的csi矩阵

        for idx in tqdm(range(1,len(drop_index))):

            org_start_idx=drop_index[idx-1]
            org_end_idx=drop_index[idx]

            time_start_idx=csi_systemtime_list.index(timesamp_org[org_start_idx])
            time_end_idx=csi_systemtime_list.index(timesamp_org[org_end_idx])

            csi_time_start=csi_systemtime_list[time_start_idx]
            csi_time_end=csi_systemtime_list[time_end_idx]

            for subcarrier in range(Number_of_subcarriers):
                for Tx in range(Txs):
                    if csi_time_end-csi_time_start>=0.02:
                        vq = timesamp_org[org_start_idx:org_end_idx]
                        data_time_drop = csi_systemtime_list[time_start_idx:time_end_idx+1]
                        data_drop = csi_data[time_start_idx:time_end_idx+1, subcarrier, Tx]
                        data_org_function = interp1d(data_time_drop, data_drop)
                        data_org = data_org_function(vq)
                        len = data_org.shape[0]

                        if idx == 1:
                            csi_org_data[org_start_idx:org_end_idx, subcarrier, Tx] = data_org
                        else:  
                            csi_org_data[org_start_idx:org_end_idx,subcarrier,Tx] = data_org
                    else:

                        x_1 = csi_data[time_start_idx, subcarrier, Tx]
                        x_2 = csi_data[time_end_idx, subcarrier, Tx]
                        csi_org_data[org_start_idx, subcarrier, Tx] = x_1

    csi_data_dict=[]

    for i in range(timesamp_org_len):
        time=timesamp_org[i]
        sensor_data=csi_org_data[i,:,:]
        frame={'frame':time,'sensor_data':sensor_data}    
        csi_data_dict.append(frame)

    with open(csi_save_fp, "wb") as fp:
        pickle.dump(csi_data_dict,fp)
    fp.close


