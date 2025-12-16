function  [NRZI_data] = data_encode(raw_data)

Len = length(raw_data);
NRZI_data(1) = raw_data(1);
for i = 2:Len
    NRZI_data(i) = xor(NRZI_data(i-1), raw_data(i));
end

for i = 1:Len
    NRZI_data(i) = NRZI_data(i) * 2 - 1 ;
end

end