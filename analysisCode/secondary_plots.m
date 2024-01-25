function foldersFailed = secondary_plots(rootDir, savePlots, cutFile)

%% Default settings

    arguments
        rootDir char
        savePlots logical = 1 
        cutFile logical = 0 
    end

    
%% get folder list
    %dbstop if error
    folders = get_folders(rootDir,1,1);
           
    
    %% Process each folder
    folderNum = length(folders);
    fprintf(1, '##### Found %d potential experiment folders to process...#####\n', folderNum);
    countFail = 1;
    for ff = 1:folderNum
      
      %% Get folder information
      folder = folders(ff).folder;
      
       
%% Load in fictrac & ROI data
       %try
            if strcmp(folder(end),'.')
                folder = folder(1:end-2); 
            end
            
            %imaging_fictrac_pipeline(folder, 0, 0, 0, 1);
            
            % Make images directory
            imagesDir = fullfile(folder,'images');
            if ~exist(imagesDir, 'dir')
                mkdir(imagesDir)
            end

            lineplotDir = fullfile(imagesDir,'lineplots');
            if ~exist(lineplotDir, 'dir')
                mkdir(lineplotDir)
            end
            
            heatmapDir = fullfile(imagesDir,'heatmaps');
            if ~exist(heatmapDir, 'dir')
                mkdir(heatmapDir)
            end
            
            jumpDir = fullfile(imagesDir,'jump_plots');
            if ~exist(jumpDir, 'dir')
                mkdir(jumpDir)
            end

             processedData_dir = fullfile(folder,'processed_data');

            if ~exist(processedData_dir,'dir')
                disp('No processed data found, running process2p_fictrac_data now')
                process2p_fictrac_data(folder)
            end

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
            
            if cutFile 
                cutStart = input('time when to start: ');
                cutEnd = input('time when to end: ');
                fictracTime = seconds(ftT.trialTime{nTrial});
                
                [startVal, startIdx] = min(abs(fictracTime-cutStart)); 
                [endVal, endIdx] = min(abs(fictracTime-cutEnd)); 
               
                for field = 3:size(ftT,2)
                    ftT.(field){1} = ftT.(field){1}(startIdx:endIdx);
                end                    
                for field = 2:size(ZData,2)
                    for roi = 1:size(ZData,1)
                        ZData.(field){roi} = ZData.(field){roi}(startIdx:endIdx); 
                        dffData.(field){roi} = dffData.(field){roi}(startIdx:endIdx); 
                    end
                end
                for field = [5,9]
                    for roi = 1:size(roiData,1)
                        roiData.(field){roi} = roiData.(field){roi}(startIdx:endIdx); 
                    end
                end                    
            end

         %% extract fictrac Data
         % Get non downsmapled fictrac values for heading dist plots
        % Plot heading 
            ftT_cueAngle = ftT.cueAngle{1};
            ftT_cueAngle_smooth = ftT_cueAngle;

            % Plot fwSpeed 
            ftT_fwSpeed = ftT.velFor{1};
            %ftT_fwSpeed_smooth = smoothdata(ftT_fwSpeed, 1, 'loess', 10);

            % Plot sideSpeed 
            ftT_sideSpeed = ftT.velSide{1};
            %ftT_sideSpeed_smooth = smoothdata(ftT_sideSpeed, 1, 'loess', 10);

            % Plot yawSpeed 
            ftT_yawSpeed = ftT.velYaw{1};
            %ftT_yawSpeed_smooth = smoothdata(ftT_yawSpeed, 1, 'loess', 10);

            roiNames = roiData.roiName;
            
            %% sanity plots
%             figure();
%             roi_sum = zeros(length(Z.data(Z.roiName == 1)),1);
%             for roi = 1:max(Z.roiName)
%                 roi_sum = roi_sum + Z(Z.roiName == roi,:).data;
%                 plot(Z.data(Z.roiName == roi))
%                 colororder(parula(roi))
%                 hold on
%             end
%             roi_ave = roi_sum/max(unique(Z.roiName));
%             plot(roi_ave,'k','lineWidth',1.5)
%             hold off
%             
%              figure();
%             roi_sum = zeros(length(Z.data(Z.roiName == 1)),1);
%             for roi = 1:max(Z.roiName)
%                 roi_sum = roi_sum + Zf(Zf.roiName == roi,:).data;
%                 plot(Zf.data(Zf.roiName == roi))
%                 colororder(parula(roi))
%                 hold on
%             end
%             roi_ave_zf = roi_sum/max(unique(Zf.roiName));
%             plot(roi_ave_zf,'k','lineWidth',1.5)
%             hold off
%             
%             figure();
%             plot(roi_ave,'k')
%             hold on
%             plot(normalize(ftT_down.velFor{1}),'g')
%             plot(normalize(ftT_down.velSide{1}),'r')
%             plot(normalize(ftT_down.velYaw{1}),'b')
            

        %% plot activty vs behaviour
        
         %Activity_Heatmap(ftT, roiData, ZData, dffData, nTrial,savePlots, heatmapDir, expID)
