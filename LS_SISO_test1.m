clear;close all;
%% ������Ϣ
L=256;              % �źų���
Nps=4;              % ��Ƶ���
K=12;               % sparsity
scale=1e-9;         % nano
t_rms=25*scale;     % RMS delay spread
num_ch=10000;       % Number of channels  ���������ŵ�ʱʹ��
fs=1000;            % sample frequency
N=128;              % FFT size
fcup=3;             % uplink carrier frequence
fcdown=6;           % downlink carrier frequence
T=0.1;              % �ź�����
%% ���������ź�X�͵�Ƶ����Pilot
X=Tsignal(L,K);
Pilot=2*(randn(1,L/Nps)>0)-1;
%% ����    QPSK
[X_data,Sup]=QPSK(fs,fcup,X,T);
% Sdown=QPSK(fs,fcdown,X,T);
%% ���ɷ����ź�X
% [X,magint,msgint_data]=AddPilot(Pilot,L,K,Nps,fs,fcup,T);
%% ����ŵ�
[H,PDP,avg_pow_h]=channelIEEE80211(t_rms,1/fs,num_ch,N);
Supr=Sup.*H';
% Sdown=Sdown.*H';
%% ���   QPSK
X_recover=QPSK_demodulate(fs,fcup,Supr,T,L);
%% ��ͼ
t=0:1/fs:L*T-1/fs;

subplot(311)
plot(t,X_data);hold on;
plot(t,X_recover);
legend('X','X_recover');
title('X and Xrecover');

subplot(312)
plot(t,Sup)
title('QPSK uplink Signal');

subplot(313)
plot(t,abs(Supr))
title('receive uplink Signal');
% plot(t,abs(Sdown))