%% RR间期删除点函数
function [hr2] = clear_RR_abp(temp_hrv)
std_hrv=std(temp_hrv);%初次RR间期标准差。
mean_hrv=mean(temp_hrv);%初次RR间期平均值。

N=length(temp_hrv);
% hr=[];
% for i=1:N;
%     if((temp_hrv(i)<800)&(temp_hrv(i)>400))
%         hr(i)=temp_hrv(i);
%         i=i+1;
%     else
%         hr(i)=rand*600-rand*500;
%          i=i+1;
%     end
% end

hr1=[];    
for i=1:N;
    if(abs(temp_hrv(i)-mean_hrv)<abs(mean_hrv-3*std_hrv))
       hr1(i)=temp_hrv(i) ;%满足要求的赋给hrv1。
       i=i+1;
    else
       hr1(i)= mean_hrv;%不满足要求的赋值为平均数给hrv1。
       i=i+1;
    end;
end
hr2=[];
mean_hr1=mean(hr1);%将满足要求与不满足要求的平均值赋值给mean_hr1。
for i=1:N;
    if(hr1(i)<0.8*mean_hr1 || hr1(i)>1.2*mean_hr1)
        hr2(i)= mean_hr1;
        i=i+1;
    else
        hr2(i)=hr1(i) ;
        i=i+1;
    end
end
hr2(hr2==mean_hrv) = [];
end
