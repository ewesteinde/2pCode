function regDebug_plots(rootDir)

%% Default settings

    arguments
        rootDir char
    end

    
%% get folder list
    folders = get_folders(rootDir);
    %% Process each folder
    folderNum = length(folders);
    fprintf(1, '##### Found %d potential experiment folders to process...#####\n', folderNum);
    for ff = 1:folderNum
      
      %% Get folder information
      folder = folders(ff).folder;
%% Load in meta & ROI data
        if strcmp(folder(end),'.')
            folder = folder(1:end-2); 
        end
        
        expID = get_expID(folder);
        expList = {expID};

        % Load metadata 
        try
            [~, trialMd] = load_metadata(expList, folder);
            numTrials = length(trialMd.trialNum); %max(size(unique(roiData.trialNum),1),
            %load(fullfile(folder,[expID,'_trialMetadata.mat'])); 
        catch 
            numTrials = 1; 
        end
        

        % Load imaging data
        %roiData = load_roi_data(expList, folder);

        
        %%
        for nTrial = 1:numTrials

            regFolder = fullfile(folder,['registration_00',num2str(nTrial)]);
            regProduct_file = fullfile(regFolder,['imagingData_reg_ch1_trial_00',num2str(nTrial),'.mat']);
            load(regProduct_file,'regProduct')

            maxy = max(max(squeeze(sum(regProduct(:,:,:,:),[1,2]))));
            miny = min(min(squeeze(sum(regProduct(:,:,:,:),[1,2]))));

            figure(1);clf;
            for slice = 1:length(regProduct(1,1,:,1))
                subplot(length(regProduct(1,1,:,1)),1,slice)
                plot(squeeze(sum(regProduct(:,:,slice,:),[1,2])))
                ylabel(['Slice ',num2str(slice)])
                ylim([miny,maxy])
            end
            fig = gcf; 
            fig.Position(4) = 780;
            
            saveDir = fullfile(regFolder,['Ch1_regproduct_trial_00',num2str(nTrial),'.fig']);
            saveDir_png = fullfile(regFolder,['Ch1_regproduct_trial_00',num2str(nTrial),'.png']);

            saveas(gcf,saveDir)
            saveas(gcf,saveDir_png)
            
            close(fig)
        end
    end
end
% imaging_roi_pipeline(rootDir)
% imaging_fictrac_plot(rootDir)