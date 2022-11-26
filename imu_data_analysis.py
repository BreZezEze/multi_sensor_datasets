import pandas as pd
import time
import datetime
import numpy as np
import os


def imucsv(filename):
    filepath=os.listdir(filename)
    imu_tag={'tag_1':[],'tag_2':[],'tag_3':[],'tag_4':[]}
    for i in range(len(filepath)):
        imu_tag_list=[]
        imucsvpath=filename+'/'+filepath[i]
        imu_head=pd.read_csv(imucsvpath,sep=',',nrows = 10,engine='python')
        imu_data=pd.read_csv(imucsvpath,sep=',',skiprows= 11,engine='python')
        imu_tag_1_starttime = datetime.datetime.strptime((str(imu_head.loc[7][1]).split())[0], "%Y-%m-%d_%H:%M:%S_%f")
        imu_tag_1_starttime_stamp=time.mktime(time.strptime(str(imu_tag_1_starttime), "%Y-%m-%d %H:%M:%S.%f"))
        imu_tag_1_starttime_microsecond=imu_tag_1_starttime.microsecond/1000000
        imu_tag_1_starttime_utc=imu_tag_1_starttime_stamp+imu_tag_1_starttime_microsecond
        for j in range(len(imu_data['SampleTimeFine'])):
            x=(imu_data['SampleTimeFine'][j]-imu_data['SampleTimeFine'][0])/1000000
            realtimefine=imu_tag_1_starttime_utc+x
            realtimefine=datetime.datetime.strftime(datetime.datetime.fromtimestamp(realtimefine),"%Y-%m-%d %H:%M:%S.%f")
            imu_tag_data={'SampleTimeFine':realtimefine,'Quat_W':imu_data['Quat_W'][j],'Quat_X':imu_data['Quat_X'][j],'Quat_Y':imu_data['Quat_Y'][j],'Quat_Z':imu_data['Quat_Z'][j],'FreeAcc_X':imu_data['FreeAcc_X'][j],'FreeAcc_Y':imu_data['FreeAcc_Y'][j],'FreeAcc_Z':imu_data['FreeAcc_Z'][j]}
            imu_tag_list.append(imu_tag_data)
        imu_tag['tag_'+str(i+1)]=imu_tag_list
    return imu_tag

if __name__ == "__main__":
    imu_tag_data=imucsv('./imu/20221115_220652/20221115_220652/')
    starttime=[]
    endtime=[]
    for tag in imu_tag_data:
        starttime.append(imu_tag_data[tag][0]['SampleTimeFine'])
        endtime.append(imu_tag_data[tag][-1]['SampleTimeFine'])

    for tag in imu_tag_data:
        for i in range(len(imu_tag_data[tag])):
            if imu_tag_data[tag][i]['SampleTimeFine']>=min(endtime):
                imu_tag_data[tag].pop(i)