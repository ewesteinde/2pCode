function [rho, theta] = CalculateAverageHeading(ftT,minVel, data_idx)

    if strcmp(data_idx,'all')
        data_idx = 1:length(ftT.cueAngle{1});
    end

    angle_temp = ftT.cueAngle{1}(data_idx); 
    speed = sqrt(ftT.velFor{1}(data_idx).^2 + ftT.velSide{1}(data_idx).^2);
    angles_flyFor = angle_temp(speed > minVel); 
    if ~isempty(angles_flyFor) 
        x = cosd(angles_flyFor); 
        y = sind(angles_flyFor);
        mean_headingVectors(1)= sum(x)/length(x); 
        mean_headingVectors(2)= sum(y)/length(y);
    else
        mean_headingVectors(1)= nan; 
        mean_headingVectors(2)= nan; 
    end
    
    rho = sqrt(mean_headingVectors(1).^2 + mean_headingVectors(2).^2); 
    theta = atan2(mean_headingVectors(2),mean_headingVectors(1));
end