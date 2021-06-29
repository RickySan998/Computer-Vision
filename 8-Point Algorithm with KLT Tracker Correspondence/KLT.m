% Code is adapted from MathWorks Documentation Example
function[points_im1,points_im2] = KLT(I1,I2)
points = detectMinEigenFeatures(I1);
%as suggested by Shi&Tomas, this is a good feature (corner) tracker for KLT

%Init the tracker and set the reference points to track in 2nd img
pointTracker = vision.PointTracker('MaxBidirectionalError', 2);
points = points.Location;
initialize(pointTracker,points,I1);
oldPoints = points;

%Then track the points in the second image
[points,isFound] = step(pointTracker,I2);%isFound is Boolean array indicating whether or not the corresponding part
%is found
points_im1 = oldPoints(isFound,:);
points_im2 = points(isFound,:);
if size(points_im2,1) >= 2
    [xform,points_im1,points_im2] = estimateGeometricTransform(points_im1,points_im2,'similarity','MaxDistance',4);
    %to remove outlier
end
figure (3); ax = axes;
showMatchedFeatures(I1,I2,points_im1(1:20,:),points_im2(1:20,:),'montage','Parent',ax);
title('Points of correspondences')
legend('Matched points 1','Matched points 2');
end