% 
         %activityVSbehaviour_lineplots(ftT, ZData, dffData, roiData, nTrial, expMd, savePlots,lineplotDir, expID)
         threshold = 3;
         %activityVSbehaviour_no0vel_secplots(ftT, ZData, dffData, roiData, nTrial, threshold, expMd,savePlots,lineplotDir, expID)
         activityVSbehaviour_no0vel_PosterPlots(ftT, ZData, roiData, nTrial, threshold, expMd,savePlots,lineplotDir)

        %% heading distribution plots
        behaviourData.vel_for = ftT_fwSpeed; 
        behaviourData.vel_side = ftT_sideSpeed;
        behaviourData.vel_yaw = wrapTo180((ftT_yawSpeed/ (2*pi) ) * 360);
        behaviourData.angle = ftT_cueAngle_smooth;
        minVel = 1.5; 
        window = 60; 
        sampRate = 60; %fictrac data samp rate 

        [rho, theta, ~, f, g] = plotHeadingDist(window, minVel, behaviourData, sampRate, 1);


        if savePlots == 1
            saveas(f, fullfile(imagesDir,[expID,'_',num2str(nTrial),'_headingVectors.fig']));
            saveas(g, fullfile(imagesDir,[expID,'_',num2str(nTrial),'_headingDist.fig']));
        %clear
        end
        measurement = 1;
        interactive = 0; 

        %% replot activity-behaviour relationship at diff headings, must be run after heading dis plots
        activityVSbehaviour_headings(rho, theta, roiData, ZData, dffData, ftT, trialMd, expMd, nTrial, measurement, savePlots, interactive,lineplotDir, expID)  
        activityVSbehaviour_headings_no0vel(rho, theta, roiData, threshold, ZData, dffData,ftT, trialMd, expMd, nTrial, measurement, savePlots, interactive,lineplotDir,expID)  
        
        if regexp(folder, 'LAL')
            activityVSbehaviour_headings_sepROIs(rho, theta, roiData, ZData, ftT, nTrial, measurement, savePlots,interactive,lineplotDir, expID)
        end
        
        % %% calculate bump position & offset
        % in progress, not working yet
        % midline distances = vector of midline distances
        % dff_data = array of dff values where row = timepoint col = midline
        % distance

        % 
        % if ~contains(expMd.expName{1},'LAL')
        %     if contains(expMd.expName{1},'FB')
        %         roi_root = 'FB_row_line_';
        %     elseif contains(expMd.expName{1},'PB')
        %         roi_root = 'PB_row_line_';
        %     else
        %         error('unknown brain region')
        %     end
        %         [~,midline_distances_idx] = regexp(org_roiData.roiName,roi_root);
        %         midline_distances_idx = cell2mat(midline_distances_idx);
        %         roiNames = org_roiData.roiName{:};
        %         for name = 1:size(org_roiData.roiName,1)
        %             midline_distances(name) = str2double(org_roiData.roiName{name}(midline_distances_idx + 1:end));
        %             dff_data(:,name) = flData_all{name}; 
        %         end
        %     
        % 
        %     [bump_mag,bump_width,adj_rs,bump_pos] = fitVonMises(midline_distances,dff_data);
        %end
        %% locate jump idxs & start & end indicies of a window around them
         if ~cutFile 
             windowSize = 10;
             [jump_array_down, jump_array] = detect_jumps(ftT, windowSize, 60);
%             
             plot_jumps(jump_array, jump_array_down, ZData, ftT, expID, nTrial, jumpDir, windowSize, savePlots, 60);
         end
%             
        
        end
        pause(2)
        close all
%         catch
%             disp([folder,' failed to process'])
%             foldersFailed{countFail} = folder;
%             countFail = countFail + 1; 
%         end
    end
end