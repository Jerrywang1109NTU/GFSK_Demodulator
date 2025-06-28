% 定义参数
EbN0_dB = 10; % 信噪比（可调整）
Insert_20 = 20; % 插入损耗（假设的参数）
pn = 1 ./ (10.^((EbN0_dB - 10*log10(Insert_20))/10));
sigma_cos = pn / 2; % 柯西分布的尺度参数 gamma

% 已知的相位偏移均值
miu_0_1 = abs(phi(70) - phi(51));
miu_1_1 = abs(phi(30) - phi(11));
miu_1_0 = -miu_0_1;
miu_0_0 = -miu_1_1;

% 计算误码率
Pe_0_1 = (1/pi) * atan(miu_0_1 / sigma_cos) + 0.5;
Pe_1_1 = (1/pi) * atan(miu_1_1 / sigma_cos) + 0.5;
Pe_1_0 = (1/pi) * atan(miu_1_0 / sigma_cos) + 0.5;
Pe_0_0 = (1/pi) * atan(miu_0_0 / sigma_cos) + 0.5;

% 输出误码率
fprintf('误码率 P(0->1): %f\n', Pe_0_1);
fprintf('误码率 P(1->1): %f\n', Pe_1_1);
fprintf('误码率 P(1->0): %f\n', Pe_1_0);
fprintf('误码率 P(0->0): %f\n', Pe_0_0);

% 绘制理论柯西分布 PDF
x = linspace(-100, 100, 20000);
pdf_cauchy = 1 ./ (pi * sigma_cos * (1 + (x/sigma_cos).^2)); % C(0, sigma_cos)

figure;
plot(x, pdf_cauchy, 'r', 'LineWidth', 2);
xlabel('x');
ylabel('Probability Density');
title('Cauchy Distribution PDF');
grid on;
