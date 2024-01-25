figure();
seconds = 10;
start = 500;
for timepoint = (start*60):(start*60) + (seconds*60)
    dffTimepoint = [];
    for roi = 1:size(dffData,1)
        dffTimepoint = [dffTimepoint dffData.dff{roi}(timepoint)];
    end
    plot(dffTimepoint)
    hold on
end

%% Look at PFL2 activity across the FB/PB based on the fly's heading 

angleBin_mid = [-175:30:175];
angle = ftT.cueAngle{1};
binCount = 0; 
for bin = angleBin_mid
    binCount = binCount + 1; 
    for roi = 1:size(dffData,1)
        dffROI = dffData.dff{roi};
        ZROI = ZData.Z{roi};
        alldffROI_angle{roi,binCount} = dffROI(angle > bin - 5 & angle < bin + 5);
        allZROI_angle{roi,binCount} = dffROI(angle > bin - 5 & angle < bin + 5);
    end 
end

figure()
for bin = 1:length(angleBin_mid)
    roiAll = []; 
    for roi = 1:size(dffData,1)
        roiAll = [roiAll (sum(alldffROI_angle{roi,bin})/length(alldffROI_angle{roi,bin}))];
        plot(roiAll)
        hold on
    end
end

