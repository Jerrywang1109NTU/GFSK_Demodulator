function  [frame_begin] = bit_synchronize(GFSKBaseband)
frame_begin = 1;
for i = 2:length(GFSKBaseband)-1
    tmp_1 = imag(GFSKBaseband(i)) * real(GFSKBaseband(i-1)) - real(GFSKBaseband(i)) * imag(GFSKBaseband(i-1)); % 计算差分值，寻找峰值
    tmp_2 = imag(GFSKBaseband(i)) * real(GFSKBaseband(i+1)) - real(GFSKBaseband(i)) * imag(GFSKBaseband(i+1));
    if (tmp_1>-1e-8 && tmp_2>-1e-8)
        frame_begin = i;
        break;
    end
end
% plot(unwrap(angle(GFSKBaseband)));
end