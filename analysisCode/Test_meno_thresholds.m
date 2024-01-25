function Test_meno_thresholds(rootDir)
varNames = ["Folder","numTrial","Goal","rho","timeMov","Indices"];
varTypes = ["string","double","double","double","double","cell"];
MenoData = table('Size',[1 6],'VariableNames', varNames,'VariableTypes',varTypes);
nMenoData = table('Size',[1 6],'VariableNames', varNames,'VariableTypes',varTypes);

PFL3 = 1; 
PFL2 = 1; 

folders = get_folders(rootDir, PFL2, PFL3);

window = 45; 
minVel = 1.5; 
Thres = 0.88;  


for f = 1:size(folders,1)
    folder = folders(f).folder; 
    if strcmp(folder(end),'.')
        folder = folder(1:end-2); 
    end
    
    expID = get_expID(folder);
    expList = {expID};
    
    [~,ftData, ~] = load_ft_data(expList, folder, 1, 0);

    % Load metadata 
    [expMd, trialMd] = load_metadata(expList, folder);

    % Load imaging data
    roiData = load_roi_data(expList, folder);
    
    processedData_dir = fullfile(folder,'processed_data');
    try
        numTrials = max(size(unique(roiData.trialNum),1),length(trialMd.trialNum));
    catch
        numTrials = 1; 
    end
    
    for nTrial = 1:numTrials
        
        data_filelist = dir(processedData_dir);
        for files = 1:length(data_filelist)
            if regexp(data_filelist(files).name,'.mat') & regexp(data_filelist(files).name,['00',num2str(nTrial)])
                load(fullfile(processedData_dir,data_filelist(files).name));
            end
        end

%%  
    Meno_chunks = [];
    not_Meno_chunks = []; 
%     tidx = find(seconds(ftT.trialTime{1}) >= 37);
%     for c = 3:size(ftT,2)
%         ftT.(c){1} = ftT.(c){1}(tidx); 
%     end
    SegmentMenovsNotMeno(ftT, window, minVel,Thres,Thres,folder,nTrial);
    end
end