%% plot PFL3 summaries dependent on Meno vs not menotaxing 

function activityVSbehaviour_PFL3crossCor(summaryArray_all,meno)
    fcount = 1;
    summaryArray = summaryArray_all(contains(summaryArray_all.Folder,'LAL'),:);  
    
    summaryArray = summaryArray(~ismembertol(summaryArray.rho,1,10^-10),:); % gets rid of trials w/ no heading change --> indicates problem
    summaryArray = summaryArray(summaryArray.timeMov > 5,:); % only look at trials where fly's vel was above threshold for at least 5 seconds

%     if meno
%         summaryArray = summaryArray(summaryArray.rho > 0.5,:);
%     else
%         summaryArray = summaryArray(summaryArray.rho < 0.5,:);
%     end
    
    all_folders = summaryArray.Folder;
    for f = 1:size(all_folders,1)
        [start,finish] = regexp(all_folders(f),'_fly', 'ignorecase');
        dateIdx = regexp(all_folders(f),'\');
        dateIdx = [dateIdx(3)+1:dateIdx(4)-1]; 
        Date = char(all_folders(f));
        Date = Date(dateIdx);
        if isempty(finish)
            [start,finish] = regexp(all_folders(f),'_Fly');
        end
        fly_temp = char(all_folders(f));
        fly = fly_temp(start:finish + 1);
        flyID = strcat(Date,fly);
        flies(f) = string(flyID);
    end
    
    flies = flies';
    uniqueFlies = unique(flies); 
    flyCount = zeros(size(all_folders));
    for fly = 1:length(uniqueFlies)
        flyCount(flies == uniqueFlies(fly)) = fly;
    end
    
    trial_corr = cell(size(uniqueFlies));
    
        
        N_totalCue  = zeros(2,14,36);
        N_totalvy = zeros(2,14,40);

    for trial = 1:size(summaryArray,1)
        try
        folder = table2array(summaryArray(trial,1)); 
        if strcmp(folder(end),'.')
            folder = folder(1:end-2); 
        end
        
        fly = flyCount(trial);

        expID = get_expID(folder);
        expList = {expID};

        [~,ftT, ~] = load_ft_data(expList, folder, 1, 0);

        % Load metadata 
        [expMd, trialMd] = load_metadata(expList, folder);

        % Load imaging data
        roiData = load_roi_data(expList, folder);

        processedData_dir = fullfile(folder,'processed_data');
        nTrial = summaryArray.numTrial(trial);
        
        data_filelist = dir(processedData_dir);
        for files = 1:length(data_filelist)
            if regexp(data_filelist(files).name,'.mat') & regexp(data_filelist(files).name,['00',num2str(nTrial)])
                load(fullfile(processedData_dir,data_filelist(files).name));
            end
        end
        
        activity = ZData.(3){2}(summaryArray.Indices{trial}) - ZData.(3){1}(summaryArray.Indices{trial});% R - L
        vy = ftT.velYaw{1}(summaryArray.Indices{trial});
        angle = - wrapTo180(wrapTo180(ftT.cueAngle{1}(summaryArray.Indices{trial}))-wrapTo180(rad2deg(summaryArray.Goal(trial)))); %directional error
        
        lag = 1 * 60; % seconds
        c = xcorr(activity,vy,lag);
        
        timeLags = linspace(-1,1,121);
        
%         figure();
%         plot(timeLags,c)
        
        trialCount = size(trial_corr{fly},1);
        trialCount = trialCount + 1; 
        
        trial_corr{fly}(trialCount,:) = (c - min(c))/(max(c)-min(c)); 
        
        catch
            disp(['folder ',folder,' failed'])
            failedFolders{fcount} = folder; 
            fcount = fcount + 1; 
            trialCount = size(trial_corr{fly},1);
            trialCount = trialCount + 1; 
            trial_corr{fly}(trialCount,:) = nan(lag*2 + 1,1);
        end
    end
    
    corrCount = 1; 
    for t = 1:size(trial_corr,1)
        if ~isempty(trial_corr{t})
            ave = squeeze(mean(trial_corr{t},1,'omitnan'));
            flyAve_corr(corrCount,:) = ave;%(ave - min(ave))/(max(ave)-min(ave));
            corrCount = corrCount + 1;
        end
    end
    
    figure()
    plot(timeLags,flyAve_corr)
    hold on 
    plot(timeLags,mean(flyAve_corr,1,'omitnan'),'k','LineWidth',1.5)
    

end