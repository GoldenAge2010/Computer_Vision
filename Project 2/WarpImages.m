function [imgout]=WarpImages(H,Img1,Img2) 
    tform = maketform('projective',H'); 

    % reproject img2 
    img21 = imtransform(Img2,tform); 

    [M1,N1,~] = size(Img1); 
    [M2,N2,~] = size(Img2); 

    % do the mosaic 
    pt = zeros(3,4);
    pt(:,1) = H*[1;1;1]; 
    pt(:,2) = H*[N2;1;1]; 
    pt(:,3) = H*[N2;M2;1]; 
    pt(:,4) = H*[1;M2;1]; 
    x2 = pt(1,:)./pt(3,:); 
    y2 = pt(2,:)./pt(3,:); 

    up = round(min(y2)); 
    Y_offset = 0; 
    if up <= 0 
        Y_offset = -up+1; 
        up = 1; 
    end 

    left = round(min(x2)); 
    X_offset = 0; 
    if left<=0 
        X_offset = -left+1; 
        left = 1; 
    end 

    [M3,N3,~] = size(img21);

    % overlap Area 
    row_Begin=max(up,Y_offset+1); 
    column_Begin=max(left,X_offset+1); 
    row_End=min(up+M3-1,Y_offset+M1); 
    column_End=min(left+N3-1,X_offset+N1); 
    imgout(up:up+M3-1,left:left+N3-1,:) = img21; 

    % pixel values of overlap area from P2
    overlapAreaP2=imgout(row_Begin:row_End,column_Begin:column_End,:);

    % img1 is above img21 
    imgout(Y_offset+1:Y_offset+M1,X_offset+1:X_offset+N1,:) = Img1; 
    overlapAreaP1=imgout(row_Begin:row_End,column_Begin:column_End,:); 
    overlapArea=imgout(row_Begin:row_End,column_Begin:column_End);

    % overlap Row and Column length 
    [overlapRowLength,overlapColumnLength]=size(overlapArea);

    % just one line
    distBoundary1OneLine=(overlapColumnLength-1:-1:0); 

    % Replicate and tile it to the size of the overlapArea.
    distBound1=repmat(distBoundary1OneLine,overlapRowLength,1);  
    distBound2OneLine=(0:overlapColumnLength-1); 

    % distant from boundary 2
    distBoundary2=repmat(distBound2OneLine,overlapRowLength,1); 

    % blending  
    overlapAreaP2=double(overlapAreaP2); 
    overlapAreaP1=double(overlapAreaP1); 
    blendingImg=zeros(overlapRowLength,overlapColumnLength,3); 

    for i=1:3 
    blendingImg(:,:,i)=(overlapAreaP2(:,:,i).*distBoundary2+overlapAreaP1(:,:,i).*distBound1)/(overlapColumnLength-1); 
    end

    blendingImg=uint8(blendingImg); 
    imgout(row_Begin:row_End,column_Begin:column_End,:)=blendingImg; 
end