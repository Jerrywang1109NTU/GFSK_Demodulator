function  [frame_begin] = bit_synchronize_fixed(GFSKBaseband, fixed_point)
frame_begin = 1;
for i = 2:length(GFSKBaseband)-1
    tmp_1 = floor(imag(GFSKBaseband(i)) * real(GFSKBaseband(i-1))*2^(-fixed_point)) - floor(real(GFSKBaseband(i)) * imag(GFSKBaseband(i-1))*2^(-fixed_point)); % 计算差分值，寻找峰值
    tmp_2 = floor(imag(GFSKBaseband(i)) * real(GFSKBaseband(i+1))*2^(-fixed_point)) - floor(real(GFSKBaseband(i)) * imag(GFSKBaseband(i+1))*2^(-fixed_point));
    if (tmp_1>-1e-8 && tmp_2>-1e-8)
        frame_begin = i;
        break;
    end
end
% plot(unwrap(angle(GFSKBaseband)));
end