function fixFictrac(rootDir, overwrite)

% code to fix fictrac alignment errors

% yaw = trialData.ficTracYaw; 
% xPanels = trialData.PanelsXDimTelegraph*-1; 
% fig = figure();plot(yaw); hold on; plot(xPanels)
% yawStart = input('yaw signal (blue): '); 
% panelsStart = input('panels signal (orange): ');
% startDiff = yawStart - panelsStart; 
% 
% xPanels = xPanels + startDiff;
% xPanels(xPanels > 10) = xPanels(xPanels > 10) - 10; 
% xPanels(xPanels < 0) = xPanels(xPanels < 0) + 10;
% 
% figure();plot(yaw); hold on; plot(xPanels)
    filelist = dir(fullfile(rootDir, '**/*.*'));   % get list of files and folders in any subfolder
    filelist = filelist([filelist.isdir]);  % only folders from list
    filelistNum = length(filelist);
    correct = [];
    for f = 1:filelistNum
      baseFolderName = filelist(f).name;
      if strcmp(baseFolderName,'..') || ~strcmp(baseFolderName,'.')
          present = false;
      else
          parentFolderName = filelist(f).folder;
          fullFolderName = fullfile(parentFolderName, baseFolderName);
          filelist(f).folder = fullFolderName;
          contents = fullfile(fullFolderName,'config.txt'); % fictrac data and ...
          present = exist(contents,'file')>0;
          listingTiff = dir(fullfile(fullFolderName,'*_daqData_*.mat'));
          present = numel(listingTiff) > 0 && present; % Image data
          if ~overwrite && present %% Do not overwrite already processed folders
              contents = dir(fullfile(fullFolderName,'*preprocess_run_*.txt'));
              present = isempty(contents);
          end
      end
      correct(end+1) = present;
    end %f
    folders = filelist(logical(correct));
   
    %% Process each folder
    folderNum = length(folders);
    fprintf(1, '##### Found %d potential experiment folders to process...#####\n', folderNum);
    for ff = 1:folderNum
      
          %% Get folder information

            folder = folders(ff).folder;
            fprintf(1, '##### Experimental folder: %s #####\n', folder);

          %% Skip if not an expID folder with the right .tif files - not correct if checking DAQ data
    %       listingTiff = dir(fullfile(folder,'*_trial_*.tif'));
    %       nogo = regexp([listingTiff.name],'anatomy|stack|time|MIP', 'once');
    %       if ~isempty(nogo)
    %           fprintf(1, '##### Not an experimental folder: %s #####\n', folder);
    %           continue
    %       else
    %           fprintf(1, '##### Experimental folder: %s #####\n', folder);
    %       end
          %% Get experiment ID
        try
          expID = get_expID(folder);
        catch
          expID = folder;
        end
        %% save csv
        try
            imaging_panels_experiment_metadata(folder, 0, 2019.1);
          catch  ME
              fprintf(1, '##### ERROR running imaging_panels_experiment_metadata for: %s #####\n', expID);
              fprintf(1, '>>>>> %s <<<<<\n', ME.message);
        end
        
        %% redo ROI -temp
         try
            imaging_roi_pipeline(folder, 'all', 0, 0, 1, 1);
          catch ME
              fprintf(1, '##### ERROR running imaging_roi_pipeline for: %s #####\n', expID);
              fprintf(1, '>>>>> %s <<<<<\n', ME.message);
          end
              
          %% Reprocess fictrac using trigger
        try
          imaging_fictrac_pipeline(folder,0, 0, 0, 1);
        catch ME
          fprintf(1, '##### ERROR running imaging_fictrac_pipeline for: %s #####\n', expID);
          fprintf(1, '>>>>> %s <<<<<\n', ME.message);
        end
           %% replot 
        try
            imaging_fictrac_plot(folder);
        catch ME
          fprintf(1, '##### ERROR running imaging_fictrac_plot for: %s #####\n', expID);
          fprintf(1, '>>>>> %s <<<<<\n', ME.message);
        end
    end
end