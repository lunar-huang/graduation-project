function [H,PDP,avg_pow_h]=channelIEEE80211(t_rms,Ts,num_ch,N)

PDP=IEEE802_11_model(t_rms,Ts); 
for k=1:length(PDP)
    h(:,k) = Ray_model(num_ch).'*sqrt(PDP(k));
    avg_pow_h(k)= mean(h(:,k).*conj(h(:,k)));
end
H=fft(h(1,:),N);