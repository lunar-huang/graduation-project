function S_recover=QPSK_demodulate(fs,fc,Y,T,L)

bit_t=0:1/fs:2*T-1/fs;
for i=1:L/2
    I_output=Y(1,(i-1)*length(bit_t)+1:i*length(bit_t)).*cos(2*pi*fc*bit_t);
    if sum(I_output)>0 %积分器求和，大于0为1，否则为-1
        I_recover(i)=1;
    else
        I_recover(i)=-1;
    end
    Q_output=Y(1,(i-1)*length(bit_t)+1:i*length(bit_t)).*cos(2*pi*fc*bit_t+ pi/2);
    if sum(Q_output)>0
        Q_recover(i)=1;
    else
        Q_recover(i)=-1;
    end
end

bit_recover=[];
for i=1:L
    if mod(i,2)~=0
        bit_recover=[bit_recover,I_recover((i-1)/2+1)];%奇数取I路信息
    else
        bit_recover=[bit_recover,Q_recover(i/2)];%偶数取Q路信息
    end
end

recover_data=[];
for i=1:L
    recover_data=[recover_data,bit_recover(i)*ones(1,T*fs)];
end
S_recover=recover_data;

