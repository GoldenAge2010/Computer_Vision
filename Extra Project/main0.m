Img1 = imread('cast-left.jpg');
Img2 = imread('cast-right.jpg');

greyImg1 = rgb2gray(Img1);
greyImg2 = rgb2gray(Img2);
[h1,w1] = size(greyImg1);
[h2,w2] = size(greyImg2);

figure,imshow(greyImg1);
figure,imshow(greyImg2);

[x1, y1, R1] = harris(greyImg1);
[x2, y2, R2] = harris(greyImg2);

[loc1, patch1] = imagePatches(greyImg1, x1, y1);
[loc2, patch2] = imagePatches(greyImg2, x2, y2);

[ncc, pairs] = ncc(patch1, patch2);

nofpoints = size(pairs, 1);
loc1_1 = [(loc1(pairs(:,1),:))'; ones(1,nofpoints)];
loc2_2 = [(loc2(pairs(:,2),:))'; ones(1,nofpoints)];
connectPoints(Img1, Img2, loc1_1, loc2_2);

loc1_1(3,:) = [];
loc2_2(3,:) = [];
matchedPoints1 = loc1_1';
matchedPoints2 = loc2_2';
[fRANSAC,inlierindex] = estimateFundamentalMatrix(matchedPoints1, matchedPoints2, 'Method', 'RANSAC', 'NumTrials', 2000, 'DistanceThreshold', 1e-2);
matcher1 = matchedPoints1(inlierindex, :);
matcher2 = matchedPoints2(inlierindex, :);

connectPoints(Img1,Img2,matcher1',matcher2');

