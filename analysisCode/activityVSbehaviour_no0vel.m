function activityVSbehaviour_no0vel(rootDir, step, threshold, measurement, savePlots)
    arguments
        rootDir char
        step double = 0.25
        threshold double = 0.5
        measurement double = 3
        savePlots logical = 0
    end
    
    folders = get_folders(rootDir);
    
    folderNum = length(folders);
    fprintf(1, '##### Found %d potential experiment folders to process...#####\n', folderNum);
    for ff = 1:folderNum
      
      %% Get folder information
      folder = folders(ff).folder;
    
    
%% Load in fictrac & ROI data
 
% Make images directory
    imagesDir = fullfile(folder,'images');
    if ~exist(imagesDir, 'dir')
        mkdir(imagesDir)
    end

    processedData_dir = fullfile(folder,'processed_data');
    if ~exist(processedData_dir,'dir')
        process2p_fictrac_data(rootDir)
    end

    % Analysis settings
    p = [];
    p.smWin = 5;
    p.flType = 'expDff';
    ztab = [];

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


    trialNums = roiData.trialNum;
    trialNums = unique(trialNums);
    numTrials = numel(trialNums); 
    
    %%
    for nTrial = 1:numTrials

        data_filelist = dir(processedData_dir);
        for files = 1:length(data_filelist)
            if regexp(data_filelist(files).name,'.mat') & regexp(data_filelist(files).name,['00',num2str(nTrial)])
                load(fullfile(processedData_dir,data_filelist(files).name));
            end
        end
        
     %% extract fictrac Data
 % Get fictrac values to plot

        if any(ftData.trialNum==nTrial)
            ftT = ftData(ftData.trialNum ==nTrial, :);
            ftT_time = ftT.frameTimes{1};

            %% Plot heading 
            ftT_cueAngle = ftT.cueAngle{1};
            ftT_cueAngle_smooth = ftT_cueAngle; %smoothdata(ftT_cueAngle, 1, 'gaussian', 50);

            %% Plot fwSpeed 
            ftT_fwSpeed = ftT.fwSpeed{1};
            ftT_fwSpeed_smooth = smoothdata(ftT_fwSpeed, 1, 'loess', 10);

            %% Plot sideSpeed 
            ftT_sideSpeed = ftT.sideSpeed{1};
            ftT_sideSpeed_smooth = smoothdata(ftT_sideSpeed, 1, 'loess', 10);

            %% Plot yawSpeed 
            ftT_yawSpeed = ftT.yawSpeed{1};
            ftT_yawSpeed_smooth = smoothdata(ftT_yawSpeed, 1, 'loess', 10);

        end
        
%% Remove idx where the fly isn't moving
    
    speed = sqrt(ftT_down.sideSpeed{1}.^2 + ftT_down.fwSpeed{1}.^2);
    %vy = ftT_down.yawSpeed{1}; 
    %no0vel_idx = find(vy > threshold/4.5 | vy < -threshold/4.5);
    no0vel_idx = find(speed > threshold); 
    speed = speed(no0vel_idx); 
    vf = ftT_down.fwSpeed{1}(no0vel_idx);
    vs = ftT_down.sideSpeed{1}(no0vel_idx);
    vy = ftT_down.yawSpeed{1}(no0vel_idx);
    angle = ftT_down.cueAngle{1}(no0vel_idx); 
    angle_360 = wrapTo360(angle);
    
        
