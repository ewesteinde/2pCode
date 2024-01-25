function activityVSbehaviour_headings(rho, theta, roiData, Z, Zf,ftT, trialMd, expMd, nTrial, measurement, savePlots, interactive,lineplotDir,expID)      

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
    %% plot activity - behaviour relationships at diff headings
    
    for measure = 1:runs
        if measure == 2
            option = '_mode';
            prefHead = mean_mode(2);
        end


        activityTable = Z;
        activity_all = zeros(size(Z.(3){1},1),1); 
        for roi = 1:size(Z,1)
            activity_all = activity_all + activityTable.(3){roi};
        end
        
        if regexp(expMd.expName{1}, 'PFL2_3')

            activity1 = activityTable.(3){1}; 

            activity2 = activityTable.(3){2}; 

            activity = activity1 - activity2;
            type = 'L-R diff';
        else
            activity = activity_all/size(Z,1);
            type = 'mean';
        end

        seg = 90; 
        step = 0.5;
        if mod(360,seg) ~= 0 
            error 'pick different segement size';
        end

        numSeg = 360/seg;

        for num = 1:numSeg
            headings(num) = wrapTo360(prefHead + seg * (num-1));
        end

        speed = sqrt(ftT.velSide{1}.^2 + ftT.velFor{1}.^2); 

        count = 1; 
        saveBinsS = cell(1,numSeg);
        saveBinsVf = cell(1,numSeg); 
        saveBinsVs = cell(1,numSeg);
        saveBinsVy = cell(1,numSeg);
        angle_360 = wrapTo360(ftT.cueAngle{1});
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

                VfinHead{count} = ftT.velFor{1}(index); 
                VsinHead{count} = ftT.velSide{1}(index);
                VyinHead{count} = ftT.velYaw{1}(index);
                SinHead{count} = speed(index);
                activityinHead{count} = activity(index);

                edges = [-(step/2):step:max(SinHead{count})]; %start at -step/2 so center of first bin is 0mm/s
                [mean_bin, centers] = binData(activityinHead{count}, SinHead{count}, edges);
                saveBinsS{count} = [centers' mean_bin];

                edges = [min(VfinHead{count}):step:max(VfinHead{count})]; 
                [mean_bin, centers] = binData(activityinHead{count}, VfinHead{count}, edges);
                saveBinsVf{count} = [centers' mean_bin];

                edges = [min(VyinHead{count}):step:max(VyinHead{count})]; 
                [mean_bin, centers] = binData(activityinHead{count}, VyinHead{count}, edges);
                saveBinsVy{count} = [centers' mean_bin];

                edges = [min(VsinHead{count}):step:max(VsinHead{count})]; 
                [mean_bin, centers] = binData(activityinHead{count}, VsinHead{count}, edges);
                saveBinsVs{count} = [centers' mean_bin];

                count = count + 1; 
        end

        colours = [[1,0,0];[0.5,0,0];[0,0,0];[0.25,0.25,0.25]];

        g = figure(name = option); clf; 

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
            title(['Trial_00',num2str(nTrial),'_',type], 'Interpreter', 'none')
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
            box off
            
            
            %%
%             colours = [[1,0,0];[0.5,0,0];[0,0,0];[0.25,0.25,0.25]];
% 
%                 k = figure(name = [option,'_roi_',num2str(roi)]); clf;
%                 
%                 subplot(4,2,1);
%                     plot(saveBinsVy{1}(:,1),saveBinsVy{1}(:,2),'Color',colours(1,:))
%                     hold on 
%                     coefficients = polyfit(saveBinsVy{1}(saveBinsVy{1}(:,1) > -5 & saveBinsVy{1}(:,1) < 5,1),saveBinsVy{1}(saveBinsVy{1}(:,1) > -5 & saveBinsVy{1}(:,1) < 5,2),1); 
%                     xfit = linspace(min(saveBinsVy{1}(:,1)),max(saveBinsVy{1}(:,1)),length(saveBinsVy{1}(:,1)));
%                     yfit = polyval(coefficients, xfit); 
%                     plot(xfit,yfit,'k-')
%                     %colororder(turbo(num))
%                 %xlim([minValPlot+1 maxValPlot-1])
%                 xlabel('Vy mm/sec')
%                 set(gcf,'color',[1 1 1])
%                 legend(legend_labels{1})
%                 box off
% 
% 
%                subplot(4,2,3);
%                     plot(saveBinsVy{2}(:,1),saveBinsVy{2}(:,2),'Color',colours(2,:))
%                     hold on 
%                     coefficients = polyfit(saveBinsVy{2}(saveBinsVy{2}(:,1) > -5 & saveBinsVy{2}(:,1) < 5,1),saveBinsVy{2}(saveBinsVy{2}(:,1) > -5 & saveBinsVy{2}(:,1) < 5,2),1); 
%                     xfit = linspace(min(saveBinsVy{2}(:,1)),max(saveBinsVy{2}(:,1)),length(saveBinsVy{2}(:,1)));
%                     yfit = polyval(coefficients, xfit); 
%                     plot(xfit,yfit,'k-')
%                     %colororder(turbo(num))
%                 %xlim([minValPlot+1 maxValPlot-1])
%                 xlabel('Vy mm/sec')
%                 set(gcf,'color',[1 1 1])
%                 legend(legend_labels{2})
%                 box off
% 
%             % sideways velocity 
% 
%                 subplot(4,2,5);
%                     plot(saveBinsVy{3}(:,1),saveBinsVy{3}(:,2),'Color',colours(3,:))
%                     hold on 
%                     coefficients = polyfit(saveBinsVy{3}(saveBinsVy{3}(:,1) > -5 & saveBinsVy{3}(:,1) < 5,1),saveBinsVy{3}(saveBinsVy{3}(:,1) > -5 & saveBinsVy{3}(:,1) < 5,2),1); 
%                     xfit = linspace(min(saveBinsVy{3}(:,1)),max(saveBinsVy{3}(:,1)),length(saveBinsVy{3}(:,1)));
%                     yfit = polyval(coefficients, xfit); 
%                     plot(xfit,yfit,'k-')
%                     %colororder(turbo(num))
%                 %xlim([minValPlot+1 maxValPlot-1])
%                 xlabel('Vy mm/sec')
%                 set(gcf,'color',[1 1 1])
%                 legend(legend_labels{3})
%                 box off
% 
%             % yaw velocity 
%                 subplot(4,2,7);
%                     plot(saveBinsVy{4}(:,1),saveBinsVy{4}(:,2),'Color',colours(4,:))
%                     hold on 
%                     coefficients = polyfit(saveBinsVy{4}(saveBinsVy{4}(:,1) > -5 & saveBinsVy{4}(:,1) < 5,1),saveBinsVy{4}(saveBinsVy{4}(:,1) > -5 & saveBinsVy{4}(:,1) < 5,2),1); 
%                     xfit = linspace(min(saveBinsVy{4}(:,1)),max(saveBinsVy{4}(:,1)),length(saveBinsVy{4}(:,1)));
%                     yfit = polyval(coefficients, xfit); 
%                     plot(xfit,yfit,'k-')
%                     %colororder(turbo(num))
%                 %xlim([minValPlot+1 maxValPlot-1])
%                 xlabel('Vy mm/sec')
%                 set(gcf,'color',[1 1 1])
%                 legend(legend_labels{4})
%                 box off
%                 
%                 
%                 subplot(4,2,2);
%                     plot(saveBinsVs{1}(:,1),saveBinsVs{1}(:,2),'Color',colours(1,:))
%                     hold on 
%                     coefficients = polyfit(saveBinsVs{1}(saveBinsVs{1}(:,1) > -5 & saveBinsVs{1}(:,1) < 5,1),saveBinsVs{1}(saveBinsVs{1}(:,1) > -5 & saveBinsVs{1}(:,1) < 5,2),1); 
%                     xfit = linspace(min(saveBinsVs{1}(:,1)),max(saveBinsVs{1}(:,1)),length(saveBinsVs{1}(:,1)));
%                     yfit = polyval(coefficients, xfit); 
%                     plot(xfit,yfit,'k-')
%                     %colororder(turbo(num))
%                 %xlim([minValPlot+1 maxValPlot-1])
%                 xlabel('Vy mm/sec')
%                 set(gcf,'color',[1 1 1])
%                 legend(legend_labels{1})
%                 box off
% 
% 
%                subplot(4,2,4);
%                     plot(saveBinsVs{2}(:,1),saveBinsVs{2}(:,2),'Color',colours(2,:))
%                     hold on 
%                     coefficients = polyfit(saveBinsVs{2}(saveBinsVs{2}(:,1) > -5 & saveBinsVs{2}(:,1) < 5,1),saveBinsVs{2}(saveBinsVs{2}(:,1) > -5 & saveBinsVs{2}(:,1) < 5,2),1); 
%                     xfit = linspace(min(saveBinsVs{2}(:,1)),max(saveBinsVs{2}(:,1)),length(saveBinsVs{2}(:,1)));
%                     yfit = polyval(coefficients, xfit); 
%                     plot(xfit,yfit,'k-')
%                     %colororder(turbo(num))
%                 %xlim([minValPlot+1 maxValPlot-1])
%                 xlabel('Vy mm/sec')
%                 set(gcf,'color',[1 1 1])
%                 legend(legend_labels{2})
%                 box off
% 
%             % sideways velocity 
% 
%                 subplot(4,2,6);
%                     plot(saveBinsVs{3}(:,1),saveBinsVs{3}(:,2),'Color',colours(3,:))
%                     hold on 
%                     coefficients = polyfit(saveBinsVs{3}(saveBinsVs{3}(:,1) > -5 & saveBinsVs{3}(:,1) < 5,1),saveBinsVs{3}(saveBinsVs{3}(:,1) > -5 & saveBinsVs{3}(:,1) < 5,2),1); 
%                     xfit = linspace(min(saveBinsVs{3}(:,1)),max(saveBinsVs{3}(:,1)),length(saveBinsVs{3}(:,1)));
%                     yfit = polyval(coefficients, xfit); 
%                     plot(xfit,yfit,'k-')
%                     %colororder(turbo(num))
%                 %xlim([minValPlot+1 maxValPlot-1])
%                 xlabel('Vy mm/sec')
%                 set(gcf,'color',[1 1 1])
%                 legend(legend_labels{3})
%                 box off
% 
%             % yaw velocity 
%                 subplot(4,2,8);
%                     plot(saveBinsVs{4}(:,1),saveBinsVs{4}(:,2),'Color',colours(4,:))
%                     hold on 
%                     coefficients = polyfit(saveBinsVs{4}(saveBinsVs{4}(:,1) > -5 & saveBinsVs{4}(:,1) < 5,1),saveBinsVs{4}(saveBinsVs{4}(:,1) > -5 & saveBinsVs{4}(:,1) < 5,2),1); 
%                     xfit = linspace(min(saveBinsVs{4}(:,1)),max(saveBinsVs{4}(:,1)),length(saveBinsVs{4}(:,1)));
%                     yfit = polyval(coefficients, xfit); 
%                     plot(xfit,yfit,'k-')
%                     %colororder(turbo(num))
%                 %xlim([minValPlot+1 maxValPlot-1])
%                 xlabel('Vs mm/sec')
%                 set(gcf,'color',[1 1 1])
%                 legend(legend_labels{4})
%                 box off
            %%


%             vf_lim = 0.2; 
%             vy_lim = 0.1;
%             vs_lim = 0.15;
%             s_lim = 0.2;
% 
%             vf_edges = [min(ftT.velFor{1}):0.2:max(ftT.velFor{1})]; 
%             vs_edges = [min(ftT.velSide{1}):0.2:max(ftT.velSide{1})];
%             vy_edges = [min(ftT.velYaw{1}):0.1:max(ftT.velYaw{1})];
%             s_edges = [0:0.2:max(speed)];
% 
% 
%             j = figure();clf; 
%             subplot(4,2,1)
%             histogram(VfinHead{1},vf_edges,'Normalization','probability')
%             hold on
%             histogram(VfinHead{3},vf_edges,'Normalization','probability')
%             title(['Trial_00',num2str(nTrial)])
%             xlabel('vf')
%             subplot(4,2,2)
%             histogram(VfinHead{1}(VfinHead{1} > vf_lim | VfinHead{1} < -vf_lim),vf_edges,'Normalization','probability')
%             hold on
%             histogram(VfinHead{3}(VfinHead{3} > vf_lim | VfinHead{3} < -vf_lim),vf_edges,'Normalization','probability')
%             xlabel('vf')
%             legend('prefHead', 'anti-prefHead')
% 
%             subplot(4,2,3)
%             histogram(VyinHead{1},vy_edges,'Normalization','probability')
%             hold on
%             histogram(VyinHead{3},vy_edges,'Normalization','probability')
%             xlabel('vy')
%             subplot(4,2,4)
%             histogram(VyinHead{1}(VyinHead{1} > vy_lim | VyinHead{1} < -vy_lim),vy_edges,'Normalization','probability')
%             hold on
%             histogram(VyinHead{3}(VyinHead{3} > vy_lim | VyinHead{3} < -vy_lim),vy_edges,'Normalization','probability')
%             xlabel('vy')
% 
%             subplot(4,2,5)
%             histogram(VsinHead{1},vs_edges,'Normalization','probability')
%             hold on
%             histogram(VsinHead{3},vs_edges,'Normalization','probability')
%             xlabel('vs')
%             subplot(4,2,6)
%             histogram(VsinHead{1}(VsinHead{1} > vs_lim | VsinHead{1} < -vs_lim),vs_edges,'Normalization','probability')
%             hold on
%             histogram(VsinHead{3}(VsinHead{3} > vs_lim | VsinHead{3} < -vs_lim),vs_edges,'Normalization','probability')
%             xlabel('vs')
% 
%             subplot(4,2,7)
%             histogram(SinHead{1},s_edges,'Normalization','probability')
%             hold on
%             histogram(SinHead{3},s_edges,'Normalization','probability')
%             xlabel('speed')
%             subplot(4,2,8)
%             histogram(SinHead{1}(SinHead{1} > s_lim),s_edges,'Normalization','probability')
%             hold on
%             histogram(SinHead{3}(SinHead{3} > s_lim),s_edges,'Normalization','probability')
%             xlabel('speed')

            if savePlots == 1
                saveas(g, fullfile(lineplotDir,[expID,'_',num2str(nTrial),'_',option,'_activityVsbehaviour_angle.fig']));
                %saveas(j, fullfile(imagesDir,[expID,'_',num2str(nTrial),option,'_behaviour_histograms_angle.fig']));
            end
    end
end