function foldersFailed = process2p_ROI_data_down(rootDir)
%     dbstop if error
    filelist = dir(fullfile(rootDir, '**/*.*'));  % get list of files and folders in any subfolder
    filelist = filelist([filelist.isdir]);  % only folders from list
    filelistNum = length(filelist);
    correct = [];
    for f = 1:filelistNum
      baseFolderName = filelist(f).name;
      if strcmp(baseFolderName,'..') || ~strcmp(baseFolderName,'.')
          present = false;
      else
          parentFolderName = filelist(f).folder;
          fullFolderName = fullfile(parentFolderName, baseFolderName);
          filelist(f).folder = fullFolderName;
          contents = fullfile(fullFolderName,'config.txt'); % fictrac data and ...
          present = exist(contents,'file')>0;
          listingTiff = dir(fullfile(fullFolderName,'*_daqData_*.mat'));
          present = numel(listingTiff) > 0 && present; % Image data
      end
      correct(end+1) = present;
    end 
    folders = filelist(logical(correct));
   
    %% Process each folder
    folderNum = length(folders);
    fprintf(1, '##### Found %d potential experiment folders to process...#####\n', folderNum);
    countFail = 1;
    for ff = 1:folderNum
        close all 
        %clearvars -except ff folderNum folders savePlots
    try
      
      %% Get folder information
      parentDir = folders(ff).folder;
      
      if strcmp(parentDir(end),'.') 
          parentDir = parentDir(1:end-2);
      end

%% Load in fictrac & ROI data
 
    % Analysis settings
    p = [];
    p.smWin = 5;
    p.flType = 'expDff';
    
    % Get data files
    expID = get_expID(parentDir);
    expList = {expID};
    
    % Load metadata 
    [expMd, trialMd, ~, ~] = load_metadata(expList, parentDir);

    % Load imaging data
    roiData_all = load_roi_data(expList, parentDir);
    
    daqFile_info = dir(fullfile(parentDir,'*_daqData_*.mat'));
    
    numTrials = max(size(unique(roiData_all.trialNum),1),length(trialMd.trialNum)); 
    

%%
        for nTrial = 1:numTrials
            if any(roiData_all.trialNum==nTrial)

            load(fullfile(parentDir,daqFile_info(nTrial).name),'trialData')
            roiData = roiData_all(roiData_all.trialNum==nTrial,:);
            
            %% Volume rate
            if size(trialMd,1) >= nTrial
                tMd = trialMd(trialMd.trialNum == nTrial, :);
            else 
                tMd = trialMd;
            end 
            
            % get roi times from DAQ volume triggers
            try
                roiData = getROItime(roiData, trialData);
                roi_time = roiData.time{1};
                
                %[0:1/trialMd.volumeRate:trialMd.trialDuration]';
            catch
                roi_time = [0:1/expMd.volumeRate:trialMd.trialDuration]';
                tMd.volumeRate = expMd.volumeRate;
            end
                
            roi_time = seconds(roi_time);
            

            %% calculate modififed Z-score & dff from roi data
            roiNames = roiData.roiName;
            % For each ROI plot with the correct ROI number
            count = 0; 
            ZData = [];
            dffData = []; 
            for nRoi = 1:numel(roiNames)

                % Get ROI name
                roiName = char(roiNames(nRoi));
                % If the ROi exists with data calculate before upsampling due to speed constraints
                currRoiData = roiData(roiData.trialNum == nTrial & strcmp(roiData.roiName, roiName), :);
                if ismember(roiName, roiData.roiName) && ~isempty(currRoiData) && ~contains(currRoiData.roiName,'mid') && ~isempty(currRoiData.rawFl{1}) %temp addition 
                    % Get dF/F % not downsampled need to determine if this is matched accurately 
                    count = count + 1;
                    dff = {deltaFoverF(roiData, nTrial, roiName, p)};
                    Z = {Mad(roiData, nTrial, roiName, p)};
                    roiTime = roiData.time(1);
                    roiName = {roiName};
                    ZData_temp = table(roiName,roiTime, Z); 
                    dffData_temp = table(roiName,roiTime, dff); 
                end
                ZData = [ZData; ZData_temp];
                dffData = [dffData; dffData_temp];
            end
        end

        processed_data_dir = fullfile(parentDir,'processed_data');
        if ~exist(processed_data_dir, 'dir')
            mkdir(processed_data_dir)
        end

        save(fullfile(processed_data_dir,['df_f_down_Trial_00',num2str(nTrial),'.mat']), 'dffData','-v7.3');
        save(fullfile(processed_data_dir,['zscored_df_f__down_Trial_00',num2str(nTrial),'.mat']), 'ZData','-v7.3');


        end
    catch 
        foldersFailed{countFail} = parentDir;
        countFail = countFail + 1; 
    end
    end

   
    disp('-------Finished processing Data----------')
end    
    
    