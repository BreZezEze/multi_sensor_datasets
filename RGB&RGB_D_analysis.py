import pickle
import numpy as np
import matplotlib.pyplot as plt
from PIL import Image
import os
from datetime import datetime

def rgb_analysis(rgb_flie_path,dateset_filepath):
        

   
    data=np.load(rgb_flie_path,allow_pickle=True) #读取数据
    ts=[]
    data_len=len(data)
    
    #判断是否为rgb数据
    
    filestr='/RGB/'
    os.makedirs(dateset_filepath+filestr)
    for i in range(data_len):
        frame=datetime.strptime(data[i]['time'],'%Y-%m-%d %H:%M:%S.%f').timestamp()
        img_data=data[i]['frame'][:,:,[2,1,0]]
        img_itm=Image.fromarray(img_data)
            
        img_itm.save(dateset_filepath+filestr+str(i)+'.jpg')
        ts.append(frame)
    


    with open(dateset_filepath+filestr+'frame.pkl', "wb") as fp:
        pickle.dump(frame,fp)
    fp.close


def rgb_d_analysis(rgb_d_flie_path,dateset_filepath):
        

   
    data=np.load(rgb_d_flie_path,allow_pickle=True) #读取数据
    ts=[]
    data_len=len(data)
    
    #判断是否为rgb数据
    
    filestr='/RGB_D/'
    os.makedirs(dateset_filepath+filestr)
    for i in range(data_len):
        frame=datetime.strptime(data[i]['time'],'%Y-%m-%d %H:%M:%S.%f').timestamp()
        img_data=data[i]['frame'][:,:,[2,1,0]]
        img_itm=Image.fromarray(img_data)
            
        img_itm.save(dateset_filepath+filestr+str(i)+'.jpg')
        ts.append(frame)
    


    with open(dateset_filepath+filestr+'frame.pkl', "wb") as fp:
        pickle.dump(frame,fp)
    fp.close
    


if __name__ == "__main__":
    time_now=datetime.strftime(datetime.now(),"%Y%m%d%H%M")

    dateset_filepath='./'+str(time_now)+'/'    
    
    os.makedirs(dateset_filepath)
    rgb_fp='./pyKinectAzure/rgb.npy'
    rgb_d_fp='./pyKinectAzure/depth.npy'

    rgb_analysis(rgb_fp,dateset_filepath)
    rgb_d_analysis(rgb_d_fp,dateset_filepath)

