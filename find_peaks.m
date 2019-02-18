%% 尝试对BP峰值选取模型进行改进
function [max_BP]=find_peaks(d,BF)

%用两个R波之间的区间，确定一个血压峰值。

%Description：
% 该程序功能为：获取数据峰值点位置信息
% 程序原理及流程：
%     Step1: 借助R波信息计算数据（BP信号或PPG信号）中的峰值点信息
%     Step2: 检索上述结果中可能的异常点并剔除

%Inputs：
%     d：ECG峰值点位置
%     BF：滤波后的BP信号或PPG信号数据

%Outputs：
%	  max_BP：BP或PPG峰值点位置

%Calls：
%	被本函数调用的函数清单
%     findpeaks：获取可能存在的峰值点位置

%Called By：
%	调用本函数的清单
%    usdbyplot：从原始信号数据获取标记出异常点位置的PWTT与BP,及滤波处理后的ECG信号，PPG信号，BP信号

%V1.0：2018/5/7



%% 借助R波信息计算BF信息中的峰值点信息
l=length(d);   %获取R波波峰个数
%% 两个R波的距离为一个处理的数据段
for i=1:1:l-1
%     bg=1000*(50/1000);%定义每相邻两个R波之间使用的BP数据段的起点（即R波开始后的50ms）
       ed=(d(i+1)-d(i))*1;%定义相邻两个R波之间使用的BP数据段的终点（因为数据不一样需要的宽度可能不一样，故此处没有限制数据长度）
       BP_begin(i)=d(i);%获取当前BP数据段的起点
       BP_end(i)=d(i)+round(ed);%获取当前BP数据段的终点
end

for i=1:1:length(BP_begin)
    i_BP=[];
    i_BP=BF(BP_begin(i):BP_end(i));%获取当前需要处理的BP数据段
    [pks,locs] = findpeaks(i_BP); %寻找当前的数据段可能存在的峰值点位置
%     if length(locs)==1
%         peak(i,1)=locs;
    if length(locs)==0      %对当前数据段可能存在的峰值点个数进行判断
        peak(i,1)=0;
        else
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            num=0;
            linshi=[];
            for tt=1:length(locs)
               %bizhi=abs(( (( pks(tt)-BF( BP_begin(i) ) )-( max(pks)-BF(BP_begin(i)) ) ) / ( max(pks)-BF(BP_begin(i)) ) ));     %计算第i个可能的峰值点与最高的点的差的比例
               %bizhi=abs( pks(tt)-BF( BP_begin(i) )) / ( max(pks)-BF(BP_begin(i)) ) ;
                %if  ( bizhi<0.3)   %如果差的比例大于0.6 ，则认为该点并非峰值点
                bizhi=abs(  (pks(tt)-BF( BP_begin(i)))/(max(pks)-BF(BP_begin(i))));
%                 bizhi=abs( pks(tt)) / ( max(pks) ) ;
                if  ( bizhi<0.6)
                    num=num+1;
                    linshi(num)=tt;
                end
            end
            locs(linshi)=[];     %将上步判断的非峰值点信息进行删除，保留峰值点信息
%             %%%检验异常点时用，作为函数运行时不影响
%             for jc=1:length(locs)
%             jiancha(i,jc)=locs(jc);
%             end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                     
            for tt=1:length(locs)
                peak(i,tt)=locs(tt);  %将峰值点信息保存到peak矩阵中
%                 bizhi=abs(( (( pks(1)-BF( BP_begin(i) ) )-( pks(tt)-BF(BP_begin(i)) ) ) / ( pks(1)-BF(BP_begin(i)) ) ));
%                 if  ( bizhi< 0.4 )   
%                     peak(i,1)=locs(1);
%                     peak(i,tt)=locs(tt);
%                 else
%                     peak(i,1)=locs( find(max(pks)==pks) );
%                 end
% %                 if  ( bizhi> 2 )  
% % %                     peak(i,1)=locs(tt);
% % %                 else
% %                     peak(i,1)=locs( find(max(pks)==pks) );
% %                 end
%                 if ( pks(1)*pks(tt) <0)
%                     peak(i,1)=locs( find(max(pks)==pks) );
%                     peak(i,2:end)=0;
%                 end
            end
%         end
    end
