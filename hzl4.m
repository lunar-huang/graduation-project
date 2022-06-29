clear all;
close all; 
clc;
%mp_mode=1是广电1信道，mp_mode=6是广电6信道，mp_mode=8是广电8信道
%mp_mode=11是巴西A信道，mp_mode=12是巴西B信道，mp_mode=17是DVB-T信道
mp_mode=11;
IFFT_bin_length=512;
carrier_count=512;%------------初始数据载波
num_symbol=16;%---------------每个载波上OFDM符号个数
Guard=carrier_count/4;%----------------------循环前缀
pilot_Inter=4;%---------------------导频间隔
modulation_mode=2;%----------QPSK调制方式
SNR=0:2:20;%---------------------信噪比取值
NumLoop=20;%--------------------循环次数
fc=2e9;
fs=1e10;
whole=carrier_count+Guard;
%----------------------------SBTC-----------------------------
O=[1 -2 -3;2+j 1+j 0;3+j 0 1+j;0 -3+j 2+j];  
co_time=size(O,1);                                                                   
Nt=size(O,2);                %发射天线数目  
Nr=2;                        %接收天线数目 

num_bit_err=zeros(length(SNR),NumLoop);
num_bit_err_ls=zeros(length(SNR),NumLoop);
num_bit_err_mmse=zeros(length(SNR),NumLoop);
num_bit_err_rcf=zeros(length(SNR),NumLoop,3);
num_bit_err_srcf=zeros(length(SNR),NumLoop,3);
%----------------------------------------------------------------------
%---------------空时编码--------------------------
num_X=1; 
for cc_ro=1:co_time 
    for cc_co=1:Nt 
        num_X=max(num_X,abs(real(O(cc_ro,cc_co)))); 
    end 
end 
co_x=zeros(num_X,1); 

for con_ro=1:co_time    
    for con_co=1:Nt     %用于确定矩阵“O”中元素的位置，符号以及共轭情况 
        if abs(real(O(con_ro,con_co)))~=0 
            delta(con_ro,abs(real(O(con_ro,con_co))))=sign(real(O(con_ro,con_co)));  
            epsilon(con_ro,abs(real(O(con_ro,con_co))))=con_co; 
            co_x(abs(real(O(con_ro,con_co))),1)=co_x(abs(real(O(con_ro,con_co))),1)+1; 
            eta(abs(real(O(con_ro,con_co))),co_x(abs(real(O(con_ro,con_co))),1))=con_ro; 
            coj_mt(con_ro,abs(real(O(con_ro,con_co))))=imag(O(con_ro,con_co)); 
        end 
    end 
end 
eta=eta.';                                                                            
eta=sort(eta); 
eta=eta.'; 
 
% 坐标： (1 to 100) + 14=(15:114)
carriers = (1: carrier_count) + (floor(IFFT_bin_length/4) - floor(carrier_count/2));
% 坐标 ：256 - (15:114) + 1= 257 - (15:114) = (242:143) 
conjugate_carriers=IFFT_bin_length-carriers+2;                                          
% tx_training_symbols=training_symbol(Nt,carrier_count); 
baseband_out_length = carrier_count * num_symbol; 


%%%%%%%%%%%%%%%主程序循环%%%%%%%%%%%%%%%%
for c1=1:length(SNR)
    fprintf('\n\n\n仿真信噪比为%f\n\n',SNR(c1));
%     data3=zeros(1440,10,10); 
    for num1=1:NumLoop
        %--------------------产生发送的随机序列-----------------------------------------
        BitsLen=carrier_count*num_symbol*modulation_mode; %6960
        BitsTx=randi([0 1],1,BitsLen); 
           
        %----------------------------QPSK调制---------------------------------------
        BitsTx1=reshape(BitsTx,BitsLen/num_symbol,num_symbol);
        Modulated_Sequence=map_4_QAM(BitsTx1);
        [scl,scw]=size(Modulated_Sequence);

        %---------------------编码------------------------------------------
        

        %-------------------导频格式---------------------------------------
        pilot_len=BitsLen/num_symbol;       
        pilot_symbols=round(rand(1,pilot_len)); 
        pilot_symbols=pilot_symbols.';
        pilot_symbols=map_4_QAM(pilot_symbols);%QPSK调制
        %----------------计算导频和数据数目----------------------------
        num_pilot=ceil(num_symbol/pilot_Inter); 
        if rem(num_symbol,pilot_Inter)==0 
            num_pilot=num_pilot+1; 
        end
        num_data=num_symbol+num_pilot; 
        %--------------------导频位置计算----------------------------------
        pilot_Indx=zeros(1,num_pilot); 
        Data_Indx=zeros(1,num_pilot*(pilot_Inter+1));
        for i=1:num_pilot-1 
            pilot_Indx(1,i)=(i-1)*(pilot_Inter+1)+1;
        end
        pilot_Indx(1,num_pilot)=num_data; 
        for j=0:num_pilot  
            Data_Indx(1,(1+j*pilot_Inter):(j+1)*pilot_Inter)=(2+j*(pilot_Inter+1)):((j+1)*(pilot_Inter+1));
        end 
        Data_Indx=Data_Indx(1,1:num_symbol); 
        %--------------------导频插入-------------------------------------
        piloted_ofdm_syms=zeros(scl,num_data);
        piloted_ofdm_syms(:,Data_Indx)=reshape(Modulated_Sequence,scl,num_symbol);
        piloted_ofdm_syms(:,pilot_Indx)=repmat(pilot_symbols,1,num_pilot);
        
        %-------------------载波----------------------
        k=1:num_data;
        carrier=cos(2*pi*fc*k/fs);
