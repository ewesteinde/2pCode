function continuous_PB_data_analysis(path,sid,tid)

%Code to analyze the imaging and behavior data, with the imaging data
%analyzed using the new 'continuous' method

%INPUT
%path = name of the main folder for this fly's data
%sid = session id 
%tid = trial id
%note: this will only work if your data is saved with the structure that
%mine has: one main data folder per fly, with '2p' and 'ball' subfolders,
%and subfolders for each session*trial id inside the 2p folder. If not, the
%code or the data structure will have to be adapted

%% Create the data analysis folder (where the output of this code will be saved at the end)

data_analysis_dir = [path,'\ContinuousAnalysis\'];
if(~exist(data_analysis_dir, 'dir'))
    mkdir(data_analysis_dir);
end

%% Load the imaging data

%Move to the folder of interest
cd(path)

%Load the roi data 
load(fullfile('registration_001','roiDefs_trial_001.mat')); % change to make flexible for > 1 trial
%Load the registered imaging stack
load(fullfile('registration_001','imagingData_reg_ch1_trial_001.mat')); % change to make flexible for > 1 trial
%Load the reference images
refPath = (fullfile('registration_001',['refImages_reg_ch1_trial_001.mat']));
load(refPath); 

%% Get the summed GCaMP7f data

%add the data across the z layers making up each volume, to obtain 1 PB image per timepoint
summedData = squeeze(sum(regProduct,3));

%% Get midline coordinates and PB mask

%1) Find the row corresponding to the midline
for row = 1:length(roiDefs)
    if contains(roiDefs(row).name,'midline')
        roi_mid = row;
    end
end

%2) Pull up the coordinate values that make up the mid line along the PB
midline_coordinates = [roiDefs(roi_mid).subROIs.position(:,1),roiDefs(roi_mid).subROIs.position(:,2)];

%3) Get the 'vector lengths' for each section of the line, to know how much
%distance of the PB they represent
midline_segment_lengths = zeros(length(midline_coordinates)-1,1);
for segment = 1:length(midline_coordinates)-1
    midline_segment_lengths(segment) = sqrt( (midline_coordinates(segment+1,1)-midline_coordinates(segment,1))^2 + (midline_coordinates(segment+1,2)-midline_coordinates(segment,2))^2 );
end
midline_distances = cumsum(midline_segment_lengths);

%4) Pull up the locations for all the px in the PB mask - across roi masks
%sums all pixels to find locations included in a mask across the zplanes
% PB_mask = zeros(size(regProduct,1),size(regProduct,2));
% for row = 1:length(roiDefs)
%     if row~=roi_mid
%         PB_mask = PB_mask + roiDefs(row).BW;
%     end
% end
% PB_mask(PB_mask>1) = 1;
% PB_coverage = logical(PB_mask);
%if prctile_cut && isempty(regexp(folder,'LAL','once'))
    slicePrctile = squeeze(prctile(refImages,97,[1 2]));
    for slice = 1:size(refImages,3)
        refSlice = refImages(:,:,slice);
        refSlice(refSlice > slicePrctile(slice)) = 0;
        refDir = fullfile(folder, ['roi_',ntrial],'prctile_cut');
        if ~exist(refDir, 'dir')
            mkdir(refDir)
        end
        figure();imshow(refSlice)
        ref_save = fullfile(refDir,['slice_00',num2str(slice),'.png']);
        saveas(gcf,ref_save)
        close gcf
        [row_ex, col_ex] = find(refImages(:,:,slice) > slicePrctile(slice)); 
        for idx = 1:length(row_ex)
            xyidx(1) = row_ex(idx); 
            xyidx(2) = col_ex(idx); 
            regProduct(xyidx(1),xyidx(2),slice,:) = 0; % treat this pixels as not being included in mask
        end
    end
%end

for row = 1:length(roiDefs)
    if row~=roi_mid
        PB_coverage = roiDefs(row).subROIs(1).mask;
    end
end

%% Get the normal line across each small segment of the PB midline

%Initialize variables
midV = cell(1,length(midline_coordinates)-1);
normal1 = cell(1,length(midline_coordinates)-1);
normal2 = cell(1,length(midline_coordinates)-1);
point1 = cell(1,length(midline_coordinates)-1);
point2 = cell(1,length(midline_coordinates)-1);

