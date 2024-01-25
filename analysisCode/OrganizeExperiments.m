function [flyFolders, PFL3_flies, PFL2_flies] = OrganizeExperiments(folders_all, PFL3, PFL2)

    count_PFL3 = 1; 
    count_PFL2 = 1;
    fly_PFL3 = [];
    fly_PFL2 = []; 
    for f = 1:length(folders_all)
        if PFL3 && PFL2
            folders = folders_all;
             if regexp(folders_all(f).folder,'PFL2_3')
                    if strcmp(folders_all(f).folder(end),'.')
                        folders_all(f).folder = folders_all(f).folder(1:end-2); 
                    end
                expDate_start = regexp(folders_all(f).folder,'\');
                expDate_start = expDate_start(end) + 1; 
                expDate_end = expDate_start + 7;
                expDate = folders_all(f).folder(expDate_start:expDate_end);
                folders_PFL3(count_PFL3) = folders_all(f);
                [~,fly_num_idx] = regexpi(folders_PFL3(count_PFL3).folder,'fly');
                fly_PFL3(count_PFL3,1) = str2double(expDate); 
                fly_PFL3(count_PFL3,2) = str2double(folders_PFL3(count_PFL3).folder(fly_num_idx + 1));
                count_PFL3 = count_PFL3 + 1;
             elseif regexp(folders_all(f).folder,'PFL2') && isempty(regexp(folders_all(f).folder,'PFL2_3'))
                 if strcmp(folders_all(f).folder(end),'.')
                    folders_all(f).folder = folders_all(f).folder(1:end-2); 
                 end
                expDate_start = regexp(folders_all(f).folder,'\');
                expDate_start = expDate_start(end) + 1; 
                expDate_end = expDate_start + 7;
                expDate = folders_all(f).folder(expDate_start:expDate_end);
                folders_PFL2(count_PFL2) = folders_all(f);
                [~,fly_num_idx] = regexpi(folders_PFL2(count_PFL2).folder,'fly');
                fly_PFL2(count_PFL2,1) = str2double(expDate);
                fly_PFL2(count_PFL2,2) = str2double(folders_PFL2(count_PFL2).folder(fly_num_idx + 1));
                count_PFL2 = count_PFL2 + 1; 
             end
        elseif PFL3
            if regexp(folders_all(f).folder,'PFL2_3')
                    if strcmp(folders_all(f).folder(end),'.')
                        folders_all(f).folder = folders_all(f).folder(1:end-2); 
                    end
                expDate_start = regexp(folders_all(f).folder,'\');
                expDate_start = expDate_start(end) + 1; 
                expDate_end = expDate_start + 7;
                expDate = folders_all(f).folder(expDate_start:expDate_end);
                folders_PFL3(count_PFL3) = folders_all(f);
                [~,fly_num_idx] = regexpi(folders_PFL3(count_PFL3).folder,'fly');
                fly_PFL3(count_PFL3,1) = str2double(expDate); 
                fly_PFL3(count_PFL3,2) = str2double(folders_PFL3(count_PFL3).folder(fly_num_idx + 1));
                count_PFL3 = count_PFL3 + 1;
            end
        elseif PFL2
            if regexp(folders_all(f).folder,'PFL2') && isempty(regexp(folders_all(f).folder,'PFL2_3'))
                 if strcmp(folders_all(f).folder(end),'.')
                    folders_all(f).folder = folders_all(f).folder(1:end-2); 
                 end
                expDate_start = regexp(folders_all(f).folder,'\');
                expDate_start = expDate_start(end) + 1; 
                expDate_end = expDate_start + 7;
                expDate = folders_all(f).folder(expDate_start:expDate_end);
                folders_PFL2(count_PFL2) = folders_all(f);
                [~,fly_num_idx] = regexpi(folders_PFL2(count_PFL2).folder,'fly');
                fly_PFL2(count_PFL2,1) = str2double(expDate);
                fly_PFL2(count_PFL2,2) = str2double(folders_PFL2(count_PFL2).folder(fly_num_idx + 1));
                count_PFL2 = count_PFL2 + 1; 
            end
        end
    end

    PFL3_flies = unique(fly_PFL3,'rows');
    PFL2_flies = unique(fly_PFL2,'rows');



    flyCount = 1; 
    for fly = 1:size(PFL3_flies,1)
        folderCount = 1; 
        for f = 1:length(folders_PFL3)
            [~,fly_num_idx] = regexpi(folders_PFL3(f).folder,'fly');
            expDate_start = regexp(folders_PFL3(f).folder,'\');
            expDate_start = expDate_start(end) + 1; 
            expDate_end = expDate_start + 7;
            expDate = str2double(folders_PFL3(f).folder(expDate_start:expDate_end));
            if  str2double(folders_PFL3(f).folder(fly_num_idx + 1)) == PFL3_flies(fly,2) && expDate == PFL3_flies(fly,1)
                flyFolders{folderCount,flyCount} = {folders_PFL3(f).folder};
                folderCount = folderCount + 1;
            end
        end
        flyCount = flyCount + 1; 
    end

    for fly = 1:size(PFL2_flies,1)
        folderCount = 1; 
        for f = 1:length(folders_PFL2)
            [~,fly_num_idx] = regexpi(folders_PFL2(f).folder,'fly');
            expDate_start = regexp(folders_PFL2(f).folder,'\');
            expDate_start = expDate_start(end) + 1; 
            expDate_end = expDate_start + 7;
            expDate = str2double(folders_PFL2(f).folder(expDate_start:expDate_end));
            if  str2double(folders_PFL2(f).folder(fly_num_idx + 1)) == PFL2_flies(fly,2) && expDate == PFL2_flies(fly,1)
                flyFolders{folderCount,flyCount} = {folders_PFL2(f).folder};
                folderCount = folderCount + 1;
            end
        end
        flyCount = flyCount + 1; 
    end
end