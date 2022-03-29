clear all;clc;
%% 基础信息
N=20;%比特数
T=1;%比特周期
fc=2;%载波频率
Fs=100;%抽样频率

% bitstream=randi([0,1],1,N);%随机产生的比特数0、1
% bitstream=2*bitstream-1;%单极性变为双极性（0到-1；1到1）
bitstream=Tsignal(N,2);
%% 分流
I=[];Q=[];
%奇数进I路,偶数进Q路
for i=1:N
    if mod(i,2)~=0
        I=[I,bitstream(i)];
    else
        Q=[Q,bitstream(i)];
    end
end

% I=m(1:2:N);
% Q=m(2:2:N);
%% 比特流
%采用绘图比较I、Q比特流
bit_data=[];
for i=1:N
    bit_data=[bit_data,bitstream(i)*ones(1,T*Fs)];%在一个比特周期里面有T*Fs个1和采样点一模一样
end
I_data=[];Q_data=[];
for i=1:N/2
    %I路和Q路是原来比特周期的两倍,2Tb=Ts(码元周期)，因此采样点个数为T*Fs*2
    I_data=[I_data,I(i)*ones(1,T*Fs*2)];
    Q_data=[Q_data,Q(i)*ones(1,T*Fs*2)];
end
%% 绘图
figure();
%时间轴
t=0:1/Fs:N*T-1/Fs;
subplot(3,1,1)
plot(t,bit_data);legend('Bitstream')%比特信息
subplot(3,1,2)
plot(t,I_data);legend('I Bitstream')%I路信息
subplot(3,1,3)
plot(t,Q_data);legend('Q Bitstream')%Q路信息
%% 载波信号
bit_t=0:1/Fs:2*T-1/Fs;%载波周期为2倍比特周期,定义时间轴
%定义I路和Q路的载波
I_carrier=[];Q_carrier=[];
for i=1:N/2
    I_carrier=[I_carrier,I(i)*cos(2*pi*fc*bit_t)];%I路载波信号
    Q_carrier=[Q_carrier,Q(i)*cos(2*pi*fc*bit_t+pi/2)];%Q路载波信号
end
%% 传输信号
QPSK_signal=I_carrier+Q_carrier;
%% 绘图
figure();%产生一个新图
subplot(3,1,1)
plot(t,I_carrier);legend('I signal')%I路信号
subplot(3,1,2)
plot(t,Q_carrier);legend('Q signal')%Q路信号
subplot(3,1,3)
plot(t,QPSK_signal);legend('QPSK signal')%I路、Q路和的信号
%% 接收信号
snr=1;%信躁比
QPSK_receive=awgn(QPSK_signal,snr);%awgn()添加噪声
%% 解调
for i=1:N/2
    I_output=QPSK_receive(1,(i-1)*length(bit_t)+1:i*length(bit_t)).*cos(2*pi*fc*bit_t);
    if sum(I_output)>0 %积分器求和，大于0为1，否则为-1
        I_recover(i)=1;
    else
        I_recover(i)=-1;
    end
     Q_output=QPSK_receive(1,(i-1)*length(bit_t)+1:i*length(bit_t)).*cos(2*pi*fc*bit_t+ pi/2);
    if sum(Q_output)>0
        Q_recover(i)=1;
    else
        Q_recover(i)=-1;
    end
end
%% 并/串变换
bit_recover=[];
for i=1:N
    if mod(i,2)~=0
        bit_recover=[bit_recover,I_recover((i-1)/2+1)];%奇数取I路信息
    else
        bit_recover=[bit_recover,Q_recover(i/2)];%偶数取Q路信息
    end
end
%适用绘图比较I、Q比特流
recover_data=[];
for i=1:N
    recover_data=[recover_data,bit_recover(i)*ones(1,T*Fs)];
end
I_recover_data=[];Q_recover_data=[];
for i=1:N/2
    I_recover_data=[I_recover_data,I_recover(i)*ones(1,T*Fs*2)];
    Q_recover_data=[Q_recover_data,Q_recover(i)*ones(1,T*Fs*2)];
end
%% 绘图
figure();
t=0:1/Fs:N*T-1/Fs;
subplot(3,1,1)
plot(t,recover_data);legend('Bitstream recover')%恢复的比特信息
subplot(3,1,2)
plot(t,I_recover_data);legend('I Bitstream recover')%恢复的I路信息
subplot(3,1,3)
plot(t,Q_recover_data);legend('Q Bitstream recover')%恢复的Q路信息
