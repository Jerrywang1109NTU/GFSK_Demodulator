function  save_raw_data(data)
file_path = fopen(['raw_data_no_CRC.txt'], 'w');
for i = 1:length(data)
    fprintf(file_path, '%d\n', data(i));
end
fclose(file_path);
end