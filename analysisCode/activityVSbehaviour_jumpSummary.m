function activityVSbehaviour_jumpSummary(summaryArray,meno)       

    summaryArray = summaryArray(~ismembertol(summaryArray.rho,1,10^-10),:); % gets rid of trials w/ no heading change --> indicates problem
    summaryArray = summaryArray(summaryArray.timeMov > 2,:); % only look at trials where fly's vel was above threshold for at least 5 seconds

%     if meno
%         summaryArray = summaryArray(summaryArray.rho > 0.5,:);
%     else
%         summaryArray = summaryArray(summaryArray.rho < 0.5,:);
%     end
    countsum90 = 1; 
    countsum180 = 1; 
    G90count = 1; 
    G180count = 1;
    for trial = 1:size(summaryArray,1)
        %try
        folder = table2array(summaryArray(trial,1)); 
        if strcmp(folder(end),'.')
            folder = folder(1:end-2); 
        end

        expID = get_expID(folder);
        expList = {expID};

        [~,ftT, ~] = load_ft_data(expList, folder, 1, 0);

        % Load metadata 
        [expMd, trialMd] = load_metadata(expList, folder);

        % Load imaging data
        roiData = load_roi_data(expList, folder);

        processedData_dir = fullfile(folder,'processed_data');
        nTrial = summaryArray.numTrial(trial);
        
        data_filelist = dir(processedData_dir);
        for files = 1:length(data_filelist)
            if regexp(data_filelist(files).name,'.mat') & regexp(data_filelist(files).name,['00',num2str(nTrial)])
                load(fullfile(processedData_dir,data_filelist(files).name));
            end
        end


    %% Remove idx where the fly isn't moving
    
            window = 10; 
            [~, jump_array, transition] = detect_jumps(ftT, window, 5,0);
            
            ftT_trial = ftT(:,[3:end]); 
            for col = 1:size(ftT_trial,2)
                ftT_trial.(col){1} = ftT_trial.(col){1}(summaryArray.Indices{trial});
            end
            
            % are there any jumps in this chunk?
            goal = summaryArray.Goal(trial);
            jump_idx = jump_array(:,2); 
            jumpsInChunk = jump_idx(find(ismember(jump_idx,summaryArray.Indices{trial})));
            figure(1);plot(ftT_trial.PanelsY{1})
            
            if ~isempty(jumpsInChunk)
                chunkJump_array = jump_array(ismember(jump_array(:,2), jumpsInChunk),:); 

                count90 = 1;
                count180 = 1;
                jump90_time = []; 
                jump180_time = []; 
                for jump = 1:size(chunkJump_array,1)
                    if abs(chunkJump_array(jump,4)) == 90
                        jumps_90(count90,:) = [chunkJump_array(jump,1):chunkJump_array(jump,3)];
                        jump90_time(:,count90) = (jumps_90(count90,:) - chunkJump_array(jump,2))/60;
                        count90 = count90 + 1; 
                    else
                        jumps_180(count180,:) = [chunkJump_array(jump,1):chunkJump_array(jump,3)];
                        jump180_time(:,count180) = (jumps_180(count180,:) - chunkJump_array(jump,2))/60;
                        count180 = count180 + 1; 
                    end
                end
                
                lastIdx_preJump = (length(jump180_time) - 1)/2;
                for jump = 1:size(jumps_90,1)
                    diff_goal = rad2deg(angdiff(deg2rad(ftT_trial.cueAngle{1}(jumps_90(jump,lastIdx_preJump))),goal)); 

                    vf90(countsum90,:) = ftT_trial.velFor{1}(jumps_90(jump,:)); 
                    vy90(countsum90,:) = abs(ftT_trial.velYaw{1}(jumps_90(jump,:))); 
                    vs90(countsum90,:) = abs(ftT_trial.velSide{1}(jumps_90(jump,:))); 
                    angle90(countsum90,:) = ftT_trial.cueAngle{1}(jumps_90(jump,:)); 
                    countsum90 = countsum90 + 1; 

                    if abs(diff_goal) < 30
                        jump90_meno(G90count,:) = summaryArray(trial,:);
                        jump90_meno.jumpIdx = jumps_90(jump,:);
                        G90count = G90count + 1; 
                    end

                end

                for jump = 1:size(jumps_180,1)
                    diff_goal = rad2deg(angdiff(deg2rad(ftT_trial.cueAngle{1}(jumps_180(jump,lastIdx_preJump))),goal)); 

                    vf180(countsum180,:) = ftT_trial.velFor{1}(jumps_180(jump,:)); 
                    vy180(countsum180,:) = abs(ftT_trial.velYaw{1}(jumps_180(jump,:))); 
                    vs180(countsum180,:) = abs(ftT_trial.velSide{1}(jumps_180(jump,:))); 
                    angle180(countsum180,:) = ftT_trial.cueAngle{1}(jumps_180(jump,:)); 
                    countsum180 = countsum180 + 1; 

                    if abs(diff_goal) < 30
                        jump180_menoIdx(G180count,:) = summaryArray(trial,:);
                        jump90_meno.jumpIdx = jumps_90(jump,:);
                        G180count = G180count + 1; 
                    end
                end

            end

%         catch
%             disp([folder, ' failed'])
%         end
    end  
    
    figure(); 
            ax1= subplot(3,1,1);
            set(gcf, 'color','w')
            set(gcf,'renderer','painters')
            plot(jump90_time,vf90');
            hold on
            plot(jump90_time(:,1), mean(vf90,1,'omitnan'),'k','lineWidth',1.5)
            xline(0)
            ylabel('vf')
            box off

            ax2= subplot(3,1,2);
            plot(jump90_time,rad2deg(vy90)');
            hold on
            plot(jump90_time(:,1), mean(rad2deg(vy90),1,'omitnan'),'k','lineWidth',1.5)
            xline(0)
            ylabel('vy')
            box off

            ax3= subplot(3,1,3);
            plot(jump90_time,vs90');
            hold on
            plot(jump90_time(:,1), mean(vs90,1,'omitnan'),'k','lineWidth',1.5)
            xline(0)
            ylabel('vs')
            box off



            figure(); 
            ax1= subplot(3,1,1);
            set(gcf, 'color','w')
            set(gcf,'renderer','painters')
            plot(jump180_time,vf180');
            hold on
            plot(jump180_time(:,1), mean(vf180,1,'omitnan'),'k','lineWidth',1.5)
            xline(0)
            ylabel('vf')
            box off

            ax2= subplot(3,1,2);
            plot(jump180_time,rad2deg(vy180'));
            hold on
            plot(jump180_time(:,1), mean(rad2deg(vy180),1,'omitnan'),'k','lineWidth',1.5)
            xline(0)
            ylabel('vy')
            box off

            ax3= subplot(3,1,3);
            plot(jump180_time,vs180');
            hold on
            plot(jump180_time(:,1), mean(vs180,1,'omitnan'),'k','lineWidth',1.5)
            xline(0)
            box off

end