function gatherFlyHeadings(rootDir, PFL3, PFL2)
    filelist = dir(fullfile(rootDir, '**/*.*'));  % get list of files and folders in any subfolder
    filelist = filelist(~[filelist.isdir]);
    correct = []; 
    for f = 1:length(filelist)
        baseFolderName = filelist(f).name;
        if PFL3
            if regexp(baseFolderName,'PFL3') & regexp(baseFolderName,'headingSummary')
                present = 1;
            else
                present = 0;
            end
            correct(end+1) = present;
        elseif PFL2
            if regexp(baseFolderName,'PFL2') & regexp(baseFolderName,'headingSummary')
                present = 1;
            else
                present = 0;
            end
            correct(end+1) = present;
        else
            if regexp(baseFolderName,'headingSummary')
                present = 1;
            else
                present = 0;
            end
            correct(end+1) = present;
        end
    end
    summaries = filelist(logical(correct));
    sumCount = 1; 
    %topTrials = []; 
    for s = 1:length(summaries)
        load(fullfile(summaries(s).folder,summaries(s).name)); 
        flySum = flySum(~ismembertol(flySum.rhoTotal,1,10^-10),:); % gets rid of trials w/ no heading change --> indicates problem
        flySum = flySum(flySum.perMove > 10,:); % only look at trials where fly's vel was above threshold for at least 5% of the trial (30 sec)
        if ~isempty(flySum)
            for f = 1:size(flySum,1)
                flySum.ranking(f) = flySum.rhoTotal(f);%*flySum.perMove(f); 
            end
            trialNameidx = cell2mat(regexp(flySum.folder(flySum.ranking == max(flySum.ranking)),'\'));
            topTrialFolder_old = cell2mat(flySum.folder(flySum.ranking == max(flySum.ranking)));
            topTrialFolder = fullfile(summaries(s).folder,topTrialFolder_old(trialNameidx(end)+1:end));
            flySum.folder(flySum.ranking == max(flySum.ranking)) = {topTrialFolder}; 
            topTrials(sumCount,:) = flySum(flySum.ranking == max(flySum.ranking),:);
            sumCount = sumCount + 1;
            %topTrials = [topTrials;flySum];
        end
    end
    
    
%% plot ave trial headings    
     C = [zeros(size(topTrials.rhoTotal)) zeros(size(topTrials.rhoTotal)), topTrials.rhoTotal];
    CC = turbo(numel(topTrials.rhoTotal));
    sz = topTrials.rhoTotal*200;
    figure();
    set(gcf,'Renderer','painters')
    set(gcf,'color','w')
    polarplot(topTrials.thetaTotal,topTrials.rhoTotal);
    ax = gca;
    rlim([0,1])
    hold on
    polarscatter([0 pi],[0.5 0.5],[0.1*200,200],'filled');
    ax.RGrid = 'off';
    ax.RTick = 'none';
    
    % compass plots
    [x,y] = pol2cart(topTrials.thetaTotal,topTrials.rhoTotal);
    figure();
    set(gcf,'Renderer','painters')
    set(gcf,'color','w')
    hC = compass(x,y,'k-o');
    for i=1:numel(hC)
        hC(i).XData(end-2:end)=nan;       % HG won't display NaN points (arrows)
    end
    
%% collect PFL3 l-r yaw tuning


% grey = [0.75,0.75,0.75];
% 
% edges_vf = [-4:0.5:10];
% edges_vs = [-7:0.5:7];
% edges_vy = [-200:10:200];
% edges_angle = [-180:10:180]; 
% 
% ZLR_vf = zeros(length(edges_vf)-1,1);
% ZLR_vs = zeros(length(edges_vs)-1,1);
% ZLR_vy = zeros(length(edges_vy)-1,1);
% ZLR_angle = zeros(length(edges_angle)-1,1);
% 
% dffLR_vf = zeros(length(edges_vf)-1,1);
% dffLR_vs = zeros(length(edges_vs)-1,1);
% dffLR_vy = zeros(length(edges_vy)-1,1);
% dffLR_angle = zeros(length(edges_angle)-1,1);
% 
% Zfig = figure(Name=['Zscore vs behaviour no 0 vel']);
% h1 = subplot(4,1,1);
% h2 = subplot(4,1,2);
% h3 = subplot(4,1,3);
% h4 = subplot(4,1,4);
% hold([h1,h2,h3,h4],'on')
% set(gcf,'color','w')
% set(gcf,'Renderer','painters')
% label = 'Z'; 
% 
% dffFig = figure(Name=['zf_f vs behaviour no 0 vel']);
% j1 = subplot(4,1,1);
% j2 = subplot(4,1,2);
% j3 = subplot(4,1,3);
% j4 = subplot(4,1,4);
% hold([j1,j2,j3,j4],'on')
% set(gcf,'color','w')
% set(gcf,'Renderer','painters')
% label = 'df_f';
%             
% for fly = 1:size(topTrials,1)
%     folder = cell2mat(topTrials.folder(fly)); 
%     
%     if strcmp(folder(end),'.')
%                 folder = folder(1:end-2); 
%     end
% 
%      processedData_dir = fullfile(folder,'processed_data');
% 
%     % Get data files
%     expID = get_expID(folder);
%     expList = {expID};
% 
%     % Load metadata 
%     [expMd, trialMd] = load_metadata(expList, folder);
% 
%     % Load imaging data
%     roiData = load_roi_data(expList, folder);
% 
%     % Load FicTrac data
%     [~,ftData, ~] = load_ft_data(expList, folder, 1, 0);
% 
%     % Load panels metadata
%     panelsMetadata = load_panels_metadata(expList, folder);
%     
%     nTrial = topTrials.trial(fly); 
%     
%     data_filelist = dir(processedData_dir);
%     for files = 1:length(data_filelist)
%         if regexp(data_filelist(files).name,'.mat') & regexp(data_filelist(files).name,['00',num2str(nTrial)])
%             load(fullfile(processedData_dir,data_filelist(files).name));
%         end
%     end
%     
%     threshold = 3;
%     
%     % Remove idx where the fly isn't moving
%     
%     total_mov_mm = abs(ftT.velFor{1}) + abs(ftT.velSide{1}) + abs(ftT.velYaw{1}*4.5);
%     no0vel_idx = find(total_mov_mm > threshold);
%     vf = ftT.velFor{1}(no0vel_idx);
%     vs = ftT.velSide{1}(no0vel_idx);
%     vy = ftT.velYaw{1}(no0vel_idx); 
%     angle = wrapTo180(ftT.cueAngle{1}(no0vel_idx)-wrapTo180(rad2deg(topTrials.thetaTotal(fly)))) ; 
%     vy = (vy/ (2*pi) ) * 360; 
% 
%     trial_roiData = roiData(roiData.trialNum == nTrial,:);
% 
%     for run = 1:2
%         
%         sum_mean{1} = zeros(length(edges_vf)-1,1);
%         sum_mean{2} = zeros(length(edges_vs)-1,1);
%         sum_mean{3} = zeros(length(edges_vy)-1,1);
%         sum_mean{4} = zeros(length(edges_angle)-1,1);
% 
%         if run == 1
%             activityTable = ZData;
%         else
%             activityTable = dffData;
%         end
%         
%         for roi = 1:size(trial_roiData,1)
%             activity = activityTable.(3){roi};
%             activity = activity(no0vel_idx);
% 
%             % vf
%             behaviour = vf; 
%             [vf_zscore, centers_vf] = binData(activity, behaviour, edges_vf);
%             sum_mean{1}(:,roi) = vf_zscore; 
% 
% 
%             % vs 
%             behaviour = vs; 
%             [vs_zscore, centers_vs] = binData(activity, behaviour, edges_vs);
%             sum_mean{2}(:,roi) = vs_zscore; 
% 
%             % vy 
%             [vy_zscore, centers_vy] = binData(activity, vy, edges_vy);
%             sum_mean{3}(:,roi) = vy_zscore; 
% 
% 
%             % angle
%             [angle_zscore, centers_angle] = binData(activity, angle, edges_angle);
%             sum_mean{4}(:,roi) = angle_zscore; 
%         end
%         
% 
%         if run == 1
%             ZLR_vf = sum([ZLR_vf , (sum_mean{1}(:,1)-sum_mean{1}(:,2))],2,'omitnan');
%             plot(h1,centers_vf,sum_mean{1}(:,1)-sum_mean{1}(:,2),'color',grey)
%             box off
%             title('L-R')
% 
%             ZLR_vs = sum([ZLR_vs , sum_mean{2}(:,1)-sum_mean{2}(:,2)],2,'omitnan');
%             plot(h2,centers_vs,sum_mean{2}(:,1)-sum_mean{2}(:,2),'color',grey)
%             box off
% 
%             ZLR_vy = sum([ZLR_vy , sum_mean{3}(:,1)-sum_mean{3}(:,2)],2,'omitnan');
%             plot(h3,centers_vy,sum_mean{3}(:,1)-sum_mean{3}(:,2),'color',grey)
%             box off
% 
%             ZLR_angle = sum([ZLR_angle , sum_mean{4}(:,1)-sum_mean{4}(:,2)],2,'omitnan');
%             plot(h4,centers_angle,sum_mean{4}(:,1)-sum_mean{4}(:,2),'color',grey)
%             box off
%         else
%             dffLR_vf = sum([dffLR_vf , (sum_mean{1}(:,1)-sum_mean{1}(:,2))],2,'omitnan');
%             plot(j1,centers_vf,sum_mean{1}(:,1)-sum_mean{1}(:,2),'color',grey)
%             box off
%             title('L-R')
% 
%             dffLR_vs = sum([dffLR_vs , sum_mean{2}(:,1)-sum_mean{2}(:,2)],2,'omitnan');
%             plot(j2,centers_vs,sum_mean{2}(:,1)-sum_mean{2}(:,2),'color',grey)
%             box off
% 
%             dffLR_vy = sum([dffLR_vy , sum_mean{3}(:,1)-sum_mean{3}(:,2)],2,'omitnan');
%             plot(j3,centers_vy,sum_mean{3}(:,1)-sum_mean{3}(:,2),'color',grey)
%             box off
% 
%             dffLR_angle = sum([dffLR_angle , sum_mean{4}(:,1)-sum_mean{4}(:,2)],2,'omitnan');
%             plot(j4,centers_angle,sum_mean{4}(:,1)-sum_mean{4}(:,2),'color',grey)
%             box off
%         end
%     end
% end
% 
% ZLR_vf = ZLR_vf/fly;
% ZLR_vs = ZLR_vs/fly;
% ZLR_vy = ZLR_vy/fly;
% ZLR_angle = ZLR_angle/fly;
% 
% plot(h1,centers_vf,ZLR_vf,'k','LineWidth',1.5)
% yline(h1,0,'--r')
% ylabel(h1,'L - R')
% xlabel(h1,'vf (mm/s)')
% plot(h2,centers_vs,ZLR_vs,'k','LineWidth',1.5)
% yline(h2,0,'--r')
% ylabel(h2,'L - R')
% xlabel(h2,'vs (mm/s)')
% plot(h3,centers_vy,ZLR_vy,'k','LineWidth',1.5)
% yline(h3,0,'--r')
% ylabel(h3,'L - R')
% xlabel(h3,'vy (deg/s)')
% plot(h4,centers_angle,ZLR_angle,'k','LineWidth',1.5)
% yline(h4,0,'--r')
% ylabel(h4,'L - R')
% xlabel(h4,'Distance from Goal (deg)')
% 
% 
% dffLR_vf = dffLR_vf/fly;
% dffLR_vs = dffLR_vs/fly;
% dffLR_vy = dffLR_vy/fly;
% dffLR_angle = dffLR_angle/fly;
% 
% plot(j1,centers_vf,dffLR_vf,'k','LineWidth',1.5)
% yline(j1,0,'--r')
% ylabel(j1,'L - R')
% xlabel(j1,'vf (mm/s)')
% plot(j2,centers_vs,dffLR_vs,'k','LineWidth',1.5)
% yline(j2,0,'--r')
% ylabel(j2,'L - R')
% xlabel(j2,'vs (mm/s)')
% plot(j3,centers_vy,dffLR_vy,'k','LineWidth',1.5)
% yline(j3,0,'--r')
% ylabel(j3,'L - R')
% xlabel(j3,'vy (deg/s)')
% plot(j4,centers_angle,dffLR_angle,'k','LineWidth',1.5)
% yline(j4,0,'--r')
% ylabel(j4,'L - R')
% xlabel(j4,'Distance from Goal (deg)')
% 
% 
% end