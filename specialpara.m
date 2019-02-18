function [qq_R,  ac_R,  dc_R,mean_q_R,pwtt_R,rr_R, ptrr_R, SDNN_R,RMSSD_R,HF_R,HFn_R,   qq,mean_ac,mean_dc,mean_q,pwtt,rr,ptrr,sdnn,rmssd,A1,A5]=specialpara(data,fs,t)

ecg1=data(:,2);%提取ECG信号
ppg1=data(:,3);%提取PPG信号
bp1=data(:,4);%提取BP信号
%% ECG PPG BP信号滤波
[st_ll1,d1,uu1]=ECG250(ecg1,fs);%ECG信号滤波，R波峰值位置。
[PPG1]=PPG250_3(ppg1,fs);%PPG滤波
[BP1]=BP250_3(bp1,fs);%BP滤波

T=t*fs;
wn=(length(data)-T)/fs;
wm=floor(wn)+1;
%% 数据循环主程序
parfor k=1:1:wm
    segment=data(((k-1)*fs+1):((k-1)*fs+T),:);%时间窗函数
    ecg=segment(:,2);%提取ECG
    ppg=segment(:,3);%提取PPG
    bp=segment(:,4);%提取BP
    d=[];loc1=[];c1=[];c11=[];loc2=[];c2=[];c22=[];loc3=[];c3=[];c33=[];c11_1=[]; c=[]; ac=[];q=[];
%% ecg
[st_ll,d,uu]=ECG250(ecg,fs);%ECG滤波，R波峰值点位置
%% ppg
[PPG]=PPG250_3(ppg,fs);%PPG滤波
[p1,loc1]=findpeaks(PPG,'MinPeakDistance',(min(diff(d))-50));%PPG峰值点位置
% min_d=min(diff(d));%RR间期最小值

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PPG波峰
%% 初步寻找PPG波峰，保证两个R波之间只有一个波峰
s=1;
for i=1:1:length(d)-1
    m=1;
    num_min=[];
    for j=1:1:length(loc1)
        if loc1(j)>d(i)&&loc1(j)<d(i+1)
            num_min(m)=loc1(j);
            m=m+1;
        end
    end
    l_m=length(num_min);
    if l_m==1
           c1(i)=num_min;         
    else
           c1(i)=0;  
    end
end
%% PPG波峰 ，掐头去尾留中间
m=1;
n=1;
if find(c1>d(end))
    z12=find(c1>d(end));
    c1(z12)=[];
end
if find(c1<d(1))
    z11=find(c1<d(1));
    c1(z11)=[];
end
%% PPG波峰整合，不够的补零
for i=1:1:length(c1)
    for j=1:1:length(d)-1
        if c1(i)>d(j)&&c1(i)<d(j+1)
           c11(j)=c1(i);
        end
    end
end
if length(d)-1>length(c11)
    c11(length(c11)+1:1:(length(d)-1))=0;
end

c11_1=c11(find(c11)~=0);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PPG波谷
%% 初步寻找PPG波谷，保证两个R波之间只有一个波谷
s=1;
n=1;
tem=[];
for i=1:1:length(d)-1
    for j=1:1:length(c11_1)
        if (d(i)<c11_1(j))&(c11_1(j)<d(i+1))
            tem=-PPG((d(i)):c11_1(j));
            c(j)=length(tem);%c为选取谷值的区间。
            ss=find(c==0);
            c(ss)=[];
            min_c=min(c);
            [p2,loc2]=findpeaks(tem,'MinPeakDistance',min(c)-2);
            l_min=length(loc2);
               if l_min==1
                  c2(j)=loc2+d(i);
               else
                  c2(j)=0;
               end
        end
    end
end

%% PPG波谷，掐头去尾留中间
m=1;
n=1;
if find(c2>d(end))
    z22=find(c2>d(end));
    c2(z22)=[];
end
if find(c2<d(1))
    z21=find(c2<d(1));
    c2(z21)=[];
end
%% PPG波谷整合，不够的补零
for i=1:1:length(c2)
    for j=1:1:length(d)-1
        if c2(i)>d(j)&&c2(i)<d(j+1)
           c22(j)=c2(i);
        end
    end
end
if length(d)-1>length(c22)
    c22(length(c22)+1:1:(length(d)-1))=0;
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% BP滤波
[BP]=BP250_3(bp,fs);%BP滤波
[p3,loc3]=findpeaks(BP,'MinPeakDistance',(min(diff(d))-50));%BP峰值点位置
%% BP波峰
%% 初步寻找BP波谷，保证两个R波之间只有一个波谷
%% 两个R波之间BP只能有一个波峰
s=1;
for i=1:1:length(d)-1
    m=1;
    num_min=[];
    for j=1:1:length(loc3)
        if loc3(j)>d(i)&&loc3(j)<d(i+1)
            num_min(m)=loc3(j);
            m=m+1;
        end
    end
    l_m=length(num_min);
    if l_m==1
        c3(i)=num_min;
    else
        c3(i)=0;
    end
end

%% BP波峰，掐头去尾留中间
m=1;
n=1;
if find(c3>d(end))
    z32=find(c3>d(end));
    c3(z32)=[];
end
if find(c3<d(1))
    z31=find(c3<d(1));
    c3(z31)=[];
end

%% BP波峰数据整合，不够的补零。
for i=1:1:length(c3)
    for j=1:1:length(d)-1
        if c3(i)>d(j)&&c3(i)<d(j+1)
           c33(j)=c3(i);
        end
    end
