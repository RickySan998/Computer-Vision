function [neighbor] = get_neighbors(image,center,win_size)
    r_off = (win_size - 1)/2;
    c_off = (win_size - 1)/2; % assuming square window and odd size window
    
    % center index shifts because we expand the image back and front
    % front doesn't shift index, but back does
    center_r = center(1) + r_off; center_c = center(2)+c_off;
    
    % expand image by zeroes in case the center is at the sides
    [r,c,D] = size(image);
    expanded = cat(1,zeros(r_off,c,D),image,zeros(r_off,c,D));
    [r,c,D] = size(expanded);
    expanded = cat(2, zeros(r,c_off,D),expanded,zeros(r,c_off,D));
    
    % get the neighbors from the designated center
    neighbor = expanded(center_r - r_off:center_r + r_off, center_c - c_off:center_c + c_off,:);
end