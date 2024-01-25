function menotaxis_linePlots(rootDir, savePlots)

summaries = dir(fullfile(rootDir, '**/*headingSummary*.mat')); 

%summaries = dir(fullfile(rootDir,'*headingSummary*.mat'));
    for s = 1:length(summaries)
        load(fullfile(summaries(s).folder,summaries(s).name)); 
        flySum = flySum(~ismembertol(flySum.rhoTotal,1,10^-10),:); % gets rid of trials w/ no heading change --> indicates problem
        flySum = flySum(flySum.perMove > 5 & ~isnan(flySum.perMove),:); % only look at trials where fly's vel was above threshold for at least 5% of the trial (30 sec)
        for f = 1:size(flySum,1)
            %try
            folder = flySum.folder{f};
            nTrial = flySum.trial(f); 
            processedData_dir = fullfile(folder,'processed_data');

            % Get data files
            expID = get_expID(folder);
            expList = {expID};

            % Load metadata  
            [~, trialMd] = load_metadata(expList, folder); 

            % get processed data
            data_filelist = dir(processedData_dir);
            for files = 1:length(data_filelist)
                if regexp(data_filelist(files).name,'.mat') & regexp(data_filelist(files).name,['00',num2str(nTrial)])
                    load(fullfile(processedData_dir,data_filelist(files).name));
                end
            end
        %% determine Menotaxic goal(s) of fly 
        % collect window idxs during which fly was menotaxing to this goal to some
        % degree
        % plot dff vs heading lineplots of all rois for those segments 

        % need to load in
        % fly heading summary
        % ftDown & roi Data for each trial 
        % Z & dff

        folderSum = flySum(f,:); 
        menotaxisThres = 0.5 ; 
        menotaxis_vector = []; 
        menotaxis_windows = []; 


        menotaxis_vector(:,1) = folderSum.rho_60sec{1}(folderSum.rho_60sec{1} > menotaxisThres); 
        menotaxis_vector(:,2) = folderSum.theta_60sec{1}(folderSum.rho_60sec{1} > menotaxisThres); 
        menotaxis_windows = folderSum.window_idx{1}(folderSum.rho_60sec{1} > menotaxisThres,:); 

        figure();polarscatter(menotaxis_vector(:,2),menotaxis_vector(:,1))

        %figure();polarhistogram(menotaxis_vector(:,2))


        edges = [-180:20:180];
        centers = (edges + 5);
        centers = centers(centers < max(edges));
        menotaxis_vector = unique(menotaxis_vector,'rows'); % vectors w/ exact same heading & str are sus
        [N] = histcounts(rad2deg(menotaxis_vector(:,2)),edges);
        
        %figure();plot(centers,N)

        menotaxis_deg = wrapTo360(centers(N == max(N)));
        
        for goal = 1:length(menotaxis_deg)
            menotaxis_rad = wrapTo2Pi(deg2rad(menotaxis_deg(goal)));
            lim1 = wrapTo360(menotaxis_deg(goal) - 20); 
            lim2 = wrapTo360(menotaxis_deg(goal) + 20); 

            deg360 = rad2deg(wrapTo2Pi(menotaxis_vector(:,2)));

            if lim1 > lim2
                [index] = find(deg360 > lim1 | deg360 < lim2); 
            else
                [index] = find(deg360 < lim2 & deg360 > lim1);
            end
            
            menotaxis_idx = [];
            for idx = 1:length(index)
                menotaxis_idx(idx,:) = [menotaxis_windows(index(idx),1):menotaxis_windows(index(idx),2)];
            end
            menotaxis_idx = unique(menotaxis_idx); 


            %organize Z & Zf into diff tables
%             ZData = [];
%             dffData = [];
%             for roi = 1:length(unique(Z.roiName))
%                 newZrow = table(roi,'VariableNames',{'roi'});
%                 newZrow.Z = {Z(Z.roiName == roi,:).data}; 
%                 newZrow.second = {Z(Z.roiName == roi,:).second}; 
% 
%                 ZData = [ZData; newZrow];
% 
%                 newdffrow = table(roi,'VariableNames',{'roi'});
%                 newdffrow.dff = {Zf(Zf.roiName == roi,:).data}; 
%                 newdffrow.second = {Zf(Zf.roiName == roi,:).second}; 
% 
%                 dffData = [dffData; newdffrow];
%             end


            edges_angle = [-180:10:180];
            fig1 = figure();
            sum_mean = zeros(length(edges_angle)-1,1);
            movThres = 0.5; 
            total_mov_rad = abs(ftT.velFor{1}(menotaxis_idx)/4.5) + abs(ftT.velSide{1}(menotaxis_idx)/4.5) + abs(ftT.velYaw{1}(menotaxis_idx));
            for roi = 1:size(ZData,1)
                activity = ZData(roi,:).Z{1}(menotaxis_idx);
                activity = activity(total_mov_rad > movThres); 
                behaviour = wrapTo180(ftT.cueAngle{1}(menotaxis_idx)-wrapTo180(menotaxis_deg(goal))) ; 
                behaviour = behaviour(total_mov_rad > movThres); 
                [angle_zscore, centers_angle] = binData(activity, behaviour, edges_angle);
                sum_mean = sum_mean + angle_zscore; 

                plot(centers_angle,angle_zscore)
                colororder(parula(roi))
                ylabel('Z')
                xlabel('distance from goal (deg)')
                str = {['Goal: ',num2str(menotaxis_deg(goal)),' +/- 20'],['mean vector str: ',(num2str(mean(menotaxis_vector(:,1))))]};
                dim = [0.35 0.72 0.2 0.2];
                annotation('textbox',dim,'String',str,'FitBoxToText','on','EdgeColor','w')
                hold on
            end
            plot(centers_angle,sum_mean/size(ZData,1),'k','LineWidth',1.5)
            xlim([-180 180])
            box off
            set(gcf,'color','w');

            fig2 = figure();
            sum_mean = zeros(length(edges_angle)-1,1);
            for roi = 1:size(dffData,1)
                activity = dffData(roi,:).dff{1}(menotaxis_idx);
                activity = activity(total_mov_rad > movThres); 
                behaviour = wrapTo180(ftT.cueAngle{1}(menotaxis_idx)-wrapTo180(menotaxis_deg(goal))); 
                behaviour = behaviour(total_mov_rad > movThres);
                [angle_zscore, centers_angle] = binData(activity, behaviour, edges_angle);
                sum_mean = sum_mean + angle_zscore; 

                plot(centers_angle,angle_zscore)
                colororder(parula(roi))
                ylabel('dff')
                xlabel('distance from goal (deg)')
                str = {['Goal: ',num2str(menotaxis_deg(goal)),' +/- 20'],['mean vector str: ',(num2str(mean(menotaxis_vector(:,1))))]};
                dim = [0.35 0.72 0.2 0.2];
                annotation('textbox',dim,'String',str,'FitBoxToText','on','EdgeColor','w')
                xlabel('distance from goal (deg)')
                hold on
            end
            plot(centers_angle,sum_mean/size(dffData,1),'k','LineWidth',1.5)
            xlim([-180 180])
            box off
            set(gcf,'color','w');
            
            %%

            fig3 = figure();
            polarscatter(menotaxis_vector(index,2),menotaxis_vector(index,1))
            [x, y] = pol2cart(menotaxis_vector(index,2),menotaxis_vector(index,1)); 
            meanx = sum(x)/length(x); 
            meany = sum(y)/length(y);
            [mean_theta, mean_rho] = cart2pol(meanx, meany);
            secMove = sum(total_mov_rad > movThres)/60; 
            hold on
            polarplot([0,mean_theta], [0,mean_rho],'k','LineWidth',2)
            str = {['Mean vector str: ',num2str(round(mean_rho,2))],['Movement: ',num2str(round(secMove,2)),'s']};
            dim = [0.72 0.75 0.2 0.2];
            annotation('textbox',dim,'String',str,'FitBoxToText','on','EdgeColor','w')
            set(gcf,'color','w');
            rlim([0 1])

           %pause
                      %%
           edges_angle = [-180:10:180];
            fig4 = figure();
            sum_mean = zeros(length(edges_angle)-1,1);
            movThres = 0.5; 
            total_mov_rad = abs(ftT.velFor{1}/4.5) + abs(ftT.velSide{1}/4.5) + abs(ftT.velYaw{1});
            for roi = 1:size(ZData,1)
                activity = ZData(roi,:).Z{1};
                activity = activity(total_mov_rad > movThres); 
                behaviour = wrapTo180(ftT.cueAngle{1}()-wrapTo180(menotaxis_deg(goal))) ; 
                behaviour = behaviour(total_mov_rad > movThres); 
                [angle_zscore, centers_angle] = binData(activity, behaviour, edges_angle);
                sum_mean = sum_mean + angle_zscore; 

                plot(centers_angle,angle_zscore)
                colororder(parula(roi))
                ylabel('Z')
                xlabel('distance from goal (deg)')
                str = {['Goal: ',num2str(menotaxis_deg(goal)),' +/- 20'],['mean vector str: ',(num2str(mean(menotaxis_vector(:,1))))]};
                dim = [0.35 0.72 0.2 0.2];
                annotation('textbox',dim,'String',str,'FitBoxToText','on','EdgeColor','w')
                hold on
            end
            plot(centers_angle,sum_mean/size(ZData,1),'k','LineWidth',1.5)
            xlim([-180 180])
            box off
            set(gcf,'color','w');

            fig5 = figure();
            sum_mean = zeros(length(edges_angle)-1,1);
            for roi = 1:size(dffData,1)
                activity = dffData(roi,:).dff{1};
                activity = activity(total_mov_rad > movThres); 
                behaviour = wrapTo180(ftT.cueAngle{1}-wrapTo180(menotaxis_deg(goal))); 
                behaviour = behaviour(total_mov_rad > movThres);
                [angle_zscore, centers_angle] = binData(activity, behaviour, edges_angle);
                sum_mean = sum_mean + angle_zscore; 

                plot(centers_angle,angle_zscore)
                colororder(parula(roi))
                ylabel('dff')
                xlabel('distance from goal (deg)')
                str = {['Goal: ',num2str(menotaxis_deg(goal)),' +/- 20'],['mean vector str: ',(num2str(mean(menotaxis_vector(:,1))))]};
                dim = [0.35 0.72 0.2 0.2];
                annotation('textbox',dim,'String',str,'FitBoxToText','on','EdgeColor','w')
                xlabel('distance from goal (deg)')
                hold on
            end
            plot(centers_angle,sum_mean/size(dffData,1),'k','LineWidth',1.5)
            xlim([-180 180])
            box off
            set(gcf,'color','w');

           %%
           %fullfile(folder,'images','lineplots','ZvsDistanceFromGoal.fig')
            if savePlots
                 saveas(fig1, fullfile(folder,'images','lineplots',['ZvsDistanceFromGoal',num2str(goal),'.fig']));
                 saveas(fig1, fullfile(folder,'images','lineplots',['ZvsDistanceFromGoal',num2str(goal),'.png']));
                 saveas(fig1, fullfile(folder,'images','lineplots',['ZvsDistanceFromGoal',num2str(goal),'.svg']));
                 saveas(fig2, fullfile(folder,'images','lineplots',['dffvsDistanceFromGoal',num2str(goal),'.png']));
                 saveas(fig2, fullfile(folder,'images','lineplots',['dffvsDistanceFromGoal',num2str(goal),'.svg']));
                saveas(fig3, fullfile(folder,'images','lineplots',['menotaxisSummary',num2str(goal),'.png']));
                 saveas(fig3, fullfile(folder,'images','lineplots',['menotaxisSummary',num2str(goal),'.svg']));
                  saveas(fig3, fullfile(folder,'images','lineplots',['menotaxisSummary',num2str(goal),'.fig']));
                  saveas(fig4, fullfile(folder,'images','lineplots',['ZvsDistanceFromGoal_wholeTrial',num2str(goal),'.png']));
                 saveas(fig4, fullfile(folder,'images','lineplots',['ZvsDistanceFromGoal_wholeTrial',num2str(goal),'.svg']));
                  saveas(fig4, fullfile(folder,'images','lineplots',['ZvsDistanceFromGoal_wholeTrial',num2str(goal),'.fig']));
                saveas(fig5, fullfile(folder,'images','lineplots',['dffvsDistanceFromGoal_wholeTrial',num2str(goal),'.png']));
                 saveas(fig5, fullfile(folder,'images','lineplots',['dffvsDistanceFromGoal_wholeTrial',num2str(goal),'.svg']));
                  saveas(fig5, fullfile(folder,'images','lineplots',['dffvsDistanceFromGoal_wholeTrial',num2str(goal),'.fig']));
            end
        
            close all
        end
%             catch
%                 disp([folder,' failed'])
%             end
        end         
    end
end



