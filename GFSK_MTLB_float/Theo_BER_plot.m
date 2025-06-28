% MATLAB 程序：GFSK 差分解调误码率绘图
% 调制指数 h = 0.7

% 参数设置
fs = 5e5;
ts = 1/fs;
h = 0.7;                      % 调制指数
B = 5e5/2;
EbN0_dB = 8:1:15;             % Eb/N0 范围 (dB)
EbN0 = 10.^(((EbN0_dB)/ 10)-log10(20));    % 将 dB 转换为线性比例
Pb = zeros(size(EbN0));       % 初始化误码率数组
BER_Theo = [0.0196932486909782, 0.0106874726204323, 0.00525387148100887, 0.00200896666201269, 0.000756550131400812, 0.000139569505613796, 3.21688219777392e-05, 0];
BER_Actu = [0.0214212136346610	0.0118661771708576	0.00539445496600329	0.00234078056920367	0.000855161787365177	0.000170741171905316	5.47713686582580e-05	7.78852594357992e-06];
% 误码率计算
sc = sinc(ts*2*B)/(ts*2*B);
for i = 1:length(EbN0)
    % Pb(i) = qfunc(sqrt(EbN0(i)/0.7*0.5));  % Q 函数计算误码率
    Pb(i) = qfunc(0.3*pi*sqrt(EbN0(i)/(1-sc)));  % Q 函数计算误码率
end


% 绘制 BER 曲线
figure;
semilogy(EbN0_dB, Pb, '-o', 'LineWidth', 1.5);  % 用半对数坐标绘制 BER 曲线
hold on;
grid on;
semilogy(EbN0_dB, BER_Theo, '-o', 'LineWidth', 1.5); 
semilogy(EbN0_dB, BER_Actu, '-o', 'LineWidth', 1.5); 
xlabel('E_b/N_0 (dB)', 'FontSize', 12);
ylabel('Bit Error Rate (BER)', 'FontSize', 12);
title('GFSK with Differential Demodulation (h = 0.7)', 'FontSize', 14);
legend('Mathematical BER Curve', 'Theoretical BER Curve', 'Actual BER Curve');
