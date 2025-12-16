function [msg_valid_flg] = Burst_detection(Window_A, Window_B, msg_valid_flg, L0, Insert)
% Threshold = abs((1+3*10^(SNR/10)*0.5));
Threshold = 100;
if (Window_A - Window_B >= Threshold)
    msg_valid_flg = 1;
%     msg_end_flg_pre = 0;
end
if (Window_B - Window_A > Threshold)
    msg_valid_flg = 0;
end
% if (Window_B - Window_A > Threshold  &&  msg_valid_flg)
%     msg_valid_flg = 1;
% end
% if (Window_B - Window_A < Threshold  &&  msg_end_flg_pre)
%     msg_valid_flg = 0;
%     msg_end_flg_pre = 0;
% end
end