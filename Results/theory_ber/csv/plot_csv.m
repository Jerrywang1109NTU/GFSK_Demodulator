% 读取数据
data = readtable('your_data.csv');  % 请将你的CSV文件路径替换为实际路径
SNR = data.EbN0_dB;  % SNR列名是EbN0_dB
BER_actual = data.BER_Actual;  % 实际BER列名是BER_Actual
BER_theory = data.BER_QDiffModel_Fit13dB;  % 理论BER列名是BER_QDiffModel_Fit13dB

% 创建图形
figure;

% 绘制理论BER曲线
semilogy(SNR, BER_theory, 'b-', 'LineWidth', 2);  % 理论曲线，蓝色，线宽为2
hold on;

% 绘制实际BER曲线
semilogy(SNR, BER_actual, 'r-o', 'LineWidth', 2, 'MarkerSize', 6);  % 实际曲线，红色，带圆圈标记

% 设置图形的属性
grid on;
xlabel('Eb/N0 (dB)', 'FontSize', 14);  % X轴标签
ylabel('Bit Error Rate (BER)', 'FontSize', 14);  % Y轴标签
title('理论与实际误码率曲线', 'FontSize', 16);  % 图表标题
legend('理论BER', '实际BER', 'Location', 'northeast', 'FontSize', 12);  % 图例
set(gca, 'FontSize', 12);  % 设置坐标轴字体大小

% 美化图形
set(gca, 'Box', 'on');  % 显示坐标轴框
set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');  % 启用小刻度
set(gca, 'LineWidth', 1.5);  % 坐标轴线宽

% 保存图形为文件
saveas(gcf, 'BER_plot.png');  % 保存为PNG文件
