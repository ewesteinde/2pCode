function [summaryData, ftData] = summarizeFlyHeading(flyFolders, rootDir, minVel, windowSize, saveSum, plotHeading) 
    %dbstop if error
    rho_all = []; 
    theta_all = []; 
    for fly = 1:size(flyFolders,2)
        headers = {'folder','trial','rhoTotal','thetaTotal','rho_60sec','theta_60sec','window_idx','perMove','straightestWindow'};
        flySum = cell2table(cell(0,9),'VariableNames',headers); 
        exp = 0;
        folders = flyFolders(:,fly);
        folders = folders(~cellfun('isempty',folders)); 
            %% Process each folder
            folderNum = length(folders);
            fprintf(1, '##### Found %d potential experiment folders to process...#####\n', folderNum);
            for ff = 1:folderNum

              %% Get folder information
              folder = cell2mat(folders{ff}); 
        %% Load in fictrac & ROI data
                 %try
                    if strcmp(folder(end),'.')
                        folder = folder(1:end-2); 
                    end

                    % Get data files
                    expID = get_expID(folder);
                    expList = {expID};

                    % Load metadata 
                    [~, trialMd] = load_metadata(expList, folder);
                     

                    % Load imaging data
                    roiData = load_roi_data(expList, folder);

                    % Load FicTrac dat data
                    %[~,~, ftData_dat] = load_ft_data(expList, folder, 0, 1);
                    % load downsampled ftData
                    
                    
                    numTrials = max(size(unique(roiData.trialNum),1),length(trialMd.trialNum)); 
                %%
                for nTrial = 1:numTrials
                    exp = exp + 1;
                    sampRate = 60;
                    load(fullfile(folder,'processed_data',['fictracData_Trial_00',num2str(nTrial)]));
                    
                    ftData = ftT;
                    trialData = []; 

                    behaviourData.vel_for = ftData.velFor{1}; 
                    behaviourData.vel_side = ftData.velSide{1};
                    behaviourData.vel_yaw = wrapTo180((ftData.velYaw{1}/ (2*pi) ) * 360);
                    behaviourData.angle = ftData.cueAngle{1};
                    %%

                    % plots mean heading vector of the fly within every window where theta
                    % represents the heading and rho represents the stability of that heading
                    % within the window (1 = very stable, 0 = unstable)
                    % copied what the Green et al 2019 paper did to compute their heading
                    % vectors
                    if iscell(behaviourData)
                        behaviourData = behaviourData{1};
                    end

                    window = windowSize * round(sampRate); 
                    if window > length(behaviourData.vel_for)
                        window = length(behaviourData.vel_for); 
                    end
                    count = 1; 

                    %% overlapping 60 second windows slid by ~1s increments
                    mean_headingVectors = [];
                    idx_windows = [];
                    speed = sqrt(behaviourData.vel_for.^2 + behaviourData.vel_side.^2);
                    for i = 1:round(sampRate):length(behaviourData.angle) - window + 1
                        idx = i:i+window-1; 
                        angle_temp = behaviourData.angle(idx); 
                        speed_temp = speed(idx); 
                        angles_flyFor = angle_temp(speed_temp > minVel); 
                        if ~isempty(angles_flyFor)
                            x = cosd(angles_flyFor); 
                            y = sind(angles_flyFor); %my arena has - angles to the left of the fly, + to the right, multiply y component by -1 to align physical arena coords to polar plot angles
                            idx_windows(count,1) = idx(1);
                            idx_windows(count,2) = idx(end);
                            idx_windows(count,3) = length(find(speed_temp > minVel))/length(speed_temp)*100;
                            mean_headingVectors(1,count)= sum(x)/length(x); 
                            mean_headingVectors(2,count)= sum(y)/length(y); 
                            count = count + 1; 
                        end
                    end 

                    trial_angle = behaviourData.angle(speed > minVel);
                    xTrial = cosd(trial_angle);
                    yTrial = sind(trial_angle); 
                    trialHeadingVector(1) = sum(xTrial)/length(xTrial);
                    trialHeadingVector(2) = sum(yTrial)/length(yTrial);

                    rhoTrial = sqrt(trialHeadingVector(1).^2 + trialHeadingVector(2).^2); 
                    thetaTrial = atan2(trialHeadingVector(2),trialHeadingVector(1)); 


                    rho = sqrt(mean_headingVectors(1,:).^2 + mean_headingVectors(2,:).^2); 
                    theta = atan2(mean_headingVectors(2,:),mean_headingVectors(1,:)); 

    %                 rhoTrial = sqrt(sum(mean_headingVectors(1,:)).^2 + sum(mean_headingVectors(2,:)).^2)/length(rho); 
    %                 thetaTrial = atan2(sum(mean_headingVectors(2,:)),sum(mean_headingVectors(1,:)));

                    rho_all = [rho_all rho];
                    theta_all = [theta_all theta];

                    % find window where the fly walked the straightest
                    trialData(:,1) = rho;
                    trialData(:,2) = theta; 
                    trialData(:,3:5) = idx_windows; 
                    move_thresh = 10*round(sampRate)/window * 100; % within each window the fly must have been moving for at least 10 seconds out of the whole window
                    rhoWindowAboveThresh = trialData(trialData(:,5) > move_thresh,:); 
                    if isempty(rhoWindowAboveThresh)
                        rhoWindowAboveThresh = trialData(trialData(:,5) == max(trialData(:,5)),:);
                    end
                    [~,bestRhoIdx] = max(rhoWindowAboveThresh(:,1));
                    straightest_window = rhoWindowAboveThresh(bestRhoIdx,:);
                    best_rho_time = ftData.trialTime{1}(straightest_window(3):straightest_window(4));  
                    
                    headers = {'rho','theta','idxStart','idxEnd','perMoveinWindow'};
                    straightest_window = array2table(straightest_window,'VariableNames',headers);
                    straightest_window.windowTime{1} = best_rho_time;
                    
                    
                    
                    
                    if regexp(folder,'PFL2_3')
                        cellType = 'PFL3';
                    else
                        cellType = 'PFL2';
                    end

                    newRow = table({folder},nTrial,'VariableNames',{'folder', 'trial'}); 
                    newRow.rhoTotal = rhoTrial; 
                    newRow.thetaTotal = thetaTrial; 
                    newRow.rho_60sec = {rho}; 
                    newRow.theta_60sec = {theta}; 
                    newRow.window_idx = {idx_windows}; 
                    newRow.perMove = sum(speed > minVel)/length(speed) * 100;
                    newRow.straightestWindow = straightest_window;

                    flySum = [flySum; newRow];

        % uncomment to plot each trial's heading data one by one
        %             polarscatter(theta, rho,'o')
        %             %rlim([0 1])
        %             hold on
        %             colormap(gca, 'hot')
                    
                    if plotHeading
                        figure();clf; 
                        polarscatter(theta, rho,'o')
                        rlim([0 1])
                        %colormap(gca, 'hot')
                        hold on
                        polarplot([0,thetaTrial], [0,rhoTrial],'k','LineWidth',2)
                        str = {['mean vector str: ',num2str(rhoTrial)]};
                        dim = [0.7 0.72 0.2 0.2];
                        annotation('textbox',dim,'String',str,'FitBoxToText','on','EdgeColor','w')
                        set(gcf,'color','w');
                        rlim([0 1])

                        saveas(gcf, fullfile(folder,'images',[expID,'_',num2str(nTrial),'_headingDist_trialVector.fig']));
                        saveas(gcf, fullfile(folder,'images',[expID,'_',num2str(nTrial),'_headingDist_trialVector.png']));
                        saveas(gcf, fullfile(folder,'images',[expID,'_',num2str(nTrial),'_headingDist_trialVector.svg']));

                    end

                end
