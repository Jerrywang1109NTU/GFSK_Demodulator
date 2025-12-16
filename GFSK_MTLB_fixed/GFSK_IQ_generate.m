function  [GFSKBaseband_I, GFSKBaseband_Q] = GFSK_IQ_generate(raw_data, Hn, Insert)

% NRZI_data = Data_encode(raw_data);
NRZI_data = 2*raw_data - 1;
% NRZI = NRZI_data;
NRZI_data = upsample(NRZI_data, Insert);
NRZI_data_conv_Hn = conv(NRZI_data, Hn, 'same');
% plot(NRZI_data_conv_Hn)
% plot(Hn);
phi = zeros(1,length(NRZI_data_conv_Hn));
phi(1) = NRZI_data_conv_Hn(1)*pi*0.7;
for i = 2:length(NRZI_data_conv_Hn)
    phi(i) = phi(i-1) + NRZI_data_conv_Hn(i)*pi*0.7;
end
GFSKBaseband_I = cos(phi);
GFSKBaseband_Q = sin(phi);
% plot(phi);
% hold on;
end
