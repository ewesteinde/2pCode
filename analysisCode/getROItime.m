function roiData = getROItime(roiData, trialData)

%% use DAQ volume clock to extract timepoints of every volume

% find timepoint in DAQ series when each volume acquisition ended
    
    volumes = trialData.volumeClock; 
    count = 1; 
    prev_jump = 0; 
    transition = zeros(size(volumes)); 
    for idx = 1:length(volumes)
        value = volumes(idx);
        if isnan(value)
            print ('nan approaching')
        end

        if count ~= 1 
            if value ~= prev_val && ~(isnan(value)) && value == 0 
                transition(count) = 1;
                prev_jump = count; 
            elseif idx == length(volumes) && value == 1
                transition(count) = 1;
                prev_jump = count; 
            else
                transition(count) = 0; 
            end

            if ~(isnan(value))
                prev_val = value;
            else
                prev_val = prev_val;
            end
            
            count = count + 1; 

        else
            transition(count) = 0; 
            prev_val = value;
            count = count + 1;
        end
    end
    
    % debugging plot
    figure();plot(trialData.Time,volumes,'o'); 
    hold on; 
    plot(trialData.Time(transition == 1),transition(transition == 1),'ro')
    
    % add timeseries data to ROI table
    for roi = 1:size(roiData,1)
        roiData.time(roi) = {trialData.Time(transition == 1)}; 
    end
end