clear all;

pr = [0.5];

for k = 1 : length(pr)
    figure();
    I1 = imread('toys1.gif');
    % I1 = double(I1);
    subplot 211
    imshow(I1);
    im1t = im2double(I1);
    im1 = imresize(im1t, pr(k)); % downsize to half

    I2 = imread('toys2.gif');
    % I2 = double(I2);
    subplot 212
    imshow(I2);
    im2t = im2double(I2);
    im2 = imresize(im2t, pr(k)); % downsize to half

    % Lucas Kanade Here
    % for each point, calculate I_x, I_y, I_t
    sigma = 1.4;
    g = fspecial('gaussian', 5*sigma, sigma);
    im1g = conv2(im1, g, 'same');
    im2g = conv2(im2, g, 'same');

    ww = 5;
    w = round(ww/2);
    Ix_m = conv2(im2g,[-1 0 1; -1 0 1; -1 0 1], 'valid'); % partial on x
    Iy_m = conv2(im2g, [-1 -1 -1; 0 0 0; 1 1 1], 'valid'); % partial on y
    It_m = im2g - im1g; % partial on t
    u = zeros(size(im2g));
    v = zeros(size(im2g));

    % within window ww * ww
    for i = w+1:size(Ix_m,1)-w
       for j = w+1:size(Ix_m,2)-w
          Ix = Ix_m(i-w:i+w, j-w:j+w);
          Iy = Iy_m(i-w:i+w, j-w:j+w);
          It = It_m(i-w:i+w, j-w:j+w);

          Ix = Ix(:);
          Iy = Iy(:);
          b = -It(:); % get b here

          A = [Ix Iy]; % get A here
          nu = pinv(A)*b; % get velocity here

          u(i,j)=nu(1);
          v(i,j)=nu(2);
          h(i,j)=atan2(v(i,j),u(i,j));
          
          
          h(i,j)=h(i,j)/360+0.5;
          % if h(i,j)>=0
            %  h(i,j)=h(i,j)/360;
          % else
            %  h(i,j)=(360 + h(i,j))/360;
         % end
        
          s(i,j)=sqrt(u(i,j)^2+v(i,j)^2);
          hsv(i,j,1)=h(i,j);
          hsv(i,j,2)=s(i,j)/200;
          hsv(i,j,3)=1;
       end;
    end;
    % downsize u and v
    u_deci = u(1:1:end, 1:1:end);
    v_deci = v(1:1:end, 1:1:end);
    [p, q] = size(u_deci);
    u_zero = zeros(p, q);
    v_zero = zeros(p, q);

    % get coordinate for u and v in the original frame
    [m, n] = size(im1);
    [X,Y] = meshgrid(1:2*n, 1:2*m);
    X_deci = X(1:2:end, 1:2:end);
    Y_deci = Y(1:2:end, 1:2:end);

    figure();
    % imshow(I2);
    % hold on;
    % draw the velocity vectors
    quiver(X_deci, Y_deci, u_deci, v_zero, 'r')

    figure();
    % imshow(I2);
    % hold on;
    quiver(X_deci, Y_deci, u_zero ,v_deci, 'm')

    figure();
    imshow(imresize(I2, pr(k)*2));
    hold on;
    quiver(X_deci, Y_deci, u_deci, v_deci, 'y')
    
    figure()
    rgb = hsv2rgb(hsv);
    image(rgb)
end
