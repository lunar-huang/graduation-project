% This examples shows how to estimate channels in MIMO-OFDM systems(LSE)

% for simplicity, this program only considers one OFDM symbol per
% transmission, the channel has two taps with power delay profile
% delay = [0,1](smaples), avarage power [0.8, 0.2]. Modultion: QPSK

% source paper: I. Barhumi, G. Leus and M. Moonen, 
% "Optimal training design for MIMO OFDM systems in mobile wireless channels," 
% in IEEE Transactions on Signal Processing, vol. 51, no. 6, pp. 1615-1624,
% June 2003.
clear;

nFFT = 512; % fft size
nCP= nFFT/4;   % cp length
% nSym= 16;
Nt = 2;     % number of transmit antennas
Nr = 2;     % number of receive antenna
snr=0:4:40;
pilotPos = 1:2:nFFT; % pilot positions

QPSK_mod=comm.QPSKModulator();
QPSK_demod=comm.QPSKDemodulator();

lse_ber=[];  mse_lse=[];  mse_lse2=[];
mmse_ber=[];  mse_mmse=[];  mse_mmse2=[];
% 
for lo=1:3

    if lo==1
        avgPow = [0.95;0.05];
    elseif lo==2
        avgPow = [0.8;0.2];
    else
        avgPow = [0.65;0.35];
    end
%---------------------主循环----------------------------
for k=1:length(snr)
    N0=10^(-snr(k)/10);
    fprintf('SNR = %f\n\n',snr(k));
%     N0 = 0.2; %noise variance
    lse_ratio=[];
    mmse_ratio=[];
    
    %% Modulation QPSK
        moduOrder = 2;
        nOfBits = Nt* nFFT *moduOrder;
        b =  randi([0,1],nOfBits,1);
        symb = zeros(nOfBits/2,1);
        for i = 0: nOfBits/2-1
            symb(i+1) = 1/sqrt(2)*((1-2*b(2*i+1))+1j*(1-2*b(2*i+2)));
        end
 %% antenna mapping
        symb = reshape(symb, nFFT, Nt);
        symb_demod=QPSK_demod(reshape(symb,Nt*nFFT,1));
        symb_demod=reshape(symb_demod,nFFT,Nt);
        % pilot
        pilot = symb(pilotPos,:);
        
        %% ofdm + cp
        txSig = zeros(nFFT+nCP,Nt);x2=[];
        for i = 1: Nt
            x = sqrt(nFFT)*ifft(symb(:,i));
            x2=[x2,x];
            txSig(:,i) = [x(end-nCP+1:end);x];
        end

%-------------------循环几次，为了获得平滑的曲线----------------------------------
    for j=1:1000  
    %% channel
        nTaps = 2;
%         avgPow = [0.8;0.2];
        delay = [0,30];
        h = zeros(Nr,Nt,nTaps);
        % h=multipath(1,1/7.56,0);
        for i = 1: Nr
            for j2 = 1: Nt
                 h(i,j2,:) = avgPow.* (randn(nTaps,1) + 1i*randn(nTaps, 1));
        %          h(i,j,:)=multipath(1,1/7.56,0);
            end
        end
        
        %% recieved signal
        rxSig = zeros(nFFT+nCP+1,Nr);
        for i = 1: Nr
            
            for j2 =  1: Nt
                y = conv(txSig(:,j2),squeeze(h(i,j2,:)));
                noise = sqrt(N0/2) * (randn(size(y)) + 1j*randn(size(y)));
                rxSig(:,i) = rxSig(:,i) + y + noise;
            end
            
        end
        
        %% remove delay spread
        rxSig = rxSig(1:end-1,:);
        % remove cp
        rxSig = rxSig(nCP+1:end,:);
        % FFT
        RxSymbs = fft(rxSig)/sqrt(nFFT);
        
        %---------------------------------------------------------------------------
        %% channel estimation LSE
        [h_hat,H_hat] = mimoOfdmChannelEst(RxSymbs,pilot,pilotPos,Nt,Nr,nFFT,nTaps,N0,'lse');
        h_lse=RxSymbs(pilotPos,:)./x2(pilotPos,:);
        % equalization with ZF
        eqSymb = zeros(nFFT,Nt);
        for iSC =  1: nFFT
            H = squeeze(H_hat(:,:,iSC));
            tmp = RxSymbs(iSC,:);
            eqSymb(iSC,:) = pinv(H)* tmp(:);        
        end
        mse_lse(j) = norm(eqSymb(:)-symb(:))^2/length(symb(:));
        lse_demod=QPSK_demod(reshape(eqSymb,nFFT*Nt,1));
        lse_demod=reshape(lse_demod,nFFT,Nt);
        [number,lse_ratio(j)]=biterr(lse_demod,symb_demod);
        
        close all
%         plot(symb(:),'r+');
%         hold on;
%         plot(eqSymb(:),'bo')
        
        %---------------------------------------------------------------------------
        %% channel estimation MMSE
        [h_hat,H_hat] = mimoOfdmChannelEst(RxSymbs,pilot,pilotPos,Nt,Nr,nFFT,nTaps,N0,'mmse');
        
        % equalization with MMSE
        eqSymb = zeros(nFFT,Nt);
        for iSC =  1: nFFT
            H = squeeze(H_hat(:,:,iSC));
            tmp = RxSymbs(iSC,:);
            eqSymb(iSC,:) = inv(H' *H + N0*eye(Nt))*H'* tmp(:);        
        end
        mse_mmse(j) = norm(eqSymb(:)-symb(:))^2/length(symb(:));
        mmse_demod=QPSK_demod(reshape(eqSymb,nFFT*Nt,1));
        mmse_demod=reshape(mmse_demod,nFFT,Nt);
        [number,mmse_ratio(j)]=biterr(mmse_demod,symb_demod);
        
        
    end
    mse_lse2(lo,k)=mean(mse_lse);
    mse_mmse2(lo,k)=mean(mse_mmse);
    lse_ber(lo,k)=mean(lse_ratio);
    mmse_ber(lo,k)=mean(mmse_ratio);
%     fprintf('Mean Square Error with noise variance %f: \n',N0);
%     fprintf('LSE: %f MMSE: %f \n',mse_lse2(k), mse_mmse2(k));
    
    
end
fprintf('LSE: %f  \n\n',lse_ber(lo,:));
% ,mmse_ber(lo,:)MMSE: %f
end
% plot(eqSymb(:),'ks')
% legend('ref symbols','rx symbs(LSE)','rx symbs(MMSE)');
% xlim([-2,2]); ylim([-2,2]);
% grid on;
% xlabel("Inphase");
% ylabel("Quadrature");,snr,lse_ber,'-gs'
% 
figure(1);
% semilogy(snr,lse(1,:),'-bo',snr,mse_lse2(2,:),'-r^',snr,mse_lse2(3,:),'-gs')
semilogy(snr,lse_ber(1,:),'-bo',snr,lse_ber(2,:),'-r^',snr,lse_ber(3,:),'-gs')
% semilogy(snr,lse_ber,'-bo',snr,mmse_ber,'-r^');
grid on;
xlabel("{\itr}_S_N_R (dB)");ylabel("{\itr}_B_E_R");
% legend('{\itN}_t=2,{\itN}_r=2','{\itN}_t=4,{\itN}_r=4','{\itN}_t=32,{\itN}_r=32');