% function  [BER, VAR_F, VAR_P, Frame_EOR, CRC_ERROR, SYNC_EOR] = GFSK_whole_process(len_data, delay1, delay2)
function  [len_data, BER, VAR_F, Frame_EOR, CRC_ERROR, Time_Shift, Frame_shift] = GFSK_whole_process_diff_coherent_sync_fixed(delay1, delay2, EbN0)
% clc;
% clear all;
% clf;
CRC_ERROR = 0;
Time_Shift = 0;
Frame_EOR = 0;
%% ------------------------- 参数设置 -------------------------
% 设置参数  ->
fd = 5e5;               % 符号频率
Insert_20 = 20;             % 插值
Insert_4 = 4;
fs = fd * Insert_20;       % 采样频率
fixed_point = 200;
% len_data = 1000;        % 100个字符
% len_front = 32+32+8;    % 前导码+同步字+长度字
% len_rear = 16;          % CRC检测码
LPF = [0.00102385, 0.00100839, 0.00094825, 0.00076164, 0.0003372, -0.00043639, -0.00163258, -0.00324784, -0.00516932, -0.00715712, -0.00884692, -0.00977619, -0.00943276, -0.00732118, -0.00303818, 0.00365339, 0.01276384, 0.02403952, 0.03695727, 0.05075386, 0.06448905, 0.0771359, 0.08768775, 0.09526827, 0.0992303, 0.0992303, 0.09526827, 0.08768775, 0.0771359, 0.06448905, 0.05075386, 0.03695727, 0.02403952, 0.01276384, 0.00365339, -0.00303818, -0.00732118, -0.00943276, -0.00977619, -0.00884692, -0.00715712, -0.00516932, -0.00324784, -0.00163258, -0.00043639, 0.0003372, 0.00076164, 0.00094825, 0.00100839, 0.00102385];
LPF_gauss = [-1.73650410627358e-19,-0.000312764768569604,-0.000838442900532669,-0.00160615861735645,-0.00259616683646523,-0.00370967352679632,-0.00474132890512477,-0.00536346039426093,-0.00513205575516567,-0.00352274247073014,1.80947883054336e-18,0.00588502208064012,0.0143819136268575,0.0254355695685422,0.0386140158903625,0.0530935877656620,0.0677165373871577,0.0811213702638479,0.0919289301492054,0.0989520184039974,0.101387658077458,0.0989520184039974,0.0919289301492054,0.0811213702638479,0.0677165373871577,0.0530935877656620,0.0386140158903625,0.0254355695685422,0.0143819136268575,0.00588502208064012,1.80947883054336e-18,-0.00352274247073014,-0.00513205575516567,-0.00536346039426093,-0.00474132890512477,-0.00370967352679632,-0.00259616683646523,-0.00160615861735645,-0.000838442900532669,-0.000312764768569604,-1.73650410627358e-19];
BT = 0.5;               % 3dB带宽-符号频率比
h = 0.7;                % 调制系数
B = fd * BT;            % fir 3dB 带宽
N = 3;                % 滤波器覆盖三个字符长度       
% delay1 = randi([2000,4000],[1,1]);
% delay2 = randi([2000,4000],[1,1]);
VAR_P = 0;
L0 = 16;
% EbN0 = 14;              % 14~17+
% SNR = 5;
%% ------------------------- 信号产生 -------------------------
% 基带信号  ->
header = [1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0];
address = [1, randi([0, 1],[1, 7])];
len_data = get_length(address);
% address = [0 0 0 0 0 0 0 1];
% len_data = 128;
raw_data_0 = randi([0, 1],[1, len_data]);
% raw_data_0 = [1,0,1,1,0,0,0,0,0,0,0,0,1,1,0,1,0,1,0,1,0,0,0,1,1,0,0,1,1,1,1,1,0,0,1,0,1,1,0,1,0,0,0,0,1,1,0,1,0,1,0,0,1,1,1,0,1,1,0,0,1,0,1,0,0,0,1,0,1,1,0,1,0,0,0,1,1,1,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1,0,0,1,1,0,0,0,0,0,0,1,1,0,1,1,0,0,1,0,1,1,1,1,0,0,0];
sync = [1 0 0 1 0 0 1 1 0 0 0 0 1 0 1 1 0 1 0 1 0 0 0 1 1 1 0 1 1 1 1 0];
crc_data = [1 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 1];
% CRC_data = Cal_CRC(raw_data);
Hn = Gaussian_fir(fs, fd, N, B);
GFSK_IQ_generate(header, Hn, Insert_20);
% 生成CRC校验序列
raw_data_tmp = [address, raw_data_0, zeros(1,16)];
raw_CRC_result = CRC_generate(raw_data_tmp, crc_data);
raw_data_tmp = [header, sync, address, raw_data_0, raw_CRC_result];
raw_data = [address, raw_data_0, raw_CRC_result];
raw_data_have_CRC = [address, raw_data_0, raw_CRC_result];
% save_raw_data(raw_data_have_CRC); %------------------------------------------------------------------------save
% 生成传输的信号的IQ分量
[GFSKBaseband_I, GFSKBaseband_Q] = GFSK_IQ_generate(raw_data_tmp, Hn, Insert_20);
% 生成传输信号
GFSKBaseband = GFSKBaseband_I+1i*GFSKBaseband_Q;  % GFSK的平均能量为1
plot(unwrap(angle(GFSKBaseband(30:70))));
hold on;
% figure
% subplot(311);    plot(angle(GFSKBaseband));     title('经调制的相位信号');
% subplot(312);    plot(GFSKBaseband_I);          title('GFSK基带I路');   
% subplot(313);    plot(GFSKBaseband_Q);          title('GFSK基带Q路');
% 生成标准序列
Hn_4 = Gaussian_fir(fs/(Insert_20/Insert_4), fd, N, B); 
% 生成标准前导码基带信号，并匹配滤波
[GFSKBaseband_header_I, GFSKBaseband_header_Q] = GFSK_IQ_generate(header, Hn_4, Insert_4);
GFSKBaseband_header = floor((GFSKBaseband_header_I+1i*GFSKBaseband_header_Q)*2^(fixed_point)); % 对标Q(fixed_point)
GFSKBaseband_header = GFSKBaseband_header(Insert_4/2+1:Insert_4:length(GFSKBaseband_header)/2);
% 生成标准同步字基带信号，并匹配滤波
[GFSKBaseband_sync_I, GFSKBaseband_sync_Q] = GFSK_IQ_generate(sync, Hn_4, Insert_4);
GFSKBaseband_sync_0 = floor((GFSKBaseband_sync_I+1i*GFSKBaseband_sync_Q)*2^(fixed_point)); % 对标Q(fixed_point)
% GFSKBaseband_sync_0 = floor(conv(GFSKBaseband_sync_0, Hn_4, 'same'));
GFSKBaseband_sync_0 = GFSKBaseband_sync_0(Insert_4/2+1:Insert_4:length(GFSKBaseband_sync_0));
GFSKBaseband_sync = floor((GFSKBaseband_sync_0(2:end).*conj(GFSKBaseband_sync_0(1:end-1)))*2^(-fixed_point)); % 对标Q(fixed_point)
% [GFSKBaseband_sync_I, GFSKBaseband_sync_Q] = GFSK_IQ_generate(sync, Hn_4, Insert_4);
% GFSKBaseband_sync_0 = floor((GFSKBaseband_sync_I+1i*GFSKBaseband_sync_Q)*2^(fixed_point)); % 对标Q(fixed_point)
% % GFSKBaseband_sync_0 = floor(conv(GFSKBaseband_sync_0, Hn_4, 'same'));
% GFSKBaseband_sync_0 = GFSKBaseband_sync_0(Insert_4/2+1:Insert_4:length(GFSKBaseband_sync_0));
% GFSKBaseband_sync = floor((GFSKBaseband_sync_0(2:end).*conj(GFSKBaseband_sync_0(1:end-1)))*2^(-fixed_point)); % 对标Q(fixed_point)
%% ------------------------- 过信道 --------------------------
% 加偏移量  ->
t = 0:1/fs:(length(GFSKBaseband)-1)/fs;  % 时间
v = 4e4*rand(1,1)-2e4;  % 频率偏移
% v = 0;
GFSKBaseband = GFSKBaseband .* exp(1i*2*pi*v*t);
% plot(abs(GFSKBaseband));
% hold on;
GFSKBaseband = [zeros(1,delay1), GFSKBaseband, zeros(1,delay2)]; % 前面延时delay1个字符，后面延迟delay2个字符
% 加性高斯白噪声
N_noise = length(GFSKBaseband);
pn = 1/(10^((EbN0-10*log10(Insert_20))/10));
noise = sqrt(pn/2)*randn(1,N_noise)+1i*sqrt(pn/2)*randn(1,N_noise);
SNR = 10*log10(1/pn);
GFSKBaseband = noise + GFSKBaseband;
% SNR = EbN0-10*log10(Insert_20);
% GFSKBaseband = awgn(GFSKBaseband, SNR, 1);
% 如果检查出错误，则需要载入错误数据，查看异常情况
% load('GFSKBaseband.mat');
%% ------------------------ 帧头检测 -------------------------
% 帧头检测  ->
% 低通滤波
GFSKBaseband = conv(GFSKBaseband, LPF_gauss, 'same');
GFSKBaseband = floor(GFSKBaseband*2^(fixed_point));
 % 对标Q(fixed_point)
