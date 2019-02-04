function [homo, inliers] = compute_ransac(ctl_coner_a, ctl_coner_b, iter, threshold)
    outliers = 0;
    num = size(ctl_coner_a,1);
 
    corner_a_extend = [ctl_coner_a, ones(num,1)];
 
    for i = 1:iter
        m = randperm(num, 4);
 
        ctl_a_p = ctl_coner_a(m,:);
        ctl_b_p = ctl_coner_b(m,:);
        ctl_a_r = ctl_a_p(:,1);
        ctl_a_c = ctl_a_p(:,2);
        ctl_b_r = ctl_b_p(:,1);
        ctl_b_c = ctl_b_p(:,2);
 
        P = zeros(8,8);
        P(1:2:end, 1:3) = [ctl_a_r, ctl_a_c, ones(4,1)];
        P(2:2:end, 4:6) = [ctl_a_r, ctl_a_c, ones(4,1)];
        P(1:2:end, 7:8) = [-ctl_a_r.*ctl_b_r, -ctl_a_c.*ctl_b_r];
        P(2:2:end, 7:8) = [-ctl_a_r.*ctl_b_c, -ctl_a_c.*ctl_b_c]; 
 
        D = reshape([ctl_b_r, ctl_b_c]', 8, 1);
 
        if (rcond(P) < 1e-12)
            homo = ones(3,3);
        else
            home_curr = P\D;
            homo = [home_curr(1), home_curr(2), home_curr(3);
                    home_curr(4), home_curr(5), home_curr(6);
                    home_curr(7), home_curr(8), 1];
        end
 
        if  (isequal(homo, ones(3,3)))
            continue;
        else
            ref = homo * corner_a_extend';
            ref(1,:) = ref(1,:)./ref(3,:);
            ref(2,:) = ref(2,:)./ref(3,:);
            err = (ref(1,:) - ctl_coner_b(:,1)').^2 + (ref(2,:) - ctl_coner_b(:,2)').^2;
            n = nnz(err < threshold);
            if  (n >= num * 0.95)
                homo = home_curr;
                inliers = find(err < threshold);
                break;
            elseif (n > outliers)
                outliers = n;
                homo = home_curr;
                inliers = find(err < threshold);
            end
        end
    end
end