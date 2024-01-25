function bumpAmpVSbehaviour_no0vel_PosterPlots(ftT, bumpParams, roiData, nTrial, threshold, expMd,savePlots,plotDir)

%% Remove idx where the fly isn't moving
    
    total_mov_mm = abs(ftT.velFor{1}) + abs(ftT.velSide{1}) + abs(ftT.velYaw{1}*4.5);
    no0vel_idx = find(total_mov_mm > threshold);
    %speed = sqrt(ftT.velSide{1}.^2 + ftT.velFor{1}.^2);
    %vy = ftT.yawSpeed{1}; 
    %no0vel_idx = find(abs(ftT.velSide{1}) > 0.5);
    %no0vel_idx = find(speed > threshold); 
    vf = ftT.velFor{1}(no0vel_idx);
    vs = abs(ftT.velSide{1}(no0vel_idx));
    vy = abs(ftT.velYaw{1}(no0vel_idx));
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
    edges_vf = [-4:0.5:max(10)];
    edges_vs = [0:0.5:6];
    edges_vy = [0:10:200];
    edges_angle = [-180:10:180]; 

        sum_mean{1} = zeros(length(edges_vf)-1,1);
        sum_mean{2} = zeros(length(edges_vs)-1,1);
        sum_mean{3} = zeros(length(edges_vy)-1,1);
        sum_mean{4} = zeros(length(edges_angle)-1,1); 
            
            figure(Name=['Zscore Goal: ',num2str(rad2deg(goal)),' strength: ',num2str(goalStr)]);clf
            set(gcf,'color','w')
            set(gcf,'Renderer','painters')
            label = 'bump amplitude';
            
                activity = bumpParams(no0vel_idx);

                % vf

                behaviour = vf; 
                [zscore, centers_vf] = binData(activity, behaviour, edges_vf);
                sum_mean{1} = zscore; 

                subplot(4,1,1);
                plot(centers_vf,zscore)
                ylabel(label)
                xlabel('vf (mm/s)')
                hold on
                box off


                % vs 
                behaviour = vs; 
                [zscore, centers_vs] = binData(activity, behaviour, edges_vs);
                sum_mean{2} = zscore; 

                subplot(4,1,2);
                plot(centers_vs,zscore)
                ylabel(label)
                xlabel('vs (mm/s)')
                hold on
                box off

                % vy 
                [zscore, centers_vy] = binData(activity, vy, edges_vy);
                sum_mean{3} = zscore; 


                subplot(4,1,3);
                plot(centers_vy,zscore)
                ylabel(label)
                xlabel('vy (deg/s)')
                hold on
                box off

                figure(Name=['Zscore Goal: ',num2str(rad2deg(goal)),' strength: ',num2str(goalStr)]);clf
                set(gcf,'color','w')
                set(gcf,'Renderer','painters')
                label = 'bump amplitude';
                % angle
                [zscore, centers_angle] = binData(activity, angle, edges_angle);
                sum_mean{4} = zscore; 


                %subplot(4,1,4);
                plot(centers_angle,zscore)
                ylabel(label)
                xlabel('cue pos (deg)')
                hold on
                box off

        
if savePlots == 1
    saveas(f1, fullfile(plotDir,['trial_',num2str(nTrial),'yawvsAmp']));
    saveas(f2, fullfile(plotDir,['trial_',num2str(nTrial),'cuePosvsAmp']));
end

end