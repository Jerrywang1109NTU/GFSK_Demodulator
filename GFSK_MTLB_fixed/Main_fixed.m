clc; 
clear;
NUM = 100;
answer = 0;
BER = zeros(1,6);
VAR_F = zeros(1,6);
Frame_EOR = zeros(1,6);
CRC_EOR = zeros(1,6);
Time_Shift  = zeros(1,6);
Frame_shift = zeros(1,6);
a = zeros(1,NUM);
b = zeros(1,NUM);

% CoreNum=8; %设定机器CPU核心数量
% if isempty(gcp('nocreate')) %如果并行未开启
%     parpool(CoreNum);
% end
for EbN0 = 14:16
    BER_0 = 0;
    VAR_F_0 = 0;
    Frame_EOR_0 = 0;
    Time_Shift_0 = 0;
    CRC_EOR_0 = 0;
    SYNC_EOR_0 = 0;
    len_data_0 = 0;
    Frame_shift_0 = 0;
    for i = 1:NUM
        delay1 = randi([2000,4000],[1,1]);
        delay2 = randi([2000,4000],[1,1]);
    %     [BER_1, VAR_F_1, VAR_P_1, Frame_EOR_1, CRC_EOR_1, SYNC_EOR_1] = GFSK_whole_process(len_data, delay1, delay2);
        [len_data_1, BER_1, VAR_F_1, Frame_EOR_1, CRC_EOR_1, Time_Shift_1, Frame_shift_1] = GFSK_whole_process_diff_coherent_sync_fixed(delay1, delay2, EbN0);
        a(i) = VAR_F_1*1e4;
        b(i) = BER_1;
        len_data_0 = len_data_0 + len_data_1;
        BER_0 = BER_0 + BER_1;
        VAR_F_0 = VAR_F_0 + VAR_F_1^2;
        Time_Shift_0 = Time_Shift_0 + abs(Time_Shift_1);
        Frame_EOR_0 = Frame_EOR_0 + Frame_EOR_1;
        CRC_EOR_0 = CRC_EOR_0 + CRC_EOR_1;
        Frame_shift_0 = Frame_shift_0 + abs(Frame_shift_1);
    end
    BER(EbN0-7) = BER_0/len_data_0;
    VAR_F(EbN0-7) = sqrt(VAR_F_0)/NUM;
    Frame_EOR(EbN0-7) = Frame_EOR_0/NUM;
    CRC_EOR(EbN0-7) = CRC_EOR_0/NUM;
    Time_Shift(EbN0-7) = Time_Shift_0/NUM;
    Frame_shift(EbN0-7) = Frame_shift_0/NUM;
end
EbN0 = 8:16;
grid on;
plot(EbN0, Time_Shift, 'r--o');
hold on;
plot(EbN0, Frame_shift, 'b--^');
title('不同Eb/N0下的定时误差'); xlabel('Eb/N0'); ylabel('偏移量(/点)');
legend('使用了位同步算法', '未使用位同步算法');
grid on;
% figure(1);
% figure(2)
% plot(EbN0, VAR_F);    title('不同频率估计算法的频率偏移量');    xlabel('Eb/N0');    ylabel('VAR_F');

% plot(a);
% hold on;
% plot(b);
% legend('var','ber')