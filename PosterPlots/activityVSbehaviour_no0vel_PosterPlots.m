function activityVSbehaviour_no0vel_PosterPlots(ftT, Z, roiData, nTrial, threshold, expMd,savePlots,plotDir)

%% Remove idx where the fly isn't moving
    
    total_mov_mm = abs(ftT.velFor{1}) + abs(ftT.velSide{1}) + abs(ftT.velYaw{1}*4.5);
    no0vel_idx = find(total_mov_mm > threshold);
    %speed = sqrt(ftT.velSide{1}.^2 + ftT.velFor{1}.^2);
    %vy = ftT.yawSpeed{1}; 
    %no0vel_idx = find(abs(ftT.velSide{1}) > 0.5);
    %no0vel_idx = find(speed > threshold); 
    vf = ftT.velFor{1}(no0vel_idx);
    vs = ftT.velSide{1}(no0vel_idx);
    vy = ftT.velYaw{1}(no0vel_idx);
    angle = ftT.cueAngle{1}(no0vel_idx); 

    xTrial = cosd(angle);
    yTrial = sind(angle); 
    trialHeadingVector(1) = sum(xTrial)/length(xTrial);
    trialHeadingVector(2) = sum(yTrial)/length(yTrial);

    goalStr = sqrt(trialHeadingVector(1).^2 + trialHeadingVector(2).^2); 
    goal = atan2(trialHeadingVector(2),trialHeadingVector(1));
    
%%

    sum_mean = cell(3,1); 
    vy = (vy/ (2*pi) ) * 360; 
    edges_vf = [min(vf):0.5:max(vf)];
    edges_vs = [min(vs):0.5:max(vs)];
    edges_vy = [min(vy):10:max(vy)];
    edges_angle = [-180:10:180]; 
    
    trial_roiData = roiData(roiData.trialNum == nTrial,:);

        sum_mean{1} = zeros(length(edges_vf)-1,1);
        sum_mean{2} = zeros(length(edges_vs)-1,1);
        sum_mean{3} = zeros(length(edges_vy)-1,1);
        sum_mean{4} = zeros(length(edges_angle)-1,1); 
        
        activityTable = Z;
        ncol = size(trial_roiData,1);
        color = (cbrewer2('RdYlBu', ncol));

        if ~contains(expMd.expName{1},'PFL2_3')
            
            
            figure(Name=['Zscore Goal: ',num2str(rad2deg(goal)),' strength: ',num2str(goalStr)]);clf
            set(gcf,'color','w')
            set(gcf,'Renderer','painters')
            label = 'Z';
            
            
            for roi = 1:size(trial_roiData,1)
                activity = activityTable.(3){roi};
                activity = activity(no0vel_idx);

                % vf
% 
%                 behaviour = vf; 
%                 [zscore, centers_vf] = binData(activity, behaviour, edges_vf);
%                 sum_mean{1} = sum_mean{1} + zscore; 
% 
%                 subplot(4,1,1);
%                 plot(centers_vf,zscore)
%                 colororder(parula(roi))
%                 ylabel(label)
%                 xlabel('vf (mm/s)')
%                 hold on
% 
% 
%                 % vs 
%                 behaviour = vs; 
%                 [zscore, centers_vs] = binData(activity, behaviour, edges_vs);
%                 sum_mean{2} = sum_mean{2} + zscore; 
% 
%                 subplot(4,1,2);
%                 plot(centers_vs,zscore)
%                 colororder(parula(roi))
%                 ylabel(label)
%                 xlabel('vs (mm/s)')
%                 hold on
% 
%                 % vy 
%                 [zscore, centers_vy] = binData(activity, vy, edges_vy);
%                 sum_mean{3} = sum_mean{3} + zscore; 
% 
% 
%                 subplot(4,1,3);
%                 plot(centers_vy,zscore)
%                 colororder(parula(roi))
%                 ylabel(label)
%                 xlabel('vy (deg/s)')
%                 hold on

                % angle
                [zscore, centers_angle] = binData(activity, angle, edges_angle);
                sum_mean{4} = sum_mean{4} + zscore; 


                %subplot(4,1,4);
                
                plot(centers_angle,zscore,'DisplayName',num2str(roi),'color',color(roi,:))
                colororder()
                xlabel('cue pos (deg)')
                hold on
            end


