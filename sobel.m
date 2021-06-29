%to obtain the gradient magnitude image with the Sobel operator, input is
%the gray level image

% Sobel Operator: Window size is 3x3

function [output] = sobel(input)
    sz = size(input);
    Gx = [-1 0 1; -2 0 2; -1 0 1];
    Gy = [1 2 1 ; 0 0 0 ; -1 -2 -1];
    nrow = sz(1);
    ncol = sz(2);
    ox = zeros(nrow,ncol);
    oy = zeros(nrow,ncol);
    for i = 2:(nrow-1)
        for j = 2:(ncol-1)
        tempx = double(input(i-1:i+1,j-1:j+1)).* Gx;
        tempy = double(input(i-1:i+1,j-1:j+1)).* Gy;
        ox(i,j) = sum(sum(tempx));
        oy(i,j) = sum(sum(tempy));
        end
    end
    output = uint8(sqrt(ox.*ox + oy.*oy));
end