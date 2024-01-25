function headingVector_summary(rootDir, PFL2, PFL3, saveSum, plotHeading)
    folders_all = get_folders(rootDir, PFL2, PFL3);



   % load in all experiment data and seperate into celltype & fly 

    [flyFolders, PFL3_flies, PFL2_flies] = OrganizeExperiments(folders_all, PFL3, PFL2);

    windowSize = 60; 
    [summaryDataStruct] = summarizeFlyHeading(flyFolders, rootDir, 1.5, windowSize, saveSum, plotHeading);
    menotaxis_linePlots(rootDir, 1)
    
    disp(['PFL2 flies: ',num2str(length(PFL2_flies))]);
    disp(['PFL3 flies: ',num2str(length(PFL3_flies))]);
    disp(['Total flies: ' num2str(length(PFL2_flies) + length(PFL3_flies))]); 

    summaryData = struct2cell(summaryDataStruct);
    summaryData = summaryData(~cellfun(@isempty,summaryData));
    
%% summary heading plots across all flies    
    rho_all = [];
    rho_wholeTrial_all = []; 
    theta_all = []; 
    theta_wholeTrial_all = [];
    count = 1; 
    for fly = 1:length(summaryData)
        flyData = summaryData{fly};
        goodTrials = flyData(flyData.perMove > 20,:); % only look at trials where fly's vel was above threshold for at least 20% of the trial
        if ~isempty(goodTrials)
            bestTrials(count,:) = goodTrials(goodTrials.rhoTotal == max(goodTrials.rhoTotal),:); 
            count = count + 1; 
        end
    end
    
    for trial = 1:size(bestTrials,1)
        rho_all = [rho_all bestTrials.rho_60sec{trial}];
        rho_wholeTrial_all = [rho_wholeTrial_all bestTrials.rhoTotal(trial)];
        theta_all = [theta_all bestTrials.theta_60sec{trial}];
        theta_wholeTrial_all = [theta_wholeTrial_all bestTrials.thetaTotal(trial)];
    end

%     polarplot([0,thetaTrial], [0,rhoTrial],'k','LineWidth',2)
%     hold on
%     rlim([0 1])
    
        deg_step = 5;
        rho_step = 0.05; 
        deg_edges = [0:deg_step:360+deg_step]; 
        rho_edges = [0:rho_step:1+rho_step]; 
        deg_all = wrapTo360(rad2deg(theta_all));
        deg_wholeTrial_all = wrapTo360(rad2deg(theta_wholeTrial_all));

        Z = histcounts2(rho_all,deg_all,rho_edges,deg_edges); 
        figure();clf
        polarPcolor(rho_edges(1:end-1),deg_edges(1:end-1),Z, 0.01, 0.99, 'Nspokes',13,'colormap','parula')
        
        Z = histcounts2(rho_wholeTrial_all,deg_wholeTrial_all,rho_edges,deg_edges); 
        figure();clf
        polarPcolor(rho_edges(1:end-1),deg_edges(1:end-1),Z,0,1,'Nspokes',13,'colormap','hot')



        


%% plots
%         f = figure();clf; 
%         polarscatter(theta_all, rho_all,'o')
%         rlim([0 1])
%         colormap(gca, 'hot')
% 
%         g = figure();clf; 
%         polarscatter(theta_all(rho_all > 0.6), rho_all(rho_all > 0.6),'o')
%         rlim([0 1])
%         colormap(gca, 'hot')
% 
%         %[mean_bin, centers] = binData(activity, behaviour, edges);
%         deg_step = 5;
%         rho_step = 0.05; 
%         deg_edges = [0:deg_step:360+deg_step]; 
%         rho_edges = [0:rho_step:1+rho_step]; 
%         deg_all = wrapTo360(rad2deg(theta_all));
% 
%         Z = histcounts2(rho_all,deg_all,rho_edges,deg_edges); 
%         h = figure();clf
%         polarPcolor(rho_edges(1:end-1),deg_edges(1:end-1),Z,'Nspokes',13,'colormap','hot')
% 
%         deg_edges = [0:deg_step:360+deg_step]; 
%         rho_edges = [0.6:rho_step/2:1+rho_step/2]; 
%         Z = histcounts2(rho_all(rho_all > 0.6),deg_all(rho_all > 0.6),rho_edges,deg_edges); 
%         i = figure();clf
%         polarPcolor(rho_edges(1:end-1),deg_edges(1:end-1),Z,'autoOrigin','off','Nspokes',13,'colormap','hot')
end