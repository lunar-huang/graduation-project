%QPSK
close all
clear
fs=1e3;
t=0:1/fs:1-1/fs;
a=randi(2,1,20);
m=2*a-1;
I=m(1:2:20);
Q=m(2:2:20);
I=[I(ceil(10*t+0.01)),ones(1,50)];
Q=[ones(1,50),Q(ceil(10*t+0.01))];

t=0:1/fs:1-1/fs+50/fs;
s=I.*cos(2*pi*50*t)-Q.*sin(2*pi*50*t);

L=512;
f=(-L/2:L/2-1)*(fs/L);
S=fft(s,512);
P=abs(fftshift(S)).^2;
%% 
figure;
subplot(411)
plot(t,I);
title('I');
axis([0,1.05,-0.03,3.3])
subplot(412)
plot(t,Q);
title('Q');
axis([0,1.05,-0.3,3.3])
%
subplot(413)
plot(t,s);
title('s');
axis([0,1.05 -inf inf])
subplot(414)
plot(f,P);
title('P');

