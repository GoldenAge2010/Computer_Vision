function index = RandIndex(Index_max,Length)
% randomly, non-repeatedly select integers
    if Length > Index_max
        index = [];
        return
    end

    index = zeros(1,Length);
    available = 1:Index_max;
    rs = ceil(rand(1,Length).*(Index_max:-1:Index_max-Length+1));
    for p = 1:Length
        while rs(p) == 0
            rs(p) = ceil(rand(1)*(Index_max-p+1));
        end
        index(p) = available(rs(p));
        available(rs(p)) = [];
    end
end