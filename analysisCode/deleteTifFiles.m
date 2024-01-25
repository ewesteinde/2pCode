% go through folders & delete tif file if it exists and shouldn't be needed
function deleteTifFiles(rootDir)

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
          listingTiff = dir(fullfile(fullFolderName,'*_trial_*.tif'));
          present = numel(listingTiff) > 0 && present; % Image data
      end
      correct(end+1) = present;
    end %f
    folders = filelist(logical(correct));
   
    
    for f = 1:length(folders)
        folder = folders(f,:).folder;
        
      if strcmp(folder(end),'.')
          folder = folder(1:end-2); 
      end
      listingTiff = dir(fullfile(folder,'*_trial_*.tif'));
      if ~isempty(listingTiff)
        for tif = 1:length(listingTiff)
            tifFile = fullfile(listingTiff(tif).folder, listingTiff(tif).name);  
            delete(tifFile)
        end
      end
    end
end
          
      
      