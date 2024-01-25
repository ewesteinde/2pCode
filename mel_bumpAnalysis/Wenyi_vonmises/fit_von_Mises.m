function [bump_params, model_data, x_grid] = fit_von_Mises(activity, x_range, to_plot)
%%% fit_von_Mises(x_range, dff_data, to_plot)
%%% based on fitVonMises (Mel Basnak)
%%%
%%% Args:
%%%    activity (struct): contains dF_F
%%%    x_range (1x2 double array): range of the angles covered (rad)
%%%    to_plot (logical): whether to plot for debugging or not
%%%
%%% Returns:
%%%    bump_params (struct): bump pos (rad, idx), bump magnitude, bump width, and
%%%    adjusted R^2
%%%
%%% Tatsuo Okubo
%%% 2022/03/23
assert(x_range(1) == 0, 'x_range(1) needs to be 0')

dff_data = activity';
T = size(dff_data, 1);

n_centroid = size(dff_data, 2);
mid_dist_2pi_wrap = linspace(x_range(1), x_range(2), n_centroid + 1)';  % + 1 for wrapping around the full circle  
mid_dist_2pi = mid_dist_2pi_wrap(1:end-1);

%% set up optimization parameters 
fo = fitoptions(...
    'Method', 'NonlinearLeastSquares',...
    'Lower', [0, -inf, 0, -inf],... % [a,c,k,u]s
    'StartPoint', [1, 0, 1, 0]);

ft = fittype('a*exp(k*cos(x-u))+c', 'options', fo);

%% initialize arrays
bump_pos = nan(T, 1);
bump_mag = nan(T, 1);
bump_width = nan(T, 1);
adj_rs = nan(T, 1);

%%
x_grid = linspace(x_range(1), x_range(2), 100);  % for plotting the best fit curve
XL = [0, ceil(x_range(2)/ (2 * pi)) * 2 * pi];
YL(1) = min(min(dff_data));
YL(2) = max(max(dff_data));       

f = waitbar(0, 'Analyzing...');

%%
if to_plot == true
    myVideo = VideoWriter('myVideoFile'); %open video file
    myVideo.FrameRate = 10;  %can adjust this, 5 - 10 works well for me
    open(myVideo)
end

for t = 1:T  % for each time point
    waitbar(t / T, f, sprintf('Progress: %d %%', floor((t / T) * 100)));
    data_to_fit = dff_data(t, :);
    [model_data, gof] = fit(mid_dist_2pi, data_to_fit', ft, 'MaxIter', 20000, 'MaxFunEvals', 20000);
    adj_rs(t) = gof.adjrsquare;
    
    % get the coefficient values.
    coeff_names = coeffnames(ft);
    coefficientValues = coeffvalues(model_data);
    a = coefficientValues(strcmp(coeff_names,'a'));
    k = coefficientValues(strcmp(coeff_names,'k'));
    u = coefficientValues(strcmp(coeff_names,'u'));
    c = coefficientValues(strcmp(coeff_names,'c'));
    
    % calculate bump parameters
    bump_pos(t) = mod(u, 2*pi);
    bump_mag(t) = a * (exp(k) - exp(-k));
    bump_width(t) = 2 * abs(acos(1/k * log(1/2 *(exp(k) + exp(-k)))));
    
    % plot results if necessary
    if to_plot == true
        figure(10); clf;
        set(gcf, 'position', [500, 400, 800, 400])
        plot(mid_dist_2pi, dff_data(t,:)', 'k.-')
        hold on    
        plot(x_grid, feval(model_data, x_grid), 'r-', 'linewidth', 2);         % plot the fitted curve
        plot(bump_pos(t), feval(model_data,bump_pos(t)), 'ro'); % add the bump position estimate
        xlabel('ROI location (rad)');
        ylabel('dF/F');
        title(['Frame #',num2str(t), ' Adj R^2 =', num2str(gof.adjrsquare)]);
        box off
        set(gca, 'tickdir', 'out', 'xtick', 0:pi:4 * pi, 'xticklabels', {'0', '\pi', '2\pi', '3 \pi', '4 \pi'}, 'ytick', 0:1:5)
        xlim(XL);
        ylim(YL)
        line([2 * pi, 2 * pi], YL, 'color', 'black', 'linestyle', ':')
        frame = getframe(gcf); %get frame
        writeVideo(myVideo, frame);
    end

end
if to_plot == true
    close(myVideo)
end

close(f)

%% save the variables in a structure array
bump_params.pos_rad = bump_pos;
bump_params.pos_idx = (n_centroid - 1) * bump_pos / x_range(2) + 1;  % bump location in terms of ROI indices
bump_params.mag = bump_mag;
bump_params.width = bump_width;
bump_params.adj_rs = adj_rs;