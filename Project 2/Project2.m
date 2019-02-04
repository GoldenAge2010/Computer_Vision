image_a = imread('DanaOffice/DSC_0309.JPG');
image_b = imread('DanaOffice/DSC_0310.JPG');
gray_a = rgb2gray(image_a);
gray_b = rgb2gray(image_b);
 
% Harris corner detecting
corner_a = compute_harris_corners(gray_a, 1.5, 0.01);
corner_b = compute_harris_corners(gray_b, 1.5, 0.01);  
 
% get corner features
[descpt1, ctl_coner_a] = compute_corner_feature(gray_a,  corner_a, 1.5);
[descpt2, ctl_coner_b] = compute_corner_feature(gray_b,  corner_b, 1.5);   
    
% compute ncc
correp = compute_ncc(descpt1, descpt2);   
    
% pick the highest ncc value
thresh = 0.8;
[correp_sorted, index] = sort(correp, 2, 'descend');
ratio = correp_sorted(:,2)./ correp_sorted(:,1);
idx = ratio > thresh;

ctl_coner_b = ctl_coner_b(idx(:,1), :); 

% compute homography estimate
[homo,  inliners] = compute_ransac(ctl_coner_a, ctl_coner_b, 1000, 1); 
    
% corner_match_line(a, ctl_coner_a, b, ctl_coner_b);
% corner_match_line(a, ctl_coner_a(inliners,:), b, ctl_coner_b(inliners,:));
 
%warp images
[I, mask] = warp_images(homo, ctl_coner_a, ctl_coner_b, true(size(ctl_coner_b,1),size(ctl_coner_b,2)));
imwrite(I,'cv_proj2.jpg');
imshow(I)
