function [x, y, R]=harris(Img) 

    gf = fspecial('gaussian',[7 7],1);
    
    I = double(Img);
    I = imfilter(I,gf);

    sobel = fspecial('sobel');
    Ix = imfilter(I, sobel, 'replicate','same');
    Iy = imfilter(I, sobel', 'replicate','same');

    Ix2 = imfilter(Ix.^2, gf, 'same');
    Iy2 = imfilter(Iy.^2, gf, 'same');
    Ixy = imfilter(Ix.*Iy, gf, 'same');
    
    [height, width] = size(I);
    R = zeros(height, width);

    for i = 1: height 
        for j = 1: width
            M = [Ix2(i, j) Ixy(i, j); Ixy(i, j) Iy2(i,j)];
            R(i, j) = det(M) - 0.05*(trace(M))^2;
        end
    end

    localmax = ordfilt2(R, 5^2, true(5));
    R = R.*(and(R == localmax, R > 0));

    [x, y] = find(R);
end