% save_data_to_vivado(GFSKBaseband, 'GFSKBaseband'); %------------------------------------------------------------------------save
% save_random_parameters(v, delay1, delay2, Insert_20, len_data); %------------------------------------------------------------------------save
div = Insert_20/Insert_4;
GFSKBaseband_pre = GFSKBaseband(1:div:end);
[frame_begin_4, frame_begin_20] = Frame_detection_diff_fixed(GFSKBaseband_pre, GFSKBaseband_sync, Insert_4, Insert_20, delay1, fixed_point);
if(frame_begin_20<delay1-Insert_20/2)
    Frame_EOR = 1;
end
% if (frame_begin_64 < delay1)
%     SYNC_EOR = 1;
%     fprintf('SYNCRINIZATION ERROR OCCURRED, PLEASE PAUSE!\n');
%     save('GFSKBaseband.mat', 'GFSKBaseband');
%     save('raw_data.mat', 'raw_data')
% end
GFSKBaseband_pre = GFSKBaseband_pre(frame_begin_4:end);
GFSKBaseband = GFSKBaseband(frame_begin_20:end);
%% ------------------------ 频率估计 -------------------------
% Fitz频偏估计
v_estimation = 0;
[v_estimation, VAR_F] = Fitz_estimation_fixed(GFSKBaseband_pre, GFSKBaseband_header, Insert_4, fd, v, L0, fixed_point);
% Kay频偏估计
% [v_estimation, VAR_F] = Kay_estimation_fixed(GFSKBaseband_pre, GFSKBaseband_header, Insert_4, fd, v, L0, fixed_point);
% L&R频偏估计
% [v_estimation, VAR_F] = LNR_estimation_fixed(GFSKBaseband_pre, GFSKBaseband_header, Insert_4, fd, v, L0, fixed_point);
% v_estimation = 0;
t = 0:1/fs:(length(GFSKBaseband)-1)/fs;
exp_est = floor(exp(1i*2*pi*(-v_estimation)*t)*2^fixed_point);
GFSKBaseband = floor(GFSKBaseband .* exp_est*2^(-fixed_point));
%% -------------------------- 解调 --------------------------
% 对其GFSKBaseband解调位
frame_begin_20_tmp = frame_begin_20;            % 实际估计的20采样点的起点
Frame_shift = delay1 - frame_begin_20_tmp;  % 小数部分理论值
frame_begin_sync = 0;                           % 最终确定的采样点的起点
sync_start = 4;                                % 位同步截取的起始点
sync_end = 30;                                  
for i = sync_start:2:sync_end
    frame_begin_sync = frame_begin_sync + bit_synchronize_fixed(GFSKBaseband(Insert_20*i - Insert_20/2 + 1:Insert_20*(i+1) + Insert_20/2), fixed_point); % 截取每个波峰所在的周期进行位同步
