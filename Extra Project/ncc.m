function [ncc,pairs] = ncc(patch1,patch2)
    n1 = size(patch1, 1);
    n2 = size(patch2, 1);
    part1 = sum(patch1.^2, 2);
    part2 = sum(patch2.^2, 2); 
    ncc = zeros(n1, n2);
    for i = 1 : n1
        for j = 1 : n2
            ncc(i,j) = sum(patch1(i, :).*patch2(j, :)) / sqrt(part1(i)*part2(j));
        end
    end
    
    thres = 0.98;
    for i = 1 : n1
        for j=1 : n2
            if ncc(i, j) <= thres
                ncc(i, j) = 0;
            end
        end
    end

    [row, col] = find(ncc ~= 0);
    pairs = [row, col];
end