%% plot heading - activity relationships NO 0 VEL

    sum_mean = cell(3,1); 
    vy = wrapTo180((vy/ (2*pi) ) * 360); 
    edges_vf = [min(vf):0.5:max(vf)];
    edges_vs = [min(vs):0.5:max(vs)];
    edges_vy = [min(vy):10:max(vy)];
    edges_angle = [-180:10:180];


    for run = 1:2
        sum_mean{1} = zeros(length(edges_vf)-1,1);
        sum_mean{2} = zeros(length(edges_vs)-1,1);
        sum_mean{3} = zeros(length(edges_vy)-1,1);
        sum_mean{4} = zeros(length(edges_angle)-1,1);
        
        

        if run == 1
            activityTable = Z;
            figure(Name=['Zscore vs behaviour, trial ', num2str(nTrial)]);clf
            label = 'Z'; 
        else
            activityTable = Zf;
            figure(Name=['zf_f vs behaviour, trial ', num2str(nTrial)]);clf
            label = 'df_f';
        end

        if ~contains(expMd.expName{1},'LAL')
            for roi = 1:size(org_roiData,1)
                activity = activityTable.data(activityTable.roiName == roi);
                activity = activity(no0vel_idx);

                % vf

                behaviour = vf; 
                [vf_zscore, centers_vf] = binData(activity, behaviour, edges_vf);
                sum_mean{1} = sum_mean{1} + vf_zscore; 

                subplot(4,1,1);
                plot(centers_vf,vf_zscore)
                colororder(parula(roi))
                ylabel(label)
                xlabel('vf (mm/s)')
                hold on


                % vs 
                behaviour = vs; 
                [vs_zscore, centers_vs] = binData(activity, behaviour, edges_vs);
                sum_mean{2} = sum_mean{2} + vs_zscore; 

                subplot(4,1,2);
                plot(centers_vs,vs_zscore)
                colororder(parula(roi))
                ylabel(label)
                xlabel('vs (mm/s)')
                hold on

                % vy 
                [vy_zscore, centers_vy] = binData(activity, vy, edges_vy);
                sum_mean{3} = sum_mean{3} + vy_zscore; 


                subplot(4,1,3);
                plot(centers_vy,vy_zscore)
                colororder(parula(roi))
                ylabel(label)
                xlabel('vy (deg/s)')
                hold on

                % angle
                [angle_zscore, centers_angle] = binData(activity, angle, edges_angle);
                sum_mean{4} = sum_mean{4} + angle_zscore; 


                subplot(4,1,4);
                plot(centers_angle,angle_zscore)
                colororder(parula(roi))
                ylabel(label)
                xlabel('cue pos (deg)')
                hold on
            end


                subplot(4,1,1)
                plot(centers_vf,sum_mean{1}/size(org_roiData,1),'k','LineWidth',1.5)
                subplot(4,1,2)
                plot(centers_vs,sum_mean{2}/size(org_roiData,1),'k','LineWidth',1.5)
                subplot(4,1,3)
                plot(centers_vy,sum_mean{3}/size(org_roiData,1),'k','LineWidth',1.5)
                subplot(4,1,4)
                plot(centers_angle,sum_mean{4}/size(org_roiData,1),'k','LineWidth',1.5)

        else
               for roi = 1:size(roiData,1)
                activity = activityTable.data(activityTable.roiName == roi);
                activity = activity(no0vel_idx); 
                % vf
                behaviour = vf; 
                [vf_zscore, centers_vf] = binData(activity, behaviour, edges_vf);
                sum_mean{1} = sum_mean{1} + vf_zscore; 

                l(1) = subplot(4,1,1);
                plot(centers_vf,vf_zscore)
                ylabel(label)
                xlabel('vf (mm/s)')
                hold on


                % vs 
                behaviour = vs; 
                [vs_zscore, centers_vs] = binData(activity, behaviour, edges_vs);
                sum_mean{2} = sum_mean{2} + vs_zscore; 

                l(2) = subplot(4,1,2);
                plot(centers_vs,vs_zscore)
                ylabel(label)
                xlabel('vs (mm/s)')
                hold on

                % vy 
                [vy_zscore, centers_vy] = binData(activity, vy, edges_vy);
                sum_mean{3} = sum_mean{3} + vy_zscore; 


                l(3) = subplot(4,1,3);
                plot(centers_vy,vy_zscore)
                ylabel(label)
                xlabel('vy (deg/s)')
                hold on

                % angle
                [angle_zscore, centers_angle] = binData(activity, angle, edges_angle);
                sum_mean{4} = sum_mean{4} + angle_zscore; 


                l(4) = subplot(4,1,4);
                plot(centers_angle,angle_zscore)
                ylabel(label)
                xlabel('cue pos (deg)')
                hold on 
               end
        end

        if run == 1
            z = gcf;
        else
            zf = gcf;
        end
    end


    if savePlots == 1
        saveas(z, fullfile(imagesDir,[expID,'_',num2str(nTrial),'_zScore_no0vel_lineplots.fig']));
        saveas(zf, fullfile(imagesDir,[expID,'_',num2str(nTrial),'_df_f_no0vel_lineplots.fig']));
    end
      