end
frame_begin_sync = round(frame_begin_sync / ((sync_end-sync_start+2)/2)); % 取平均
a_tmp_diff_1 = frame_begin_sync - Insert_20 -1;                          % 通过位同步计算的小数部分
Time_Shift = a_tmp_diff_1 - Frame_shift;
frame_begin_20 = Insert_20*(32 + 32) + a_tmp_diff_1 - Insert_20/2 + 1;
% frame_begin_20 = Insert_20*(32 + 32) - Insert_20/2 + 1; % 不进行位同步的理论解调起点
GFSKBaseband = GFSKBaseband(frame_begin_20:end); % 由于之前已经取过一次GFSKBaseband = GFSKBaseband(frame_begin_20:end); 所以只用往后移动到同步字之后就是解调起点
% 差分解调
[len_data_demo, demo_raw_data] = Diff_demo_IQ(GFSKBaseband, raw_data, Insert_20, fixed_point);
% [len_data_demo, demo_raw_data] = Diff_demo_phi(GFSKBaseband, raw_data, Insert_20);
% 进行CRC校验
demo_CRC_result = CRC_check(demo_raw_data(1:length(demo_raw_data)), crc_data);
% 判断CRC校验是否成功
if(sum(demo_CRC_result))
    CRC_ERROR = 1;
    fprintf('CRC ERROR OCCURRED, PLEASE PAUSE!\n');
    save('GFSKBaseband.mat', 'GFSKBaseband');
    save('raw_data.mat', 'raw_data')
end
% load('raw_data.mat');
BER = sum(xor(raw_data, demo_raw_data(1:length(raw_data))));
pos = upsample(xor(raw_data, demo_raw_data(1:length(raw_data))), Insert_20);
idx = 1:length(raw_data)*20;
% if (BER)
%     clf;
%     plot(unwrap(angle(GFSKBaseband)));
%     hold on;
%     plot(idx, pos);
% end
end