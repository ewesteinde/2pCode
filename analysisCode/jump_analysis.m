 %% get folders from rootDir
folders = get_folders(rootDir);

%% Process each folder
folderNum = length(folders);
fprintf(1, '##### Found %d potential experiment folders to process...#####\n', folderNum);
for ff = 1:folderNum

  %% Get folder information
  folder = folders(ff).folder;

%% Load in fictrac & ROI data
    if strcmp(folder(end),'.')
        folder = folder(1:end-2); 
    end
    
            jumpDir = fullfile(folder,'images','jump_plots');
            if ~exist(jumpDir, 'dir')
                mkdir(jumpDir)
            end

             processedData_dir = fullfile(folder,'processed_data');

            % Get data files
            expID = get_expID(folder);
            expList = {expID};

            % Load metadata 
            [expMd, trialMd] = load_metadata(expList, folder);

            % Load imaging data
            roiData = load_roi_data(expList, folder);

            % Load FicTrac data
            [~,ftData, ~] = load_ft_data(expList, folder, 1, 0);

            % Load panels metadata
            panelsMetadata = load_panels_metadata(expList, folder);


            numTrials = max(size(unique(roiData.trialNum),1),length(trialMd.trialNum)); 
        %%
        for nTrial = 1:numTrials
            
            %% get processed data

            data_filelist = dir(processedData_dir);
            for files = 1:length(data_filelist)
                if regexp(data_filelist(files).name,'.mat') & regexp(data_filelist(files).name,['00',num2str(nTrial)])
                    load(fullfile(processedData_dir,data_filelist(files).name));
                end
            end

            roiNames = roiData.roiName;
            
            %% locate jump idxs & start & end indicies of a window around them
            windowSize = 10;
            [jump_array_down, jump_array] = detect_jumps(roiData, ftT_down, ftData, windowSize);
            
            savePlots = 0; 
            plot_jumps(jump_array, jump_array_down, Z, ftData, expID, nTrial, jumpDir, roiData, windowSize, savePlots);
            
            
            
        end

end