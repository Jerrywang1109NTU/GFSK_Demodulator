% MATLAB Script to compute the spectrum of an FSK signal

% Parameters
clc;
clear;
fd = 5e5;               % 符号频率
Insert_20 = 20;
fs = fd * Insert_20;       % 采样频率
T = 1/fs;            % Sampling period in seconds
L = 1000;            % Length of signal (number of samples)
t = (0:L-1) * T;     % Time vector
BT = 0.5 ;
% FSK Signal Parameters
f1 = fd + 0.35*fd;            % Frequency for binary '1'
f2 = fd - 0.35*fd;             % Frequency for binary '0'
data = randi([0, 1], 1, 50);  % Random binary data sequence
bit_duration = L / length(data); % Duration of each bit

% Generate FSK signal
signal = zeros(1, L);
for k = 1:length(data)
    idx = (k-1)*bit_duration + 1 : k*bit_duration;
    if data(k) == 1
        signal(idx) = cos(2*pi*f1*t(idx));
    else
        signal(idx) = cos(2*pi*f2*t(idx));
    end
    fsk(idx) = data(k)*2-1;
end
% Compute the Fourier Transform
Y = fft(signal);
f = fs*(0:(L/2))/L;
% Compute the two-sided spectrum P2 and the single-sided spectrum P1
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
% P1(2:end-1) = 2*P1(2:end-1);
figure;
plot(f, 20*log10(P1), 'LineWidth', 1)
title('GFSK调制与FSK调制信号频谱对比');
xlabel('频率(Hz)');
ylabel('功率(dB)');
hold on;
% Define the frequency axis

B = fd * BT;            % fir 3dB 带宽
N = 1.5;                % 滤波器覆盖三个字符长度   
Hn = Gaussian_fir(fs, fd, N, B);
gfsk = GFSK_IQ_generate(data, Hn, Insert_20);
Y = fft(gfsk);

% Compute the two-sided spectrum P2 and the single-sided spectrum P1
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
% P1(2:end-1) = 2*P1(2:end-1);
plot(f, 20*log10(P1), 'LineWidth', 1);
legend('FSK', 'GFSK')
% Plot the single-sided amplitude spectrum


NRZI_data = 2*data - 1;
% NRZI = NRZI_data;
NRZI_data = upsample(NRZI_data, Insert_20);
NRZI_data_conv_Hn = conv(NRZI_data, Hn, 'same');
figure;
plot(fsk/20); title('GFSK调制与FSK调制信号波形对比'); 
xlabel('采样点数');
ylabel('幅度');
hold on;
plot(NRZI_data_conv_Hn);
legend('FSK', 'GFSK')
% clf;
% subplot(211);   plot(signal);
% subplot(211);   plot(signal);
% % End of script