%                 subplot(4,1,1)
%                 plot(centers_vf,sum_mean{1}/size(trial_roiData,1),'k','LineWidth',1.5)
%                 box off
%                 subplot(4,1,2)
%                 plot(centers_vs,sum_mean{2}/size(trial_roiData,1),'k','LineWidth',1.5)
%                 box off
%                 subplot(4,1,3)
%                 plot(centers_vy,sum_mean{3}/size(trial_roiData,1),'k','LineWidth',1.5)
%                 box off
%                 subplot(4,1,4)
                plot(centers_angle,sum_mean{4}/size(trial_roiData,1),'k','LineWidth',1.5)
                %legend(L)
                box off

        else

                    % vy 
                    f1 = figure(Name=['Goal: ',num2str(rad2deg(goal)),' strength: ',num2str(goalStr)]);
                    set(gcf,'color','w')
                    set(gcf,'Renderer','painters')
                    label = 'Z'; 

                    activity = activityTable.(3){1};
                    activity = activity(no0vel_idx);
                    behaviour = vy; 
                    [zscore, centers_vy, SEM] = binData(activity, behaviour, edges_vy);
                    keepIndex = ~isnan(SEM);
                    SEMhigh = [zscore(keepIndex) + SEM(keepIndex)]'; 
                    SEMlow = [zscore(keepIndex) - SEM(keepIndex)]';
                    ax1 = subplot(2,1,1);
                    patch([centers_vy(keepIndex) fliplr(centers_vy(keepIndex))],[SEMhigh fliplr(SEMlow)],'b','FaceAlpha',.3,'EdgeColor','none')
                    hold on
                    plot(centers_vy,zscore)
                    ylabel(label)
                    xlabel('vy (deg/s)')

                    activity = activityTable.(3){2};
                    activity = activity(no0vel_idx);
                    behaviour = vy; 
                    [zscore, centers_vy, SEM] = binData(activity, behaviour, edges_vy); 
                    keepIndex = ~isnan(SEM);
                    SEMhigh = [zscore(keepIndex) + SEM(keepIndex)]'; 
                    SEMlow = [zscore(keepIndex) - SEM(keepIndex)]';
                    patch([centers_vy(keepIndex) fliplr(centers_vy(keepIndex))],[SEMhigh fliplr(SEMlow)],'r','FaceAlpha',.3,'EdgeColor','none')
                    hold on
                    plot(centers_vy,zscore)
                    ylabel(label)
                    xlabel('vy (deg/s)')
                    ylim([-4,4])

                    %vy L-R
                    ax2 = subplot(2,1,2) ;

                    activity = activityTable.(3){2} - activityTable.(3){1};
                    activity = activity(no0vel_idx);
                    behaviour = vy; 
                    [zscore, centers_vy, SEM] = binData(activity, behaviour, edges_vy);
                    keepIndex = ~isnan(SEM);
                    SEMhigh = [zscore(keepIndex) + SEM(keepIndex)]'; 
                    SEMlow = [zscore(keepIndex) - SEM(keepIndex)]';
                    patch([centers_vy(keepIndex) fliplr(centers_vy(keepIndex))],[SEMhigh fliplr(SEMlow)],'k','FaceAlpha',.3,'EdgeColor','none')
                    hold on
                    plot(centers_vy,zscore,'k')
                    yline(0,'--r')
                    ylabel('R - L')
                    xlabel('vy (deg/s)')
                    ylim([-4,4])
                    linkaxes([ax1 ax2],'x')


                    % cue Pos 
                    f2 = figure(Name=['Goal: ',num2str(rad2deg(goal)),' strength: ',num2str(goalStr)]);
                    ax1b = subplot(2,1,1);
                    set(gcf,'color','w')
                    set(gcf,'Renderer','painters')
                    label = 'Z'; 

                    activity = activityTable.(3){1};
                    activity = activity(no0vel_idx);
                    behaviour = wrapTo180(wrapTo180(angle)-wrapTo180(rad2deg(goal))); 
                    [zscore, centers_angle, SEM] = binData(activity, behaviour, edges_angle);
                    keepIndex = ~isnan(SEM);
                    SEMhigh = [zscore(keepIndex) + SEM(keepIndex)]'; 
                    SEMlow = [zscore(keepIndex) - SEM(keepIndex)]';
                    patch([centers_angle(keepIndex) fliplr(centers_angle(keepIndex))],[SEMhigh fliplr(SEMlow)],'b','FaceAlpha',.3,'EdgeColor','none')
                    hold on
                    plot(centers_angle,zscore)
                    ylabel(label)
                    xlabel('Cue Position from Goal')
                    ylim([-4,4])

                    activity = activityTable.(3){2};
                    activity = activity(no0vel_idx);
                    [zscore, centers_angle, SEM] = binData(activity, behaviour, edges_angle); 
                    keepIndex = ~isnan(SEM);
                    SEMhigh = [zscore(keepIndex) + SEM(keepIndex)]'; 
                    SEMlow = [zscore(keepIndex) - SEM(keepIndex)]';
                    patch([centers_angle(keepIndex) fliplr(centers_angle(keepIndex))],[SEMhigh fliplr(SEMlow)],'r','FaceAlpha',.3,'EdgeColor','none')
                    hold on
                    plot(centers_angle,zscore)
                    ylabel('df/f (z-scored)')
                    xlabel('Cue Position from Goal')

                    %cue Pos L-R
                    ax2b = subplot(2,1,2);
                    set(gcf,'color','w')
                    set(gcf,'Renderer','painters')
                    label = 'Z'; 

                    activity = activityTable.(3){2} - activityTable.(3){1};
                    activity = activity(no0vel_idx);
                    [zscore, centers_angle, SEM] = binData(activity, behaviour, edges_angle);
                    keepIndex = ~isnan(SEM);
                    SEMhigh = [zscore(keepIndex) + SEM(keepIndex)]'; 
                    SEMlow = [zscore(keepIndex) - SEM(keepIndex)]';
                    patch([centers_angle(keepIndex) fliplr(centers_angle(keepIndex))],[SEMhigh fliplr(SEMlow)],'k','FaceAlpha',.3,'EdgeColor','none')
                    hold on
                    plot(centers_angle,zscore,'k')
                    yline(0,'--r')
                    ylabel('R - L')
                    xlabel('Cue Position from Goal')
                    ylim([-4,4])
                    linkaxes([ax1b ax2b],'x')

        end
        
if savePlots == 1
    saveas(f1, fullfile(plotDir,['trial_',num2str(nTrial),'yawvsZ']));
    saveas(f2, fullfile(plotDir,['trial_',num2str(nTrial),'cuePosvsZ']));
end

end