%% load heading dist plots or else replot heading dist w/ circular mean for exps acquired before 2/16/22

    %% heading distribution plots
    behaviourData.vel_for = ftT_fwSpeed_smooth; 
    behaviourData.vel_side = ftT_sideSpeed_smooth;
    behaviourData.vel_yaw = wrapTo180((ftT_yawSpeed_smooth/ (2*pi) ) * 360);
    behaviourData.angle = ftT_cueAngle_smooth;
    minVel = 1.5; 
    window = 60; 
    sampRate = round(length(ftT_cueAngle_smooth)/ftT_down.frameTimes{1}(end));  


    [rho, theta, ~, ~, ~] = plotHeadingDist(window, minVel, behaviourData, sampRate, 1);
    %prefHead = mean(wrapTo360(rad2deg(theta))); 

    mean_mode(1) = mean(wrapTo360(rad2deg(theta.*rho)));
    mean_mode(2) = mode(wrapTo360(rad2deg(theta.*rho)));
 
    if measurement == 1
        prefHead = mean_mode(1); 
        option = '_mean';
        runs = 1;
    elseif measurement == 2
        prefHead = mean_mode(2); 
        option = '_mode';
        runs = 1; 
    else
        prefHead = mean_mode(1); 
        option = '_mean';
        runs = 2;
    end

%% plot activity - behaviour relationships SEP BY HEADING

        %for roi = 1:height(org_roiData)
            for measure = 1:runs
                if measurement == 3 && measure == 2
                    option = '_mode';
                    prefHead = mean_mode(2);
                elseif measurement == 3 && measure == 1
                    option = '_mean';
                    prefHead = mean_mode(1);
                end


