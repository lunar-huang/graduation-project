function [X,pilot_loc,msgint_data]=AddPilot(P,L,msgint,Nps,fs,fcup,T)

[msgint_data,mod_msgint]=QPSK(fs,fcup,msgint,T) ;
% msgint_data=qammod(msgint,16);

ip=0;
pilot_loc=[];

for i=1:L
    if(mod(i,Nps))==1
        X(i)=P(floor(i/Nps)+1);
        pilot_loc=[pilot_loc i];
        ip=ip+1;
    else
        X(i)=mod_msgint(i-ip);
    end
end