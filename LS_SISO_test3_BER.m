clear;close all;
%% 基础信息
L=512;              % 信号长度
Nps=1;              % 导频间隔
scale=1e-6;         % ms
t_rms=10*scale;     % RMS delay spread
num_ch=1e5;         % Number of channels  生成瑞利信道时使用
fs=1e6;             % sample frequency
Nfft=512;           % FFT size
snr=30;
%% 调制解调
QPSK_mod=comm.QPSKModulator;
QPSK_demod=comm.QPSKDemodulator;
%% 生成含有信息的信号msgint,导频序列Pilot,发射信号X
Np=L/Nps;           % 导频信号数量
msgint=randi([0,3],1,L-Np);
Pilot=randi([0,3],1,Np);
X=Pilot;
% [X,pilot_loc]=AddPilot(Pilot,L,msgint,Nps);
%% 调制发送信号  QPSK
X_mod=QPSK_mod(X.');
Pilot_mod=QPSK_mod(Pilot.');
%% 获得信道
[H,PDP,avg_pow_h]=channelIEEE80211(t_rms,1/fs,num_ch,Nfft);
%% 接收信号 添加噪声
Y=X.*H;
%% LS算法
% H_est=LS_CE(Y,Pilot_mod,pilot_loc,L,Nps,'spline');
H_est=Y./Pilot_mod.';
%% ZF均衡
% Y_eq=lteEqualizeZF(Y,H_est);
%% 解调 QPSK
Y_recover=Y./H_est;
Y_input=Y_recover.';
Y_demod=QPSK_demod(Y_input);
%% 计算误码率
numerr=0;
for i=1:L
    numerr=numerr+abs(Y_demod(i)-X(i));
end
ratio=numerr/(4*L)
%% 绘图

