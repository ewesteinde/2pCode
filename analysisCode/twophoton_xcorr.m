folders = get_folders(rootDir);

folderNum = length(folders);
fprintf(1, '##### Found %d potential experiment folders to process...#####\n', folderNum);
for ff = 1:folderNum
      
      %% Get folder information
      folder = folders(ff).folder;
%% Load in fictrac & ROI data

    processedData_dir = fullfile(folder,'processed_data');
    if ~exist(processedData_dir,'dir')
        process2p_fictrac_data(rootDir)
    end

    % Get data files
    expID = get_expID(folder);
    expList = {expID};

    % Load metadata 
    [expMd, trialMd] = load_metadata(expList, folder);

    % Load FicTrac data
    ftData = load_ft_data(expList, folder);

    % Load panels metadata
    panelsMetadata = load_panels_metadata(expList, folder);


    numTrials = size(trialMd,1); 
    %%
    for nTrial = 1:numTrials
        
        data_filelist = dir(processedData_dir);
        for files = 1:length(data_filelist)
            if regexp(data_filelist(files).name,'.mat') & regexp(data_filelist(files).name,['00',num2str(nTrial)])
                load(fullfile(processedData_dir,data_filelist(files).name));
            end
        end

    yaw_vel = ftData.yawSpeed{1};
    angle = ftT_down.cueAngle{1};
    L = Z.data(Z.roiName == 1); 
    R = Z.data(Z.roiName == 2); 
    L_minus_R = L - R; 
    
    figure(2);clf;
    yyaxis left; 
    plot(smoothdata(L_minus_R - median(L_minus_R),1,'loess',10)); 
    yline(0)
    yyaxis right;
    plot(angle)
    %plot(smoothdata(yaw_vel,1,'loess',30),'-g'); 
    yline(0)
    %yyaxis right; 
    %plot(unwrap(angle)); 
    
    [R_corr, R_lag] = xcorr(ftT_down.cueAngle{1},R);
    
    figure();clf;
    plot(R_lag/trialMd.volumeRate,R_corr)

        
        
    end
end