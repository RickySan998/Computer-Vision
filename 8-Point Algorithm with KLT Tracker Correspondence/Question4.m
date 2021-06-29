% Note: Please ensure that images inria1.tif, inria2.tif, frc1.tif,
% frc2.tif are all added to the path when executing this code. Also ensure
% that the supporting functions displayEpipolarF.m and epipoles.m are
% added to path.
clc,clear;
I1 = imread('inria1.tif'); 
%I1 = imread('frc1.tif');
I2 = imread('inria2.tif'); 
%I2 = imread('frc2.tif');

% detect and extract VALID corners using Harris-Stephen Algorithm

%%% This is for taking corners with minimum quality
% corners1 = detectHarrisFeatures(I1,'MinQuality',0.02); 
% corners2 = detectHarrisFeatures(I2,'MinQuality',0.02);
% %%% 

%%% This is for random sampling or taking all points, uncomment and comment the minimum quality
%%% for random sampling
corners1 = detectHarrisFeatures(I1);
corners2 = detectHarrisFeatures(I2);
%%%

[features1, points1] = extractFeatures(I1, corners1);
[features2, points2] = extractFeatures(I2, corners2);


% match the features between the 2 images
indexpairs = matchFeatures(features1,features2);
matched_points_1 = points1(indexpairs(:,1),:);
matched_points_2 = points2(indexpairs(:,2),:);
% here, points at the same index in matched_points_1 and matched_points_2
% correspond to a pair of matched points

n = 18;
%%%%% random sampling n points. Uncomment this section and comment the
%%%%% minimum quality, to implement random sampling
% np = size(matched_points_1);
% np = np(1);
% samples = randsample(np,n);
% matched_points_1 = matched_points_1(samples,:);
% matched_points_2 = matched_points_2(samples,:);
%%%%%

matched_loc_1 = matched_points_1.Location;
matched_loc_2 = matched_points_2.Location;


% display points of correspondences
figure (1); ax = axes;
showMatchedFeatures(I1,I2,matched_points_1,matched_points_2,'montage','Parent',ax);
title('Points of correspondences')
legend('Matched points 1','Matched points 2');


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



