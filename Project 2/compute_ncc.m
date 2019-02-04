function correp = compute_ncc(A, B)
    m = size(A, 1); 
    n = size(B, 1); 
    m2 = sum(A.^2, 2); 
    n2 = sum(B.^2, 2);     
 
    correp = zeros(m, n);
    for i = 1:m
        for j = 1:n
            correp(i, j) = sum(A(i,:) .* B(j,:)) / sqrt(m2(i) * n2(j));
        end
    end    
end