end
if length(d)-1>length(c33)
    c33(length(c33)+1:1:(length(d)-1))=0;
end

%% 删除异常点的数值
c11(c22==0|c33==0)=0;
c22(c11==0|c33==0)=0;
c33(c11==0|c22==0)=0;
c11(c11==0)=[];
c22(c22==0)=[];
c33(c33==0)=[];

%%  寻找ac（PPG幅值），dc（PPG峰值）与q=ac/dc。
for i=1:1:length(c11)
    ac(i)=PPG(c11(i))-PPG(c22(i));
end
    dc=PPG(c11);
for i=1:1:length(ac)
    q(i)=ac(i)/dc(i);
end
mean_ac(k)=mean(ac);%ac的平均值
mean_dc(k)=mean(dc);%dc的平均值
qq(k)=mean_ac(k)/mean_dc(k);%ac的平均值/dc的平均值
mean_q(k)=mean(q);%ppg滤波之后，这个q能用。
mean_bp(k)=mean(BP(c33));%bp平均值
ac=[];dc=[];q=[];

%% RR间期
     [PWTT]=usedbypwtt(segment,fs);
        differ=diff(d); 
        HR=60*fs./differ;
        x=PWTT;
        x(x==0)=[];
        pwtt(k)=mean(x);%PWTT
        rr(k)=mean(differ);%RR间期
        ptrr(k)=pwtt(k)/rr(k);%PWTT/RR间期

        
%% 
A=ecg;%提取ECG信号
N=length(A);
t=(0:N-1)/fs; %时间段（总样本数/ Fs），时间的刻度

%% 滤波和频谱
ecg_smooth=filter_lb(A,t);  %ecg小波变换滤波滤波
spectrum=FCG(A);  %原始心电频谱图
f_spectrum=f_FCG(ecg_smooth);  %滤波后心电频谱
%% 求RR间期
% rr7=diff(d);%两个R波之间的长度
% rr3 = clear_RR_abp(rr7);% 删除异常的RR间期。
rr8=differ;%将RR间期转置

%% HRV频域参数
sdnn(k)=SDNN(rr8);%相邻RR间期的标准差。

rmssd(k)=RMSSD(rr8);%相邻RR间期差值的平方和的平均值再开方（相邻RR间期差的均方根）

%% HRV频域特征参数，输入为RR间期的值。
[HF,HFn] = HRV_Fchoose_2(rr8);

A1(k)=HF;%高频段功率谱

A5(k)=HFn;%归一化高频段功率
        
end

%%  画 ECG PPG BP总波形，以及R波
figure
plot(uu1,'r')
hold on
plot(PPG1,'k')
plot(BP1,'b')
plot(d1,uu1(d1),'*k')
title('ECG PPG BP波形图')
legend('ECG','PPG','BP')
set(gca,'fontsize',20)
set(gca,'fontname','Times New Romans')

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% q与BP峰值的相关性。(qq=mean_ac/mean_dc)
PK_BP=mean_bp;
figure
[qq_R]=correlationsubplot(qq,PK_BP,1);
xlabel('AC/DC')
ylabel('BP')
title('AC/DC与BP之间的关系')

%% ac(幅值)与BP峰值的相关性。(mean_ac)
[ac_R]=correlationsubplot(mean_ac,PK_BP,2);
xlabel('ac/dc')
ylabel('BP')
title('AC(幅值)与BP之间的关系')

%% dc(峰值)与BP峰值的相关性。(mean_dc)
[dc_R]=correlationsubplot(mean_dc,PK_BP,3);
xlabel('ac/dc')
ylabel('BP')
title('DC(峰值)与BP之间的关系')

%% q与BP峰值的相关性。(mean_q)求出所有的q值，并求q的平均值，目前方法不可取。
[mean_q_R]=correlationsubplot(mean_q,PK_BP,4);
xlabel('ac/dc')
ylabel('BP')
title('Q与BP之间的关系')

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PWTT与BP峰值的相关性。
figure
[pwtt_R]=correlationsubplot(pwtt,PK_BP,1);
xlabel('PWTT')
ylabel('BP')
title('pwtt与BP之间的关系')

%% RR间期与BP峰值的相关性。
[rr_R]=correlationsubplot(rr,PK_BP,2);
title('RR间期与BP之间的关系')
xlabel('RR间期')
ylabel('BP')

%% PWTT/RR间期与BP峰值的相关性。
[ptrr_R]=correlationsubplot(ptrr,PK_BP,3);
title('PWTT/RR间期与BP之间的关系')
xlabel('PWTT/RR间期')
ylabel('BP')

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% HRV时域特征参数
%% SDNN与BP峰值的相关性
figure
[SDNN_R]=correlationsubplot(sdnn,PK_BP,1);
xlabel('SDNN')
ylabel('BP')
title('SDNN与BP之间的关系(时域)')

%% RMSSD与BP峰值的相关性
[RMSSD_R]=correlationsubplot(rmssd,PK_BP,2);
xlabel('RMSSD')
ylabel('BP')
title('RMSSD与BP之前的关系(时域)')

%% HRV频域特征参数
%% HF与BP峰值的相关性
[HF_R]=correlationsubplot(A1,PK_BP,3);
xlabel('HF')
ylabel('BP')
title('HF与BP的之间的关系(频域)')

%% HFn与BP峰值的相关性
[HFn_R]=correlationsubplot(A5,PK_BP,4);
xlabel('HFn')
ylabel('BP')
title('HFn与BP的之间的关系(频域)') 


end
