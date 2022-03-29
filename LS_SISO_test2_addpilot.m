clear;close all;
%% 基础信息
L=256;              % 信号长度
Nps=4;              % 导频间隔
% K=12;               % sparsity
K=randi(L);
scale=1e-9;         % nano
t_rms=25*scale;     % RMS delay spread
num_ch=10000;       % Number of channels  生成瑞利信道时使用
fs=1000;            % sample frequency
Nfft=256;           % FFT size
fcup=3;             % uplink carrier frequence
fcdown=6;           % downlink carrier frequence
T=0.1;              % 信号周期
%% 生成含有信息的信号msgint和导频序列Pilot
Np=L/Nps;
% msgint=Tsignal(L-Np,K);
msgint=(randn(1,L-Np)>0);
Pilot=2*(randn(1,L/Nps)>0)-1;
%% 生成发射信号X
[X,pilot_loc,msgint_data]=AddPilot(Pilot,L,msgint,Nps,fs,fcup,T);
%% 获得信道
[H,PDP,avg_pow_h]=channelIEEE80211(t_rms,1/fs,num_ch,Nfft);
Y=X.*H';
%% 解调   QPSK


%% LS算法
H_est=LS_CE(Y,Pilot,pilot_loc,L,Nps,'spline');
%% 绘图
t=0:1/fs:(L-Np)*T-1/fs;

subplot(311)
plot(t,msgint_data);
% hold on;
% plot(t,X_recover);
% legend('X','X_recover');
title('msgint');

t=1:L;
subplot(312)
plot(t,X);

subplot(313)
plot(t,abs(Y));