function [rho, theta, idx_windows, f, g] = plotHeadingDist(window, minVel, behaviourData, sampRate, plotFig)
% plots mean heading vector of the fly within every window where theta
% represents the heading and rho represents the stability of that heading
% within the window (1 = very stable, 0 = unstable)
% copied what the Green et al 2019 paper did to compute their heading
% vectors
if iscell(behaviourData)
    behaviourData = behaviourData{1};
end

window = window * sampRate; 
if window > length(behaviourData.vel_for)
    window = length(behaviourData.vel_for); 
end
count = 1; 

%% overlapping windows slid by 1s increments
mean_headingVectors = [];
speed = sqrt(behaviourData.vel_for.^2 + behaviourData.vel_side.^2);
for i = 1:sampRate:length(behaviourData.angle) - window + 1
    idx = i:i+window-1; 
    angle_temp = behaviourData.angle(idx); 
    speed_temp = speed(idx); 
    angles_flyFor = angle_temp(speed_temp > minVel); 
    if ~isempty(angles_flyFor)
        x = cosd(angles_flyFor); 
        y = sind(angles_flyFor); 
        idx_windows(count,1) = idx(1);
        idx_windows(count,2) = idx(end);
        mean_headingVectors(1,count)= sum(x)/length(x); 
        mean_headingVectors(2,count)= sum(y)/length(y); 
        count = count + 1; 
    end
end 

rho = sqrt(mean_headingVectors(1,:).^2 + mean_headingVectors(2,:).^2); 
theta = atan2(mean_headingVectors(2,:),mean_headingVectors(1,:)); 
c = 1:length(rho); 

if plotFig == 1
    f = figure();clf; 
        polarscatter(theta, rho,[],c,'filled','o')
        rlim([0 1])
        colormap(gca, 'hot')
        % darkest points = start of trial, lightest points = end

    g = figure();
    polarhistogram(theta,15)

else
    f = [];
    g = [];
end
    
% % for arrows 
% [u, v] = pol2cart(theta,rho);
% g = figure();clf;
% compass(u,v)

end 