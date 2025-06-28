function  [len] = get_length(data)
len = 0;
for i = 1:length(data)
    len = len * 2 + data(i);
end
end