function  [Hn] = Gaussian_fir (fs, fd, N, B)
% fd = 5e5;
% Insert = 8;
% fs = fd * Insert;
% len = 100;
% BT = 0.5;
% h = 0.7;
% B = fd * BT;
% N = 2;
T = 1/fd;
t = -N/fd:1/fs:N/fd;
K = 2*pi*B/sqrt(log(2));
Hn = fs / 2 * (qfunc(K*(t-T/2)) - qfunc(K*(t+T/2)));
Hn = Hn/sum(Hn);
% plot (t,Hn/sum(Hn)*Insert,'.');
end