for segment = 1:length(midline_coordinates)-1
    
    y_part = [midline_coordinates(segment,1),midline_coordinates(segment,2)];
    x_part = [midline_coordinates(segment+1,1),midline_coordinates(segment+1,2)];
    V = y_part - x_part;
    midV{segment} = x_part + 0.5 * V;
    normal1{segment} = [ V(2), -V(1)];
    normal2{segment} = [-V(2),  V(1)];
    
    point1{segment} = [midV{segment}(1), midV{segment}(2)];
    point2{segment} = [midV{segment}(1) + normal1{segment}(1), midV{segment}(2) + normal1{segment}(2)];
end

%%Uncomment to plot the normals and the DF/F for an example timepoint

% figure('Position',[200 50 600 800]);
% subplot(3,1,1)
% plot(midline_coordinates(:,1),midline_coordinates(:,2), 'r');
% hold on
% for segment = 1:length(midline_coordinates)-1
%     plot([midV{segment}(1), midV{segment}(1) + normal1{segment}(1)], [midV{segment}(2), midV{segment}(2) + normal1{segment}(2)], 'b');
%     plot([midV{segment}(1), midV{segment}(1) + normal2{segment}(1)], [midV{segment}(2), midV{segment}(2) + normal2{segment}(2)], 'b');
% end
% title('PB midline and normal segments');

%%% Get the distance to each normal line in an example timepoint

% PB_image = summedData(:,:,3);
% PB_image(PB_coverage == 0) = 0;
% 
% %For each of those locations, find the distance to each normal in the
% %midline
% midline_f = zeros(1,length(midline_coordinates)-1); %start empty midline brightness vector
% 
% for row = 1:size(PB_coverage,1)
%     for column = 1:size(PB_coverage,2)
%         if PB_coverage(row,column) == 1
%             %for every normal to the midline
%             dist_to_midline = zeros(length(normal1),1);
%             for norm_line = 1:length(normal1)
%                 % Get the distance to that normal
%                 dist_to_midline(norm_line) = GetPointLineDistance(column,row,point1{norm_line}(1),point1{norm_line}(2),point2{norm_line}(1),point2{norm_line}(2));
%             end
%             %find the minimum distance
%             [~ , Imin] = min(dist_to_midline);
%             %add intensity value of that pixel to that point in the midline
%             midline_f(Imin) = midline_f(Imin) + PB_image(row,column);
%         end
%     end
% end
% % 
% % Plot
% subplot(3,1,2)
% imagesc(flip(PB_image))
% title('PB activity at example timepoint');
% colormap(gray)
% 
% subplot(3,1,3)
% plot(midline_distances,midline_f)
% title('Fluorescence at example timepoint using midline');
% 
% saveas(gcf,'ExampleTimepoint.png');

% 
%% Calculate the distance to each midline normal for each pixel in the PB mask and assign to the closest midline segment

%Initialize variables
midline_ff = zeros(length(midline_coordinates)-1,size(summedData,3)); %start empty midline brightness vector
PB_Image = cell(1,size(summedData,3));

%For each timepoint
for timepoint = 1:size(summedData,3)
    
    PB_Image{timepoint} = summedData(:,:,timepoint);
    PB_Image{timepoint}(PB_coverage == 0) = 0;
    
    %For each of those locations, find the distance to each normal in the
    %midline
    for row = 1:size(PB_coverage,1)
        for column = 1:size(PB_coverage,2)
            if PB_coverage(row,column) == 1
                %for every normal to the midline
                for norm_line = 1:length(normal1)
                    % Get the distance to that normal
                    dist_to_midline(norm_line) = GetPointLineDistance(column,row,point1{norm_line}(1),point1{norm_line}(2),point2{norm_line}(1),point2{norm_line}(2));
                end
                %find the minimum distance
                [~, Imin] = min(dist_to_midline);
                %add intensity value of that pixel to that point in the midline
                midline_ff(Imin,timepoint) = midline_ff(Imin,timepoint) + PB_Image{timepoint}(row,column);
            end
        end
    end
        
end


%% Compute DF/F for each midline segment

%1) Get the baseline fluorescence
baseline_f = zeros(1,length(midline_coordinates)-1);

for segment = 1:length(midline_coordinates)-1
    
    sorted_f = sort(midline_ff(segment,:));
    %Get baseline as the tenth percentile of activity
    baseline_f(segment) = prctile(sorted_f,10);
    
end

