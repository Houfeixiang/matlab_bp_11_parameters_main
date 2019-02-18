function [st_ll,d,uu]=ECG250(ecg,fs)

%d为R波峰值点位置。
%uu为归一去线性化ecg。

%Description：
% 该程序功能为：对ECG信号进行滤波并获取峰值位置信息
% 程序原理及流程：
%     Step1:  ECG数据预处理
%     Step2: 寻找预处理后的数据的R波峰值点
%     Step3: 寻找并剔除判断异常的R波峰值点
%     Step4: 寻找原始ECG信号的峰值点位置

%Inputs：
%     ecg：原始ECG信号
%     fs：采样频率

%Outputs：
%	  st_ll：预处理后的数据的R波峰值点
%     d：获取当前R波峰值点位置
%     uu：数据去线性趋势

%Calls：
%	被本函数调用的函数清单
%     detrend：对数据去线性趋势;
%     fir1：用窗函数法设计线性相位FIRDF的工具箱函数
%     filter：使用有位移的滤波器进行滤波
%     detectionRR2：获取ECG信号峰值信息

%Called By：
%	调用本函数的清单
%     usdbyplot：从原始信号数据获取标记出异常点位置的PWTT与BP,及滤波处理后的ECG信号，PPG信号，BP信号

%V1.0：2018/5/7
%V1.1：2018/5/17



%% ECG数据预处理%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p=ecg;
tr=length(p);
%归一化、去线性趋势                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
uu=p;%数据去线性趋势
%设计FIR带通滤波器
fc1=5;%通带下限截止频率5hz  24
fc2=24;%通带上限截止频率26hz  30
b=fir1(60,[2*fc1/fs,2*fc2/fs]);%设置FIR滤波器，阶数设为60
SF=filter(b,1,uu);%使用该滤波器进行滤波
SF=SF';
%o_as=SF;
%得到滤波后信号的导数
t=1:1:tr;
a=diff(SF)./diff(t);%求导，R波斜率大，突出R波
%a为导数。
c=abs(a);%求绝对值

 for hh=1:tr-80
     as(hh)=mean(c(hh:hh+(80)-1));%求80ms内平均值，移动类推
 end

%% 寻找预处理后的数据的R波峰值点
o_as=as/max(as);%将预处理后的心电数据进行归一化
% o_as=o_as.^0.5;
[heartRate,peak]  = detectionRR2(o_as,fs);%对  归一化  的ECG求R波峰值点
pk=find(peak~=0);%找出R波峰值点所在位置和个数,pk为peak不为零的位置。
    %% 如果对未分段前的数据进行R波峰值检测之后，R波峰值点个数大于25，则认为没有出现异常情况，不用进行分段处理
    %可以直接对检测到的R波峰值点进行处理，减去延时对应道预处理之后的ECG上
    pk=pk-60;
    for i=1:1:length(pk)
        if pk(i)<=0
            pk(i)=0;
        end
    end
    p_ll=find(pk~=0);
    pk=pk(p_ll(1):end);
 
    st_ll=pk;
%% 寻找原始ECG信号的峰值点位置
%预处理后的ECG找到的R波峰值点对比原始ECG数据的R波峰值点，一般延迟在30个采样点之内
%所有我们在预处理后的ECG找到的R波峰值点位置的基础上，在原始ECG上找其前面30个点的最大值
%该最大值即为对应的原始ECG的R波峰值点位置
 %p=p(101:end);%因为预处理后的ECG前面总是存在一个较大峰值点导致后面无法检测，删除了前面100个点，所有原始ECG也删除前面100个点
l_ll=length(st_ll);%获取R波峰值点的个数
for i=1:1:l_ll
    if st_ll(i)-35>0
        pp=p(st_ll(i)-35:st_ll(i));%获取当前R波峰值点位置的前面30个数据，p为原始数据。
        m=st_ll(i)-35;
    else
        pp=p(1:st_ll(i));
        m=1;
    end
    RRpeak=max(pp);%获取数据中最大值
    for n=m:1:st_ll(i)
        if pp(n-m+1)==RRpeak%寻找着30个数据中等于最大值的点，即为R波峰值点
            d(i)=n;%获取当前R波峰值点位置
        end
    end
end

%%%%%去除ECG信号错误的峰值点%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:1:length(d)-1
     if (d(i+1)-d(i))<100
        d(i+1)=d(i);
        d(i)=0;
    end
end
z=find(d==0);
d(z)=[];
   
d(uu(d)<mean(uu(d))*0.7)=[];

end
