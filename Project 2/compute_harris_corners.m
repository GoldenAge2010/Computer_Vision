function corner = compute_harris_corners(I, sigma, coeff)
    % gradient in x
    Ix = filter2([-1 0 1], I, 'same');
    % gradient in y
    Iy = filter2([-1; 0; 1], I, 'same');
 
    % gaussian filetering
    Ix2 = imgaussfilt(Ix.^2, sigma);
    Iy2 = imgaussfilt(Iy.^2, sigma);
    Ixy = imgaussfilt(Ix.*Iy, sigma); 
 
    R = (Ix2.*Iy2 - Ixy.^2) - 0.04*(Ix2 + Iy2).^2;
 
    %   find    local   maximum
    R_max = max(R(:));
    R_regional_max = imregionalmax(R, 8);
    threshold = coeff * R_max;
 
    % set R
    R_regional_max(R < threshold) = 0;
    % set boundary to zero
    R_regional_max([1,end],:) = 0;
    R_regional_max(:,[1,end]) = 0;
 
    [m,n] = find(R_regional_max);
    
    corner = [m,n];
    
end