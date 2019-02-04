function connectPoints(Img1,Img2,loc1,loc2)
    x1 = loc1(2,:);
    y1 = loc1(1,:);
    x2 = loc2(2,:);
    y2 = loc2(1,:);
    dist = size(Img1,2);
    figure;
    imshowpair(Img1,Img2,'montage');
    hold on;
    for k = 1:size(x1,2)
        plot(x1(k),y1(k),'b.');
        plot(x2(k)+dist,y2(k),'b.');
        plot([x1(k),x2(k)+dist],[y1(k),y2(k)]);
    end
end