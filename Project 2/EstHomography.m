function [f,  inlierIdx] = EstHomography(Img1,Img2,x,y) 
    ransacCoef.minPtNum = 4; 
    ransacCoef.iterNum = 1500; 
    ransacCoef.thDist = 3; 
    ransacCoef.thInlrRatio = .1; 
    PtNum_min = ransacCoef.minPtNum; 
    iterNum = ransacCoef.iterNum; 
    th_InlrRatio = ransacCoef.thInlrRatio; 
    th_Dist = ransacCoef.thDist; 
    ptNum = size(x,2); 
    thInlr = round(th_InlrRatio*ptNum); 
    inlrNum = zeros(1,iterNum); 
    fLib = cell(1,iterNum); 

    for p = 1:iterNum 
        % repeated sample 4 points  
        sample_Idx = RandIndex(ptNum,PtNum_min);

        % compute a homography from the points 
        f1 = Homo(x(:,sample_Idx),y(:,sample_Idx)); 

        % map all points using homography and calculate the distance 
        dist =  CalcuDist(f1,x,y); 
        inlier1 = find(dist < th_Dist); 
        inlrNum(p) = length(inlier1); 
        if length(inlier1) < thInlr, continue;
        end

        % compute a least squares
        fLib{p} = Homo(x(:,inlier1),y(:,inlier1)); 
    end 

    % find the Homography with the most inlier 
    [~,idx] = max(inlrNum); 
    f = fLib{idx}; 
    dist =  CalcuDist(f,x,y); 
    inlierIdx = find(dist < th_Dist); 

    % show the two images 
    img3 = Appendimages(Img1,Img2); 

    % Show a figure with lines joining the accepted matches. 
    figure('Position', [100 100 size(img3,2) size(img3,1)]); 
    colormap('gray');
    imagesc(img3); 
    hold on; 
    cols1 = size(Img1,2); 
    fprintf('%d matches left after using RANSAC.\n',size(inlierIdx,2) ); 
    for i = 1: size(inlierIdx,2) 
    line([y(1,inlierIdx(i))  x(1,inlierIdx(i))+cols1], ... 
        [y(2,inlierIdx(i)) x(2,inlierIdx(i))], 'Color', 'r');  
    end 

    hold off; 
 
end 