clear all;clc;
%% ������Ϣ
N=20;%������
T=1;%��������
fc=2;%�ز�Ƶ��
Fs=100;%����Ƶ��

% bitstream=randi([0,1],1,N);%��������ı�����0��1
% bitstream=2*bitstream-1;%�����Ա�Ϊ˫���ԣ�0��-1��1��1��
bitstream=Tsignal(N,2);
%% ����
I=[];Q=[];
%������I·,ż����Q·
for i=1:N
    if mod(i,2)~=0
        I=[I,bitstream(i)];
    else
        Q=[Q,bitstream(i)];
    end
end

% I=m(1:2:N);
% Q=m(2:2:N);
%% ������
%���û�ͼ�Ƚ�I��Q������
bit_data=[];
for i=1:N
    bit_data=[bit_data,bitstream(i)*ones(1,T*Fs)];%��һ����������������T*Fs��1�Ͳ�����һģһ��
end
I_data=[];Q_data=[];
for i=1:N/2
    %I·��Q·��ԭ���������ڵ�����,2Tb=Ts(��Ԫ����)����˲��������ΪT*Fs*2
    I_data=[I_data,I(i)*ones(1,T*Fs*2)];
    Q_data=[Q_data,Q(i)*ones(1,T*Fs*2)];
end
%% ��ͼ
figure();
%ʱ����
t=0:1/Fs:N*T-1/Fs;
subplot(3,1,1)
plot(t,bit_data);legend('Bitstream')%������Ϣ
subplot(3,1,2)
plot(t,I_data);legend('I Bitstream')%I·��Ϣ
subplot(3,1,3)
plot(t,Q_data);legend('Q Bitstream')%Q·��Ϣ
%% �ز��ź�
bit_t=0:1/Fs:2*T-1/Fs;%�ز�����Ϊ2����������,����ʱ����
%����I·��Q·���ز�
I_carrier=[];Q_carrier=[];
for i=1:N/2
    I_carrier=[I_carrier,I(i)*cos(2*pi*fc*bit_t)];%I·�ز��ź�
    Q_carrier=[Q_carrier,Q(i)*cos(2*pi*fc*bit_t+pi/2)];%Q·�ز��ź�
end
%% �����ź�
QPSK_signal=I_carrier+Q_carrier;
%% ��ͼ
figure();%����һ����ͼ
subplot(3,1,1)
plot(t,I_carrier);legend('I signal')%I·�ź�
subplot(3,1,2)
plot(t,Q_carrier);legend('Q signal')%Q·�ź�
subplot(3,1,3)
plot(t,QPSK_signal);legend('QPSK signal')%I·��Q·�͵��ź�
%% �����ź�
snr=1;%�����
QPSK_receive=awgn(QPSK_signal,snr);%awgn()�������
%% ���
for i=1:N/2
    I_output=QPSK_receive(1,(i-1)*length(bit_t)+1:i*length(bit_t)).*cos(2*pi*fc*bit_t);
    if sum(I_output)>0 %��������ͣ�����0Ϊ1������Ϊ-1
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
%% ��/���任
bit_recover=[];
for i=1:N
    if mod(i,2)~=0
        bit_recover=[bit_recover,I_recover((i-1)/2+1)];%����ȡI·��Ϣ
    else
        bit_recover=[bit_recover,Q_recover(i/2)];%ż��ȡQ·��Ϣ
    end
end
%���û�ͼ�Ƚ�I��Q������
recover_data=[];
for i=1:N
    recover_data=[recover_data,bit_recover(i)*ones(1,T*Fs)];
end
I_recover_data=[];Q_recover_data=[];
for i=1:N/2
    I_recover_data=[I_recover_data,I_recover(i)*ones(1,T*Fs*2)];
    Q_recover_data=[Q_recover_data,Q_recover(i)*ones(1,T*Fs*2)];
end
%% ��ͼ
figure();
t=0:1/Fs:N*T-1/Fs;
subplot(3,1,1)
plot(t,recover_data);legend('Bitstream recover')%�ָ��ı�����Ϣ
subplot(3,1,2)
plot(t,I_recover_data);legend('I Bitstream recover')%�ָ���I·��Ϣ
subplot(3,1,3)
plot(t,Q_recover_data);legend('Q Bitstream recover')%�ָ���Q·��Ϣ
