% function  [BER, VAR_F, VAR_P, Frame_EOR, CRC_ERROR, SYNC_EOR] = GFSK_whole_process(len_data, delay1, delay2)
% function  [len_data, BER, VAR_F, VAR_P, Frame_EOR, CRC_ERROR, SYNC_EOR] = GFSK_whole_process_diff_coherent_sync_fixed(delay1, delay2, EbN0)
clc;
clear all;
% clf;
CRC_ERROR = 0;
SYNC_EOR = 0;
Frame_EOR = 0;
%% ------------------------- 参数设置 -------------------------
% 设置参数  ->
fd = 5e5;               % 符号频率
Insert_20 = 20;             % 插值
Insert_4 = 4;
fs = fd * Insert_20;       % 采样频率
fixed_point = 10;
% len_data = 1000;        % 100个字符
% len_front = 32+32+8;    % 前导码+同步字+长度字
% len_rear = 16;          % CRC检测码
% LPF = [0.00102385, 0.00100839, 0.00094825, 0.00076164, 0.0003372, -0.00043639, -0.00163258, -0.00324784, -0.00516932, -0.00715712, -0.00884692, -0.00977619, -0.00943276, -0.00732118, -0.00303818, 0.00365339, 0.01276384, 0.02403952, 0.03695727, 0.05075386, 0.06448905, 0.0771359, 0.08768775, 0.09526827, 0.0992303, 0.0992303, 0.09526827, 0.08768775, 0.0771359, 0.06448905, 0.05075386, 0.03695727, 0.02403952, 0.01276384, 0.00365339, -0.00303818, -0.00732118, -0.00943276, -0.00977619, -0.00884692, -0.00715712, -0.00516932, -0.00324784, -0.00163258, -0.00043639, 0.0003372, 0.00076164, 0.00094825, 0.00100839, 0.00102385];
BT = 0.5;               % 3dB带宽-符号频率比
h = 0.7;                % 调制系数
B = fd * BT;            % fir 3dB 带宽
N = 1.5;                % 滤波器覆盖三个字符长度       
delay1 = randi([2000,4000],[1,1]);
delay2 = randi([2000,4000],[1,1]);
VAR_P = 0;
L0 = 16;
EbN0 = 17;              % 14~17+
len_data_tmp = 0;
% SNR = 5;
%% ------------------------- 信号产生 -------------------------
% 基带信号  ->
for i = 1:1000
    header = [1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0];
    address = [1, randi([0, 1],[1, 7])];
    len_data = get_length(address);
    raw_data_0 = randi([0, 1],[1, len_data]);
%     raw_data_0 = [1,0,1,1,0,0,0,0,0,0,0,0,1,1,0,1,0,1,0,1,0,0,0,1,1,0,0,1,1,1,1,1,0,0,1,0,1,1,0,1,0,0,0,0,1,1,0,1,0,1,0,0,1,1,1,0,1,1,0,0,1,0,1,0,0,0,1,0,1,1,0,1,0,0,0,1,1,1,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1,0,0,1,1,0,0,0,0,0,0,1,1,0,1,1,0,0,1,0,1,1,1,1,0,0,0];
    sync = [1 0 0 1 0 0 1 1 0 0 0 0 1 0 1 1 0 1 0 1 0 0 0 1 1 1 0 1 1 1 1 0];
    crc_data = [1 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 1];
    % CRC_data = Cal_CRC(raw_data);
    Hn = Gaussian_fir(fs, fd, N, B);
    % 生成CRC校验序列
    raw_data_tmp = [address, raw_data_0, zeros(1,16)];
    raw_CRC_result = CRC_generate(raw_data_tmp, crc_data);
    raw_data_tmp = [header, sync, address, raw_data_0, raw_CRC_result];
    raw_data = [address, raw_data_0, raw_CRC_result];
    raw_data_with_CRC_tmp = [address, raw_data_0, raw_CRC_result]; % 生成传输的信号的IQ分量
    [GFSKBaseband_I, GFSKBaseband_Q] = GFSK_IQ_generate(raw_data_tmp, Hn, Insert_20);
    % 生成传输信号
    GFSKBaseband_tmp = GFSKBaseband_I+1i*GFSKBaseband_Q;  % GFSK的平均能量为1
    %% ------------------------- 过信道 --------------------------
    % 加偏移量  ->
    t = 0:1/fs:(length(GFSKBaseband_tmp)-1)/fs;  % 时间
    v = 4e4*rand(1,1)-2e4;  % 频率偏移
    GFSKBaseband_tmp = GFSKBaseband_tmp .* exp(1i*2*pi*v*t);
    GFSKBaseband_tmp = [zeros(1,delay1), GFSKBaseband_tmp, zeros(1,delay2)]; % 前面延时delay1个字符，后面延迟delay2个字符
    % 加性高斯白噪声
    N_noise = length(GFSKBaseband_tmp);
    pn = 1/(10^((EbN0-10*log10(Insert_20))/10));
    noise = sqrt(pn/2)*randn(1,N_noise)+1i*sqrt(pn/2)*randn(1,N_noise);
    SNR = 10*log10(1/pn);
    GFSKBaseband_tmp = noise + GFSKBaseband_tmp;
    %% ------------------------ 帧头检测 -------------------------
    GFSKBaseband_tmp = conv(GFSKBaseband_tmp, Hn, 'same');
    GFSKBaseband_tmp = floor(GFSKBaseband_tmp*2^(fixed_point));
    len_data_tmp = len_data_tmp + length(raw_data);
    if (i == 1)
        raw_data_with_CRC = raw_data_with_CRC_tmp;
        GFSKBaseband = GFSKBaseband_tmp;
        len_data_out = [0, len_data_tmp];
    else
        raw_data_with_CRC = [raw_data_with_CRC, raw_data_with_CRC_tmp];
        GFSKBaseband = [GFSKBaseband, GFSKBaseband_tmp];
        len_data_out = [len_data_out, len_data_tmp];
    end
end
file_path_raw_data = fopen('raw_data_no_CRC.txt', 'w');
file_path_I = fopen('GFSKBaseband_real.txt', 'w');
file_path_Q = fopen('GFSKBaseband_imag.txt', 'w');
file_path_length = fopen('len_data_out.txt', 'w');
for i = 1:length(raw_data_with_CRC)
    fprintf(file_path_raw_data, '%d\n', raw_data_with_CRC(i));
end
for j = 1:length(GFSKBaseband)
    hexStr = dec2hex(typecast(int16(real(GFSKBaseband(j))), 'uint16'), 4);
    fprintf(file_path_I, '%s\n', hexStr);
end
for j = 1:length(GFSKBaseband)
    hexStr = dec2hex(typecast(int16(imag(GFSKBaseband(j))), 'uint16'), 4);
    fprintf(file_path_Q, '%s\n', hexStr);
end
for j = 1:length(len_data_out)
    hexStr = dec2hex(typecast(int32(len_data_out(j)), 'uint32'), 8);
    fprintf(file_path_length, '%s\n', hexStr);
end
fclose(file_path_raw_data);
fclose(file_path_I);
fclose(file_path_Q);