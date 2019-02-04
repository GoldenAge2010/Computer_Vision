function show_precision(positions_MIL, positions, positions_test, ground_truth, title)
%SHOW_PRECISION
%   Calculates precision for a series of distance thresholds (percentage of
%   frames where the distance to the ground truth is within the threshold).
%   The results are shown in a new figure.
%
%   Accepts positions and ground truth as Nx2 matrices (for N frames), and
%   a title string.
%
%   João F. Henriques, 2012
%   http://www.isr.uc.pt/~henriques/

	
	max_threshold = 50;  %used for graphs in the paper
	
	
	if size(positions,1) ~= size(ground_truth,1)
		disp('Could not plot precisions, because the number of ground')
		disp('truth frames does not match the number of tracked frames.')
		return
	end
	
	%calculate distances to ground truth over all frames
    %MIL Tracker
    distances_MIL = sqrt((positions_MIL(:,1) - ground_truth(:,1)).^2 + ...
				 	 (positions_MIL(:,2) - ground_truth(:,2)).^2);
	distances_MIL(isnan(distances_MIL)) = [];    
    %CM Tracker
	distances = sqrt((positions(:,1) - ground_truth(:,1)).^2 + ...
				 	 (positions(:,2) - ground_truth(:,2)).^2);
	distances(isnan(distances)) = [];
    %My Tracker
    distances_test = sqrt((positions_test(:,1) - ground_truth(:,1)).^2 + ...
				 	 (positions_test(:,2) - ground_truth(:,2)).^2);
	distances_test(isnan(distances_test)) = [];

	%compute precisions
	precisions_MIL = zeros(max_threshold, 1);
    precisions = zeros(max_threshold, 1);
    precisions_test = zeros(max_threshold, 1);
	for p = 1:max_threshold
        precisions_MIL(p) = nnz(distances_MIL < p) / numel(distances_MIL);
		precisions(p) = nnz(distances < p) / numel(distances);
        precisions_test(p) = nnz(distances_test < p) / numel(distances_test);
    end
	

	%plot the precisions
	figure('NumberTitle','off', 'Name',['Precisions - ' title])
    plot(precisions_MIL, 'b-', 'LineWidth',2,'DisplayName', 'MIL')
    hold on
    plot(precisions, 'y-', 'LineWidth',2,'DisplayName', 'CM')
    hold on
    plot(precisions_test,'g-', 'LineWidth', 2, 'DisplayName', 'My Tracker')
    %plot(precisions_test, 'k-', 'LineWidth',2)
	xlabel('Threshold'), ylabel('Precision')
    legend('show', 'Location', 'southeast')
    hold off

end

