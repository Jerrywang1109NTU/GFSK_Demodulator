function  [frame_begin, frame_end] = Frame_detection_dual_window(GFSKBaseband, Insert, len_data, len_front, len_rear)
Insert_8 = 8;
div = Insert / Insert_8;
GFSKBaseband = GFSKBaseband(1:div:end);
L0 = 64;
msg_valid_flg_pre = 0;
msg_valid_flg = 0;
% msg_end_flg_pre = 0;
GFSKBaseband_tmp = zeros(1, L0*div);
Window_A = 0;
Window_B = 0;
frame_begin = 1;
frame_end = 0;
a = zeros(1, length(GFSKBaseband));
b = zeros(1, length(GFSKBaseband));
c = zeros(1, length(GFSKBaseband));
d = zeros(1, length(GFSKBaseband));
for i = length(GFSKBaseband_tmp):length(GFSKBaseband)-8
    % 移动窗口
%     GFSKBaseband_tmp = GFSKBaseband((i-length(GFSKBaseband_tmp)+1):i).*conj(GFSKBaseband((i-length(GFSKBaseband_tmp)+1)+8:i+8));
    GFSKBaseband_tmp = GFSKBaseband((i-length(GFSKBaseband_tmp)+1):i);
    Window_A = Window_A + abs(GFSKBaseband_tmp(length(GFSKBaseband_tmp)))^2 - abs(GFSKBaseband_tmp(length(GFSKBaseband_tmp)-(L0/2)*div+1))^2;
    Window_B = Window_B + abs(GFSKBaseband_tmp(length(GFSKBaseband_tmp)-(L0/2)*div+1))^2 - abs(GFSKBaseband_tmp(length(GFSKBaseband_tmp)-L0*div+1))^2;
%     [msg_valid_flg, msg_end_flg_pre] = Burst_detection(Window_A, Window_B, msg_valid_flg, msg_end_flg_pre, SNR);
    [msg_valid_flg] = Burst_detection(Window_A, Window_B, msg_valid_flg, L0, div);
    c(i) = msg_valid_flg_pre;
    if (not(msg_valid_flg) && msg_valid_flg_pre && ((i-frame_begin+1)<(len_data+len_front+len_rear)*div))
        msg_valid_flg = 1;
    end
    a(i) = Window_A - Window_B;
    b(i) = Window_B - Window_A;
    d(i) = msg_valid_flg;
    if (msg_valid_flg && not(msg_valid_flg_pre))
        frame_begin = i;
    end
    if (not(msg_valid_flg) && msg_valid_flg_pre && not(frame_end))
        frame_end = i;
    end
    msg_valid_flg_pre = msg_valid_flg;
end
if (not(frame_end))
    frame_end = frame_begin+(len_data+len_front)*div-1;
end
% if (frame_begin < 1600)
    subplot(411);   plot(a);    grid on;
    subplot(412);   plot(b);    grid on;
    subplot(413);   plot(c);    grid on;
    subplot(414);   plot(d);    grid on;
% end
end