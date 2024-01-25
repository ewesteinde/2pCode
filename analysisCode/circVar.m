angle = ftData_DAQ.cueAngle{1};
vf = ftData_DAQ.velFor{1};
vs = ftData_DAQ.velSide{1};
sampRate = 60; 
windowSize = 1; 
minVel = 0.5;

window = windowSize * round(sampRate); 
if window > length(angle)
    window = length(angle); 
end

[~, ~, jumps] = detect_jumps(ftData_DAQ, 5, 6);

count = 1;
%% overlapping 60 second windows slid by ~1s increments
mean_headingVectors = [];
idx_windows = [];
speed = sqrt(vf.^2 + vs.^2);
for i = 1:round(sampRate):length(angle) - window + 1
    idx = i:i+window-1;
    jumps_temp = jumps(idx);
    angle_temp = angle(idx); 
    speed_temp = speed(idx); 
    angles_flyFor = angle_temp(speed_temp > minVel & jumps_temp == 0); 
    if ~isempty(angles_flyFor)
        x = cosd(angles_flyFor); 
        y = sind(angles_flyFor); %my arena has - angles to the left of the fly, + to the right, multiply y component by -1 to align physical arena coords to polar plot angles
%         idx_windows(count,1) = idx(1);
%         idx_windows(count,2) = idx(end);
%         idx_windows(count,3) = length(find(speed_temp > minVel))/length(speed_temp)*100;
        mean_headingVectors(1,count)= sum(x)/length(x); 
        mean_headingVectors(2,count)= sum(y)/length(y); 
        count = count + 1; 
    end
end 

rho = sqrt(mean_headingVectors(1,:).^2 + mean_headingVectors(2,:).^2); 
theta = atan2(mean_headingVectors(2,:),mean_headingVectors(1,:)); 
cVar = 1 - rho;