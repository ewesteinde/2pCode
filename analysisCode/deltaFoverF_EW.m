function [flData] = deltaFoverF_EW(roiData, currTrialNum, roiName, p)
    currRoiData = roiData(roiData.trialNum == currTrialNum & strcmp(roiData.roiName, roiName), :);
    currExpFl = currRoiData.rawFl{:};
    if strcmp(p.flType, 'trialDff')
        currExpFl = (currExpFl - currRoiData.trialBaseline{1}) ./ currRoiData.trialBaseline{1};
    elseif strcmp(p.flType, 'expDff')
        currExpFl = (currExpFl - currRoiData.expBaseline) ./ currRoiData.expBaseline;
    end
    flData = smoothdata(currExpFl, 1, 'sgolay', p.smWin*currRoiData.sampRate,'degree',p.deg);
end