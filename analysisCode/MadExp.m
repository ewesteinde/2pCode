function [flData] = MadExp(roiData, currTrialNum, roiName, p, expMedian, expMad)
    currRoiData = roiData(roiData.trialNum == currTrialNum & strcmp(roiData.roiName, roiName), :);
    currExpFl = currRoiData.rawFl{:};  
    currExpFl = smoothdata(currExpFl, 1, 'gaussian', p.smWin);
    flData = (currExpFl-expMedian)/expMad;
end