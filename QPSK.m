function [X_data,s]=QPSK(fs,fc,X,T)
%fs ����Ƶ��
%fc �ز�Ƶ��
%T  ��������
%L  �źų���

t=0:1/fs:1-1/fs;
m=2*X-1;
L=length(X);

I=m(1:2:L);
Q=m(2:2:L);

bit_data=[];
for i=1:L
    bit_data=[bit_data,X(i)*ones(1,T*fs)];%��һ����������������T*Fs��1�Ͳ�����һģһ��
end
X_data=bit_data;
I_data=[];Q_data=[];
for i=1:L/2
    %I·��Q·��ԭ���������ڵ�����,2Tb=Ts(��Ԫ����)����˲��������ΪT*Fs*2
    I_data=[I_data,I(i)*ones(1,T*fs*2)];
    Q_data=[Q_data,Q(i)*ones(1,T*fs*2)];
end
% t=0:1/fs:L*T-1/fs;

% �ز��ź�
bit_t=0:1/fs:2*T-1/fs;%�ز�����Ϊ2����������,����ʱ����
%����I·��Q·���ز�
I_carrier=[];Q_carrier=[];
for i=1:L/2
    I_carrier=[I_carrier,I(i)*cos(2*pi*fc*bit_t)];%I·�ز��ź�
    Q_carrier=[Q_carrier,Q(i)*cos(2*pi*fc*bit_t+pi/2)];%Q·�ز��ź�
end
% �����ź�
s=I_carrier+Q_carrier;