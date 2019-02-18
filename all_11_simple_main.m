close all; 
clc;       
clear all; 

load('/Users/houfeixiang/Downloads/20190109_初始文件2/失血2.mat')
% load('/Users/houfeixiang/Downloads/军科院动物实验/动物实验数据/数据阶段三/20190109动物数据/0109动物数据/1_500万.mat')
% data=data(636000:700000,:);
% data=data(660000:700000,:);

%%
fs=1000;%采样周期频率
t=30;%取t(s)为一个周期。
%% 调用主运算函数主程序
[R_Q,R_AC,R_DC,R_mean_Q,R_PWTT,R_RR, R_PTRR, R_SDNN,R_RMSSD,R_HF,R_HFn,   data_Q,data_AC,data_DC,data_mean_Q,data_PWTT,data_RR,data_PTRR,data_SDNN,data_RMSSD,data_HF,data_HFn]=specialpara(data,fs,t);

%% 数据的相关性，11个参数的相关性
R_11Q=[R_Q   R_AC   R_DC   R_mean_Q   R_PWTT  R_RR   R_PTRR]
R_4HRV=[ R_SDNN  R_RMSSD    R_HF    R_HFn ]

%% 循环数据长度
length_cycle=floor((length(data)-t*fs)/fs)+1;
