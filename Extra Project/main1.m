Img1 = imread('Cones_im2.jpg');
Img2 = imread('Cones_im6.jpg');

greyImg1 = rgb2gray(Img1);
greyImg2 = rgb2gray(Img2);

imgHeight1 = size(greyImg1,1);
imgWidth1 = size(greyImg1,2);
imgHeight2 = size(greyImg2,1);
imgWidth2 = size(greyImg2,2);

disp_v = zeros(size(greyImg1));
disp_h = zeros(size(greyImg1));

for i = 1 : imgHeight1
    for j = 1 : imgWidth1
        if (i < 6 || j < 6 || i > imgHeight1 - 5 || j > imgWidth1 - 5)
            continue; 
        end
        nbhd1 = greyImg1((i-5): (i+5), (j-5): (j+5));
        L1 = ([i; j; 1]' * 5)'; 
        imgHeight1 = L1(1); 
        imgWidth1 = L1(2);
        c1 = L1(3);
        if (abs(imgHeight1) > (abs(imgWidth1)))
            NCCArray = zeros(1,imgHeight2);
            for i2 = 1 : imgHeight2
                j2 = int16(-c1 - imgWidth1*i2) / imgHeight1;
                if (j2 >= 0 && j2 < imgHeight2)
                    if (i2 < 6 || j2 < 6 || i2 > imgHeight2-5 || j2 > imgWidth2-5)
                        continue; 
                    end
                    nbhd2 = Igrey2((i2-5): (i2+5), (j2-5): (j2+5));
                    ncc = normxcorr2(nbhd1, nbhd2);
                    NCCArray(1,i2)= max(ncc(:));
                    NCC_idx(i2,1:2) = [i2 j2];
                end
            end
        else
            NCCArray = zeros(1, imgWidth2); 
            for j2 = 1 : imgWidth2
                i2 = int16(-c1 - imgHeight1*j2) / imgWidth1;
                if (i2 >= 0 && i2 < imgWidth2) 
                    if (i2 < 6 || j2 < 6 || i2 > imgHeight2-5 || j2 > imgWidth2-5) 
                        continue;
                    end
                    nbhd2 = Igrey2((i2-5): (i2+5), (j2-5): (j2+5));
                    ncc = normxcorr2(nbhd1, nbhd2);
                    NCCArray(1, j2) = max(ncc(:));
                    NCC_idx(j2, 1:2) = [i2 j2];
                end
            end
        end
        
        if(j2 > 0)
            [LargestNCC, jIndex] = max(NCCArray(:));
            i2_sel = NCC_idx(jIndex, 1);
            j2_sel = NCC_idx(jIndex, 2);
            disp_v(i, j) = i2_sel - i;
            disp_h(i, j) = j2_sel - j;
        end
    end
end

disp_v(disp_v >= 255) = 255; 
disp_v(disp_v <= 0) = 0; 
disp_h(disp_h >= 255) = 255; 
disp_h(disp_h <= 0) = 0;

figure(6);
imshow(disp_v, []); 
figure(7);
imshow(disp_h, []);
                    