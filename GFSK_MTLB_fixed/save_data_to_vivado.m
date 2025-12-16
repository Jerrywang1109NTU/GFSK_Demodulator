function save_data_to_vivado(data, data_name)

file_path = fopen([data_name '_real.txt'], 'w');

for i = 1:length(data)
    hexStr = dec2hex(typecast(int16(real(data(i))), 'uint16'), 4);
    fprintf(file_path, '%s\n', hexStr);
end

fclose(file_path);

file_path = fopen([data_name '_imag.txt'], 'w');
for i = 1:length(data)
    hexStr = dec2hex(typecast(int16(imag(data(i))), 'uint16'), 4);
    fprintf(file_path, '%s\n', hexStr);
end

end