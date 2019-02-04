function [MatchLoc1, MatchLoc2] = FindCorr(Img1,Img2,Img3,Img4,Locs1,Locs2) 
    MatchTable = zeros(1,size(Locs1,1)); 
    NCC=zeros(1,size(Locs2,1));

    % make a pair 
    counter=zeros(1,size(Locs2,1));

    for i=1:size(Locs1,1) 
       for j=1:size(Locs2,1) 

        % match each descriptor in the first image with the second image.  
        i1Patch=Img1(Locs1(i,1)-2: Locs1(i,1)+2,Locs1(i,2)-2: Locs1(i,2)+2); 
        i2Patch=Img2(Locs2(j,1)-2: Locs2(j,1)+2,Locs2(j,2)-2: Locs2(j,2)+2); 
        i1PatchMean=mean(mean(i1Patch)); 
        i2PatchMean=mean(mean(i2Patch));

        %sustract the mean
        i1Patch=i1Patch-i1PatchMean; 
        i2Patch=i2Patch-i2PatchMean;  
        i1PSumSq=sum(sum(i1Patch.^2))^0.5; 
        i2PSumSq=sum(sum(i2Patch.^2))^0.5; 

        i1PatchNorml=i1Patch/i1PSumSq; 
        i2PatchNorml=i2Patch/i2PSumSq;

        % Computes vector of dot products
        NCC(j)= sum(sum(i1PatchNorml.*i2PatchNorml));  
        end 

    [vals,index]=sort(NCC)  ; 

    % Check if the angle of nearest neighbor has   
        if (vals(end)>0.9)&&(counter(index(end))==0) 
          MatchTable(i) = index(end); 
          counter(index(end))=1; 
        else 
          MatchTable(i) = 0; 
        end 
    end

    % show the two images side by side. 
    Img3 = Appendimages(Img3,Img4); 

    % Show a figure with lines joining the accepted matches. 
    figure('Position', [100 100 size(Img3,2) size(Img3,1)]);  
    imagesc(Img3); 
    hold on; 
    cols1 = size(Img1,2); 
    for i = 1: size(Locs1,1) 
      if (MatchTable(i) > 0) 
        line([Locs1(i,2) Locs2(MatchTable(i),2)+cols1], ... 
             [Locs1(i,1) Locs2(MatchTable(i),1)], 'Color', 'r'); 
      end 
    end

    hold off;
    num = sum(MatchTable > 0); 
    fprintf('%d matches found.\n', num); 

    idx1 = find(MatchTable); 
    idx2 = MatchTable(idx1); 
    x1 = Locs1(idx1,2); 
    x2 = Locs2(idx2,2); 
    y1 = Locs1(idx1,1); 
    y2 = Locs2(idx2,1); 

    MatchLoc1 = [x1,y1]; 
    MatchLoc2 = [x2,y2]; 
end