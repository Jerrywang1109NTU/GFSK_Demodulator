function  [len, demo_raw_data] = Diff_demo_IQ(GFSKBaseband, raw_data, Insert, fixed_point)
% plot(angle(GFSKBaseband));
% hold on;
% GFSKBaseband = GFSKBaseband(Insert/2:Insert:length(GFSKBaseband)-Insert/2);     % 下采样，实际情况还要采用峰值判决
demo_NRZI_data = zeros(1, length(raw_data));
% demo_raw_data = zeros(1, length(raw_data));
j = 0;
for i = Insert+1:Insert:length(GFSKBaseband)
    j = j + 1;
    diff = 0;
    for k = 0:0.35*Insert
        diff = diff + imag(GFSKBaseband(i-k)) * real(GFSKBaseband(i-Insert+k)) - real(GFSKBaseband(i-k)) * imag(GFSKBaseband(i-Insert+k)); % Q(fixed_point)
%     diff = imag(GFSKBaseband(i)) * real(GFSKBaseband(i-Insert)) - real(GFSKBaseband(i)) * imag(GFSKBaseband(i-Insert));       % 比较sin(后-前)，由于相位差不可能大于pi，所以sin值的正负可以解决
    end
    if (diff > 1e-8)
        demo_NRZI_data(j) = 1;
    else
        demo_NRZI_data(j) = 0;
    end
%     demo_raw_data(j) = xor(demo_NRZI_data(j), demo_NRZI_data(j-1));
end
demo_raw_data = demo_NRZI_data;
len = get_length(demo_raw_data(1:8));
% plot(phi)
% legend('pre', 'noi', 'noi_diff')

% hold on;
% plot(demo);
% legend('modulate', 'demodulate')

end