%                 activityTable = Z;
%                 activity = zeros(length(no0vel_idx),1); 
%                 for roi = 1:size(org_roiData,1)
%                     roi_activity = activityTable.data(activityTable.roiName == roi); 
%                     activity = activity + roi_activity(no0vel_idx);
%                 end
                
                    activityTable = Z;   

                    roi_activity = activityTable.data(activityTable.roiName == 1); 
                    activity1 = roi_activity(no0vel_idx);
                    
                    roi_activity = activityTable.data(activityTable.roiName == 2); 
                    activity2 = roi_activity(no0vel_idx);
                    
                    activity = activity1 - activity2; 


                %activity_mean = activity/height(org_roiData); 
                
                
                time = unique(Z.second); 

                seg = 90; 
                if mod(360,seg) ~= 0 
                    error 'pick different segement size';
                end

                numSeg = 360/seg;

                for num = 1:numSeg
                    headings(num) = wrapTo360(prefHead + seg * (num-1));
                end

                count = 1; 
                saveBinsS = cell(1,numSeg);
                saveBinsVf = cell(1,numSeg); 
                saveBinsVs = cell(1,numSeg);
                saveBinsVy = cell(1,numSeg);
                legend_labels = {}; 
                VfinHead = {}; 
                VsinHead = {}; 
                VyinHead = {}; 
                SinHead = {}; 
                activityinHead = {}; 


                for head = headings
                    legend_labels{count} = int2str(head); 

                    lim1 = wrapTo360(head-seg/2);
                    lim2 = wrapTo360(head+seg/2);

                    if lim1 > lim2
                        [index] = find(angle_360 > lim1 | angle_360 < lim2); 
                    else
                        [index] = find(angle_360 < lim2 & angle_360 > lim1);
                    end

                    VfinHead{count} = vf(index); 
                    VsinHead{count} = vs(index);
                    VyinHead{count} = vy(index);
                    SinHead{count} = speed(index);
                    activityinHead{count} = activity(index);

                    edges = [-(step/2):step:max(SinHead{count})]; %start at -step/2 so center of first bin is 0mm/s
                    [mean_bin, centers] = binData(activityinHead{count}, SinHead{count}, edges);
                    saveBinsS{count} = [centers' mean_bin];

                    edges = [min(VfinHead{count}):step:max(VfinHead{count})]; 
                    [mean_bin, centers] = binData(activityinHead{count}, VfinHead{count}, edges);
                    saveBinsVf{count} = [centers' mean_bin];

                    edges = [min(VyinHead{count}):10:max(VyinHead{count})]; 
                    [mean_bin, centers] = binData(activityinHead{count}, VyinHead{count}, edges);
                    saveBinsVy{count} = [centers' mean_bin];

                    edges = [min(VsinHead{count}):step:max(VsinHead{count})]; 
                    [mean_bin, centers] = binData(activityinHead{count}, VsinHead{count}, edges);
                    saveBinsVs{count} = [centers' mean_bin];

                    count = count + 1; 
                end

                colours = [[1,0,0];[0.5,0,0];[0,0,0];[0.25,0.25,0.25]];

                g = figure(name = [option,'_roi_',num2str(roi)]); clf;
                
                subplot(4,1,1);
                    plot(saveBinsVy{1}(:,1),saveBinsVy{1}(:,2),'Color',colours(num,:))
                    hold on 
                    coefficients = polyfit(saveBinsVy{1}(saveBinsVy{1}(:,1) > -100 & saveBinsVy{1}(:,1) < 100,1),saveBinsVy{1}(saveBinsVy{1}(:,1) > -100 & saveBinsVy{1}(:,1) < 100,2),1); 
                    xfit = linspace(min(saveBinsVy{1}(:,1)),max(saveBinsVy{1}(:,1)),length(saveBinsVy{1}(:,1)));
                    yfit = polyval(coefficients, xfit); 
                    plot(xfit,yfit,'k-')
                    %colororder(turbo(num))
                %xlim([minValPlot+1 maxValPlot-1])
                xlabel('Vy mm/sec')
                set(gcf,'color',[1 1 1])
                legend(legend_labels{1})
                box off


               subplot(4,1,2);
                    plot(saveBinsVy{2}(:,1),saveBinsVy{2}(:,2),'Color',colours(num,:))
                    hold on 
                    coefficients = polyfit(saveBinsVy{2}(saveBinsVy{2}(:,1) > -100 & saveBinsVy{2}(:,1) < 100,1),saveBinsVy{2}(saveBinsVy{2}(:,1) > -100 & saveBinsVy{2}(:,1) < 100,2),1); 
                    xfit = linspace(min(saveBinsVy{2}(:,1)),max(saveBinsVy{2}(:,1)),length(saveBinsVy{2}(:,1)));
                    yfit = polyval(coefficients, xfit); 
                    plot(xfit,yfit,'k-')
                    %colororder(turbo(num))
                %xlim([minValPlot+1 maxValPlot-1])
                xlabel('Vy mm/sec')
                set(gcf,'color',[1 1 1])
                legend(legend_labels{2})
                box off

            % sideways velocity 

                subplot(4,1,3);
                    plot(saveBinsVy{3}(:,1),saveBinsVy{3}(:,2),'Color',colours(num,:))
                    hold on 
                    coefficients = polyfit(saveBinsVy{3}(saveBinsVy{3}(:,1) > -100 & saveBinsVy{3}(:,1) < 100,1),saveBinsVy{3}(saveBinsVy{3}(:,1) > -100 & saveBinsVy{3}(:,1) < 100,2),1); 
                    xfit = linspace(min(saveBinsVy{3}(:,1)),max(saveBinsVy{3}(:,1)),length(saveBinsVy{3}(:,1)));
                    yfit = polyval(coefficients, xfit); 
                    plot(xfit,yfit,'k-')
                    %colororder(turbo(num))
                %xlim([minValPlot+1 maxValPlot-1])
                xlabel('Vy mm/sec')
                set(gcf,'color',[1 1 1])
                legend(legend_labels{3})
                box off

            % yaw velocity 
                subplot(4,1,4);
                    plot(saveBinsVy{4}(:,1),saveBinsVy{4}(:,2),'Color',colours(num,:))
                    hold on 
                    coefficients = polyfit(saveBinsVy{4}(saveBinsVy{4}(:,1) > -100 & saveBinsVy{4}(:,1) < 100,1),saveBinsVy{4}(saveBinsVy{4}(:,1) > -100 & saveBinsVy{4}(:,1) < 100,2),1); 
                    xfit = linspace(min(saveBinsVy{4}(:,1)),max(saveBinsVy{4}(:,1)),length(saveBinsVy{4}(:,1)));
                    yfit = polyval(coefficients, xfit); 
                    plot(xfit,yfit,'k-')
                    %colororder(turbo(num))
                %xlim([minValPlot+1 maxValPlot-1])
                xlabel('Vy mm/sec')
                set(gcf,'color',[1 1 1])
                legend(legend_labels{4})
                box off

%                 subplot(4,1,1);
%                 for num = 1:numSeg
%                     plot(saveBinsS{num}(:,1),saveBinsS{num}(:,2),'Color',colours(num,:))
%                     %colororder(turbo(num))
%                     hold on 
%                 end
%                 xlabel('Speed mm/sec')
%                 xlim([0 inf])
%                 set(gcf,'color',[1 1 1])
%                 legend(legend_labels)
%                 box off
% 
% 
%                subplot(4,1,2);
%                 for num = 1:numSeg
%                     plot(saveBinsVf{num}(:,1),saveBinsVf{num}(:,2),'Color',colours(num,:))
%                     %colororder(turbo(num))
%                     hold on 
%                 end
%                 %xlim([minValPlot+1 maxValPlot-1])
%                 xlabel('Vf mm/sec')
%                 set(gcf,'color',[1 1 1])
%                 legend(legend_labels)
%                 box off
% 
%             % sideways velocity 
% 
%                 subplot(4,1,3);
%                 for num = 1:numSeg
%                     plot(saveBinsVs{num}(:,1),saveBinsVs{num}(:,2),'Color',colours(num,:))
%                     %colororder(turbo(num))
%                     hold on 
%                 end
%                 %xlim([minValPlot+1 maxValPlot-1])
%                 xlabel('Vs mm/sec')
%                 set(gcf,'color',[1 1 1])
%                 legend(legend_labels)
%                 box off
%                 %ylabel('Vm (mV)')
% 
%             % yaw velocity 
%                 subplot(4,1,4);
%                 for num = 1:numSeg
%                     plot(saveBinsVy{num}(:,1),saveBinsVy{num}(:,2),'Color',colours(num,:))
%                     %colororder(turbo(num))
%                     hold on 
%                 end
%                 %xlim([minValPlot+1 maxValPlot-1])
%                 xlabel('Vy mm/sec')
%                 set(gcf,'color',[1 1 1])
%                 legend(legend_labels)
%                 box off


%                 vf_lim = 0.2; 
%                 vy_lim = 0.1;
%                 vs_lim = 0.15;
%                 s_lim = 0.2;
% 
%                 vf_edges = [min(vf):0.2:max(vf)]; 
%                 vs_edges = [min(vs):0.2:max(vs)];
%                 vy_edges = [min(vy):0.1:max(vy)];
%                 s_edges = [0:0.2:max(speed)];


%                 j = figure();clf; 
%                 subplot(4,2,1)
%                 histogram(VfinHead{1},vf_edges,'Normalization','probability')
%                 hold on
%                 histogram(VfinHead{3},vf_edges,'Normalization','probability')
%                 xlabel('vf')
%                 subplot(4,2,2)
%                 histogram(VfinHead{1}(VfinHead{1} > vf_lim | VfinHead{1} < -vf_lim),vf_edges,'Normalization','probability')
%                 hold on
%                 histogram(VfinHead{3}(VfinHead{3} > vf_lim | VfinHead{3} < -vf_lim),vf_edges,'Normalization','probability')
%                 xlabel('vf')
%                 legend('prefHead', 'anti-prefHead')
% 
%                 subplot(4,2,3)
%                 histogram(VyinHead{1},vy_edges,'Normalization','probability')
%                 hold on
%                 histogram(VyinHead{3},vy_edges,'Normalization','probability')
%                 xlabel('vy')
%                 subplot(4,2,4)
%                 histogram(VyinHead{1}(VyinHead{1} > vy_lim | VyinHead{1} < -vy_lim),vy_edges,'Normalization','probability')
%                 hold on
%                 histogram(VyinHead{3}(VyinHead{3} > vy_lim | VyinHead{3} < -vy_lim),vy_edges,'Normalization','probability')
%                 xlabel('vy')
% 
%                 subplot(4,2,5)
%                 histogram(VsinHead{1},vs_edges,'Normalization','probability')
%                 hold on
%                 histogram(VsinHead{3},vs_edges,'Normalization','probability')
%                 xlabel('vs')
%                 subplot(4,2,6)
%                 histogram(VsinHead{1}(VsinHead{1} > vs_lim | VsinHead{1} < -vs_lim),vs_edges,'Normalization','probability')
%                 hold on
%                 histogram(VsinHead{3}(VsinHead{3} > vs_lim | VsinHead{3} < -vs_lim),vs_edges,'Normalization','probability')
%                 xlabel('vs')
% 
%                 subplot(4,2,7)
%                 histogram(SinHead{1},s_edges,'Normalization','probability')
%                 hold on
%                 histogram(SinHead{3},s_edges,'Normalization','probability')
%                 xlabel('speed')
%                 subplot(4,2,8)
%                 histogram(SinHead{1}(SinHead{1} > s_lim),s_edges,'Normalization','probability')
%                 hold on
%                 histogram(SinHead{3}(SinHead{3} > s_lim),s_edges,'Normalization','probability')
%                 xlabel('speed')

                if savePlots == 1
                    saveas(g, fullfile(imagesDir,[expID,'_',num2str(nTrial),'roi_',num2str(roi),'_',option,'_no0vel_angle.fig']));
                    %saveas(j, fullfile(imagesDir,[expID,'_',num2str(nTrial),option,'_behaviour_histograms_angle.fig']));
                end
            end
            %end
        end
    end
end
    