%         carrier=carrier.';

        %--------------------IFFT变换-----------------------------------------
        time_signal=sqrt(scl)*ifft(piloted_ofdm_syms);
        time_signal_c=time_signal.*carrier;

        %-------------------加循环前缀--------------------------------------
        add_cyclic_signal=[time_signal_c(scl-Guard+1:scl,:);time_signal_c];
        Tx_data_trans=reshape(add_cyclic_signal,1,(scl+Guard)*num_data);
        %--------------------信道处理（CP长192）----------------------------------
        h1 = multipath(mp_mode,1/7.56,0); 
        Rx_data=filter(h1,1,Tx_data_trans); 
        Rx_data=awgn(Rx_data,SNR(c1),'measured'); 

        %------------信号接收、去循环前缀、FFT变换-----------------
        Rx_signal=reshape(Rx_data,(scl+Guard),num_data); 
        Rx_signal_matrix=zeros(scl,num_data);
        Rx_signal_matrix=Rx_signal(Guard+1:end,:);
        Rx_signal_c=Rx_signal_matrix./carrier;
        Rx_carriers=fft(Rx_signal_c)/sqrt(scl);
        %------------------导频和数据提取--------------------------------
        Rx_pilot=Rx_carriers(:,pilot_Indx);
        Rx_fre_data=Rx_carriers(:,Data_Indx);

        %-------------导频位置信道响应LS估计------------------------
        pilot_patt=repmat(pilot_symbols,1,num_pilot);
        pilot_esti=Rx_pilot./pilot_patt;
        %----------------LS估计的线性插值------------------------------
        int_len=pilot_Indx; 
        len=1:num_data;
        for ii=1:scl  
            channel_H_ls(ii,:)=interp1(int_len,pilot_esti(ii,1:(num_pilot)),len,'linear'); 
        end     
         channel_H_data_ls=channel_H_ls(:,Data_Indx);
         h_ls=ifft(channel_H_data_ls,scl);
         hh=h1.';
         hh= repmat(hh,1,scw);
         H=fft((hh),scl);
        %------------------MMSE算法--------------------------------------------             
        channel_H_mmse2=[];
        for cy=1:length(pilot_patt)
        channel_H_mmse2=[channel_H_mmse2; 
        MMSE_CE(Rx_carriers(cy,:),repmat(pilot_symbols(cy),1,num_pilot),pilot_Indx,num_data,pilot_Inter,num_pilot,h1,SNR(c1))];
        end
        channel_H_data_mmse=channel_H_mmse2(:,Data_Indx);
        h_mmse=ifft(channel_H_data_mmse,scl);        

        %------------------ideal channel estimation ------------------------
         Tx_data_estimate=Rx_fre_data.*conj(H)./(abs(H).^2);
        %----------------LS估计中发送数据的估计值----------------------
         Tx_data_estimate_ls=Rx_fre_data.*conj(channel_H_data_ls)./(abs(channel_H_data_ls).^2); 
        %----------------MMSE估计中发送数据的估计值----------------------
         Tx_data_estimate_mmse=Rx_fre_data.*conj(channel_H_data_mmse)./(abs(channel_H_data_mmse).^2); 
        
%      %-------------------ideal符号解调--------------------------------
         demod_in=Tx_data_estimate;
         demod_out=de_map4(demod_in);  
         
%  %       ----------------LS符号解调------------------------------------
         demod_in_ls=Tx_data_estimate_ls;
         demod_out_ls=de_map4(demod_in_ls);

%  %       ----------------MMSE符号解调------------------------------------
         demod_in_mmse=Tx_data_estimate_mmse;
         demod_out_mmse=de_map4(demod_in_mmse);
          
%         %----------------误码率的计算---------------------------------
         for i=1:length(BitsTx) 
              if demod_out(i)~=BitsTx(i) 
                 num_bit_err(c1,num1)=num_bit_err(c1,num1)+1; 
              end
              if demod_out_ls(i)~=BitsTx(i)
                 num_bit_err_ls(c1,num1)=num_bit_err_ls(c1,num1)+1;
              end
              if demod_out_mmse(i)~=BitsTx(i)
                 num_bit_err_mmse(c1,num1)=num_bit_err_mmse(c1,num1)+1;
              end
         end
     end
    end   
BER_ls2=mean(num_bit_err_ls.')/length(BitsTx);                    %LS信道估计
BER_mmse2=mean(num_bit_err_mmse.')/length(BitsTx);                %MMSE信道估计
BER=mean(num_bit_err.')/length(BitsTx);                                 %ideal信道估计
%%%%%%%%%%%%主程序循环换结束%%%%%%%%%%%%%%%%%%
% figure
% semilogy(SNR,BER_ls,'-k^',SNR,BER_mmse,'-ro',SNR,BER,'-bs');grid on;
% xlabel('SNR (dB)'),ylabel('BER');
% legend('LS信道估计','MMSE信道估计','理想信道估计','FontName','宋体');
% title('静态广电8信道',FontName='宋体');

