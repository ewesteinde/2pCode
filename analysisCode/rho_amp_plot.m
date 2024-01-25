figure();       
    ax(1) = subplot(6,1,1);
    plot(seconds(ftT.trialTime{1}),ftT.cueAngle{1})
    xlim([min(seconds(ftT.trialTime{1})),max(seconds(ftT.trialTime{1}))])
    ax(2) = subplot(6,1,2);  
    ax(3) = subplot(6,1,3);
    ax(4) = subplot(6,1,4);
    ax(5) = subplot(6,1,5);
    ax(6) = subplot(6,1,6);
    hold on
    axcount = 2; 
    minVel = 1.5;

for window = [5,10,30,60,90]
        sampRate = 60;     
        window = window * sampRate; 
        if window > length(ftT.velFor{1})
            window = length(ftT.velFor{1}); 
        end
        count = 1; 


        mean_headingVectors = [];
        speed = sqrt(ftT.velFor{1}.^2 + ftT.velSide{1}.^2);

        [~, jump_array, ~] = detect_jumps(ftT, 5, 5,0);
        jump_idx = [];
        for jump = 1:size(jump_array,1)
            jump_idx = [jump_idx , jump_array(jump,2):jump_array(jump,3)];
        end

        for i = 1 - window/2:1:length(ftT.cueAngle{1}) - window/2
            idx = i:i + window; 
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
                angles_flyFor = angle_temp(speed_temp > minVel); 
                if ~isempty(angles_flyFor) 
                    x = cosd(angles_flyFor); 
                    y = sind(angles_flyFor); %my arena has - angles to the left of the fly, + to the right, multiply y component by -1 to align physical arena coords to polar plot angles
                    idx_windows{count,1} = idx;
                    mean_headingVectors(1,count)= sum(x)/length(x); 
                    mean_headingVectors(2,count)= sum(y)/length(y);
    %                 gradient_temp = gradient(angles_flyFor); 
    %                 gradient_temp(abs(gradient_temp) > 160) = 0; 
    %                 slope(count) = sum(gradient_temp); 
                    count = count + 1;
                else
                    mean_headingVectors(1,count)= nan; 
                    mean_headingVectors(2,count)= nan; 
                    slope(count) = nan;
                    count = count + 1;
                end
        end

        rho = sqrt(mean_headingVectors(1,:).^2 + mean_headingVectors(2,:).^2); 
        plot(ax(axcount),seconds(ftT.trialTime{1}),rho)
        title(ax(axcount), ['window: ',num2str(window/60)])
        axcount = axcount + 1; 
        
end

figure();
%ax1= subplot(2,1,1)
plot(ftT.trialTime{1},bump_params.amp)