end
% %%%%%%%
% clear peak;peak=jiancha;
% %%%%%%%

%%  整理峰值点位置信息到一维向量 max_BP 中
order=1;
for i=1:1:length(BP_begin)
    for j=1:length(peak(i,:))
        if peak(i,j)~=0            % 如果第i个R波到第i+1个R波间的第j个峰值点信息不为零则进行，则认为该点为一个有效的峰值点，并进行下面的操作
           max_BP(order)=peak(i,j)+BP_begin(i);  %计算峰值点在整段信息中的位置，并存储到一维向量max_BP中
           order=order+1;
        end
    end
end


%% 寻找这样的一类异常点，即该点峰值的高度小于近10个连续峰值高度平均值的40%
order=0;
z=[];
for i=10:10:length(d)-10
    height=[];  %用于存储峰值点对应的峰值的高度
    for h=1:10
        temp_BP(h,1)=BP_begin(i+h-10);                           %将10个信号起始点位置储存到 temp_BP（:,1）中
        temp=max_BP( (max_BP>d(i-10+h)) & (max_BP<d(i-9+h))  );  %将两个R波间所有的峰值点均储存到temp_BP（:,2,end）中
        temp_BP(h,2:length(temp)+1)=temp;                        %将两个R波间所有的峰值点均储存到temp_BP（:,2,end）中
        for len=1:length(temp_BP(h,:))
            if temp_BP(h,len)~=0        %如果第h个点的第len个峰值位置信息不为零，则进行下面的操作
                height(h,len)= BF(temp_BP(h,len))- BF(temp_BP(h,1)); %计算每个峰值的高度
            end
        end
    end

    the_mean=sum(height(:))/length(find( height(:)~=0 ));
    aim=[];  %用于存储连续十个R波间异常点位置信息
    if sum(height(:)<the_mean*0.4) & sum((height(find( (height<the_mean*0.4) )))~=0) %如果某点高度小于平均高度的40%且高度不为零，则认为该点为异常点
        aim=find( height<the_mean*0.4  &   height~=0  );
        for tt=1:length(find(aim))
            order=order+1;
            z(order)=temp_BP(aim(tt));  %将检索到的异常点位置信息储存到向量Z中
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             order=order+1;
%             z(order)=temp_BP(aim(tt)-1);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
    end
end
z=unique(z);   %确保向量z中没有重复的数值

%% 对寻找到的异常点进行删除
order=0;
delect=[];   %用于存储异常点位置信息
for i=1:length(z)
    linshi=find(max_BP==z(i));     % 寻找并记录异常点在储存峰值位置信息的向量中的位置信息
    if linshi                      %如果异常点数量不为零则进行下面的操作
        for j=1:length(linshi)
        order=order+1;
        delect(order)=linshi(j);   %将异常点信息记录到delect向量中
        end
    end
end
delect=delect(delect<max(max_BP)); %确保能够正常删除相应数据
max_BP(delect)=[];     %对异常点从峰值点信息中进行删除

%% 对BP异常点位置的检索 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% for i=1:1:length(d)-1%对存储有所有R波峰值点位置信息的数组进行循环，查找每相邻两个R波之间的BP峰值点
%     m=1;
%     s=1;
%     num_max=[];%用于存储两个R波峰值点之间的BP峰值点位置信息
%     % 循环查找当前两个R波峰值点之间的BP峰值点
%     for j=1:1:length(max_BP)%对存储有所有B峰值点位置信息的数组进行循环
%         if max_BP(j)>d(i)&&max_BP(j)<d(i+1)%判断该BP峰值点是否在当前两个R波峰值点之间
%             num_max(m)=max_BP(j);%如果该BP峰值点存在于当前两个R波峰值点之间，则存储到num_max中
%             m=m+1;
%         end
%     end
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     l_m=length(num_max);%获取当前两个R波峰值点之间的BP峰值点个数
%     if l_m==1%判断当前两个R波峰值点之间是否有且仅有一个BP峰值点P
%         max_r(i)=num_max(1);%将该BP峰值点位置信息存入数组max_r中
%     else%其他情况均视为异常点情况
%         max_r(i)=0;%将当前位置存入0
%     end
% end
% 
% 
% delect_BP=find(max_r==0);%找到数组max_r中数值为0的点，即为干扰点
        


    
end
