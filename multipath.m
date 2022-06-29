function h = multipath(mp_mode, unit_delay, dbg)

if or(mp_mode>19,mp_mode<1) h=1; return; end

%--------%multipath channel model 
%Medium-Echo Static (1--6), 
%Violence-Echo Static (7--10)
path_scale(1:19,1:6)=0; %in db
path_delay(1:19,1:6)=0; %in us

path_scale(1,1:6)=[  -20    0  -20  -10  -14  -18];
path_delay(1,1:6)=[ -1.8    0 0.15  1.8  5.7   18]+1.8;

path_scale(2,1:6)=[  -18    0  -20  -20  -10  -14];
path_delay(2,1:6)=[ -1.8    0 0.15  1.8  5.7   30]+1.8;

path_scale(3,1:6)=[  -20    0  -14  -10  -20  -18];
path_delay(3,1:6)=[ -1.8    0 0.15  1.8  5.7   18]+1.8;

path_scale(4,1:6)=[    0  -10  -14  -18  -20  -20];
path_delay(4,1:6)=[    0  0.2  1.9  3.9  8.2   15];

path_scale(5,1:6)=[  -19    0  -22  -17  -22  -19];
path_delay(5,1:6)=[ -0.2    0 0.08 0.15  0.3  0.6]+0.2;

path_scale(6,1:6)=[  -10  -20    0  -20  -10  -14];
path_delay(6,1:6)=[  -18 -1.8    0 0.15  1.8  5.7]+18;

path_scale(7,1:6)=[  -20    0  -20  -10    0  -18];
path_delay(7,1:6)=[ -1.8    0 0.15  1.8  5.7   18]+1.8;

path_scale(8,1:6)=[  -18    0  -20  -20  -10    0];
path_delay(8,1:6)=[ -1.8    0 0.15  1.8  5.7   30]+1.8;

path_scale(9,1:6)=[ -5.1    0 -3.9 -3.8 -2.5 -1.3];
path_delay(9,1:6)=[ 0.07 0.52 0.60 0.85 2.75 3.23]-0.07;

path_scale(10,1:6)=[    0 -0.5 -4.3 -4.4 -3.0 -1.8];
path_delay(10,1:6)=[ 0.43 0.52 0.85 1.37 2.75 3.23]-0.43;

path_scale(11,1:6)=[ 0 -13.8 -16.2 -14.9 -13.6 -16.4];
path_delay(11,1:6)=[ 0  0.15  2.22  3.05  5.86  5.93];


path_scale(18,1:6)=[  0.0 -1.0  -9.0  -10.0 -15.0 -20];   %ITU-R Vehicular A
path_delay(18,1:6)=[  0.0 0.31  0.71  1.09  1.73  2.51];

path_scale(19,1:6)=[-2.5   0.0 -12.8 -10.0 -25.2 -16.0];  % ITU-R Vehicular B
path_delay(19,1:6)=[ 0.0  0.30  8.90 12.90 17.10 20.00];


%attenuation, delay (in us) and phase (in rad) values
x=[...
 1 0.057662 1.003019 4.855121;
 2 0.176809 5.422091 3.419109;
 3 0.407163 0.518650 5.864470;
 4 0.303585 2.751772 2.215894;
 5 0.258782 0.602895 3.758058;
 6 0.061831 1.016585 5.430202;
 7 0.150340 0.143556 3.952093;
 8 0.051534 0.153832 1.093586;
 9 0.185074 3.324866 5.775198;
10 0.400967 1.935570 0.154459;
11 0.295723 0.429948 5.928383;
12 0.350825 3.228872 3.053023;
13 0.262909 0.848831 0.628578;
14 0.225894 0.073883 2.128544;
15 0.170996 0.203952 1.099463;
16 0.149723 0.194207 3.462951;
17 0.240140 0.924450 3.664773;
18 0.116587 1.381320 2.833799;
19 0.221155 0.640512 3.334290;
20 0.259730 1.368671 0.393889];

%--------%get the transfer function of multipath channel
%system impulse response for ideal low pass filter is sin(pi*t/Ts)/(pi*t/Ts)=sinc(t/Ts)
M=1; %upsampling parameter
unit=unit_delay/M;

if (mp_mode==16 || mp_mode==17)
  scale_temp=x(:,2)'.*exp(-j*x(:,4)'); %rou=rou/norm(rou);
  delay_temp=x(:,3)';
else
  delay_temp=path_delay(mp_mode,:);
  scale_temp=path_scale(mp_mode,:); scale_temp=10.^(scale_temp/20);
end

if (mp_mode==17) %dvb-t rician channel
  %rou(0)^2=sum(rou(i)^2)*10 (K=10 for rician factor)
  scale_temp=[scale_temp sqrt(10)*norm(scale_temp)];
  delay_temp=[delay_temp 0];
end

%--------%get the transfer function of multipath channel

h_len=round(max(delay_temp)/unit)+1;

h=zeros(1,h_len+M*6);
for i1=1:length(delay_temp)
  delay = round(delay_temp(i1)/unit) + 1;
  h(delay+3*M) = h(delay+3*M) + scale_temp(i1); %multi-path may overlap at given sampling rate
end;


h=resample(h,1,M); h=h/norm(h(4:end));
if (dbg)
  figure;
  subplot(2,1,1); plot(real(h),'b.-');
  subplot(2,1,2); plot(abs(fft([h zeros(1,1024-length(h))])),'b.-');
end
