function [X,signal_data,pilot_loc]=AddPilot(P,L,msgint,Nps,fs,fcup,T)

[mod_msgint]=QPSK(fs,fcup,msgint,T) ;
% msgint_data=qammod(msgint,16);

ip=0;
pilot_loc=[];

for i=1:L
    if(mod(i,Nps))==1
        X(i)=P(floor(i/Nps)+1);
        pilot_loc=[pilot_loc i];
        ip=ip+1;
    else
        X(i)=msgint(i-ip);
    end
end

signal_data=[];ip=1;
for i=1:L
    if (mod(i,Nps))==1
        signal_data=[signal_data,P(ip)*ones(1,T*fs)];
        ip=ip+1;    
    else
        signal_data=[signal_data,mod_msgint(1,(i-ip)*T*fs+1:(i-ip+1)*T*fs)];
    end
end
    
    
    