%                 catch
%                     exp = exp + 1; 
%                     rhoTrial(exp) = nan;
%                     thetaTrial(exp) = nan; 
% 
%                     newRow = table({folder},nTrial,'VariableNames',{'folder', 'trial'}); 
%                     newRow.rhoTotal = nan; 
%                     newRow.thetaTotal = nan; 
%                     newRow.rho_60sec = {nan}; 
%                     newRow.theta_60sec = {nan}; 
%                     newRow.window_idx = {nan};
%                     newRow.perMove = nan;
%                     headers = {'rho','theta','idxStart','idxEnd','perMoveinWindow','windowTime'};
%                     emptyTable = cell(1,6);
%                     newRow.straightestWindow = straightest_window; 
% 
%                     flySum = [flySum; newRow];
% 
%                     disp([folder,' failed to process'])
%                 end  
            end

            [~,fly_num_idx] = regexpi(folder,'fly');
            fly_num = str2double(folder(fly_num_idx + 1));
            
            if ~isempty(flySum)
                folderidx = regexp(flySum.folder{1},'\'); 
                dateDir = folder(folderidx(end-1)+1:folderidx(end)-1);
                count = 2; 
                while isnan(str2double(dateDir))
                    dateDir = folder(folderidx(end-count)+1:folderidx(end-(count - 1))-1);
                    count = count + 1; 
                end

                if saveSum == 1
                    if contains(rootDir, dateDir)
                        save(fullfile(rootDir,[cellType,'_fly',num2str(fly_num),'_headingSummary.mat']),'flySum')
                    else
                        save(fullfile(rootDir,dateDir,[cellType,'_fly',num2str(fly_num),'_headingSummary.mat']),'flySum')
                    end
                end
            end
    summaryData.(['fly',num2str(fly)]) = flySum;        
    end

close all
end