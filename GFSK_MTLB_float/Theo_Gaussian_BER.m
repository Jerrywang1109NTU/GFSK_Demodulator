clc;
clear;

load('BER.mat', 'BER');

Insert_20 = 20;
fd = 5e5;               % 符号频率
fs = fd * Insert_20;       % 采样频率
BT = 0.5;
B = fd * BT;            % fir 3dB 带宽
N = 1.5;                % 滤波器覆盖三个字符长度       

Hn = Gaussian_fir(fs, fd, N, B);

EbN0 = 8:16;

test_seq = [1 1 1 0 0 0 1 1 1];
[~, ~, phi] = GFSK_IQ_generate(test_seq, Hn, Insert_20);

% miu_0_1 = abs(phi(70)-phi(51));
% miu_1_1 = abs(phi(30)-phi(11));

miu_0_1 = abs(phi(70)-phi(51));
miu_1_1 = abs(phi(30)-phi(11));
miu_1_0 = -miu_0_1;
miu_0_0 = -miu_1_1;

pn = 1./(10.^((EbN0-10*log10(Insert_20))/10));
% arctan(g(t))服从什么分布？kd
sigma_cos = pn;

t = -100:0.01:100;

BER_0_1 = zeros(1,length(sigma_cos));
BER_1_1 = zeros(1,length(sigma_cos));
BER_1_0 = zeros(1,length(sigma_cos));
BER_0_0 = zeros(1,length(sigma_cos));

for i = 1:length(sigma_cos)
    tmp = sigma_cos(i);
    tmp_0_1 = -(t-miu_0_1).^2/tmp/2;
    tmp_1_1 = -(t-miu_1_1).^2/tmp/2;
    tmp_1_0 = -(t-miu_1_0).^2/tmp/2;
    tmp_0_0 = -(t-miu_0_0).^2/tmp/2;

    Q_0_1 = 1/sqrt(2*pi*tmp).*exp(tmp_0_1)/100;
    Q_1_1 = 1/sqrt(2*pi*tmp).*exp(tmp_1_1)/100;
    Q_1_0 = 1/sqrt(2*pi*tmp).*exp(tmp_1_0)/100;
    Q_0_0 = 1/sqrt(2*pi*tmp).*exp(tmp_0_0)/100;

    for j = 1:length(t)
        if (sin(t(j)) < 0)
            BER_0_1(i) = BER_0_1(i) + Q_0_1(j);
            BER_1_1(i) = BER_1_1(i) + Q_1_1(j);
        else
            BER_1_0(i) = BER_1_0(i) + Q_1_0(j);
            BER_0_0(i) = BER_0_0(i) + Q_0_0(j);
        end
    end 
end

BER_theo = (BER_0_1 + BER_1_1 + BER_0_0 + BER_1_0)/4;

figure;
semilogy(EbN0, BER_theo, '-o', 'LineWidth', 1.5);  % 用半对数坐标绘制 BER 曲线
hold on;
grid on;
semilogy(EbN0, BER, '-o', 'LineWidth', 1.5); 
xlabel('E_b/N_0 (dB)', 'FontSize', 12);
ylabel('Bit Error Rate (BER)', 'FontSize', 12);
title('GFSK with Differential Demodulation (h = 0.7)', 'FontSize', 14);
legend('Theoretical BER Curve', 'Actual BER Cureve');