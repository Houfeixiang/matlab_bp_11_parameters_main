function [PPG]=PPG250_3(ppg,fs)

% lo=(ppg-mean(ppg))/std(ppg);%数据归一化 
% u_ppg=detrend(lo);
wp=2*15/fs;                                      
ws=2*30/fs;   
Rp=1;                %     1                         
As=30;              %    30
[N,wc]=buttord(wp,ws,Rp,As);        
[B,A]=butter(N,wc);                 
[H,W]=freqz(B,A);                                        
PPG=filtfilt(B,A,ppg);

end
