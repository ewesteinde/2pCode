
function plot_jumps(jump_array, jump_array_down, Z, ftData, expID, nTrial, jumpDir, windowSize, savePlots, volumeRate)

%% plot jump windows


    figure()
    for jump = 1:length(jump_array)
        window_idx = [jump_array(jump,1):jump_array(jump,3)];
        jump_cueAngle = ftData.cueAngle{1}(window_idx);
        jump_idx = round(length(jump_cueAngle)/2);
        time = [-windowSize:1/60:windowSize];

        subplot(length(jump_array),1,jump)
        plot(time,jump_cueAngle)
        %xline(0)
        ylim([-200 200])
    end

    if savePlots == 1
        saveas(gcf, fullfile(jumpDir,[expID,'_',num2str(nTrial),'_cueAngleSum.fig']));
    end


    figure()
    for jump = 1:length(jump_array_down)
        window_idx = [jump_array_down(jump,1):jump_array_down(jump,3)];
        time = [-windowSize:1/volumeRate:windowSize];
        if length(time) < length(window_idx)
            time = [-windowSize:1/volumeRate:windowSize + 1/volumeRate];
        end
        subplot(length(jump_array_down),1,jump)
        for roi = 1:size(Z,1)
            jump_Z = Z.(3){roi}(window_idx);
            roi_jump(roi,:) = jump_Z; 
            jump_idx = round(length(jump_Z)/2);
            plot(time,jump_Z)
            hold on
        end
        jump_aveZ = sum(roi_jump,1)/size(Z,1);
        plot(time,jump_aveZ,'k','lineWidth',1.5)
        colororder(parula(roi))
        xline(0)
        xlim([-10 10])
        %title('Z')
    end

        if savePlots == 1
            saveas(gcf, fullfile(jumpDir,[expID,'_',num2str(nTrial),'_roiDataSum.fig']));
        end

    %% individual jump plots


    for jump = 1:length(jump_array)
        i = figure();
        window_idx = [jump_array(jump,1):jump_array(jump,3)];
        jump_cueAngle = ftData.cueAngle{1}(window_idx);
        jump_idx = round(length(jump_cueAngle)/2);
        time = [-windowSize:1/60:windowSize];

        ax(1) = subplot(14,1,1:4);
        plot(time,jump_cueAngle)
        %xline(0)
        ylim([-200 200])
        ylabel('cue angle')
        title(['jump ', num2str(jump)])

        ax(2) = subplot(14,1,9:10);
        plot(time, smoothdata(ftData.velFor{1}(window_idx),'loess',20))
        ylabel('vf')
        xline(0)
        ax(3) = subplot(14,1,11:12);
        plot(time, smoothdata(ftData.velYaw{1}(window_idx),'loess',20))
        ylabel('vy')
        xline(0)
        ax(4) = subplot(14,1,13:14);
        plot(time, smoothdata(ftData.velSide{1}(window_idx),'loess',20))
        ylabel('vs')
        xline(0)


        window_idx = [jump_array_down(jump,1):jump_array_down(jump,3)];
        time = [-windowSize:1/volumeRate:windowSize];
        time = [-windowSize:1/volumeRate:windowSize];
        if length(time) < length(window_idx)
            time = [-windowSize:1/volumeRate:windowSize + 1/volumeRate];
        end
        ax(5) = subplot(14,1,5:8);
        for roi = 1:size(Z,1)
            jump_Z = Z.(3){roi}(window_idx);
            roi_jump(roi,:) = jump_Z; 
            jump_idx = round(length(jump_Z)/2);
            plot(time,jump_Z)
            colororder(parula(roi))
            hold on
        end
        jump_aveZ = sum(roi_jump,1)/size(Z,1);
        plot(time,jump_aveZ,'k','lineWidth',1.5)
        xline(0)
        xlim([-10 10])
        ylabel('Z')
        linkaxes(ax,'x')

    %     subplot(14,1,9:10)
    %     plot(time, ftT_down.fwSpeed{1}(window_idx))
    %     ylabel('vf')
    %     xline(0)
    %     subplot(14,1,11:12)
    %     plot(time, ftT_down.yawSpeed{1}(window_idx))
    %     ylabel('vy')
    %     xline(0)
    %     subplot(14,1,13:14)
    %     plot(time, ftT_down.sideSpeed{1}(window_idx))
    %     ylabel('vs')
    %     xline(0)

        if savePlots == 1
            saveas(i, fullfile(jumpDir,[expID,'_',num2str(nTrial),'_jump',num2str(jump),'.fig']));
        end

    end

end
    