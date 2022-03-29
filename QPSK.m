function [X_data,s]=QPSK(fs,fc,X,T)
%fs 采样频率
%fc 载波频率
%T  比特周期
%L  信号长度

t=0:1/fs:1-1/fs;
m=2*X-1;
L=length(X);

I=m(1:2:L);
Q=m(2:2:L);

bit_data=[];
for i=1:L
    bit_data=[bit_data,X(i)*ones(1,T*fs)];%在一个比特周期里面有T*Fs个1和采样点一模一样
end
X_data=bit_data;
I_data=[];Q_data=[];
for i=1:L/2
    %I路和Q路是原来比特周期的两倍,2Tb=Ts(码元周期)，因此采样点个数为T*Fs*2
    I_data=[I_data,I(i)*ones(1,T*fs*2)];
    Q_data=[Q_data,Q(i)*ones(1,T*fs*2)];
end
% t=0:1/fs:L*T-1/fs;

% 载波信号
bit_t=0:1/fs:2*T-1/fs;%载波周期为2倍比特周期,定义时间轴
%定义I路和Q路的载波
I_carrier=[];Q_carrier=[];
for i=1:L/2
    I_carrier=[I_carrier,I(i)*cos(2*pi*fc*bit_t)];%I路载波信号
    Q_carrier=[Q_carrier,Q(i)*cos(2*pi*fc*bit_t+pi/2)];%Q路载波信号
end
% 传输信号
s=I_carrier+Q_carrier;