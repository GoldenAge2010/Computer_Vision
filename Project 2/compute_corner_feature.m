function [descpt, ctl_coner] = compute_corner_feature(I, corner, sigma)
    I_gaussian = imgaussfilt(I, sigma);
    [height, width] = size(I_gaussian);
    
    ctl_coner = corner(corner(:,1) > 2 & corner(:,1) < height - 1 & corner(:,2) > 2 & corner(:,2) < width - 1, :);
    num = size(ctl_coner,1);
    descpt = zeros(num,  25);
    
    for i = 1:num
        xmin = ctl_coner(i,2)-2;
        ymin = ctl_coner(i,1)-2;
        patch = imcrop(I_gaussian, [xmin ymin 4 4]);
        patch = (patch - mean2(patch))./ std2(patch);
        descpt(i,:) = patch(:);   
    end
end
