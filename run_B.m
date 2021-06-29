%%%%% Section B %%%%%
% This m file is used to test your code for Section B
% Ensure that when you run this script file, the output images are generated and displayed correctly

%--- 1.
I = imread('./test2.bmp');
figure(1)
imshow(I);
title('Original Image');

% For illustration purposes, also display the color images via 3 channels,
% i.e. RGB
IR = I(:,:,1); % Red Channel
IG = I(:,:,2); % Green Channel
IB = I(:,:,3); % Blue Channel
IGray = rgb2gray(I); % Luminance, i.e. greyscaled version

figure(2)
subplot(1,2,1);
histogram(IR);
title('Histogram of Red Channel Image');
subplot(1,2,2);
imshow(IR);
title('Image by Red Channel');

figure(3)
subplot(1,2,1);
histogram(IG);
title('Histogram of Green Channel Image');
subplot(1,2,2);
imshow(IG);
title('Image by Green Channel');

figure(4)
subplot(1,2,1);
histogram(IB);
title('Histogram of Blue Channel Image');
subplot(1,2,2);
imshow(IB);
title('Image by Blue Channel');


figure(5)
subplot(1,2,1);
histogram(IGray);
title('Histogram of Greyscaled Image');
subplot(1,2,2);
imshow(IGray);
title('Image by Greyscaled Channel');

% For generality of code, use greyscale for processing. In the report
% however, Red Channel is used because specific to this problem, it gives
% the best contrast between object and background. Please input IR (red
% channel image) into the sobel to replicate the results shown in the
% report.
I1 = sobel(IGray);
figure(6)
imshow(I1);
title('Image after applying Sobel Gradient Magnitude Windowing');

figure(7)
histogram(I1);
title('Image histogram after applying Sobel Gradient Magnitude Windowing');

%--- 2.
I1_t = reshape(I1,[1 numel(I1)]);
% For generality of code, 95th percentile is used to ensure that the
% boundary is not broken. In the report however, 97th percentile is used to
% give the best boundary. Please run using 97th percentile to replicate the
% results shown in the report
threshold = prctile(I1_t,95);
I2 = edgemap(I1,threshold);
fprintf('The threshold is %d\n',threshold);
figure(8)
imshow(I2);
title('Edgemap after applying Median Filtering');

%--- 3.
I3 = boundaries(I2);
figure(9)
imshow(I3);
title('Single-line Boundary from Edgemap');

%--- 4.
[P1, A1, C1, xbar1, ybar1, rmax1, rmin1,rowmax1,colmax1,rowmin1,colmin1, P2, A2, C2, xbar2, ybar2, rmax2, rmin2,rowmax2,colmax2,rowmin2,colmin2] = features(I3);
fprintf("For shape 1:\nPerimeter = %f\nArea= %d\nCompactness= %f\nCentroid= (x=%f, y=%f)\nMaximum radial distance = %f\nMinimum radial distance= %f\n",P1,A1,C1,xbar1,ybar1,rmax1,rmin1);
fprintf("\n");
fprintf("For shape 2:\nPerimeter = %f\nArea= %d\nCompactness= %f\nCentroid= (x=%f, y=%f)\nMaximum radial distance = %f\nMinimum radial distance= %f\n",P2,A2,C2,xbar2,ybar2,rmax2,rmin2);

%--- 5.
Isup = im2uint8(I3);
Isup = I + 255*Isup;
%Isup(Isup==255) = 185;
sz = size(Isup);
nrow = sz(1);
ycent1 = uint32(nrow-ybar1);
ycent2 = uint32(nrow-ybar2);
xcent1 = uint32(xbar1);
xcent2 = uint32(xbar2);
Isup(ycent1-1:ycent1+1,xcent1-1:xcent1+1,1)=255;
Isup(ycent2-1:ycent2+1,xcent2-1:xcent2+1,1)=255;
Isup(ycent1-1:ycent1+1,xcent1-1:xcent1+1,2:3)=0;
Isup(ycent2-1:ycent2+1,xcent2-1:xcent2+1,2:3)=0;

Isup(rowmax1-1:rowmax1+1,colmax1-1:colmax1+1,:)= 255;
Isup(rowmax1-1:rowmax1+1,colmax1-1:colmax1+1,2)= 0;

Isup(rowmin1-1:rowmin1+1,colmin1-1:colmin1+1,:)= 0;
Isup(rowmin1-1:rowmin1+1,colmin1-1:colmin1+1,3)= 255;

Isup(rowmax2-1:rowmax2+1,colmax2-1:colmax2+1,:)=255;
Isup(rowmax2-1:rowmax2+1,colmax2-1:colmax2+1,2)=0;

Isup(rowmin2-1:rowmin2+1,colmin2-1:colmin2+1,:)=0;
Isup(rowmin2-1:rowmin2+1,colmin2-1:colmin2+1,3)=255;

figure(11)
imshow(Isup);
title('Boundary, Centroid, and Max/Min Distance Points Marked');