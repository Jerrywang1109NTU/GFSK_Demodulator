function  save_random_parameters(v, delay1, delay2, Insert_20, len_data)

file_path = fopen('parameters.txt', 'w');

fprintf(file_path, 'Data Length: %f\n', len_data);
fprintf(file_path, 'Frequency Variance: %f\n', v);
fprintf(file_path, 'Front Delay: %f\n', delay1);
fprintf(file_path, 'Rear Delay: %f\n', delay2);
fprintf(file_path, 'V_est Begin: %f\n', delay1 + 1);
fprintf(file_path, 'Sync Begin: %f\n', delay1 + Insert_20*32 + 1);
fprintf(file_path, 'Demo Begin: %f\n', delay1 + Insert_20*(32+32) - Insert_20/2 + 1);

end 