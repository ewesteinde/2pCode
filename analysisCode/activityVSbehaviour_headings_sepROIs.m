function activityVSbehaviour_headings_sepROIs(rho, theta, roiData, Z, ftT_down, nTrial, measurement, savePlots, interactive,lineplotDir, expID)          
    if interactive
        prefHead = input('preferred heading: ');
        runs = 1; 
        option = 'manual';
    else

        [x, y] = pol2cart(theta,rho); 
        meanx = sum(x)/length(x); 
        meany = sum(y)/length(y);
        [mean_theta, ~] = cart2pol(meanx, meany);
        
        
        mean_mode(1) = wrapTo360(rad2deg(mean_theta));
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
    end
    trial_roiData = roiData(roiData.trialNum == nTrial,:);
    threshold = 0.5;
    total_mov_mm = abs(ftT_down.velFor{1}) + abs(ftT_down.velSide{1}) + abs(ftT_down.velYaw{1}*4.5);
    no0vel_idx = find(total_mov_mm > threshold);
    speed = sqrt(ftT_down.velFor{1}.^2 + ftT_down.velSide{1}.^2);
    speed = speed(no0vel_idx); 
    vf = ftT_down.velFor{1}(no0vel_idx);
    vs = ftT_down.velSide{1}(no0vel_idx);
    vy = ftT_down.velYaw{1}(no0vel_idx);
    angle = ftT_down.cueAngle{1}(no0vel_idx); 

    %% plot activity - behaviour relationships at diff headings
    
    for measure = 1:runs
        if measure == 2
            option = '_mode';
            prefHead = mean_mode(2);
        end


        activityTable = Z;
        activity1 = activityTable.(3){1}; 
        activity2 = activityTable.(3){2}; 
        
        activity(:,1) = activity1(no0vel_idx);
        activity(:,2) = activity2(no0vel_idx);

        seg = 90; 
        step = 0.5;
        if mod(360,seg) ~= 0 
            error 'pick different segement size';
        end

        numSeg = 360/seg;

        for num = 1:numSeg
            headings(num) = wrapTo360(prefHead + seg * (num-1));
        end
         
        saveBinsS = cell(numSeg,size(trial_roiData,1));
        saveBinsVf = cell(numSeg,size(trial_roiData,1)); 
        saveBinsVs = cell(numSeg,size(trial_roiData,1));
        saveBinsVy = cell(numSeg,size(trial_roiData,1));
        angle_360 = wrapTo360(angle);
        legend_labels = {}; 
        VfinHead = {}; 
        VsinHead = {}; 
        VyinHead = {}; 
        SinHead = {}; 
        activityinHead = {}; 
        
        for roi = 1:size(trial_roiData,1)
            count = 1;
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
                    activityinHead{count} = activity(index,roi);

                    edges = [-(step/2):step:max(SinHead{count})]; %start at -step/2 so center of first bin is 0mm/s
                    [mean_bin, centers] = binData(activityinHead{count}, SinHead{count}, edges);
                    saveBinsS{count,roi} = [centers' mean_bin];

                    edges = [min(VfinHead{count}):step:max(VfinHead{count})]; 
                    [mean_bin, centers] = binData(activityinHead{count}, VfinHead{count}, edges);
                    saveBinsVf{count,roi} = [centers' mean_bin];

                    edges = [min(VyinHead{count}):step:max(VyinHead{count})]; 
                    [mean_bin, centers] = binData(activityinHead{count}, VyinHead{count}, edges);
                    saveBinsVy{count,roi} = [centers' mean_bin];

                    edges = [min(VsinHead{count}):step:max(VsinHead{count})]; 
                    [mean_bin, centers] = binData(activityinHead{count}, VsinHead{count}, edges);
                    saveBinsVs{count,roi} = [centers' mean_bin];

                    count = count + 1; 
            end
        end

        colours1 = [[1,0,0];[0.5,0,0];[0,0,0];[0,0,0.6]];
        colours2 = colours1;

        g = figure(name = option); clf; 

            subplot(4,2,1);
            for num = 1:numSeg
                plot(saveBinsS{num,1}(:,1),saveBinsS{num,1}(:,2),'Color',colours1(num,:))
                %colororder(turbo(num))
                hold on 
            end
            xlabel('Speed mm/sec')
            xlim([0 inf])
            set(gcf,'color',[1 1 1])
            legend(legend_labels)
            title('left LAL')
            box off


           subplot(4,2,3);
            for num = 1:numSeg
                plot(saveBinsVf{num,1}(:,1),saveBinsVf{num,1}(:,2),'Color',colours1(num,:))
                %colororder(turbo(num))
                hold on 
            end
            %xlim([minValPlot+1 maxValPlot-1])
            xlabel('Vf mm/sec')
            set(gcf,'color',[1 1 1])
            box off

        % sideways velocity 

            subplot(4,2,5);
            for num = 1:numSeg
                plot(saveBinsVs{num,1}(:,1),saveBinsVs{num,1}(:,2),'Color',colours1(num,:))
                %colororder(turbo(num))
                hold on 
            end
            %xlim([minValPlot+1 maxValPlot-1])
            xlabel('Vs mm/sec')
            set(gcf,'color',[1 1 1])
            box off
            %ylabel('Vm (mV)')

        % yaw velocity 
            subplot(4,2,7);
            for num = 1:numSeg
                plot(saveBinsVy{num,1}(:,1),saveBinsVy{num,1}(:,2),'Color',colours1(num,:))
                %colororder(turbo(num))
                hold on 
            end
            %xlim([minValPlot+1 maxValPlot-1])
            xlabel('Vy mm/sec')
            set(gcf,'color',[1 1 1])
            box off
            
            subplot(4,2,2);
            for num = 1:numSeg
                plot(saveBinsS{num,2}(:,1),saveBinsS{num,2}(:,2),'Color',colours2(num,:))
                %colororder(turbo(num))
                hold on 
            end
            xlabel('Speed mm/sec')
            xlim([0 inf])
            set(gcf,'color',[1 1 1])
            title('right LAL')
            box off


           subplot(4,2,4);
            for num = 1:numSeg
                plot(saveBinsVf{num,2}(:,1),saveBinsVf{num,2}(:,2),'Color',colours2(num,:))
                %colororder(turbo(num))
                hold on 
            end
            %xlim([minValPlot+1 maxValPlot-1])
            xlabel('Vf mm/sec')
            set(gcf,'color',[1 1 1])
            box off

        % sideways velocity 

            subplot(4,2,6);
            for num = 1:numSeg
                plot(saveBinsVs{num,2}(:,1),saveBinsVs{num,2}(:,2),'Color',colours2(num,:))
                %colororder(turbo(num))
                hold on 
            end
            %xlim([minValPlot+1 maxValPlot-1])
            xlabel('Vs mm/sec')
            set(gcf,'color',[1 1 1])
            box off
            %ylabel('Vm (mV)')

        % yaw velocity 
            subplot(4,2,8);
            for num = 1:numSeg
                plot(saveBinsVy{num,2}(:,1),saveBinsVy{num,2}(:,2),'Color',colours2(num,:))
                %colororder(turbo(num))
                hold on 
            end
            %xlim([minValPlot+1 maxValPlot-1])
            xlabel('Vy mm/sec')
            set(gcf,'color',[1 1 1])
            box off
            
            
            

            if savePlots == 1
                saveas(g, fullfile(lineplotDir,[expID,'_',num2str(nTrial),'_',option,'_activityVsbehaviour_angle_sepROIs.fig']));
            end
    end
end