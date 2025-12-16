
function  [frame_begin_4, frame_begin_20] = Frame_detection_diff_fixed(GFSKBaseband, GFSKBaseband_sync, Insert_4, Insert_20, delay1, fixed_point)
GFSKBaseband_diff = zeros(1, Insert_4*length(GFSKBaseband_sync));
GFSK_coherent = zeros(1, length(GFSKBaseband));
Sync_coherent = zeros(1, length(GFSKBaseband));

for i = 1:Insert_4*length(GFSKBaseband_sync)
    GFSKBaseband_diff(i) = floor(GFSKBaseband(i)*conj(GFSKBaseband(i+Insert_4))*2^(-fixed_point)); % 对标Q(fixed_point)
end
frame_begin_4 = 0;
detected = 0;
for i = Insert_4*length(GFSKBaseband_sync)+1:length(GFSKBaseband)-Insert_4
    GFSKBaseband_diff_tmp = GFSKBaseband_diff(1:Insert_4:end);
    Sync_coherent(i) = floor(abs(sum((GFSKBaseband_diff_tmp.*GFSKBaseband_sync)*2^(-fixed_point)))^2*2^(-fixed_point)); % 对标Q(fixed_point)
    GFSK_coherent(i) = 10*sum(floor((abs(GFSKBaseband_diff_tmp).^2)*2^(-fixed_point))); % 对标Q(fixed_point)
    if (Sync_coherent(i) > GFSK_coherent(i) && detected == 0 && Sync_coherent(i) > 2^(fixed_point)*100)
        frame_begin_4 = i ;
    end
    if (frame_begin_4 && Sync_coherent(i) < Sync_coherent(i-1) && detected == 0)
        frame_begin_4 = i - 1;
        detected = 1;
%         break;
    end
    GFSKBaseband_diff = [GFSKBaseband_diff(2:end), floor(GFSKBaseband(i)*conj(GFSKBaseband(i+Insert_4))*2^(-fixed_point))]; % 对标Q(fixed_point)
end
frame_begin_4_tmp = frame_begin_4;
frame_begin_20 = (frame_begin_4 - 2*Insert_4*32 + 1)/Insert_4*Insert_20;
frame_begin_4 = frame_begin_4 - 2*Insert_4*32 + 1 + Insert_4/2 + 1;
if (frame_begin_20<delay1-Insert_20/2)
    figure;
    fprintf('FRAME DETECTION ERROR OCCURRED, PLEASE PAUSE!\n');
    fprintf(num2str(delay1));
    fprintf('\n');
    fprintf(num2str(frame_begin_20));
    fprintf('\n');
    fprintf(num2str(frame_begin_4_tmp));
    fprintf('\n');
    plot(Sync_coherent);
    hold on;
    plot(GFSK_coherent);
    legend('Sync-co', 'Diff-co')
end
% plot(unwrap(angle(GFSKBaseband)));
% plot(Sync_coherent);
% hold on;
% plot(GFSK_coherent);
% title('帧同步算法的峰值判决仿真图'); xlabel('采样点数'); ylabel('幅值');
% legend('差分相关值', '自适应阈值');
end