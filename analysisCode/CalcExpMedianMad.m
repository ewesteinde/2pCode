function [expMedian, expMad] = CalcExpMedianMad(rootDir, PFL3, PFL2, region)
%     dbstop if error
p = [];
p.smWin = 5;
p.flType = 'expDff';

folders = get_folders(rootDir, PFL2, PFL3);
   
    %% Process each folder
    folderNum = length(folders);
    fprintf(1, '##### Found %d potential experiment folders to process...#####\n', folderNum);
    countFail = 1;
    
    if strcmp(region,'LAL')
        roiData_all = cell(2,1);
    elseif strcmp(region,'PB')
        roiData_all = cell(10,1);
    elseif strcmp(region,'FB')
        roidata_all = cell(9,1); 
    end
        
    for ff = 1:folderNum
        close all 
        %clearvars -except ff folderNum folders savePlots
    try
      
      %% Get folder information
      parentDir = folders(ff).folder;
      
      if strcmp(parentDir(end),'.') 
          parentDir = parentDir(1:end-2);
      end

%% Load in ROI data

    % Get data files
    expID = get_expID(parentDir);
    expList = {expID};

    % Load imaging data
    roiData = load_roi_data(expList, parentDir);
    trials = max(roiData.trialNum);
    
    for t = 1:trials
        roiTrial = roiData(roiData.trialNum == t,:);
    
        for roi = 1:size(roiTrial,1)
            roiData_all{roi} = [roiData_all{roi};roiTrial.rawFl{roi}];
        end
    end

    catch
        disp([parentDir,' failed'])
    end
    end
    
    for roi = 1:size(roiData_all,1)
        currExpFl = roiData_all{roi, :};
        currExpFl = smoothdata(currExpFl, 1, 'gaussian', p.smWin);
        expMedian(roi) = median(currExpFl); 
        expMad(roi) = mad(currExpFl); 
    end
