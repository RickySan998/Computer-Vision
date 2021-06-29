%%%%% Section A %%%%%
% This m file is used to test your code for Section A
% Ensure that when you run this script file, the output images are generated and displayed correctly

%--- 1.
I = imread('./test1.bmp');
figure(1)
imshow(I);
title('Original Image');

I1 = sobel(I);
figure(2)
imshow(I1);
title('Image after applying Sobel Gradient Magnitude Windowing');

figure(3)
histogram(I1);
title('Histogram of Sobel Gradient Magnitude Image');

%--- 2.
% For generality of code, 95th percentile is used here. However, in the
% report, 98th percentile is used because specific to this case, it gives
% the best boundary in step 3. Please input 98th percentile to replicate
% the results shown in the report.
I1_t = reshape(I1,[1 numel(I1)]);
threshold = prctile(I1_t,95);
fprintf('The threshold is %d\n',threshold);
I2 = edgemap(I1,threshold);
figure(4)
imshow(I2);
title('Edgemap after applying Median Filtering');

%--- 3.
I3 = boundaries(I2);
figure(5)
imshow(I3);
title('Single-line Boundary from Edgemap');

%--- 4.
[P1, A1, C1, xbar1, ybar1, rmax1, rmin1,rowmax1,colmax1,rowmin1,colmin1, P2, A2, C2, xbar2, ybar2, rmax2, rmin2,rowmax2,colmax2,rowmin2,colmin2] = features(I3);
fprintf("For shape 1:\nPerimeter = %f\nArea= %d\nCompactness= %f\nCentroid= (x=%f, y=%f)\nMaximum radial distance = %f\nMinimum radial distance= %f\n",P1,A1,C1,xbar1,ybar1,rmax1,rmin1);
fprintf("\n");
fprintf("For shape 2:\nPerimeter = %f\nArea= %d\nCompactness= %f\nCentroid= (x=%f, y=%f)\nMaximum radial distance = %f\nMinimum radial distance= %f\n",P2,A2,C2,xbar2,ybar2,rmax2,rmin2);

%--- 5. To superimpose detected boundary, maximum and minimum points
Isup = im2uint8(I3);
Isup = I + 255*Isup;
Isup(Isup==255) = 185;
sz = size(Isup);
nrow = sz(1);
ycent1 = uint32(nrow-ybar1);
ycent2 = uint32(nrow-ybar2);
xcent1 = uint32(xbar1);
xcent2 = uint32(xbar2);
Isup(ycent1-1:ycent1+1,xcent1-1:xcent1+1)=255;
Isup(ycent2-1:ycent2+1,xcent2-1:xcent2+1)=255;
Isup(rowmax1-1:rowmax1+1,colmax1-1:colmax1+1)=255;
Isup(rowmin1-1:rowmin1+1,colmin1-1:colmin1+1)=255;
Isup(rowmax2-1:rowmax2+1,colmax2-1:colmax2+1)=255;
Isup(rowmin2-1:rowmin2+1,colmin2-1:colmin2+1)=255;
figure(6)
imshow(Isup);
title('Boundary, Centroid, and Max/Min Distance Points Marked');


