clc; 
close all 

Img1 = imread('DanaHallWay1/DSC_0282.JPG'); 
Img2 = imread('DanaHallWay1/DSC_0283.JPG'); 

% duplicate img1 
ImgDou1=rgb2gray(Img1);
ImgDou1=double(ImgDou1); 

% duplicate img2
ImgDup2=rgb2gray(Img2); 
ImgDup2=double(ImgDup2); 
 
% Harris corner detecting
[Locs1] = Harris(ImgDou1); 
[Locs2] = Harris(ImgDup2); 
 
% Compute NCC
[match_Loc1, match_Loc2] =  FindCorr(ImgDou1,ImgDup2,Img1,Img2,Locs1,Locs2); 

% use RANSAC to compute homography estimate 
[H, inlierIdx] = EstHomography(Img1,Img2,match_Loc2',match_Loc1');
[output]=WarpImages(H,Img1,Img2);

figure,
imshow(uint8(output)); 