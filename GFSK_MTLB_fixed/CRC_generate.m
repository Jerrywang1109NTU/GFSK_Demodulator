function  [raw_CRC_result] = CRC_generate(raw_data, crc_data)
raw_CRC_result = raw_data(1:17);
for i = 1:length(raw_data)-17
    if (raw_CRC_result(1))
        raw_CRC_result = [xor(raw_CRC_result(2:17),crc_data(2:17)),raw_data(i+17)];
    else
        raw_CRC_result = [raw_CRC_result(2:17), raw_data(i+17)];
    end
end
raw_CRC_result = raw_CRC_result(2:17);
end