%2) Compute df/f
dff = (midline_ff'-baseline_f)./baseline_f;

%%Uncomment to plot
figure('Position',[100 100 1400 300]),
imagesc(dff')
colormap(flipud(gray));
title('Dff using new method');
% saveas(gcf,'epg_activity_heatmap.png');


%% Compute bump parameters

[bump_mag, bump_width, adj_rs, bump_pos] = fitVonMises(midline_distances,dff);

%%Uncomment to plot bump parameters evolution
% figure,
% subplot(3,1,1)
% imagesc(dff')
% colormap(flipud(gray))
% title('EPG activity');
% 
% subplot(3,1,2)
% plot(bump_mag)
% title('Bump magnitude');
% xlim([1 length(bump_mag)]);
% 
% subplot(3,1,3)
% plot(bump_width)
% title('Bump width');
% xlim([1 length(bump_width)]);


%% Get stimulus position and compute animal's velocities

% 1)Import behavior file
ball_dir = [path,'\ball\'];
expression = ['*sid_' num2str(sid) '_tid_' num2str(tid) '*.mat'];
ball_file = dir(fullfile(ball_dir, expression));
ballData = load(fullfile(ball_dir, ball_file.name)); %load ballData
runobjFile = dir(fullfile([ball_dir,'\runobj\'], ['*_sid_' num2str(sid) '_*']));
load(fullfile([ball_dir,'\runobj\'], runobjFile.name)); %load run_obj
bdata_raw = ballData.trial_bdata; %get the ball data
bdata_time = ballData.trial_time; %get the trial time

% 2)Use an auxiliary function to get the different components of the behavior data
[smoothed, bdata_time_out, visual_stim_pos, fly_pos_rad] = get_data_360(bdata_time, bdata_raw, run_obj.number_frames);

% 3)Recover relevant movement parameters
vel_for = smoothed.xVel';
vel_yaw = smoothed.angularVel;
vel_for_deg = smoothed.xVelDeg';
vel_side_deg = smoothed.yVelDeg';
total_mvt = smoothed.total_mvt;

% Get stim y dimension
panel_y = downsample(bdata_raw(:,6), floor(4000/50));

% 4)Subsample all the variables to have the length of the number of
%volumes scanned (i.e. downsample the behavior data to match the imaging
%data)
volumes = length(dff); %get the volume number
time_ds = bdata_time_out(round(linspace(1, length(bdata_time_out), volumes))); 
vel_for_ds = vel_for(round(linspace(1, length(vel_for), volumes)));
vel_yaw_ds = vel_yaw(round(linspace(1, length(vel_yaw), volumes)));
vel_for_deg_ds = vel_for_deg(round(linspace(1, length(vel_for_deg), volumes)));
vel_side_deg_ds = vel_side_deg(round(linspace(1, length(vel_side_deg), volumes)));
total_mvt_ds = total_mvt(round(linspace(1, length(total_mvt), volumes)));
panel_y_ds = panel_y(round(linspace(1, length(panel_y), volumes)));
visual_stim_pos_ds = visual_stim_pos(round(linspace(1, length(visual_stim_pos), volumes)));
fly_pos_rad_ds = resample(wrapToPi(fly_pos_rad),volumes,length(fly_pos_rad));


%% Offset calculation

%we will compute and define the offset as the
%circular distance between the bump's position and the fly's heading
offset = wrapTo180(rad2deg(circ_dist(bump_pos',-fly_pos_rad_ds)));

%% Save the data into the analysis folder

% General experiment info
continuous_data.parentDir = path;
continuous_data.sid = sid;
continuous_data.tid = tid;
continuous_data.time = time_ds;
continuous_data.run_obj = run_obj;
continuous_data.trial_dur = run_obj.trial_t;
continuous_data.fr_y_ds = panel_y_ds;

% Movement parameters
continuous_data.vel_for = vel_for;
continuous_data.vel_yaw = vel_yaw;
continuous_data.vel_for_ds = vel_for_ds;
continuous_data.vel_yaw_ds = vel_yaw_ds;
continuous_data.vel_side_deg_ds = vel_side_deg_ds;
continuous_data.vel_for_deg_ds = vel_for_deg_ds;
continuous_data.total_mvt_ds = total_mvt_ds;
continuous_data.heading = fly_pos_rad_ds;
continuous_data.heading_deg = rad2deg(fly_pos_rad_ds);
continuous_data.panel_angle = visual_stim_pos_ds;

% Imaging data
continuous_data.volumes = volumes;
continuous_data.dff_matrix = dff;
continuous_data.bump_magnitude = bump_mag;
continuous_data.bump_width = bump_width;
continuous_data.adj_rs = adj_rs;
continuous_data.bump_pos = wrapToPi(bump_pos);
continuous_data.offset = offset;


% Write file
filename = [path, '\analysis\continuous_analysis_sid_' num2str(sid) '_tid_' num2str(tid) '.mat'];
save(filename, 'continuous_data');

end