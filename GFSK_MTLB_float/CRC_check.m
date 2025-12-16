function  [demo_CRC_result] = CRC_check(demo_raw_data, crc_data)
demo_CRC_result = demo_raw_data(1:17);
for i = 18:length(demo_raw_data)
    if (demo_CRC_result(1))
        demo_CRC_result = [xor(demo_CRC_result(2:17),crc_data(2:17)),demo_raw_data(i)];
    else
        demo_CRC_result = [demo_CRC_result(2:17), demo_raw_data(i)];
    end
end
demo_CRC_result = demo_CRC_result(2:17);
end