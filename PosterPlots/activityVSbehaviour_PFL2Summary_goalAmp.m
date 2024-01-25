function activityVSbehaviour_PFL2Summary_goalAmp(rootDir)       
    folders = get_folders(rootDir,1,0);   
    
    for f = 1:size(folders,1)
        [start,finish] = regexp(string(folders(f).folder),'_fly');
        dateIdx = regexp(string(folders(f).folder),'\');
        dateIdx = [dateIdx(3)+1:dateIdx(4)-1]; 
        date = folders(f).folder;
        date = date(dateIdx);
        if isempty(finish)
            [start,finish] = regexp(string(folders(f).folder),'_Fly');
        end
        fly = string(folders(f).folder(start:finish + 1));
        flyID = strcat(date,fly);
        flies(f) = flyID;
    end
        flies = flies';
        uniqueFlies = unique(flies); 
        flyCount = zeros(size(folders));
        for fly = 1:length(uniqueFlies)
            flyCount(flies == uniqueFlies(fly)) = fly;
        end

    edges_vy = [-200:10:200];
    edges_vf = [-4:1:10];
    edges_rho = [0:0.1:1]; 
    
    threshold=3;
    trial_count = 1;
    
    trial_vy = [];
    trial_rho = [];
    trial_vf = []; 
    speed_sum = [];
    activity_values = [];

%     N_totalCue  = zeros(14,36);
%     N_totalvy = zeros(14,40);
    for f = 1:length(folders) 
        if isempty(regexp(folders(f).folder,'LAL'))
            try
             folder = folders(f).folder;
            if strcmp(folder(end),'.')
                folder = folder(1:end-2);
            end
            
            fly = flyCount(f); 

            expID = get_expID(folder);
            expList = {expID};

            %[~,ftT, ~] = load_ft_data(expList, folder, 1, 0);

            %Load metadata 
            [~, trialMd] = load_metadata(expList, folder);

            %Load imaging data
            roiData = load_roi_data(expList, folder);

            processedData_dir = fullfile(folder,'processed_data');
            nTrial = 1;

            data_filelist = dir(processedData_dir);
            for files = 1:length(data_filelist)
                if regexp(data_filelist(files).name,'.mat') & regexp(data_filelist(files).name,['00',num2str(nTrial)])
                    load(fullfile(processedData_dir,data_filelist(files).name));
                end
                load(fullfile(processedData_dir,'PFL2_fit_params_estGoal_withJump_down_goalOffset.mat'))
            end

            ftT = ftT_down;
    % Remove idx where the fly isn't moving
            total_mov_mm = abs(ftT.velFor{1}) + abs(ftT.velSide{1}) + abs(ftT.velYaw{1})*4.5;
            no0vel_idx = find(total_mov_mm > threshold);
            vf = ftT.velFor{1};
            vf = vf(no0vel_idx); 
            vs = ftT.velSide{1};
            vs = vs(no0vel_idx); 
            vy = ftT.velYaw{1};
            vy = vy(no0vel_idx); 
            speed = sqrt(vf.^2 + vs.^2); 
    %         angle = ftT.cueAngle{1}; 
    %         angle = angle(no0vel_idx); 
    %         angle = wrapTo180(wrapTo180(angle)-wrapTo180(rad2deg(summaryArray.Goal(trial)))); 
            speed_sum = [speed_sum,speed'];

        %% calculate rho
        sampRate = trialMd.volumeRate;

        [jump_array,~, ~] = detect_jumps(ftT, 10, sampRate,1);
        jump_idx = [];
        for jump = 1:size(jump_array,1)
            jump_idx = [jump_idx , jump_array(jump,2):jump_array(jump,3)];
        end
        window = 30; 
        window = round(window * sampRate); % mult by samp rate

            for i = 1:length(ftT_down.velFor{1})
                idx = i - round(window/2):i + round(window/2); 
                if idx(end) > length(ftT_down.cueAngle{1})
                    idx = idx(1):1:length(ftT_down.cueAngle{1});
                elseif idx(1) < 1 
                    idx = 1:idx(end); 
                end
                if sum(ismember(idx, jump_idx)) % remove idx from window that were influenced by jumps
                    badIdx = ismember(idx, jump_idx);
                    idx = idx(badIdx == 0);
                end
                    angle_temp = ftT_down.cueAngle{1}(idx); 
                    speed_temp = total_mov_mm(idx); 
                    angles_flyFor = angle_temp(speed_temp > threshold); 
                    if ~isempty(angles_flyFor) 
                        x = cosd(angles_flyFor); 
                        y = sind(angles_flyFor); 
                        mean_headingVectors(1,i)= sum(x)/length(x); 
                        mean_headingVectors(2,i)= sum(y)/length(y);
                    else
                        mean_headingVectors(1,i)= nan; 
                        mean_headingVectors(2,i)= nan; 
                    end
            end
            %est_goal = atan2(mean_headingVectors(2,:),mean_headingVectors(1,:)); 
            rho_all = sqrt(mean_headingVectors(1,:).^2 + mean_headingVectors(2,:).^2);
            rho = rho_all(no0vel_idx);
            rho = rho';
            


        %%

            sum_mean = cell(3,1); 
            vy = (vy/ (2*pi) ) * 360; 

%             try
%                 trial_roiData = roiData(roiData.trialNum == nTrial,:);
%             catch 
%                 if strcmp(region, 'LAL')
%                     trial_roiData = [1;2]; 
%                 elseif strcmp(region,'PB')
%                     trial_roiData = [1:10]';
%                 elseif strcmp(region,'FB')
%                     trial_roiData = [1:9]';
%                 end
% 
%             end

            sum_mean{1} = zeros(length(edges_vy)-1,1);
            sum_mean{2} = zeros(length(edges_vf)-1,1);
            sum_mean{3} = zeros(length(edges_rho)-1,1);

            activity = PFL2fit_params.goalAmp;
            activity = activity(no0vel_idx);
            activity = activity';
            activity = PFL2fit_params.rs(no0vel_idx)';

            %vf 
            behaviour = vf; 
            [zscore, centers_vf, ~] = binData(activity, behaviour, edges_vf);
            sum_mean{2} = zscore;

            %vy 
             behaviour = vy; 
            [zscore, centers_vy, ~] = binData(activity, behaviour, edges_vy);
            sum_mean{1} = zscore; 

            %rho
            [zscore, centers_rho, ~] = binData(activity, rho, edges_rho);
            sum_mean{3} = zscore; 

    %         [N_vy, vy_vf_activity, heatvy_centers, heatvf_centers] = create_activity_heatmap(vy, vf, activity, edges_vy, edges_vf);
    %         [N_Cue, angle_vf_activity, heatangle_centers, heatvf_centers] = create_activity_heatmap(angle, vf, activity, edges_angle, edges_vf);
    %         trial_vf_vy(trial_count,:,:) = vy_vf_activity;
    %         trial_vf_angle(trial_count,:,:) = angle_vf_activity;
    %         N_totalCue = N_totalCue + N_Cue;
    %         N_totalvy = N_totalvy + N_vy;

            trial_vf(fly,trial_count,:) = sum_mean{2};
            trial_vy(fly, trial_count,:) = sum_mean{1};
            trial_rho(fly,trial_count,:) = sum_mean{3};

            trial_count = trial_count + 1; 

            catch
                disp(['folder ',folder,' failed'])
                trial_vf(fly,trial_count,:) = nan;
                trial_vy(fly, trial_count,:) = nan;
                trial_rho(fly,trial_count,:) = nan;
                trial_count = trial_count + 1;
            end
        end
    end  
% heatmaps    
            
%             trial_vf_vy(trial_vf_vy == 0) = nan; 
%             trial_vf_angle(trial_vf_angle == 0) = nan; 

            trial_vf(trial_vf == 0) = nan; 
            trial_vy(trial_vy == 0) = nan; 
            trial_rho(trial_rho == 0) = nan; 


%             aveTrial_vy_vf = squeeze(mean(trial_vf_vy,1,'omitnan'));
%             aveTrial_angle_vf = squeeze(mean(trial_vf_angle,1,'omitnan'));
%             greyBins = N_totalvy < 100 ;
%             aveTrial_vy_vf(aveTrial_vy_vf == 0) = nan;
%             aveTrial_vy_vf(greyBins) = nan; 
%             ncol = length(unique(aveTrial_vy_vf));
%             color = flipud(cbrewer2('RdYlBu', ncol));
%             figure();
%             set(gcf,'color','w')
%             set(gcf,'renderer','painters')
%             subplot(2,1,1);
%             s = pcolor(aveTrial_vy_vf);
%             colormap(color)
%             hold on
% 
%             greyBins(greyBins == 0) = nan; 
%             pcolor(greyBins)
%             cmap = ['none',0.5,0.5,0.5;]
%             
%             
%             ylabel('Vf mm/s')
%             xt = linspace(1,numel(heatvy_centers),7);                            
%             xtlbl = linspace(heatvy_centers(xt(1)), heatvy_centers(xt(end)), 7);   
%             set(gca, 'XTick',xt, 'XTickLabel',xtlbl)
%             xlabel('Vy deg/s')
%             colorbar
%             yt = linspace(1,numel(heatvf_centers),5); 
%             ytlbl = linspace(heatvf_centers(yt(1)), heatvf_centers(yt(end)), 5);
%             set(gca, 'YTick',yt, 'YTickLabel',ytlbl)
%             set(s, 'EdgeColor', 'none');
%             set(gca,'color','none')
%             box off
%             
%             greyBins = N_totalCue < 100 ;
%             aveTrial_angle_vf(aveTrial_angle_vf == 0) = nan;
%             aveTrial_angle_vf(greyBins) = nan;
%             ncol = length(unique(aveTrial_angle_vf));
%             color = flipud(cbrewer2('RdYlBu', ncol));
%             subplot(2,1,2);
%             s = pcolor(aveTrial_angle_vf); 
%             colormap(color)
%             ylabel('Vf mm/s')
%             xt = linspace(1,numel(heatangle_centers),5);                            
%             xtlbl = linspace(heatangle_centers(xt(1)), heatangle_centers(xt(end)), 5);   
%             set(gca, 'XTick',xt, 'XTickLabel',xtlbl)
%             xlabel('cue pos rel to goal')
%             colorbar
%             yt = linspace(1,numel(heatvf_centers),5); 
%             ytlbl = linspace(heatvf_centers(yt(1)), heatvf_centers(yt(end)), 5);
%             set(gca, 'YTick',yt, 'YTickLabel',ytlbl)
%             set(s, 'EdgeColor', 'none');
%             set(gca,'color','none')
%             box off
            
             
% lineplots    
%             allTrial_vf = var(trial_vf,[],3,'omitnan');
%             allTrial_vy = var(trial_vy,[],3,'omitnan');
%             allTrial_angle = var(trial_rho,[],3,'omitnan');
            
            aveFly_trial_vf =  squeeze(mean(trial_vf,2,'omitnan'));
            aveFly_trial_vy =  squeeze(mean(trial_vy,2,'omitnan'));
            aveFly_trial_rho =  squeeze(mean(trial_rho,2,'omitnan'));
            
            SEM_vf = std(aveFly_trial_vf,[],1,'omitnan') / sqrt(size(aveFly_trial_vf,1));
            SEM_vy = std(aveFly_trial_vy,[],1,'omitnan') / sqrt(size(aveFly_trial_vy,1));
            SEM_rho = std(aveFly_trial_rho,[],1,'omitnan') / sqrt(size(aveFly_trial_rho,1));
            
            aveTrial_vf = mean(aveFly_trial_vf,1,'omitnan');
            aveTrial_vy = mean(aveFly_trial_vy,1,'omitnan');
            aveTrial_rho = mean(aveFly_trial_rho,1,'omitnan');
            
            
            figure();
            set(gcf,'color','w')
            set(gcf,'Renderer','painters')
            keepIndex = ~isnan(SEM_vy);
            SEMhigh = [aveTrial_vy(keepIndex) + SEM_vy(keepIndex)]; 
            SEMlow = [aveTrial_vy(keepIndex) - SEM_vy(keepIndex)];
            ax1 = subplot(2,1,1);
            hold on
            plot(centers_vy, aveTrial_vy,'b')
            patch([centers_vy(keepIndex) fliplr(centers_vy(keepIndex))],[SEMhigh fliplr(SEMlow)],[0,0,0.75],'FaceAlpha',0.25,'EdgeColor','none')
            xlabel('vy (deg/s)')
            ylabel('goal amplitude')
            
            set(gcf,'color','w')
            set(gcf,'Renderer','painters')
            keepIndex = ~isnan(SEM_vf);
            SEMhigh = [aveTrial_vf(keepIndex) + SEM_vf(keepIndex)]; 
            SEMlow = [aveTrial_vf(keepIndex) - SEM_vf(keepIndex)];
            ax3 = subplot(2,1,2);
            hold on
            plot(centers_vf, aveTrial_vf,'b')
            patch([centers_vf(keepIndex) fliplr(centers_vf(keepIndex))],[SEMhigh fliplr(SEMlow)],[0,0,0.75],'FaceAlpha',0.25,'EdgeColor','none')
            xlabel('vf (mm/s)')
            ylabel('goal amplitude')
            ax3.YAxis.Exponent = 0;
            
            keepIndex = ~isnan(SEM_rho);
            SEMhigh = [aveTrial_rho(keepIndex) + SEM_rho(keepIndex)]; 
            SEMlow = [aveTrial_rho(keepIndex) - SEM_rho(keepIndex)];
            %ax2 = subplot(3,1,3);
            figure();
            set(gcf,'color','w')
            set(gcf,'Renderer','painters')
            hold on
            plot(centers_rho, aveTrial_rho,'k')
            patch([centers_rho(keepIndex) fliplr(centers_rho(keepIndex))],[SEMhigh fliplr(SEMlow)],[0.75,0.75,0.75],'FaceAlpha',0.25,'EdgeColor','none')
            ax1.YAxis.Exponent = 0;
            ax2.YAxis.Exponent = 0;
            xlabel('rho')
            ylabel('R')

            

%     if savePlots == 1
%         saveas(z, fullfile(lineplotDir,[expID,'_',num2str(nTrial),'_goalAmp_behaviour_no0vel.fig']));
%     end
end