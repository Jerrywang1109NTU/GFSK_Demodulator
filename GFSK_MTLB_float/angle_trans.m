function  [angle_out] = angle_trans(angle_in)
angle_out = angle_in;
if (angle_in > pi)
    angle_out = -(angle_in - 2*pi);
end 
if (angle_in < -pi)
    angle_out = -(2*pi + angle_in);
end 

end