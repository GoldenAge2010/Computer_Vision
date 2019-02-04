function im = Appendimages(Image1, Image2)
    % Select the image with the fewest rows and fill in enough empty rows
    rows1 = size(Image1,1);
    rows2 = size(Image2,1);

    if (rows1 < rows2)
         Image1(rows2,1) = 0;
    else
         Image2(rows1,1) = 0;
    end
im = [Image1 Image2];  