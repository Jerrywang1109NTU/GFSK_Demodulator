% function [v_estimation] = Fitz_estimation(GFSKBaseband, GFSKBaseband_header, Insert, fd, v, Hn, L0)
function [v_estimation, var_estimation] = Fitz_estimation_fixed(GFSKBaseband, GFSKBaseband_header, Insert, fd, v, L0, fixed_point)
T = 1/fd;
N = L0/2;
R = zeros(1, L0);
% figure(1)
% plot(angle(GFSKBaseband(frame_begin:2000)))
% hold on;
% plot(angle(GFSKBaseband_header))
% legend('Signal','Header');
% header下采样
% GFSKBaseband下采样
% 混频
GFSKBaseband = GFSKBaseband(1:Insert:end);
GFSKBaseband = floor(GFSKBaseband(1:L0).*conj(GFSKBaseband_header(1:L0))*2^(-fixed_point)); % Q(fixed_point)
% figure(2)
% plot(unwrap(angle(GFSKBaseband)));
% 低通滤波，滤除镜像频率
% GFSKBaseband = conv(GFSKBaseband, Hn, 'same');
% subplot(212);      plot(real(GFSKBaseband))
for i = 1:N
    for j = i+1:L0
        R(i) = R(i) + floor(GFSKBaseband(j).*conj(GFSKBaseband(j-i))*2^(-fixed_point)); % Q(fixed_point)
    end
    R(i) = R(i)*2^(-fixed_point)/(L0-i); % Q(fixed_point)
end
v_estimation = sum(angle(R))/(pi*N*(N+1)*T);
var_estimation = abs(v_estimation-v)/fd;
% v_estimation
% fd/4 - v

end