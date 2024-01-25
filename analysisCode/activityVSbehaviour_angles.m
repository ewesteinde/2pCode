function activityVSbehaviour_angles(folder, step, measurement, savePlots)
    arguments
        folder char
        step double
        measurement double = 3
        savePlots logical = 1 
    end
%% load in data

    processedData_dir = fullfile(folder,'processed_data');
    filelist = dir(processedData_dir);  % get list of files and folders in any subfolder
    filelist = filelist(~[filelist.isdir]);  % only files from list
    ismat = regexp({filelist.name},'.mat');
    for c = 1:length(ismat)
        if isempty(ismat{c})
            ismat{c} = 0 ;
        end
    end
    filelist = filelist(logical(cell2mat(ismat)));
    
    expID = get_expID(folder);
    expList = {expID};
    ftData = load_ft_data(expList, folder);
    numTrials = unique(ftData.trialNum); 
    
    for trial = 1:length(numTrials)
        istrial = regexp({filelist.name},['00',num2str(trial)]);
        for c = 1:length(istrial)
            if isempty(istrial{c})
                istrial{c} = 0 ;
            end
        end
        trial_filelist = filelist(logical(cell2mat(istrial))); 
        
        for files = 1:length(trial_filelist)
            fileName = fullfile(processedData_dir,trial_filelist(files).name);
            load(fileName)
        end


    %% load heading dist plots or else replot heading dist w/ circular mean for exps acquired before 2/16/22

        %% heading distribution plots
        behaviourData.vel_for = ftData.fwSpeed{trial}; 
        behaviourData.vel_side = ftData.sideSpeed{trial};
        behaviourData.vel_yaw = wrapTo180((ftData.yawSpeed{trial}/ (2*pi) ) * 360);
        behaviourData.angle = ftData.cueAngle{trial};
        minVel = 1.5; 
        window = 60; 
        sampRate = round(length(ftData.cueAngle{trial})/Z.second(end));  


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

    %% plot activity - behaviour relationships
    
    vf_down = ftT_down.fwSpeed{1};
    vy_down = ftT_down.yawSpeed{1};
    vs_down = ftT_down.sideSpeed{1};
    angle_down = ftT_down.cueAngle{1};

        for p = 1:length(runs)
            if p == 2
                option = '_mode';
                prefHead = mean_mode(2);
            end
            activityTable = Z;
            activity = zeros(length(org_roiData.rawFl{1}),size(org_roiData,1)); 
            for roi = 1:size(org_roiData,1)
                activity(:,roi) = activityTable.data(activityTable.roiName == roi);
            end
            time = unique(Z.second); 
            
            if ~regexp(folder,'LAL')
                activity = sum(activity,2)/size(org_roiData,1);
            end

            seg = 90; 
            if mod(360,seg) ~= 0 
                error 'pick different segement size';
            end

            numSeg = 360/seg;
            headings = []; 
            for num = 1:numSeg
                headings(num) = wrapTo360(prefHead + seg * (num-1));
            end

            speed = sqrt(vs_down.^2 + vf_down.^2); 

            count = 1; 
            saveBinsS = cell(numSeg,2);
            saveBinsVf = cell(numSeg,2); 
            saveBinsVs = cell(numSeg,2);
            saveBinsVy = cell(numSeg,2);
            angle_360 = wrapTo360(angle_down);
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

                    VfinHead{count} = vf_down(index); 
                    VsinHead{count} = vs_down(index);
                    VyinHead{count} = vy_down(index);
                    SinHead{count} = speed(index);
                
                    for r = 1:size(activity,2)
                        activityinHead{count} = activity(index,r);

                        edges = [-(step/2):step:max(SinHead{count})]; %start at -step/2 so center of first bin is 0mm/s
                        [mean_bin, centers] = binData(activityinHead{count}, SinHead{count}, edges);
                        saveBinsS{count,r} = [centers' mean_bin];

                        edges = [min(VfinHead{count}):step:max(VfinHead{count})]; 
                        [mean_bin, centers] = binData(activityinHead{count}, VfinHead{count}, edges);
                        saveBinsVf{count,r} = [centers' mean_bin]; 

                        edges = [min(VyinHead{count}):step:max(VyinHead{count})]; 
                        [mean_bin, centers] = binData(activityinHead{count}, VyinHead{count}, edges);
                        saveBinsVy{count,r} = [centers' mean_bin]; 

                        edges = [min(VsinHead{count}):step:max(VsinHead{count})]; 
                        [mean_bin, centers] = binData(activityinHead{count}, VsinHead{count}, edges);
                        saveBinsVs{count,r} = [centers' mean_bin]; 

                    end
                count = count + 1; 
            end
            
            if ~regexp(folder,'LAL')
            
                colours = [[1,0,0];[0.5,0,0];[0,0,0];[0.25,0.25,0.25]];

                g = figure(); clf; 

                    subplot(4,1,1);
                    for num = 1:numSeg
                        plot(saveBinsS{num}(:,1),saveBinsS{num}(:,2),'Color',colours(num,:))
                        %colororder(turbo(num))
                        hold on 
                    end
                    xlabel('Speed mm/sec')
                    xlim([0 inf])
                    set(gcf,'color',[1 1 1])
                    legend(legend_labels)
                    box off


                   subplot(4,1,2);
                    for num = 1:numSeg
                        plot(saveBinsVf{num}(:,1),saveBinsVf{num}(:,2),'Color',colours(num,:))
                        %colororder(turbo(num))
                        hold on 
                    end
                    %xlim([minValPlot+1 maxValPlot-1])
                    xlabel('Vf mm/sec')
                    set(gcf,'color',[1 1 1])
                    legend(legend_labels)
                    box off

                % sideways velocity 

                    subplot(4,1,3);
                    for num = 1:numSeg
                        plot(saveBinsVs{num}(:,1),saveBinsVs{num}(:,2),'Color',colours(num,:))
                        %colororder(turbo(num))
                        hold on 
                    end
                    %xlim([minValPlot+1 maxValPlot-1])
                    xlabel('Vs mm/sec')
                    set(gcf,'color',[1 1 1])
                    legend(legend_labels)
                    box off
                    %ylabel('Vm (mV)')

                % yaw velocity 
                    subplot(4,1,4);
                    for num = 1:numSeg
                        plot(saveBinsVy{num}(:,1),saveBinsVy{num}(:,2),'Color',colours(num,:))
                        %colororder(turbo(num))
                        hold on 
                    end
                    %xlim([minValPlot+1 maxValPlot-1])
                    xlabel('Vy mm/sec')
                    set(gcf,'color',[1 1 1])
                    legend(legend_labels)
                    box off
                    
            else
                colours1 = [[1,0,0];[0.5,0,0];[0,0,0];[0.25,0.25,0.25]];
                colours2 = [[0,1,0];[0,0.5,0];[0,0,0];[0.25,0.25,0.25]];

                g = figure(); clf; 

                    subplot(4,2,2);
                    for num = 1:numSeg
                        plot(saveBinsS{num,1}(:,1),saveBinsS{num,1}(:,2),'Color',colours1(num,:))
                        %colororder(turbo(num))
                        hold on 
                    end
                    xlabel('Speed mm/sec')
                    title('right LAL')
                    xlim([0 inf])
                    set(gcf,'color',[1 1 1])
                    legend(legend_labels)
                    box off


                   subplot(4,2,4);
                    for num = 1:numSeg
                        plot(saveBinsVf{num,1}(:,1),saveBinsVf{num,1}(:,2),'Color',colours1(num,:))
                        %colororder(turbo(num))
                        hold on 
                    end
                    %xlim([minValPlot+1 maxValPlot-1])
                    xlabel('Vf mm/sec')
                    set(gcf,'color',[1 1 1])
                    legend(legend_labels)
                    box off

                % sideways velocity 

                    subplot(4,2,6);
                    for num = 1:numSeg
                        plot(saveBinsVs{num,1}(:,1),saveBinsVs{num,1}(:,2),'Color',colours1(num,:))
                        %colororder(turbo(num))
                        hold on 
                    end
                    %xlim([minValPlot+1 maxValPlot-1])
                    xlabel('Vs mm/sec')
                    set(gcf,'color',[1 1 1])
                    legend(legend_labels)
                    box off
                    %ylabel('Vm (mV)')

                % yaw velocity 
                    subplot(4,2,8);
                    for num = 1:numSeg
                        plot(saveBinsVy{num,1}(:,1),saveBinsVy{num,1}(:,2),'Color',colours1(num,:))
                        %colororder(turbo(num))
                        hold on 
                    end
                    %xlim([minValPlot+1 maxValPlot-1])
                    xlabel('Vy mm/sec')
                    set(gcf,'color',[1 1 1])
                    legend(legend_labels)
                    box off
                    
                    subplot(4,2,1);
                    for num = 1:numSeg
                        plot(saveBinsS{num,2}(:,1),saveBinsS{num,2}(:,2),'Color',colours2(num,:))
                        %colororder(turbo(num))
                        hold on 
                    end
                    xlabel('Speed mm/sec')
                    title('Left LAL')
                    xlim([0 inf])
                    set(gcf,'color',[1 1 1])
                    legend(legend_labels)
                    box off


                   subplot(4,2,3);
                    for num = 1:numSeg
                        plot(saveBinsVf{num,2}(:,1),saveBinsVf{num,2}(:,2),'Color',colours2(num,:))
                        %colororder(turbo(num))
                        hold on 
                    end
                    %xlim([minValPlot+1 maxValPlot-1])
                    xlabel('Vf mm/sec')
                    set(gcf,'color',[1 1 1])
                    legend(legend_labels)
                    box off

                % sideways velocity 

                    subplot(4,2,5);
                    for num = 1:numSeg
                        plot(saveBinsVs{num,2}(:,1),saveBinsVs{num,2}(:,2),'Color',colours2(num,:))
                        %colororder(turbo(num))
                        hold on 
                    end
                    %xlim([minValPlot+1 maxValPlot-1])
                    xlabel('Vs mm/sec')
                    set(gcf,'color',[1 1 1])
                    legend(legend_labels)
                    box off
                    %ylabel('Vm (mV)')

                % yaw velocity 
                    subplot(4,2,7);
                    for num = 1:numSeg
                        plot(saveBinsVy{num,2}(:,1),saveBinsVy{num,2}(:,2),'Color',colours2(num,:))
                        %colororder(turbo(num))
                        hold on 
                    end
                    %xlim([minValPlot+1 maxValPlot-1])
                    xlabel('Vy mm/sec')
                    set(gcf,'color',[1 1 1])
                    legend(legend_labels)
                    box off

            end
            
                    vf_lim = 0.2; 
                    vy_lim = 0.1;
                    vs_lim = 0.15;
                    s_lim = 0.2;

                    vf_edges = [min(ftT_down.fwSpeed{1}):0.2:max(ftT_down.fwSpeed{1})]; 
                    vs_edges = [min(ftT_down.sideSpeed{1}):0.2:max(ftT_down.sideSpeed{1})];
                    vy_edges = [min(ftT_down.yawSpeed{1}):0.1:max(ftT_down.yawSpeed{1})];
                    s_edges = [0:0.2:max(speed)];
            
                    h = figure();clf;
                    subplot(4,2,1)
                    histogram(VfinHead{1},vf_edges,'Normalization','probability')
                    hold on
                    histogram(VfinHead{3},vf_edges,'Normalization','probability')
                    xlabel('vf')
                    subplot(4,2,2)
                    histogram(VfinHead{1}(VfinHead{1} > vf_lim | VfinHead{1} < -vf_lim),vf_edges,'Normalization','probability')
                    hold on
                    histogram(VfinHead{3}(VfinHead{3} > vf_lim | VfinHead{3} < -vf_lim),vf_edges,'Normalization','probability')
                    xlabel('vf')
                    legend('prefHead', 'anti-prefHead')

                    subplot(4,2,3)
                    histogram(VyinHead{1},vy_edges,'Normalization','probability')
                    hold on
                    histogram(VyinHead{3},vy_edges,'Normalization','probability')
                    xlabel('vy')
                    subplot(4,2,4)
                    histogram(VyinHead{1}(VyinHead{1} > vy_lim | VyinHead{1} < -vy_lim),vy_edges,'Normalization','probability')
                    hold on
                    histogram(VyinHead{3}(VyinHead{3} > vy_lim | VyinHead{3} < -vy_lim),vy_edges,'Normalization','probability')
                    xlabel('vy')

                    subplot(4,2,5)
                    histogram(VsinHead{1},vs_edges,'Normalization','probability')
                    hold on
                    histogram(VsinHead{3},vs_edges,'Normalization','probability')
                    xlabel('vs')
                    subplot(4,2,6)
                    histogram(VsinHead{1}(VsinHead{1} > vs_lim | VsinHead{1} < -vs_lim),vs_edges,'Normalization','probability')
                    hold on
                    histogram(VsinHead{3}(VsinHead{3} > vs_lim | VsinHead{3} < -vs_lim),vs_edges,'Normalization','probability')
                    xlabel('vs')

                    subplot(4,2,7)
                    histogram(SinHead{1},s_edges,'Normalization','probability')
                    hold on
                    histogram(SinHead{3},s_edges,'Normalization','probability')
                    xlabel('speed')
                    subplot(4,2,8)
                    histogram(SinHead{1}(SinHead{1} > s_lim),s_edges,'Normalization','probability')
                    hold on
                    histogram(SinHead{3}(SinHead{3} > s_lim),s_edges,'Normalization','probability')
                    xlabel('speed')

                if savePlots == 1
                    saveas(g, fullfile(imagesDir,[expID,'_',num2str(nTrial),option, '_activityVsbehaviour_angle.fig']));
                    saveas(h, fullfile(imagesDir,[expID,'_',num2str(nTrial),option,'_behaviour_histograms_angle.fig']));
                end
        end
    end
end
    