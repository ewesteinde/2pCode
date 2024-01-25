PFL3 = 0; 
PFL2 = 1; 

folders = get_folders(rootDir, PFL2, PFL3);
count = 1; 

for f = 1:size(folders,1)
    folder = folders(f).folder; 
    if contains(folder,'FB') || contains(folder,'PB')
        region = folder(end-1:end);
        
        if strcmp(folder(end),'.')
            folder = folder(1:end-2); 
        end

        try

        expID = get_expID(folder);
        expList = {expID};

        % Load metadata 
        [expMd, trialMd] = load_metadata(expList, folder);

        % Load imaging data
        roiData = load_roi_data(expList, folder);

        processedData_dir = fullfile(folder,'processed_data');
        try
            numTrials = max(size(unique(roiData.trialNum),1),length(trialMd.trialNum));
        catch
            numTrials = 1; 
        end

        for nTrial = 1:numTrials

            data_filelist = dir(processedData_dir);
            for files = 1:length(data_filelist)
                if regexp(data_filelist(files).name,'.mat') & regexp(data_filelist(files).name,['00',num2str(nTrial)])
                    load(fullfile(processedData_dir,data_filelist(files).name));
                end
                load(fullfile(processedData_dir,['zscored_df_f__down_Trial_00',num2str(nTrial),'.mat']));
            end

    %%

            x_range = [0,2*pi];

            activity = [];
            for roi = 1:size(ZData,1)
                activity(roi,:) = ZData.Z{roi};
            end

            minZ = min(activity,[],[1, 2]);
            if minZ < 0 % I think the Z score better compensates for the unequal baseline F across ROIs but the fit doesn't work with negative values
                activity = activity + abs(minZ);
            end
            %bump_params = fit_von_Mises(activity, x_range, 0);
            bump_params_down = fit_sinusoid(activity, x_range, 0);

            %% Offset calculation

            %we will compute and define the offset as the
            %circular distance between the bump's position and the fly's heading
            fly_pos_rad = wrapToPi(deg2rad(ftT_down.cueAngle{1}));
            offset = wrapTo180(rad2deg(circ_dist(bump_params_down.pos_rad,-fly_pos_rad)));
            bump_params.offset = offset; 
            offset(bump_params.adj_rs < 0.1) = nan; 

            save(fullfile(processedData_dir,['bump_parameters_down_Trial00',num2str(nTrial),'.mat']),'bump_params')

            %plotBumpParameters(folder,dffData, ftT, nTrial, bump_params)
        end
        catch
            failedFolders{count} = folder; 
            disp(['Folder failed: ',folder])
            count= count + 1; 
        end
    end
end
