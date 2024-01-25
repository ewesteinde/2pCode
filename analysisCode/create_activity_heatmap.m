function [N, heatmap_array, x_centers, y_centers] = create_activity_heatmap(x_values, y_values, activity_values, x_edges, y_edges)
 % x values = vel 1
 % y values = vel 2
 % activity values = spike rate
 % x edges & y edges = edges of velocity bins -- decide how to partition
 % Vel data
    activity_values = normalize(activity_values); 
    %Puts values in X & Y into 2D bin partition by given Xedges & Y edges
    %Also returns index arrays in binX & binY
    [N, ~, ~, y_bin, x_bin] = histcounts2(y_values, x_values, y_edges, x_edges);
    % converts subscripts to linear indices (row, col) --> #
    bin_2d = sub2ind([size(y_edges, 2) size(x_edges, 2)], y_bin+1, x_bin+1);
    
    x_centers = x_edges(1:end-1)+diff(x_edges)/2;
    y_centers = y_edges(1:end-1)+diff(y_edges)/2;
    
    %sums values in activity values that share the same associated bin_2d
    %coordinate pairs, values of coordinate pairs determines position in
    %temp (x,y)
    temp = accumarray(bin_2d, activity_values, [length(y_edges)*length(x_edges) 1]);
    temp_reshaped = reshape(temp, length(y_edges), length(x_edges));
    % performs binary opteration specified by @rdivide
    heatmap_array = bsxfun(@rdivide, temp_reshaped(2:end, 2:end), N);
    heatmap_array(isnan(heatmap_array)) = 0;
    
end
%%imagesc(flip(heatmap_array))

% x bin  tells you what col correlated data point is at 
% 0 refers to any value to one or both pairs of the row,col data pair is out of bounds of the bins, turns into row col index of 1, thats why temp_reshapes takes + 1
% match activity value with same x,y bin 
% 
% plot heatmap/tuning curve based on position of bar/heading fo fly for a cell & then shift heading position & neural activity by x lag indices & 
% intro +- lag push trace of panel forward or trace & calc tuning curve of head for every time difference & plot against forward velocity 

