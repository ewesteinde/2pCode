        
%% load data
processedData_dir = fullfile(folder,'processed_data');
data_filelist = dir(processedData_dir);
nTrial = 1;
for files = 1:length(data_filelist)
    if regexp(data_filelist(files).name,'.mat') & regexp(data_filelist(files).name,['00',num2str(nTrial)])
        load(fullfile(processedData_dir,data_filelist(files).name));
    end
end
%% find idx of high activity

% find idx in Z where zscored activity is > 2

Z_leftLAL = Z(Z.roiName == 1, :); 
Z_rightLAL = Z(Z.roiName == 2, :); 

hActivity_idx = find(Z_leftLAL.data > 2 | Z_rightLAL.data > 2); 
lActivity_idx = find(Z_leftLAL.data < 2 | Z_rightLAL.data < 2); 

vf_high = ftT_down.fwSpeed{1}(hActivity_idx);
vs_high = ftT_down.sideSpeed{1}(hActivity_idx);
vy_high = ftT_down.yawSpeed{1}(hActivity_idx);

vf_low = ftT_down.fwSpeed{1}(lActivity_idx);
vs_low = ftT_down.sideSpeed{1}(lActivity_idx);
vy_low = ftT_down.yawSpeed{1}(lActivity_idx);

%% compare histograms of fly activity when PFL2 activity is high vs low 

vf_edges = [min(ftT_down.fwSpeed{1}):0.2:max(ftT_down.fwSpeed{1})]; 
vs_edges = [min(ftT_down.sideSpeed{1}):0.2:max(ftT_down.sideSpeed{1})];
vy_edges = [min(ftT_down.yawSpeed{1}):0.1:max(ftT_down.yawSpeed{1})];


h = figure();clf; 
subplot(3,1,1)
histogram(vf_low,vf_edges,'Normalization','probability')
hold on
histogram(vf_high,vf_edges,'Normalization','probability')
xlabel('vf')


subplot(3,1,2)
histogram(vy_low,vy_edges,'Normalization','probability')
hold on
histogram(vy_high,vy_edges,'Normalization','probability')
xlabel('vy')


subplot(3,1,3)
histogram(vs_low,vs_edges,'Normalization','probability')
hold on
histogram(vf_high,vs_edges,'Normalization','probability')
xlabel('vs')


    