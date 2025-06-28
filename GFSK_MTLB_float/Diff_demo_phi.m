function  [len, demo_raw_data] = Diff_demo_phi(GFSKBaseband, raw_data, Insert)
%GFSKBaseband = conv(GFSKBaseband, Hn, 'same');
% plot(real(GFSKBaseband));
% hold on;
% GFSKBaseband = GFSKBaseband(Insert/2:Insert:length(GFSKBaseband)-Insert/2);     % 下采样，实际情况还要采用峰值判决
demo_NRZI_data = zeros(1, length(raw_data));
demo_raw_data = zeros(1, length(raw_data));
% figure(2);
% clf;
% plot(raw_data);
phi = zeros(1, length(GFSKBaseband));
for i = 2:length(GFSKBaseband)
%     diff = imag(GFSKBaseband(i)) * real(GFSKBaseband(i-1)) - real(GFSKBaseband(i)) * imag(GFSKBaseband(i-1));       % 比较sin(后-前)，由于相位差不可能大于pi，所以sin值的正负可以解决
    phi(i) = phi(i-1) + angle_trans(angle(GFSKBaseband(i)) - angle(GFSKBaseband(i-1)));
%     diff = angle(real(GFSKBaseband(i))+1i*imag(GFSKBaseband(i))) - angle(real(GFSKBaseband(i-1))+1i*imag(GFSKBaseband(i-1)));
end
% plot(phi)
% legend('pre', 'noi', 'noi_diff')
j = 0;
for i = (Insert+1):Insert:length(phi)
    j = j + 1;
    diff = 0;
    for k = 0:0.35*Insert-1
        diff = diff + phi(i-k)-phi(i-Insert+k);
    end 
    if (diff > 0)
        demo_NRZI_data(j) = 1;
    else
        demo_NRZI_data(j) = 0;
    end
%     demo_raw_data(j) = xor(demo_NRZI_data(j), demo_NRZI_data(j-1));
end
demo_raw_data = demo_NRZI_data;
len = get_length(demo_raw_data(1:8));
% hold on;
% plot(demo);
% legend('modulate', 'demodulate')

end