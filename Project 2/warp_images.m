function [I, mask] = warp_images( homo, ctl_coner_a, ctl_coner_b, dst_mask)
    [hight1, width1, ~] = size(ctl_coner_a);
    [hight2, width2, ~] = size(ctl_coner_b);
 
    [r,c] = meshgrid(1:hight1, 1:width1);
    S = ones(3, hight1 * width1);
    S(1,:) = reshape(r, 1, hight1 * width1);                
    S(2,:) = reshape(c, 1, hight1 * width1);
 
    ref = homo * S;
    top = fix(min([1, min(ref(1,:)./ref(3,:))]));
    bottom = fix(max([hight2, max(ref(1,:)./ref(3,:))]));
    left = fix(min([1, min(ref(2,:)./ref(3,:))]));
    right = fix(max([width2, max(ref(2,:)./ref(3,:))]));
 
    Height = bottom - top + 1;
    Width = right - left + 1;
    nDstTop = 1 - top + 1;
    nDstLeft = 1 - left + 1;
 
    I = zeros(Height, Width, class(ctl_coner_b));
    I(nDstTop:nDstTop + hight2 - 1, nDstLeft:nDstLeft + width2 - 1, :) = ctl_coner_b;
 
    mask = false(Height,   Width);
    mask(nDstTop:nDstTop + hight2 - 1, nDstLeft:nDstLeft + width2 - 1) = mask(nDstTop:nDstTop + hight2 - 1, nDstLeft:nDstLeft + width2 - 1) | dst_mask;
 
    for i = 1:Height
        for j = 1:Width
            coor = [i-nDstTop+1; j-nDstLeft+1; 1];
            ref_coor = homo \ coor;
            r   =   fix(ref_coor(1)/ref_coor(3));
            c   =   fix(ref_coor(2)/ref_coor(3));
            if (r >=1 && r <= hight1 && c >= 1 && c <= width1)
                if  (mask(i,j))
                    sp = ctl_coner_a(r,c,:);
                    dp = ctl_coner_b(i-nDstTop+1,j-nDstLeft+1,:);
                    if (sum(sp)>sum(dp))
                        I(i,j,:) = sp;
                    else
                        I(i,j,:) = dp;
                    end
                else
                    I(i,j,:) = ctl_coner_a(r,c,:);
                    mask(i,j) = true;
                end
            else
                continue;
            end
        end
   end
end