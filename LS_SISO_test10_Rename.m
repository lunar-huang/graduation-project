clear; close all;
%% 基础信息
L=1024;
Nps=8;
U_delay=7.56;
Fs=2e9;
SNR=3;
F_uplink=7e8;
F_downlink=8e8;
%% 调制解调函数
QPSK_mod=comm.QPSKModulator;
QPSK_demod=comm.QPSKDemodulator;

%% 生成信号和导频 合并成发送信号
Frame_msgint=randi([0,3],L-L/Nps,1);
Frame_pilot=randi([0,3], L/Nps,1);
[Frame_with_pilot,pilot_loc]=AddPilot(Frame_pilot,L,Frame_msgint,Nps);
Frame_with_pilot=Frame_with_pilot.';

%% 导频的载波
carrier_pilot=cos(2*pi*F_downlink*pilot_loc/Fs);
carrier_pilot=carrier_pilot.';

%% 载波
t1=1:L;
carrier=cos(2*pi*F_downlink*t1/Fs);
carrier=carrier.';

%% 调制并添加载波
Frame_pilot_mod=QPSK_mod(Frame_pilot);
Frame_pilot_mod_carrier=Frame_pilot_mod.*carrier_pilot;
Frame_with_pilot_mod=QPSK_mod(Frame_with_pilot);
Frame_with_pilot_mod_carrier=Frame_with_pilot_mod.*carrier;

%% 生成信道
h=multipath(1,1/U_delay,0);
H=fft(h,L);
H=H.';

%% 信号通过信道
Frame_conv=Frame_with_pilot_mod_carrier.*H;

%% 计算信号能量和噪声能量并生成噪声
power_signal=sum(abs(Frame_conv).^2);
power_noise=power_signal./((10^(SNR/10))*L);
power_noise_db=10*log10(power_noise);
Frame_noise=wgn(L,1,power_noise_db);
% power_noise_check=sum(abs(Frame_noise).^2);

%% 添加噪声
Frame_receive=Frame_conv+Frame_noise;

%% 信道估计
H_est=LS_CE(Frame_receive,Frame_pilot_mod_carrier.',pilot_loc,L,Nps,'spline');
H_est=H_est.';

%% 信道均衡 去除载波 解调
Frame_eq_LS=Frame_receive./H_est;
Frame_without_carrier=Frame_eq_LS./carrier;
Frame_recover=QPSK_demod(Frame_without_carrier);

%% 计算误码率
Frame_conv_bit=int2bit(Frame_with_pilot,2);
Frame_recover_bit=int2bit(Frame_recover,2);
[number,ratio]=biterr(Frame_conv_bit,Frame_recover_bit)