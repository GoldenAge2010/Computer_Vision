%  Exploiting the Circulant Structure of Tracking-by-detection with Kernels
%
%  Main script for tracking, with a gaussian kernel.
%
%  João F. Henriques, 2012
%  http://www.isr.uc.pt/~henriques/

clc;
clear;
%choose the path to the videos (you'll be able to choose one with the GUI)
base_path = './data/';

%Read the MIL data
positions_MIL = csvread(strcat(base_path,'tiger2/tiger2_MIL_TR001.txt'));
positions_output(:,3:4) = positions_MIL(:,3:4);
positions_MIL(:,1) = positions_MIL(:,1) + positions_MIL(:,3)/2;
positions_MIL(:,2) = positions_MIL(:,2) + positions_MIL(:,4)/2;
positions_MIL(:,[1 2]) = positions_MIL(:,[2 1]);
positions_MIL(:,4) = [];
positions_MIL(:,3) = [];

%parameters according to the paper
padding = 1;					%extra area surrounding the target
output_sigma_factor = 1/16;		%spatial bandwidth (proportional to target)
sigma = 0.2;					%gaussian kernel bandwidth
lambda = 1e-2;					%regularization
interp_factor = 0.075;			%linear interpolation factor for adaptation



%notation: variables ending with f are in the frequency domain.

%ask the user for the video
video_path = choose_video(base_path);
if isempty(video_path), return, end  %user cancelled
[img_files, pos, target_sz, resize_image, ground_truth, video_path] = ...
	load_video_info(video_path);


%window size, taking padding into account
sz = floor(target_sz * (1 + padding));


%desired output (gaussian shaped), bandwidth proportional to target size
output_sigma = sqrt(prod(target_sz)) * output_sigma_factor;
[rs, cs] = ndgrid((1:sz(1)) - floor(sz(1)/2), (1:sz(2)) - floor(sz(2)/2));
y = exp(-0.5 / output_sigma^2 * (rs.^2 + cs.^2));
yf = fft2(y);

%store pre-computed cosine window
cos_window = hann(sz(1)) * hann(sz(2))';


time = 0;  %to calculate FPS
positions = zeros(numel(img_files), 2);  %to calculate precision
positions_My = zeros(numel(img_files), 2);

pos_My = pos;
for frame = 1:numel(img_files)
	%load image
	im = imread([video_path img_files{frame}]);
	if size(im,3) > 1
		im = rgb2gray(im);
	end
	if resize_image
		im = imresize(im, 0.5);
	end
	
	tic()
	
	%extract and pre-process subwindow
	x = get_subwindow(im, pos, sz, cos_window);
    x_My = get_subwindow(im, pos_My, sz, cos_window);
	

	if frame > 1
		%calculate response of the classifier at all locations
		k = dense_gauss_kernel(sigma, x, z);
		response = real(ifft2(alphaf .* fft2(k)));   %(Eq. 9)
        [row, col] = find(response == max(response(:)), 1);  
        %calculate MyTracker response of the classifier at all locations
        k_My = dense_gauss_kernel(sigma, x_My, z_My);
        response_My = real(ifft2(alphaf_My .* fft2(k_My)));   %(Eq. 9)
        [row_My, col_My] = find(response_My == max(response_My(:)), 1);
        
        %Calculate Peak to Sidelobe Ratio
        %Compute value of the peak
        Gmax = max(response_My(:));
        %Compute mean value of the sidelobe
        temp = sum(response_My(:))-sum(sum(response_My(row_My-5:row_My+5,col_My-5:col_My+5)));
        avr = temp/(size(response_My, 1)*size(response_My, 2)-11*11);
        %Compute standard deviation of the sidelobe
        temp = sumsqr(response_My(:))-sumsqr(response_My(row_My-5:row_My+5,col_My-5:col_My+5));
        temp = temp/(size(response_My, 1)*size(response_My, 2)-11*11);
        std = sqrt(temp-avr^2);
        %Compute PSR
        PSR = (Gmax-avr)/std;
        
        %CM Tracker
        pos = pos - floor(sz/2) + [row, col];
        
        %My Tracker
        if PSR > 5.5
            %target location is at the maximum response
            pos_My = pos_My - floor(sz/2) + [row_My, col_My];
    
        else
            %For Tiger1
            Ax = hankel(positions_My(frame-10:frame-6,1),positions_My(frame-6:frame-2,1));
            Ay = hankel(positions_My(frame-10:frame-6,2),positions_My(frame-6:frame-2,2));
            bx = positions_My(frame-5:frame-1,1);
            by = positions_My(frame-5:frame-1,2);
            %For Tiger2
%             Ax = hankel(positions_My(frame-4:frame-3,1),positions_My(frame-3:frame-2,1));
%             Ay = hankel(positions_My(frame-4:frame-3,2),positions_My(frame-3:frame-2,2));
%             bx = positions_My(frame-2:frame-1,1);
%             by = positions_My(frame-2:frame-1,2);
            %Calculate Hankel Matrix
            A = [Ax;Ay];
            b = [bx;by];
            H = A\b;
            %For Tiger1
            C = positions_My(frame-5:frame-1,:);
            %For Tiger2
%             C = positions_My(frame-2:frame-1,:);
            pos_My = (C'*H)';    
            
        end 
	end
	
	%CM Traker--get subwindow at current estimated target position, to train classifer
	x = get_subwindow(im, pos, sz, cos_window);
    %My Traker--get subwindow at current estimated target position, to train classifer
	x_My = get_subwindow(im, pos_My, sz, cos_window);
    
	% CM Tracker--Kernel Regularized Least-Squares, calculate alphas (in Fourier domain)
	k = dense_gauss_kernel(sigma, x);
	new_alphaf = yf ./ (fft2(k) + lambda);   %(Eq. 7)
	new_z = x;	
    % My Tracker--Kernel Regularized Least-Squares, calculate alphas (in Fourier domain)
    k_My = dense_gauss_kernel(sigma, x_My);
	new_alphaf_My = yf ./ (fft2(k_My) + lambda);   %(Eq. 7)
	new_z_My = x_My;
    
	if frame == 1  %first frame, train with a single image
		%CM Tracker
        alphaf = new_alphaf;
		z = x;
        %My Tracker
        alphaf_My = new_alphaf_My;
		z_My = x_My;
	else
		%CM Tracker--subsequent frames, interpolate model
		alphaf = (1 - interp_factor) * alphaf + interp_factor * new_alphaf;
		z = (1 - interp_factor) * z + interp_factor * new_z;
        %My Tracker--subsequent frames, interpolate model
		alphaf_My = (1 - interp_factor) * alphaf_My + interp_factor * new_alphaf_My;
		z_My = (1 - interp_factor) * z_My + interp_factor * new_z_My;
	end
	
	%save position and calculate FPS
	%CM Tracker
    positions(frame,:) = pos;
    %My Tracker
    positions_My(frame,:) = pos_My;
	time = time + toc();

	%visualization
    %MIL Tracker
    pos_MIL = positions_MIL(frame,:);
    rect_position_MIL = [pos_MIL([2,1]) - target_sz([2,1])/2, target_sz([2,1])];
    %CM Tracker
	rect_position = [pos([2,1]) - target_sz([2,1])/2, target_sz([2,1])];
    %My Tracker
    rect_position_My = [pos_My([2,1]) - target_sz([2,1])/2, target_sz([2,1])];
	if frame == 1  %first frame, create GUI
		figure('NumberTitle','off', 'Name',['Tracker - ' video_path])
		im_handle = imshow(im, 'Border','tight', 'InitialMag',200);
        %MIL Tracker
        rect_handle_MIL = rectangle('Position',rect_position_MIL, 'EdgeColor','b','LineWidth',2);
		%CM Tracker
        rect_handle = rectangle('Position',rect_position, 'EdgeColor','y','LineWidth',2);
        %My Tracker
        rect_handle_My = rectangle('Position',rect_position_My, 'EdgeColor','g','LineWidth',2);
	else
		try  %subsequent frames, update GUI
			set(im_handle, 'CData', im);
            %MIL Tracker
            set(rect_handle_MIL, 'Position', rect_position_MIL);
			%CM Tracker
            set(rect_handle, 'Position', rect_position);
            %My Tracker
            if PSR > 5.5
                set(rect_handle_My, 'Position', rect_position_My, 'EdgeColor', 'g');
            else
                set(rect_handle_My, 'Position', rect_position_My, 'EdgeColor', 'r');
                pause(30)  %uncomment to run slower
            end
		catch  %#ok, user has closed the window
			return
		end
	end
	
	drawnow;
% 	pause(0.05)  %uncomment to run slower
end

if resize_image 
    positions = positions * 2;
    positions_My = positions_My * 2;
    positions_MIL = positions_MIL*2;
end

disp(['Frames-per-second: ' num2str(numel(img_files) / time)])

positions_output(:,1:2) = positions_My(:,[2 1]);
csvwrite('Tiger2_Hankel_output.txt', positions_output);

%show the precisions plot
show_precision(positions_MIL, positions, positions_My, ground_truth, video_path)

