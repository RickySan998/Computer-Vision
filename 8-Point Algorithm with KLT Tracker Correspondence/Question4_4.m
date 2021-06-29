% Ensure that KLT.m and images inria1.tif, inria2.tif, as well as
% frc1.tif,frc2.tif are added to path when running this script

% I1 = imread('inria1.tif');
% I2 = imread('inria2.tif');

I1 = imread('frc1.tif');
I2 = imread('frc2.tif');

[matched_loc_1,matched_loc_2] = KLT(I1,I2);
F = estimateF(matched_loc_1,matched_loc_2);
figure (2);
displayEpipolarF(I1,I2,F);

function [ F ] = estimateF( x1, x2 )
matched_loc_1 = x1;
matched_loc_2 = x2;
% normalize the points
mean1 = mean(matched_loc_1,1);
mean2 = mean(matched_loc_2,1);
var1 = var(matched_loc_1,0,1);
var2 = var(matched_loc_2,0,1);
sdx1 = sqrt(var1(1)); sdy1 = sqrt(var1(2)); sdx2 = sqrt(var2(1)); sdy2 = sqrt(var2(2));
meanx1 = mean1(1); meany1 = mean1(2); meanx2 = mean2(1); meany2 = mean2(2);
T1 = [1/sdx1 0 -meanx1/sdx1; 0 1/sdy1 -meany1/sdy1; 0 0 1];
T2 = [1/sdx2 0 -meanx2/sdx2; 0 1/sdy2 -meany2/sdy2; 0 0 1];

len = size(matched_loc_1);
len = len(1);

% for i = 1:len
% %     matched_loc_1(i,:) = (matched_loc_1(i,:) - mean1)./ sqrt(var1);
% %     matched_loc_2(i,:) = (matched_loc_2(i,:) - mean2)./ sqrt(var2);  
%      matched_loc_1(i,:) = [matched_loc_1(i,:) 1];
%      matched_loc_2(i,:) = [matched_loc_2(i,:) 1];  
% end


matched_loc_1 = transpose(T1 * cat(1,transpose(matched_loc_1),ones(1,len)));
matched_loc_2 = transpose(T2 * cat(1,transpose(matched_loc_2),ones(1,len)));

% Construct the matrix A to get Af = 0
A = zeros(len,9);
for i = 1:len
    pl = matched_loc_1(i,:); xl = pl(1) ; yl = pl(2);
    pr = matched_loc_2(i,:); xr = pr(1) ; yr = pr(2);
    A(i,:) = [xr*xl xr*yl xr yr*xl yr*yl yr xl yl 1];
end
[U S V] = svd(A);

szv = size(V);
f = V(:,szv(2));
f = reshape(f,[3 3]);

[U S V] = svd(f);
sv = diag(S);
sv(numel(sv)) = 0;
Snew = diag(sv);
fnew = U * Snew * transpose(V); 

% Denormalize F, T' = T2, T = T1
sdx1 = sqrt(var1(1)); sdy1 = sqrt(var1(2)); sdx2 = sqrt(var2(1)); sdy2 = sqrt(var2(2));
meanx1 = mean1(1); meany1 = mean1(2); meanx2 = mean2(1); meany2 = mean2(2);
T1 = [1/sdx1 0 -meanx1/sdx1; 0 1/sdy1 -meany1/sdy1; 0 0 1];
T2 = [1/sdx2 0 -meanx2/sdx2; 0 1/sdy2 -meany2/sdy2; 0 0 1];
final_f = transpose(T2) * fnew * T1;
F = final_f
end