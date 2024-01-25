function activityVSbehaviour_Summary_vyCue(summaryArray,meno)       
    edges_vy = [-200:10:200];
    edges_vy = [-5:1:10];
    edges_angle = [-180:10:180]; 
    
    threshold=3;
    trial_count = 1;
    
    trial_Cue_vy = [];
    trial_angle = [];
    trial_vf = []; 
    speed_sum = [];
    
    
    activity_values = [];

    summaryArray = summaryArray(~ismembertol(summaryArray.rho,1,10^-10),:); % gets rid of trials w/ no heading change --> indicates problem
    summaryArray = summaryArray(summaryArray.timeMov > 2,:); % only look at trials where fly's vel was above threshold for at least 5 seconds

%     if meno
%         summaryArray = summaryArray(summaryArray.rho > 0.5,:);
%     else
%         summaryArray = summaryArray(summaryArray.rho < 0.5,:);
%     end

    N_totalvyCue  = zeros(40,36);
    for trial = 1:size(summaryArray,1)
        try
        folder = table2array(summaryArray(trial,1)); 
        if strcmp(folder(end),'.')
            folder = folder(1:end-2); 
        end

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

%% Remove idx where the fly isn't moving
        total_mov_mm = abs(ftT.velFor{1}(summaryArray.Indices{trial}) + abs(ftT.velSide{1}(summaryArray.Indices{trial})) + abs(ftT.velYaw{1}(summaryArray.Indices{trial}))*4.5);
        no0vel_idx = find(total_mov_mm > threshold);
        vf = ftT.velFor{1}(summaryArray.Indices{trial});
        vf = vf(no0vel_idx); 
        vs = ftT.velSide{1}(summaryArray.Indices{trial});
        vs = vs(no0vel_idx); 
        vy = ftT.velYaw{1}(summaryArray.Indices{trial});
        vy = abs(vy(no0vel_idx)); 
        speed = sqrt(vf.^2 + vs.^2); 
        angle = ftT.cueAngle{1}(summaryArray.Indices{trial}); 
        angle = angle(no0vel_idx); 
        angle = wrapTo180(wrapTo180(angle)-wrapTo180(rad2deg(summaryArray.Goal(trial)))); 
        speed_sum = [speed_sum,speed'];

    %%

        sum_mean = cell(2); 
        vy = (vy/ (2*pi) ) * 360; 

        try
            trial_roiData = roiData(roiData.trialNum == nTrial,:);
        catch 
            if strcmp(region, 'LAL')
                trial_roiData = [1;2]; 
            elseif strcmp(region,'PB')
                trial_roiData = [1:10]';
            elseif strcmp(region,'FB')
                trial_roiData = [1:9]';
            end
            
        end
        sum_mean{1} = zeros(length(edges_angle)-1,1);
        sum_mean{2} = zeros(length(edges_angle)-1,1);

        activity = vy;

        % vy angle
        behaviour = angle; 
        [zscore, centers_angle, ~] = binData(activity, behaviour, edges_angle);
        sum_mean{1} = zscore; 

        activity = vf;

        % vy angle
        behaviour = angle; 
        [zscore, centers_angle, ~] = binData(activity, behaviour, edges_angle);
        sum_mean{2} = zscore; 
 
        trial_Cue_vy(trial_count,:) = sum_mean{1};
        trial_Cue_vf(trial_count,:) = sum_mean{2};

        trial_count = trial_count + 1; 
        
        catch
            disp(['folder ',folder,' failed'])
        end
    end  
          
%% lineplots    
%             allTrial_vf = var(trial_vf,[],3,'omitnan');
%             allTrial_vy = var(trial_vy,[],3,'omitnan');
%             allTrial_angle = var(trial_angle,[],3,'omitnan');
            
            SEM_Cue_vy = std(trial_Cue_vy,[],1,'omitnan') / sqrt(size(trial_Cue_vy,1));
            SEM_Cue_vf = std(trial_Cue_vf,[],1,'omitnan') / sqrt(size(trial_Cue_vf,1));
            
            aveTrial_Cue_vy = mean(trial_Cue_vy,1,'omitnan');
            aveTrial_Cue_vf = mean(trial_Cue_vf,1,'omitnan');
            
            figure();
            set(gcf,'color','w')
            set(gcf,'Renderer','painters')
            keepIndex = ~isnan(SEM_Cue_vy);
            SEMhigh = [aveTrial_Cue_vy(keepIndex) + SEM_Cue_vy(keepIndex)]; 
            SEMlow = [aveTrial_Cue_vy(keepIndex) - SEM_Cue_vy(keepIndex)];
            ax1 = subplot(2,1,1);
            hold on
            plot(centers_angle, aveTrial_Cue_vy,'k')
            patch([centers_angle(keepIndex) fliplr(centers_angle(keepIndex))],[SEMhigh fliplr(SEMlow)],[0.75,0.75,0.75],'FaceAlpha',0.25,'EdgeColor','none')
            ylabel('|vy| (deg/s)')
            xlabel('cue pos rel to goal')
            
            set(gcf,'color','w')
            set(gcf,'Renderer','painters')
            keepIndex = ~isnan(SEM_Cue_vf);
            SEMhigh = [aveTrial_Cue_vf(keepIndex) + SEM_Cue_vf(keepIndex)]; 
            SEMlow = [aveTrial_Cue_vf(keepIndex) - SEM_Cue_vf(keepIndex)];
            ax2 = subplot(2,1,2);
            hold on
            plot(centers_angle, aveTrial_Cue_vf,'k')
            patch([centers_angle(keepIndex) fliplr(centers_angle(keepIndex))],[SEMhigh fliplr(SEMlow)],[0.75,0.75,0.75],'FaceAlpha',0.25,'EdgeColor','none')
            ylabel('vf (mm/s)')
            xlabel('cue pos rel to goal')

%     if savePlots == 1
%         saveas(z, fullfile(lineplotDir,[expID,'_',num2str(nTrial),'_zScore_behaviour_no0vel.fig']));
%     end
end