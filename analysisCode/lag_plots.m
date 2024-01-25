function lag_plots(rootDir, savePlots)

%% Default settings

    arguments
        rootDir char
        savePlots logical = 0 
    end
%% get folder list

    folders = get_folders(rootDir);
           
    
    %% Process each folder
    folderNum = length(folders);
    fprintf(1, '##### Found %d potential experiment folders to process...#####\n', folderNum);
    for ff = 1:folderNum
      
      %% Get folder information
      folder = folders(ff).folder;
      
       
%% Load in fictrac & ROI data
        try
            if strcmp(folder(end),'.')
                folder = folder(1:end-2); 
            end

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
            ftData = load_ft_data(expList, folder);

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
                
                trial_roiData = roiData(roiData.trialNum == nTrial,:);
                %% plots
                threshold = 3;
                %activityVSbehaviour_no0vel_secplots(ftT_down, Z, Zf, roiData, nTrial, threshold, expMd,0,lineplotDir, expID)
                
                no0vel_idx = find(ftT_down.moveSpeed{1} > threshold);
                angle = ftT_down.cueAngle{1}(no0vel_idx);
                
                figure();
                for roi = 1:size(trial_roiData,1)
                    activity = Z.data(Z.roiName == roi);
                    activity = activity(no0vel_idx);

                    % angle
                    edges_angle = [-180:10:180]; 
                    [angle_zscore, centers_angle] = binData(activity, angle, edges_angle);
                    smooth_angle_zscore = smoothdata(angle_zscore, 1, 'gaussian', 5); 
                    roi_angle_max(roi) = centers_angle(smooth_angle_zscore == max(smooth_angle_zscore));

                    plot(centers_angle,smooth_angle_zscore)
                    colororder(parula(roi))
                    ylabel('Z')
                    xlabel('cue pos (deg)')
                    hold on
                end
                lag = 2; 
                plot_2pxCorr(ftT_down, lag, roiData, Z, roi_angle_max)
                
                volume_lagTime = input('around how many volumes does the ROI data lag velocity? ');
                
                if volume_lagTime > 0
                    var_names = ftT_down.Properties.VariableNames;  
                    for col = 1:width(ftT_down)
                        if strcmp(var_names{col},'expID')
                            temp_table = ftT_down(:,col); 
                        elseif iscell(ftT_down.(col)) && ~isempty(ftT_down.(col){1})
                            temp_table = ftT_down.(col){1}(1+volume_lagTime:end,:);
                            temp_table = cell2table({temp_table}); 
                        else
                            temp_table = ftT_down(:,col); 
                        end          
                        ftT_lag(:,col) = temp_table;
                    end
                    
                    allVars = 1:width(ftT_lag); 
                    ftT_lag = renamevars(ftT_lag,allVars,var_names);
                    
                    Headers = {'roiName','second','data'};
                    Z_lag = cell2table(cell(0,3),'VariableNames',Headers);
                    Zf_lag = cell2table(cell(0,3),'VariableNames',Headers);
                    for roi = 1:size(trial_roiData,1)
                        Z_temp = Z(Z.roiName == roi,:);
                        Z_lag = [Z_lag; Z_temp(1:end-volume_lagTime,:)];
                        Zf_temp = Zf(Zf.roiName == roi,:);
                        Zf_lag = [Zf_lag; Zf_temp(1:end-volume_lagTime,:)];
                    end
                else
                end
                
                
                activityVSbehaviour_no0vel_secplots(ftT_lag, Z_lag, Zf_lag, roiData, nTrial, threshold, expMd,savePlots,lineplotDir, expID)
                
                
        behaviourData.vel_for = ftT_lag.fwSpeed{1}; 
        behaviourData.vel_side = ftT_lag.sideSpeed{1};
        behaviourData.vel_yaw = wrapTo180((ftT_lag.yawSpeed{1}/ (2*pi) ) * 360);
        behaviourData.angle = ftT_lag.cueAngle{1};
        minVel = 1.5; 
        window = 60; 
        sampRate = roiData.sampRate(1); %fictrac data samp rate 

        [rho, theta, ~, f, g] = plotHeadingDist(window, minVel, behaviourData, sampRate, 1);


        if savePlots == 1
            saveas(f, fullfile(imagesDir,[expID,'_',num2str(nTrial),'_headingVectors.fig']));
            saveas(g, fullfile(imagesDir,[expID,'_',num2str(nTrial),'_headingDist.fig']));
        %clear
        end
        measurement = 1;
        interactive = 0; 
        activityVSbehaviour_headings(rho, theta, roiData, Z_lag, Zf_lag, ftT_lag, trialMd, expMd, nTrial, measurement, savePlots, interactive,lineplotDir, expID)  
        %activityVSbehaviour_headings_no0vel(rho, theta, roiData, threshold, Z_lag, Zf_lag,ftT_lag, trialMd, expMd, nTrial, measurement, savePlots, interactive,lineplotDir,expID)  
        %need to fix index prob
            end
        
        catch
            disp('something went wrong')
        end
    end
end