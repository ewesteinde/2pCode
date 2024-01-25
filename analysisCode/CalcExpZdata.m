function foldersFailed = CalcExpZdata(rootDir, PFL3, PFL2)
%     dbstop if error
    folders = get_folders(rootDir, PFL2, PFL3);
    
    if PFL3
        [expMedian, expMad] = CalcExpMedianMad(rootDir, 1, 0, 'LAL');
    end
        
   
    %% Process each folder
    folderNum = length(folders);
    fprintf(1, '##### Found %d potential experiment folders to process...#####\n', folderNum);
    countFail = 1;
    for ff = 1:folderNum
        close all 
        %clearvars -except ff folderNum folders savePlots
    try
      
      %% Get folder information
      parentDir = folders(ff).folder;
      
      if strcmp(parentDir(end),'.') 
          parentDir = parentDir(1:end-2);
      end

%% Load in fictrac & ROI data
 
    % Analysis settings
    p = [];
    p.smWin = 5;
    p.flType = 'expDff';
    
    % Get data files
    expID = get_expID(parentDir);
    expList = {expID};
    
    % Load metadata 
    [expMd, trialMd, ~, ~] = load_metadata(expList, parentDir);

    % Load imaging data
    roiData_all = load_roi_data(expList, parentDir);

    % Load FicTrac data
    [~,ftData, ~] = load_ft_data(expList, parentDir, 1, 0);
    
    daqFile_info = dir(fullfile(parentDir,'*_daqData_*.mat'));
    
    numTrials = max(size(unique(roiData_all.trialNum),1),length(trialMd.trialNum)); 
    

%%
        for nTrial = 1:numTrials
            if any(roiData_all.trialNum==nTrial)

            load(fullfile(parentDir,daqFile_info(nTrial).name),'trialData')
            roiData = roiData_all(roiData_all.trialNum==nTrial,:);
            
            %% Volume rate
            if size(trialMd,1) >= nTrial
                tMd = trialMd(trialMd.trialNum == nTrial, :);
            else 
                tMd = trialMd;
            end 
            
            % get roi times from DAQ volume triggers
            try
                roiData = getROItime(roiData, trialData);
                roi_time = roiData.time{1};
                
                %[0:1/trialMd.volumeRate:trialMd.trialDuration]';
            catch
                roi_time = [0:1/expMd.volumeRate:trialMd.trialDuration]';
                tMd.volumeRate = expMd.volumeRate;
            end
                
            roi_time = seconds(roi_time);
            

            %% calculate modififed Z-score & dff from roi data
            roiNames = roiData.roiName;
            % For each ROI plot with the correct ROI number
            count = 0; 
            ZData = [];
            for nRoi = 1:numel(roiNames)

                % Get ROI name
                roiName = char(roiNames(nRoi));
                % If the ROi exists with data calculate before upsampling due to speed constraints
                currRoiData = roiData(roiData.trialNum == nTrial & strcmp(roiData.roiName, roiName), :);
                if ismember(roiName, roiData.roiName) && ~isempty(currRoiData) && ~contains(currRoiData.roiName,'mid') && ~isempty(currRoiData.rawFl{1}) %temp addition 
                    count = count + 1;
                    Z = {MadExp(roiData, nTrial, roiName, p, expMedian(nRoi), expMad(nRoi))};
                    roiTime = roiData.time(1);
                    roiName = {roiName};
                    ZData_temp = table(roiName,roiTime, Z); 
                end
                ZData = [ZData; ZData_temp];
            end
            
            %% resample ROI data to fictrac rate
            
            if length(roi_time) ~= length(roiData.rawFl{1})
                if length(roi_time) == length(roiData.rawFl{1}) - 1 
                    for row = 1:size(roiData,1)
                        roiData.rawFl{row} = roiData.rawFl{row}(1:end-1);
                        ZData.Z{row} = ZData.Z{row}(1:end-1); 
                    end
                else
                    disp('uh oh')
                end             
            end
            
            for r = 1:size(roiData,1)
                rawFl = roiData.rawFl{r};
                roi = table(rawFl); 
                roi.seconds = roiData.time{r}; 
                roi_timetable_temp = table2timetable(roi,'RowTimes','seconds'); 
                roi_timetable = retime(roi_timetable_temp,'regular','spline','SampleRate',60); 

                roi = timetable2table(roi_timetable); 
                roiData.rawFl{r} = roi.rawFl;
                roiData.time{r}= roi.seconds;
                roiData.sampRate(r) = 60;
                
                Z = ZData.Z{r};
                roi = table(Z); 
                roi.seconds = ZData.roiTime{r}; 
                roi_timetable_temp = table2timetable(roi,'RowTimes','seconds'); 
                roi_timetable = retime(roi_timetable_temp,'regular','spline','SampleRate',60); 

                roi = timetable2table(roi_timetable); 
                ZData.Z{r} = roi.Z;
                ZData.roiTime{r}= roi.seconds;
            end
            
