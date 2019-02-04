function [locs] = Harris(frame) 
    I=frame; 
    min_N=350;
    max_N=450; 
    sigma=1.4;
    Thrs=20;
    r=4;

    % The Mask 
    dx = [-1 0 1; -1 0 1; -1 0 1];  
    dy = dx'; 

    Ix = conv2(I, dx, 'same');    
    Iy = conv2(I, dy, 'same'); 

    % Gaussien Filter
    g = fspecial('gaussian',5*sigma, sigma);
    Ix2 = conv2(Ix.^2, g, 'same');   
    Iy2 = conv2(Iy.^2, g, 'same'); 
    Ixy = conv2(Ix.*Iy, g,'same'); 

    k = 0.04; 
    R11 = (Ix2.*Iy2 - Ixy.^2) - k*(Ix2 + Iy2).^2;
    R11=(1000/max(max(R11)))*R11;   
    R=R11; 

    sze = 2*r+1;
    % non-Maximum supression
    Mx = ordfilt2(R,sze^2,ones(sze)); 
    R11 = (R==Mx)&(R>Thrs);       
    count=sum(sum(R11(5:size(R11,1)-5,5:size(R11,2)-5))); 

    % adaptive threshold
    loop=0;
    while (((count<min_N)||(count>max_N))&&(loop<30)) 
        if count>max_N 
            Thrs=Thrs*1.5; 
        elseif count < min_N 
            Thrs=Thrs*0.5; 
        end 

        R11 = (R==Mx)&(R>Thrs);  
        count=sum(sum(R11(5:size(R11,1)-5,5:size(R11,2)-5))); 
        loop=loop+1; 
    end 

    % ignore the corners on the boundary 
    R=R*0; 
    R(5:size(R11,1)-5,5:size(R11,2)-5)=R11(5:size(R11,1)-5,5:size(R11,2)-5);
    [r1,c1] = find(R); 
    Pip=[r1,c1];  
    locs=Pip; 

    % Display 
    Size_PI=size(Pip,1); 
    for r=1: Size_PI 
    I(Pip(r,1)-2:Pip(r,1)+2,Pip(r,2))=255; 
    I(Pip(r,1)-2:Pip(r,1)+2,Pip(r,2))=255; 
    I(Pip(r,1),Pip(r,2)-2:Pip(r,2)+2)=255; 
    I(Pip(r,1),Pip(r,2)-2:Pip(r,2)+2)=255; 
    end
end