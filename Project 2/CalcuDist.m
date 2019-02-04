function d = CalcuDist(H,pts1,pts2) 
    % Project PTS1 to PTS3
    n = size(pts1,2); 
    pts3 = H*[pts1;ones(1,n)]; 
    pts3 = pts3(1:2,:)./repmat(pts3(3,:),2,1);
    
    % calcultate the distances between PTS2 and PTS3 
    d = sum((pts2-pts3).^2,1); 
end