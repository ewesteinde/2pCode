function est_goal = EstimateGoal(ftT, i, window, jump_idx,sampRate)
        speed = abs(ftT.velFor{1}) + abs(ftT.velSide{1}) + abs(ftT.velYaw{1})*4.5;
        window = round(window * sampRate); % mult by samp rate
        idx = i - round(window/2):i + round(window/2); 
            if idx(end) > length(ftT.cueAngle{1})
                idx = idx(1):1:length(ftT.cueAngle{1});
            elseif idx(1) < 1 
                idx = 1:idx(end); 
            end
            if sum(ismember(idx, jump_idx)) % remove idx from window that were influenced by jumps
                badIdx = ismember(idx, jump_idx);
                idx = idx(badIdx == 0);
            end
                angle_temp = ftT.cueAngle{1}(idx); 
                speed_temp = speed(idx); 
                angles_flyFor = angle_temp(speed_temp > 3); 
                if ~isempty(angles_flyFor) 
                    x = cosd(angles_flyFor); 
                    y = sind(angles_flyFor); 
                    mean_headingVectors(1)= sum(x)/length(x); 
                    mean_headingVectors(2)= sum(y)/length(y);
                else
                    mean_headingVectors(1)= nan; 
                    mean_headingVectors(2)= nan; 
                end
        est_goal = atan2(mean_headingVectors(2),mean_headingVectors(1)); 
        %rho = sqrt(mean_headingVectors(1,:).^2 + mean_headingVectors(2,:).^2);
end
        
        