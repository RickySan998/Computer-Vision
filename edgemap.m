function [output] = edgemap(input,threshold)
    sz = size(input);
    nrow = sz(1);
    ncol = sz(2);
    output = zeros(nrow,ncol);
    for i = 1:nrow
        for j= 1:ncol
           if input(i,j) <= threshold
              output(i,j) = 0;
           else
               output(i,j) = 1;
           end
        end
    end
    
    % to make results cleaner from noise, a median filtering is employed
    output = medfilter(output);
    
end