%             %debug plot
%             figure();
%             plot(roi_time,roiData_all.rawFl{1});
%             hold on
%             plot(seconds(roiData.time{1}),roiData.rawFl{1});
            
%% match fictrac start & end times to volume start & end times

            volStart = round(seconds(roiData.time{1}(1)),3);
            volEnd = round(seconds(roiData.time{1}(end)),3); 
            
            if any(ftData.trialNum==nTrial)
                ftT = ftData(ftData.trialNum ==nTrial, :);
            end

            var_names = ftT.Properties.VariableNames;         
            for col = 1:width(ftT)
                if strcmp(var_names{col},'expID')
                    ftT.(col){1} = ftT.(col){1}; 
                elseif iscell(ftT.(col)) && ~isempty(ftT.(col){1})
                     ftT.(col){1} = ftT.(col){1}(round(seconds(ftData.trialTime{1}),3) >= volStart & round(seconds(ftData.trialTime{1}),3) <= volEnd);
                     if cell2mat(regexp(var_names(col),'vel'))
                        if isnan(ftT.(col){1}(1)) || isinf(ftT.(col){1}(1))
                            ftT.(col){1}(1) = 0;
                        end
                        ftT.(col){1} = smoothdata(ftT.(col){1},'loess',25);
                     end
                else
                    ftT(:,col) = ftT(:,col); 
                end          
            end 
            
            if length(ftT.velFor{1}) ~= length(roiData.rawFl{1})
                upSample_roiTime = roiData.time{1};
                if length(roiData.time{1}) > length(ftT.trialTime{1})
                    if upSample_roiTime(end) > ftT.trialTime{1}(end)
                        fictracEnd = round(seconds(ftT.trialTime{1}(end)),4);    
                        for row = 1:size(roiData,1)
                            roiData.rawFl{row} = roiData.rawFl{row}(round(seconds(upSample_roiTime),4)<= fictracEnd); 
                            roiData.time{row} = roiData.time{row}(round(seconds(upSample_roiTime),4)<= fictracEnd); 
                            
                            ZData.Z{row} = ZData.Z{row}(round(seconds(upSample_roiTime),4)<= fictracEnd); 
                            ZData.roiTime{row} = ZData.roiTime{row}(round(seconds(upSample_roiTime),4)<= fictracEnd); 
                        end
                    else
                        disp('uh oh')
                    end
                else
                    disp('uh oh')
                end
            end
        end

        processed_data_dir = fullfile(parentDir,'processed_data');
        ZDataExp = ZData;
        save(fullfile(processed_data_dir,['expZscored_df_f_Trial_00',num2str(nTrial),'.mat']), 'ZDataExp','-v7.3');
        end
    catch 
        foldersFailed{countFail} = parentDir;
        countFail = countFail + 1; 
    end
    %end
    % testing plot
%     figure(2);clf;
%     plot(ftT.frameTimes{1}, ftT.fwSpeed{1});
%     hold on
%     plot(ftT_down.frameTimes{1},ftT_down.fwSpeed{1}); 
%     legend
   
    disp('-------Finished processing Data----------')
end    
    
    

    