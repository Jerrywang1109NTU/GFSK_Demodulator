t = 2*pi/4096:2*pi/4096:2*pi;
sin_table = floor(sin(t)*2^12);
cos_table = floor(cos(t)*2^12);
sin_2_phi_pos = zeros(1,4096);
for i = 1:1024
    if(sin_2_phi_pos(sin_table(i)) == 0)
        sin_2_phi_pos(sin_table(i)) = i;
    end
end



for i = 1: