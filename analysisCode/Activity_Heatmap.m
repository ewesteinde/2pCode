function Activity_Heatmap(ftT, roiData, Z, Zf, nTrial,savePlots, heatmapDir, expID)

    vf = ftT.velFor{1};
    vs = ftT.velSide{1};
    vy = ftT.velYaw{1};
    angle = ftT.cueAngle{1};
    
    trial_roiData = roiData(roiData.trialNum == nTrial,:);
    
    for type = 1:2
        if type == 1
            activity = Z;
            activity_name = 'Z';
        else
            activity = Zf;
            activity_name = 'dff'; 
        end
        
        activity_temp = zeros(size(activity.(3){1}));
        for roi = 1:size(Z,1)
            activity_temp =  activity_temp + activity.(3){roi};
        end
        
        activity_values = activity_temp/size(Z,1);

        x_values = angle;
        y_values = vf;


        x_edges = [-180:10:180]; 
        y_edges = [-2:0.5:10];

        [N, heatmap, x_centers, y_centers] = create_activity_heatmap(x_values, y_values, activity_values, x_edges, y_edges);



        figure(); clf;
        f(1) = subplot(3,1,1);
        s = pcolor(heatmap); 
        ylabel('Vf mm/s')
        title(['Mean ',activity_name], 'interpreter', 'none')
        xt = get(gca, 'XTick');                            
        xtlbl = linspace(x_centers(xt(1)), x_centers(xt(end)), numel(xt));                  
        set(gca, 'XTick',xt, 'XTickLabel',xtlbl)
        xlabel('angle')
        colorbar
        yt = get(gca, 'YTick');
        ytlbl = linspace(y_centers(yt(1)), y_centers(yt(end)), numel(yt));
        set(gca, 'YTick',yt, 'YTickLabel',ytlbl)
        set(s, 'EdgeColor', 'none');

        x_values = vy;
        y_values = vf;

        x_edges = [-8:0.5:8]; 
        y_edges = [-2:0.5:10];


        [N, heatmap, x_centers, y_centers] = create_activity_heatmap(x_values, y_values, activity_values, x_edges, y_edges);

        f(2) = subplot(3,1,2);
        s = pcolor(heatmap); 
        ylabel('Vf mm/s')
        xt = get(gca, 'XTick');                            
        xtlbl = linspace(x_centers(xt(1)), x_centers(xt(end)), numel(xt));                  
        set(gca, 'XTick',xt, 'XTickLabel',xtlbl)
        xlabel('Vy deg/s')
        colorbar
        yt = get(gca, 'YTick');
        ytlbl = linspace(y_centers(yt(1)), y_centers(yt(end)), numel(yt));
        set(gca, 'YTick',yt, 'YTickLabel',ytlbl)
        set(s, 'EdgeColor', 'none');


% uncomment to check side relationship

        x_values = angle;
        y_values = vy;

        x_edges = [-180:10:180];  
        y_edges = [-10:1:10]; 

        [N, heatmap, x_centers, y_centers] = create_activity_heatmap(x_values, y_values, activity_values, x_edges, y_edges);


        f(3) = subplot(3,1,3);
        s = pcolor(heatmap); 
        ylabel('Vy rad/s')
        xt = get(gca, 'XTick');                            
        xtlbl = linspace(x_centers(xt(1)), x_centers(xt(end)), numel(xt));                  
        set(gca, 'XTick',xt, 'XTickLabel',xtlbl)
        xlabel('angle')
        colorbar
        yt = get(gca, 'YTick');
        ytlbl = linspace(y_centers(yt(1)), y_centers(yt(end)), numel(yt));
        set(gca, 'YTick',yt, 'YTickLabel',ytlbl)
        set(s, 'EdgeColor', 'none');

        if savePlots
            saveas(gcf, fullfile(heatmapDir,[expID,'_',num2str(nTrial),'_',activity_name,'_AveROIs_heatmap.fig']));
        end

    end
    
    
% plot sep heatmaps for L & R LALs
    if regexp(trial_roiData.roiName{1},'LAL')
        for roi = 1:size(trial_roiData,1)

            for type = 1:2

                if type == 1
                    activity_values = Z.(3){roi};
                    activity_name = 'Z';
                else
                    activity_values = Zf.(3){roi};
                    activity_name = 'dff'; 
                end

                x_values = angle;
                y_values = vf;


                x_edges = [-180:10:180]; 
                y_edges = [-2:0.5:10];

                [N, heatmap, x_centers, y_centers] = create_activity_heatmap(x_values, y_values, activity_values, x_edges, y_edges);

                figure(); clf;
                f(1) = subplot(3,1,1);
                s = pcolor(heatmap); 
                ylabel('Vf mm/s')
                xt = get(gca, 'XTick');                            
                xtlbl = linspace(x_centers(xt(1)), x_centers(xt(end)), numel(xt));                  
                set(gca, 'XTick',xt, 'XTickLabel',xtlbl)
                xlabel('angle')
                colorbar
                title([activity_name,'_',trial_roiData.roiName{roi}], 'interpreter', 'none')
                yt = get(gca, 'YTick');
                ytlbl = linspace(y_centers(yt(1)), y_centers(yt(end)), numel(yt));
                set(gca, 'YTick',yt, 'YTickLabel',ytlbl)
                set(s, 'EdgeColor', 'none');

                x_values = vy;
                y_values = vf;

                x_edges = [-8:0.5:8]; 
                y_edges = [-2:0.5:10];


                [N, heatmap, x_centers, y_centers] = create_activity_heatmap(x_values, y_values, activity_values, x_edges, y_edges);

                f(2) = subplot(3,1,2);
                s = pcolor(heatmap); 
                ylabel('Vf mm/s')
                xt = get(gca, 'XTick');                            
                xtlbl = linspace(x_centers(xt(1)), x_centers(xt(end)), numel(xt));                  
                set(gca, 'XTick',xt, 'XTickLabel',xtlbl)
                xlabel('Vy deg/s')
                colorbar
                yt = get(gca, 'YTick');
                ytlbl = linspace(y_centers(yt(1)), y_centers(yt(end)), numel(yt));
                set(gca, 'YTick',yt, 'YTickLabel',ytlbl)
                set(s, 'EdgeColor', 'none');


        % uncomment to check side relationship

                x_values = angle;
                y_values = vy;

                x_edges = [-180:10:180];  
                y_edges = [-10:1:10]; 

                [N, heatmap, x_centers, y_centers] = create_activity_heatmap(x_values, y_values, activity_values, x_edges, y_edges);


                f(3) = subplot(3,1,3);
                s = pcolor(heatmap); 
                ylabel('Vy rad/s')
                xt = get(gca, 'XTick');                            
                xtlbl = linspace(x_centers(xt(1)), x_centers(xt(end)), numel(xt));                  
                set(gca, 'XTick',xt, 'XTickLabel',xtlbl)
                xlabel('angle')
                colorbar
                yt = get(gca, 'YTick');
                ytlbl = linspace(y_centers(yt(1)), y_centers(yt(end)), numel(yt));
                set(gca, 'YTick',yt, 'YTickLabel',ytlbl)
                set(s, 'EdgeColor', 'none');

                if savePlots
                    saveas(gcf, fullfile(heatmapDir,[expID,'_',num2str(nTrial),'_',activity_name,'_', trial_roiData.roiName{roi},'_heatmap_sepROIs.fig']));
                end

            end
        end
        
        if regexp(heatmapDir,'PFL2_3')

            for type = 1:2

                if type == 1
                    activity = Z;
                    activity_name = 'Z';
                else
                    activity = Zf;
                    activity_name = 'dff'; 
                end
                
                % L - R
                activity_values = activity.(3){1} - activity.(3){2};

                x_values = angle;
                y_values = vf;


                x_edges = [-180:10:180]; 
                y_edges = [-2:0.5:10];

                [N, heatmap, x_centers, y_centers] = create_activity_heatmap(x_values, y_values, activity_values, x_edges, y_edges);



                figure(); clf;
                f(1) = subplot(3,1,1);
                s = pcolor(heatmap); 
                ylabel('Vf mm/s')
                xt = get(gca, 'XTick');                            
                xtlbl = linspace(x_centers(xt(1)), x_centers(xt(end)), numel(xt));                  
                set(gca, 'XTick',xt, 'XTickLabel',xtlbl)
                xlabel('angle')
                colorbar
                title([activity_name,'_L-R'], 'interpreter', 'none')
                yt = get(gca, 'YTick');
                ytlbl = linspace(y_centers(yt(1)), y_centers(yt(end)), numel(yt));
                set(gca, 'YTick',yt, 'YTickLabel',ytlbl)
                set(s, 'EdgeColor', 'none');

                x_values = vy;
                y_values = vf;

                x_edges = [-8:0.5:8]; 
                y_edges = [-2:0.5:10];


                [N, heatmap, x_centers, y_centers] = create_activity_heatmap(x_values, y_values, activity_values, x_edges, y_edges);

                f(2) = subplot(3,1,2);
                s = pcolor(heatmap); 
                ylabel('Vf mm/s')
                xt = get(gca, 'XTick');                            
                xtlbl = linspace(x_centers(xt(1)), x_centers(xt(end)), numel(xt));                  
                set(gca, 'XTick',xt, 'XTickLabel',xtlbl)
                xlabel('Vy deg/s')
                colorbar
                yt = get(gca, 'YTick');
                ytlbl = linspace(y_centers(yt(1)), y_centers(yt(end)), numel(yt));
                set(gca, 'YTick',yt, 'YTickLabel',ytlbl)
                set(s, 'EdgeColor', 'none');

                x_values = angle;
                y_values = vy;

                x_edges = [-180:10:180];  
                y_edges = [-10:1:10]; 

                [N, heatmap, x_centers, y_centers] = create_activity_heatmap(x_values, y_values, activity_values, x_edges, y_edges);


                f(3) = subplot(3,1,3);
                s = pcolor(heatmap); 
                ylabel('Vy rad/s')
                xt = get(gca, 'XTick');                            
                xtlbl = linspace(x_centers(xt(1)), x_centers(xt(end)), numel(xt));                  
                set(gca, 'XTick',xt, 'XTickLabel',xtlbl)
                xlabel('angle')
                colorbar
                yt = get(gca, 'YTick');
                ytlbl = linspace(y_centers(yt(1)), y_centers(yt(end)), numel(yt));
                set(gca, 'YTick',yt, 'YTickLabel',ytlbl)
                set(s, 'EdgeColor', 'none');

                if savePlots
                    saveas(gcf, fullfile(heatmapDir,[expID,'_',num2str(nTrial),'_',activity_name,'_PFL2_3_heatmap_Left-Right.fig']));
                end

            end
        end
        
    end

end