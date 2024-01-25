function [est_goal,rho] = EstimateGoal_wholeTrial(ftT, window, jump_idx,sampRate)
    
    %speed = sqrt(ftT.velFor{1}.^2 + ftT.velSide{1}.^2);
    window = window * sampRate; % mult by samp rate
    count = 1;  
    for i = 1:length(ftT.velFor{1})
        idx = round(i - window/2:i + window/2); 
            if idx(end) > length(ftT.cueAngle{1})
                idx = idx(1):1:length(ftT.cueAngle{1});
            elseif idx(1) < 1 
                idx = 1:idx(end); 
            end
%             if sum(ismember(idx, jump_idx)) % remove idx from window that were influenced by jumps
%                 badIdx = ismember(idx, jump_idx);
%                 idx = idx(badIdx == 0);
%             end
                angle_temp = ftT.cueAngle{1}(idx); 
                %speed_temp = speed(idx); 
                angles_flyFor = angle_temp; %angle_temp(speed_temp > 1.5); 
                if ~isempty(angles_flyFor) 
                    x = cosd(angles_flyFor); 
                    y = sind(angles_flyFor); 
                    mean_headingVectors(1,count)= sum(x)/length(x); 
                    mean_headingVectors(2,count)= sum(y)/length(y);
                    count = count + 1; 
                else
                    mean_headingVectors(1,count)= nan; 
                    mean_headingVectors(2,count)= nan; 
                    count = count + 1; 
                end
    end    
    est_goal = atan2(mean_headingVectors(2,:),mean_headingVectors(1,:)); 
    rho = sqrt(mean_headingVectors(1,:).^2 + mean_headingVectors(2,:).^2);
        
end