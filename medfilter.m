function [out] = medfilter(input)
    input = extendinput(input);
    sz = size(input);
    nrow = sz(1);
    ncol = sz(2);
    out = zeros(nrow,ncol);
    for i = 2:nrow-1
       for j = 2:ncol-1
           n = [input(i-1,j-1) input(i-1,j) input(i-1,j+1) input(i,j+1) input(i+1,j+1) input(i+1,j) input(i+1,j-1) input(i,j-1) input(i,j)];
           n = sort(n);
           out(i,j) = uint8(n(5));
       end
    end
    out(1,:) = [];
    out(:,1) = [];
    so = size(out);
    ro = so(1);
    co = so(2);
    out(ro,:) = [];
    out(:,co) = [];
end

function [out] = extendinput(input)
    sz = size(input);
    nrow = sz(1);
    ncol = sz(2);
    A = zeros(nrow,1);
    input = cat(2,A,input,A);
    B = zeros(1,ncol+2);
    input = cat(1,B,input,B);
    out = input;
end