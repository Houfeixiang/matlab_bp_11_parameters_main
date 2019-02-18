function [HF,HFn] = HRV_Fchoose_2(in)

fs = 1000;

[freq, data, N] = psd_estimation(in, fs,'welch');

df = fs/N; % length of PSD window

HF = 2*sum(data(freq <=0.4 & freq >= 0.15))*df;%HF

totalpower = (2*sum(data(freq <=0.4 & freq > 0))+data(1))*df; %totalpower

VLF = (2*sum(data(freq <= 0.04  & freq > 0)) + data(1))*df; %VLF

differ = totalpower-VLF;

HFn = HF/differ*100;%HFn

end
