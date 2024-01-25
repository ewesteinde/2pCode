
    for f = 1:size(folders,1)
        [start,finish] = regexp(string(folders.folder{f}),'_fly');
        dateIdx = regexp(string(folders.folder{f}),'\');
        dateIdx = [dateIdx(3)+1:dateIdx(4)-1]; 
        date = folders.folder{f};
        date = date(dateIdx);
        if isempty(finish)
            [start,finish] = regexp(string(folders.folder{f}),'_Fly');
        end
        fly = string(folders.folder{f}(start:finish + 1));
        flyID = strcat(date,fly);
        flies(f) = flyID;
    end
        flies = flies';
        uniqueFlies = unique(flies); 
        flyCount = zeros(size(folders));
        for fly = 1:length(uniqueFlies)
            flyCount(flies == uniqueFlies(fly)) = fly;
        end
 %%  
   
    for f = 1:size(folders,1)
        [start,finish] = regexp(string(folders.Folder{f}),'_fly');
        dateIdx = regexp(string(folders.Folder{f}),'\');
        dateIdx = [dateIdx(3)+1:dateIdx(4)-1]; 
        date = folders.Folder{f};
        date = date(dateIdx);
        if isempty(finish)
            [start,finish] = regexp(string(folders.Folder{f}),'_Fly');
        end
        fly = string(folders.Folder{f}(start:finish + 1));
        flyID = strcat(date,fly);
        flies(f) = flyID;
    end
        flies = flies';
        uniqueFlies = unique(flies); 
        flyCount = zeros(size(folders));
        for fly = 1:length(uniqueFlies)
            flyCount(flies == uniqueFlies(fly)) = fly;
        end