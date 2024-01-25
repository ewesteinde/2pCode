function plotBestMenotaxisWindow(rootDir)
    summaries = dir(fullfile(rootDir,'*headingSummary*.mat'));
    for s = 1:length(summaries)
        load(fullfile(rootDir,summaries(s).name)); 
        flySum = flySum(~ismembertol(flySum.rhoTotal,1,10^-10),:); % gets rid of trials w/ no heading change --> indicates problem
        flySum = flySum(flySum.perMove > 5,:); % only look at trials where fly's vel was above threshold for at least 5% of the trial (30 sec)
        for f = 1:size(flySum,1)
            breakIdx = regexp(flySum.folder{f},'\');
            trial_folder = flySum.folder{f}(breakIdx(end) + 1:end);
            folder = fullfile(summaries(s).folder, trial_folder); 
            nTrial = flySum.trial(f); 
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

            % get processed data
            data_filelist = dir(processedData_dir);
            for files = 1:length(data_filelist)
                if regexp(data_filelist(files).name,'.mat') & regexp(data_filelist(files).name,['00',num2str(nTrial)])
                    load(fullfile(processedData_dir,data_filelist(files).name));
                end
            end

            windowInfo = flySum.straightestWindow(f,:); 
            winStart = windowInfo.windowTime{1}(1); 
            winEnd = windowInfo.windowTime{1}(end); 
            
            winIdx = find(ftT.trialTime{1} >= winStart & ftT.trialTime{1} <= winEnd); 
            
            ZData = [];
            dffData = [];
            for roi = 1:length(unique(Z.roiName))
                newZrow = table(roi,'VariableNames',{'roi'});
                newZrow.Z = {Z(Z.roiName == roi,:).data}; 
                newZrow.second = {Z(Z.roiName == roi,:).second}; 
                
                ZData = [ZData; newZrow];
                
                newdffrow = table(roi,'VariableNames',{'roi'});
                newdffrow.dff = {Zf(Zf.roiName == roi,:).data}; 
                newdffrow.second = {Zf(Zf.roiName == roi,:).second}; 
                
                dffData = [dffData; newdffrow];
            end
            
            %% collect only roi data within window idx
            
            winDffData = [];
            winZData = []; 
            for roi = 1:size(dffData,1)
                newdffrow = table(dffData(roi,:).roi,'VariableNames',{'roi'}); 
                newdffrow.dff = {dffData.dff{roi}(winIdx)};
                newdffrow.second = {dffData.second{roi}(winIdx)}; 
                
                winDffData = [winDffData; newdffrow]; 
                
                newZrow = table(ZData(roi,:).roi,'VariableNames',{'roi'}); 
                newZrow.Z = {ZData.Z{roi}(winIdx)};
                newZrow.second = {ZData.second{roi}(winIdx)}; 
                
                winZData = [winZData; newZrow];
            end
            
            %% collect only fictrac data within window idx
            window_cueAngle = ftT_down.cueAngle{1}(winIdx);  
            
            %% plot ROI vs cue angle plots 
            
            figure();
            edges_angle = [-180:10:180]; 
            sum_mean = zeros(length(edges_angle)-1,1);
            for roi = 1:size(ZData,1)
                activity = winZData.Z{roi};
                behaviour = window_cueAngle;
                
                [angle_zscore, centers_angle] = binData(activity, behaviour, edges_angle);
                sum_mean = sum_mean + angle_zscore; 
                
                plot(centers_angle,angle_zscore)
                colororder(parula(roi))
                xlabel('cue pos (deg)')
                xlim([-180 180])
                hold on
            end
            plot(centers_angle,sum_mean/size(ZData,1),'k','LineWidth',1.5)
            
            activityVSbehaviour_no0vel_secplots(ftT_down, Z, Zf, roiData, nTrial, threshold, expMd,savePlots,lineplotDir, expID)

        %% look at ave movment within each heading vector epoch
        
        win_velFor = []; 
        win_velSide = [];
        win_velYaw = []; 
        for win = 1:length(flySum.rho_60sec{f})
            win_velFor(win) = sum(ftData.velFor{nTrial}(flySum.window_idx{f}(win,1):flySum.window_idx{f}(win,2)))/length(ftData.velFor{nTrial}(flySum.window_idx{f}(win,1):flySum.window_idx{f}(win,2)));
            win_velSide(win) = sum(ftData.velSide{nTrial}(flySum.window_idx{f}(win,1):flySum.window_idx{f}(win,2)))/length(ftData.velFor{nTrial}(flySum.window_idx{f}(win,1):flySum.window_idx{f}(win,2)));
            win_velYaw(win) = sum(ftData.velYaw{nTrial}(flySum.window_idx{f}(win,1):flySum.window_idx{f}(win,2)))/length(ftData.velFor{nTrial}(flySum.window_idx{f}(win,1):flySum.window_idx{f}(win,2))); 
        end
        
        win_totalRad = win_velFor/4.5 + abs(win_velSide/4.5) + abs(win_velYaw); 
        
        %% bin vector headings per window by vector strength: what heading is the fly facing most consistantly & most strongly?
        
       rho_edges = [0:0.1:1];
       deg_edges = [-180:10:180];
       figure();histogram2(rad2deg(flySum.theta_60sec{f}),flySum.rho_60sec{f},deg_edges,rho_edges)
      
        
    end
    
end