function  [len] = get_length(data)
tmp = 1;
len = 0;
for i = 1:length(data)
    len = len + tmp * data(i);
    tmp = 2 * tmp;
end
end