function  [frame_begin_4, frame_begin_20] = Frame_detection_diff(GFSKBaseband, GFSKBaseband_sync, Insert_4, Insert_20, delay1)
GFSKBaseband_diff = zeros(1, Insert_4*length(GFSKBaseband_sync));
GFSK_coherent = zeros(1, length(GFSKBaseband));
Sync_coherent = zeros(1, length(GFSKBaseband));
for i = 1:Insert_4*length(GFSKBaseband_sync)
    GFSKBaseband_diff(i) = GFSKBaseband(i)*conj(GFSKBaseband(i+Insert_4));
end
frame_begin_4 = 0;
detected = 0;
for i = Insert_4*length(GFSKBaseband_sync)+1:length(GFSKBaseband)-Insert_4
    GFSKBaseband_diff_tmp = GFSKBaseband_diff(1:Insert_4:end);
    Sync_coherent(i) = abs(sum(GFSKBaseband_diff_tmp.*GFSKBaseband_sync))^2;
    GFSK_coherent(i) = 10*sum(abs(GFSKBaseband_diff_tmp).^2);
    if (Sync_coherent(i) > GFSK_coherent(i) && detected == 0 && Sync_coherent(i) > 10)
        frame_begin_4 = i ;
    end
    if (frame_begin_4 && Sync_coherent(i) < Sync_coherent(i-1) && detected == 0)
        frame_begin_4 = i - 1;
        detected = 1;
    end
    GFSKBaseband_diff = [GFSKBaseband_diff(2:end), GFSKBaseband(i)*conj(GFSKBaseband(i+Insert_4))];
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
end