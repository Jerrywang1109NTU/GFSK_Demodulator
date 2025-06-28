clc; 
clear;
NUM = 3000;
len_data = 100;
answer = 0;
BER = zeros(1,4);
VAR_F = zeros(1,4);
VAR_P = zeros(1,4);
Frame_EOR = zeros(1,4);
CRC_EOR = zeros(1,4);
SYNC_EOR = zeros(1,4);
a = zeros(1,NUM);
b = zeros(1,NUM);

% CoreNum=8; %设定机器CPU核心数量
% if isempty(gcp('nocreate')) %如果并行未开启
%     parpool(CoreNum);
% end
for EbN0 = 8:16
    BER_0 = 0;
    VAR_F_0 = 0;
    VAR_P_0 = 0;
    Frame_EOR_0 = 0;
    CRC_EOR_0 = 0;
    SYNC_EOR_0 = 0;
    len_data_0 = 0;
    for i = 1:NUM
        delay1 = randi([2000,4000],[1,1]);
        delay2 = randi([2000,4000],[1,1]);
    %     [BER_1, VAR_F_1, VAR_P_1, Frame_EOR_1, CRC_EOR_1, SYNC_EOR_1] = GFSK_whole_process(len_data, delay1, delay2);
        % [len_data_1, BER_1, VAR_F_1, VAR_P_1, Frame_EOR_1, CRC_EOR_1, SYNC_EOR_1] = GFSK_whole_process_diff_coherent(delay1, delay2, EbN0);
        [len_data_1, BER_1, VAR_F_1, VAR_P_1, Frame_EOR_1, CRC_EOR_1, SYNC_EOR_1] = Theo_GFSK_whole_process_diff_coherent(delay1, delay2, EbN0);
        a(i) = VAR_F_1*1e4;
        b(i) = BER_1;
        len_data_0 = len_data_0 + len_data_1;
        BER_0 = BER_0 + BER_1;
        VAR_F_0 = VAR_F_0 + VAR_F_1;
        VAR_P_0 = VAR_P_0 + VAR_P_1;
        Frame_EOR_0 = Frame_EOR_0 + Frame_EOR_1;
        CRC_EOR_0 = CRC_EOR_0 + CRC_EOR_1;
        SYNC_EOR_0 = SYNC_EOR_0 + SYNC_EOR_1;
    end
    BER(EbN0-7) = BER_0/len_data_0;
    VAR_F(EbN0-7) = VAR_F_0/NUM;
    VAR_P(EbN0-7) = VAR_P_0/NUM;
    Frame_EOR(EbN0-7) = Frame_EOR_0/NUM;
    CRC_EOR(EbN0-7) = CRC_EOR_0/NUM;
    SYNC_EOR(EbN0-7) = SYNC_EOR_0/NUM;
end
EbN0 = 8:16;
grid on;
figure(1)
semilogy(EbN0, BER);    title('BER under different Eb/N0');    xlabel('Eb/N0');    ylabel('BER');

% plot(a);
% hold on;
% plot(b);
% legend('var','ber')