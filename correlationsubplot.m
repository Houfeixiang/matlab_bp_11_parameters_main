function [c]=correlationsubplot(a,b,n)
subplot(2,2,n)
plot(a,b,'ro')
R1=corrcoef(a,b); %求得ac/dc和bp峰值的相关性
c=R1(1,2);
hold on
[p1,S1]=polyfit(a,b,1);%求得拟合参数
y1=polyval(p1,a);%求得拟合的直线   
plot(a,y1);
set(gca,'FontSize',15);%横纵坐标轴字号，15
set(gca,'Fontname','Times New Roman');%横纵坐标轴字体，新罗马字体
end
