function activityVSbehaviour_PFL2Summary_mean(summaryArray_all,meno,regions, data)       
    edges_vy = [-200:10:200];
    edges_vf = [-4:1:10];
    edges_angle = [-180:10:180]; 
    
    threshold=3;
    trial_count = 1;
    
    trial_vy = [];
    trial_angle = [];
    trial_vf = []; 
    speed_sum = [];
    
for r = 1:length(regions)
    region = regions{r};
    
    if strcmp(region, 'LAL')
        summaryArray = summaryArray_all(contains(summaryArray_all.Folder,'LAL'),:);
        roiNum = 2; 
    elseif strcmp(region,'PB')
        summaryArray = summaryArray_all(contains(summaryArray_all.Folder,'PB'),:);
        roiNum = 10; 
    elseif strcmp(region,'FB')
        summaryArray = summaryArray_all(contains(summaryArray_all.Folder,'FB'),:);
        roiNum = 9; 
    end
    
    activity_values = [];

    summaryArray = summaryArray(~ismembertol(summaryArray.rho,1,10^-10),:); % gets rid of trials w/ no heading change --> indicates problem
    summaryArray = summaryArray(summaryArray.timeMov > 2,:); % only look at trials where fly's vel was above threshold for at least 5 seconds

    if meno
        summaryArray = summaryArray(summaryArray.rho > 0.5,:);
    else
        summaryArray = summaryArray(summaryArray.rho < 0.5,:);
    end

    
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
        vy = vy(no0vel_idx); 
        speed = sqrt(vf.^2 + vs.^2); 
        angle = ftT.cueAngle{1}(summaryArray.Indices{trial}); 
        angle = angle(no0vel_idx); 
        angle = wrapTo180(wrapTo180(angle)-wrapTo180(rad2deg(summaryArray.Goal(trial)))); 
        speed_sum = [speed_sum,speed'];

    %%

        sum_mean = cell(3,1); 
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

        sum_mean{1} = zeros(length(edges_vy)-1,1);
        sum_mean{2} = zeros(length(edges_angle)-1,1);
        sum_mean{3} = zeros(length(edges_vf)-1,1);

        if strcmp(data,'Z')
            activityTable = ZData; 
        else
            activityTable = dffData;
        end
        
        activity_temp = zeros(size(angle));
        for roi = 1:size(trial_roiData,1)
                activity = activityTable.(3){roi}(summaryArray.Indices{trial});
                activity = activity(no0vel_idx);
                activity_temp =  activity_temp + activity;

                % vf 
                behaviour = vf; 
                [zscore, centers_vf, ~] = binData(activity, behaviour, edges_vf);
                sum_mean{3}(:,roi) = zscore;
                
                % vy 
                 behaviour = vy; 
                [zscore, centers_vy, ~] = binData(activity, behaviour, edges_vy);
                sum_mean{1}(:,roi) = zscore; 
                

                % angle
                [zscore, centers_angle, ~] = binData(activity, angle, edges_angle);
                sum_mean{2}(:,roi) = zscore; 
                

        end
        
        activity_values = activity_temp/roiNum;
        
        [~, vy_vf_activity, heatvy_centers, heatvf_centers] = create_activity_heatmap(vy, vf, activity_values, edges_vy, edges_vf);
        [~, angle_vf_activity, heatangle_centers, heatvf_centers] = create_activity_heatmap(angle, vf, activity_values, edges_angle, edges_vf);
        trial_vf_vy(trial_count,:,:) = vy_vf_activity;
        trial_vf_angle(trial_count,:,:) = angle_vf_activity;
        
        trial_vf(trial_count,:) = mean(sum_mean{3},2,'omitnan');
        trial_vy(trial_count,:) = mean(sum_mean{1},2,'omitnan');
        trial_angle(trial_count,:) = mean(sum_mean{2},2,'omitnan');

        trial_count = trial_count + 1; 
        
        catch
            disp(['folder ',folder,' failed'])
        end
    end  
end

%% heatmaps    
            
            trial_vf_vy(trial_vf_vy == 0) = nan; 
            trial_vf_angle(trial_vf_angle == 0) = nan; 

            trial_vf(trial_vf == 0) = nan; 
            trial_vy(trial_vy == 0) = nan; 
            trial_angle(trial_angle == 0) = nan; 


            aveTrial_vy_vf = squeeze(mean(trial_vf_vy,1,'omitnan'));
            aveTrial_angle_vf = squeeze(mean(trial_vf_angle,1,'omitnan'));
            
            aveTrial_vy_vf(aveTrial_vy_vf == 0) = nan;
            ncol = length(unique(aveTrial_vy_vf));
            color = flipud(cbrewer2('RdYlBu', ncol));
            figure();
            set(gcf,'color','w')
            set(gcf,'renderer','painters')
            subplot(2,1,1);
            s = pcolor(aveTrial_vy_vf); 
            colormap(color)
            ylabel('Vf mm/s')
            xt = linspace(1,numel(heatvy_centers),7);                            
            xtlbl = linspace(heatvy_centers(xt(1)), heatvy_centers(xt(end)), 7);   
            set(gca, 'XTick',xt, 'XTickLabel',xtlbl)
            xlabel('Vy deg/s')
            colorbar
            yt = linspace(1,numel(heatvf_centers),5); 
            ytlbl = linspace(heatvf_centers(yt(1)), heatvf_centers(yt(end)), 5);
            set(gca, 'YTick',yt, 'YTickLabel',ytlbl)
            set(s, 'EdgeColor', 'none');
            set(gca,'color','none')
            box off
            
            aveTrial_angle_vf(aveTrial_angle_vf == 0) = nan;
            ncol = length(unique(aveTrial_angle_vf));
            color = flipud(cbrewer2('RdYlBu', ncol));
            subplot(2,1,2);
            s = pcolor(aveTrial_angle_vf); 
            colormap(color)
            ylabel('Vf mm/s')
            xt = linspace(1,numel(heatangle_centers),5);                            
            xtlbl = linspace(heatangle_centers(xt(1)), heatangle_centers(xt(end)), 5);   
            set(gca, 'XTick',xt, 'XTickLabel',xtlbl)
            xlabel('cue pos rel to goal')
            colorbar
            yt = linspace(1,numel(heatvf_centers),5); 
            ytlbl = linspace(heatvf_centers(yt(1)), heatvf_centers(yt(end)), 5);
            set(gca, 'YTick',yt, 'YTickLabel',ytlbl)
            set(s, 'EdgeColor', 'none');
            set(gca,'color','none')
            box off
            
             
%% lineplots    
%             allTrial_vf = var(trial_vf,[],3,'omitnan');
%             allTrial_vy = var(trial_vy,[],3,'omitnan');
%             allTrial_angle = var(trial_angle,[],3,'omitnan');
            
            SEM_vf = std(trial_vf,[],1,'omitnan') / sqrt(size(trial_vf,1));
            SEM_vy = std(trial_vy,[],1,'omitnan') / sqrt(size(trial_vy,1));
            SEM_angle = std(trial_angle,[],1,'omitnan') / sqrt(size(trial_angle,1));
            
            aveTrial_vf = mean(trial_vf,1,'omitnan');
            aveTrial_vy = mean(trial_vy,1,'omitnan');
            aveTrial_angle = mean(trial_angle,1,'omitnan');
            
            
            figure();
            set(gcf,'color','w')
            set(gcf,'Renderer','painters')
            keepIndex = ~isnan(SEM_vy);
            SEMhigh = [aveTrial_vy(keepIndex) + SEM_vy(keepIndex)]; 
            SEMlow = [aveTrial_vy(keepIndex) - SEM_vy(keepIndex)];
            ax1 = subplot(3,1,1);
            hold on
            plot(centers_vy, aveTrial_vy,'b')
            patch([centers_vy(keepIndex) fliplr(centers_vy(keepIndex))],[SEMhigh fliplr(SEMlow)],[0,0,0.75],'FaceAlpha',0.25,'EdgeColor','none')
            xlabel('vy (deg/s)')
            ylabel(data)
            
            
            keepIndex = ~isnan(SEM_angle);
            SEMhigh = [aveTrial_angle(keepIndex) + SEM_angle(keepIndex)]; 
            SEMlow = [aveTrial_angle(keepIndex) - SEM_angle(keepIndex)];
            ax2 = subplot(3,1,2);
            hold on
            plot(centers_angle, aveTrial_angle,'b')
            patch([centers_angle(keepIndex) fliplr(centers_angle(keepIndex))],[SEMhigh fliplr(SEMlow)],[0,0,0.75],'FaceAlpha',0.25,'EdgeColor','none')
            ax1.YAxis.Exponent = 0;
            ax2.YAxis.Exponent = 0;
            xlabel('cue pos rel goal')
            ylabel(data)

            set(gcf,'color','w')
            set(gcf,'Renderer','painters')
            keepIndex = ~isnan(SEM_vf);
            SEMhigh = [aveTrial_vf(keepIndex) + SEM_vf(keepIndex)]; 
            SEMlow = [aveTrial_vf(keepIndex) - SEM_vf(keepIndex)];
            ax3 = subplot(3,1,3);
            hold on
            plot(centers_vf, aveTrial_vf,'b')
            patch([centers_vf(keepIndex) fliplr(centers_vf(keepIndex))],[SEMhigh fliplr(SEMlow)],[0,0,0.75],'FaceAlpha',0.25,'EdgeColor','none')
            xlabel('vf (mm/s)')
            ylabel(data)
            ax3.YAxis.Exponent = 0;

%     if savePlots == 1
%         saveas(z, fullfile(lineplotDir,[expID,'_',num2str(nTrial),'_zScore_behaviour_no0vel.fig']));
%     end
end