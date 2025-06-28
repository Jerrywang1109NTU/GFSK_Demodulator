function  [v_estimation, var_estimation] = Kay_estimation(GFSKBaseband, GFSKBaseband_header, Insert, fd, v, L0)
T = 1/fd;
% figure(1)
% plot(angle(GFSKBaseband(frame_begin:2000)))
% hold on;
% plot(angle(GFSKBaseband_header))
% legend('Signal','Header');
% header下采样
% GFSKBaseband下采样
GFSKBaseband = GFSKBaseband(1:Insert:end);
% 混频
GFSKBaseband = GFSKBaseband(1:L0).*conj(GFSKBaseband_header(1:L0));
% 低通滤波，滤除镜像频率
% GFSKBaseband = conv(GFSKBaseband, Hn, 'same');
v_estimation = 0;
for k = 1:L0-1
	R = 3*L0/2/(L0^2-1)*(1-(((2*k-L0)/L0)^2));
	v_estimation = v_estimation+R*angle(GFSKBaseband(k+1)*conj(GFSKBaseband(k)))/2/pi/T;
end
var_estimation = abs(v_estimation-v)/fd;

end