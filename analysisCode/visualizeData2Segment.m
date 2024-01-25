% Make images directory
    imagesDir = fullfile(parentDir,'images');
    if ~exist(imagesDir, 'dir')
        mkdir(imagesDir)
    end
    
    % Analysis settings
    p = [];
    p.smWin = 5;
    p.flType = 'expDff';
    ztab = [];
    
    % Get data files
    expID = get_expID(parentDir);
    expList = {expID};
    
    % Load metadata 
    [expMd, trialMd] = load_metadata(expList, parentDir);

    % Load imaging data
    roiData = load_roi_data(expList, parentDir);

    % Load FicTrac data
    ftData = load_ft_data(expList, parentDir);
    
    % Load panels metadata
    panelsMetadata = load_panels_metadata(expList, parentDir);
    

ftT = ftData(ftData.trialNum == 1, :);
ftT_time = ftT.frameTimes{1};
nTrial = 1;

% Plot heading 
ftT_cueAngle = ftT.cueAngle{1};
ftT_cueAngle_smooth = ftT_cueAngle; %smoothdata(ftT_cueAngle, 1, 'gaussian', 50);

% Plot fwSpeed 
ftT_fwSpeed = ftT.fwSpeed{1};
ftT_fwSpeed_smooth = smoothdata(ftT_fwSpeed, 1, 'loess', 10);

% Plot sideSpeed 
ftT_sideSpeed = ftT.sideSpeed{1};
ftT_sideSpeed_smooth = smoothdata(ftT_sideSpeed, 1, 'loess', 10);

% Plot yawSpeed 
ftT_yawSpeed = ftT.yawSpeed{1};
ftT_yawSpeed_smooth = smoothdata(ftT_yawSpeed, 1, 'loess', 10);

% plot panelsX pos
ftT_PanelsX = ftT.PanelsX{1};

% plot panelsY pos
ftT_PanelsY = ftT.PanelsY{1};

%% Organize ROIs   

if regexp(expMd.expName{1},'PB')
    org_roiData = roiData(7:-1:3,:);
    org_roiData(6:10,:) = roiData(8:12,:);
elseif regexp(expMd.expName{1},'FB')
    org_roiData = roiData(6:-1:3,:);
    org_roiData(5:9,:) = roiData(7:11,:);
elseif regexp(expMd.expName{1},'LAL')
    org_roiData = roiData;
else
    error('Unknown brain region, organize manually')
end
    

tMd = trialMd(trialMd.trialNum == 1, :);
volRate = expMd.volumeRate;
nVolumes = tMd.nVolumes;
roiTotalTime = nVolumes/volRate;
roiTime = 0:(roiTotalTime/nVolumes):roiTotalTime;
roiTime(end)=[];
ztab = [];
zftab = []; 

roiNames = org_roiData.roiName;
nRois = numel(roiNames);

count = 0; 
for nRoi = 1:numel(roiNames)

    %% Get ROI name
    roiName = char(roiNames(nRoi));
    %% If the ROi exists with data 
    currRoiData = org_roiData(org_roiData.trialNum == nTrial & strcmp(org_roiData.roiName, roiName), :);
    if ismember(roiName, org_roiData.roiName) && ~isempty(currRoiData) && ~contains(currRoiData.roiName,'mid') && ~isempty(currRoiData.rawFl{1}) %temp addition 
        %% Get dF/F % not downsampled need to determine if this is matched accurately 
        count = count + 1;
        flData = deltaFoverF(org_roiData, nTrial, roiName, p);
        mflData = Mad(org_roiData, nTrial, roiName, p);
        for ii = 1:size(mflData,1)
            zcell = {count,ii/volRate,mflData(ii)}; %{roiName,ii,mflDataDown(ii)};
            ztab = [ztab;zcell];
            zfcell = {count,ii/volRate,flData(ii)};
            zftab = [zftab;zfcell];
        end
%                     else %% But if not ...
%                         flData = zeros(size(roiTime));
    end
    flData_all{count} = flData;
    flData_names{count} = roiName;
end

Z = cell2table(ztab, 'VariableNames',{'roiName' 'second' 'zScore'});
Zf = cell2table(ztab, 'VariableNames',{'roiName' 'second' 'df_f'});

% find closest fictrac timepoint to each vol timepoint

A = repmat(ftT_time,[1 length(Z.second(Z.roiName == 1))]);
[minValue,closestIndex] = min(abs(A-(Z.second(Z.roiName == 1))'));
vf_down = ftT_fwSpeed_smooth(closestIndex);
vs_down = ftT_sideSpeed_smooth(closestIndex);
vy_down = ftT_yawSpeed_smooth(closestIndex);
angle_down = ftT_cueAngle(closestIndex);
    
figure();clf
plot(angle_down)

%% manually set diff goal start/stop idxs
% should better automate in the future, make a gui maybe

heading1idx(1,1) = 324;
heading1idx(2,1) = 2146;
heading1idx(1,2) = 1453;
heading1idx(2,2) = 2871;

heading2idx(1,1) = 1503;
heading2idx(1,2) = 2080;

% collect data in diff heading segements 

h1_vf_down = vf_down(heading1idx(1,1):heading1idx(1,2));
h1_vf_down = [h1_vf_down; vf_down(heading1idx(2,1):heading1idx(2,2))];

h1_vs_down = vs_down(heading1idx(1,1):heading1idx(1,2));
h1_vs_down = [h1_vs_down; vs_down(heading1idx(2,1):heading1idx(2,2))];

h1_vy_down = vy_down(heading1idx(1,1):heading1idx(1,2));
h1_vy_down = [h1_vy_down; vy_down(heading1idx(2,1):heading1idx(2,2))];

h1_angle_down = angle_down(heading1idx(1,1):heading1idx(1,2));
h1_angle_down = [h1_angle_down; angle_down(heading1idx(2,1):heading1idx(2,2))];

h1_roiData = org_roiData; 
h2_roiData = org_roiData;

for roi = 1:length(org_roiData.rawFl)
    
    h1_roiData.rawFl{roi} = h1_roiData.rawFl{roi}(heading1idx(1,1):heading1idx(1,2));
    h1_roiData.rawFl{roi} = [h1_roiData.rawFl{roi}; org_roiData.rawFl{roi}(heading1idx(2,1):heading1idx(2,2))];
        
    h2_roiData.rawFl{roi} = h2_roiData.rawFl{roi}(heading2idx(1,1):heading2idx(1,2));

end 

h2_vf_down = vf_down(heading2idx(1,1):heading2idx(1,2));
% h2_vf_down = [h2_vf_down; vf_down(heading2idx(2,1):heading2idx(2,2))];

h2_vs_down = vs_down(heading2idx(1,1):heading2idx(1,2));
% h2_vs_down = [h2_vs_down; vs_down(heading2idx(2,1):heading2idx(2,2))];

h2_vy_down = vy_down(heading2idx(1,1):heading2idx(1,2));
% h2_vy_down = [h2_vy_down; vy_down(heading2idx(2,1):heading2idx(2,2))];

h2_angle_down = angle_down(heading2idx(1,1):heading2idx(1,2));
% h2_angle_down = [h2_angle_down; angle_down(heading2idx(2,1):heading2idx(2,2))];

%% rerun plots on segemented data

heading = 'h2'; 

if strcmp(heading,'h1')
    roiData = h1_roiData; 
    vf = h1_vf_down; 
    vy = h1_vy_down; 
    vs = h1_vs_down; 
    angle = h1_angle_down; 
elseif strcmp(heading,'h2')
    roiData = h2_roiData; 
    vf = h2_vf_down; 
    vy = h2_vy_down; 
    vs = h2_vs_down; 
    angle = h2_angle_down; 
end

%%
if any(roiData.trialNum==nTrial)

    %% Volume rate
    tMd = trialMd(trialMd.trialNum == nTrial, :);
    volRate = expMd.volumeRate;
    ztab = [];
    zftab = []; 
    zcell = []; 
    zfcell = []; 

    roiNames = roiData.roiName;
    nRois = numel(roiNames);

    %% For each ROI plot with the correct ROI number
    count = 0; 
    for nRoi = 1:numel(roiNames)

        %% Get ROI name
        roiName = char(roiNames(nRoi));
        %% If the ROi exists with data 
        currRoiData = roiData(roiData.trialNum == nTrial & strcmp(roiData.roiName, roiName), :);
        if ismember(roiName, roiData.roiName) && ~isempty(currRoiData) && ~contains(currRoiData.roiName,'mid') && ~isempty(currRoiData.rawFl{1}) %temp addition 
            %% Get dF/F % not downsampled need to determine if this is matched accurately 
            count = count + 1;
            flData = deltaFoverF(roiData, nTrial, roiName, p);
            mflData = Mad(roiData, nTrial, roiName, p);
            for ii = 1:size(mflData,1)
                zcell = {count,ii/volRate,mflData(ii)}; %{roiName,ii,mflDataDown(ii)};
                ztab = [ztab;zcell];
                zfcell = {count,ii/volRate,flData(ii)};
                zftab = [zftab;zfcell];
            end
%                     else %% But if not ...
%                         flData = zeros(size(roiTime));
        end
        flData_all{count} = flData;
        flData_names{count} = roiName;
    end
end

Z = cell2table(ztab, 'VariableNames',{'roiName' 'second' 'zScore'});
Zf = cell2table(ztab, 'VariableNames',{'roiName' 'second' 'df_f'});


%% plot activty vs behaviour
sum_mean = cell(3,1); 
vy = wrapTo180((vy/ (2*pi) ) * 360); 
edges_vf = [min(vf):0.5:max(vf)];
edges_vs = [min(vs):0.5:max(vs)];
edges_vy = [min(vy):10:max(vy)];
edges_angle = [-180:10:180];
sum_mean{1} = zeros(length(edges_vf)-1,1);
sum_mean{2} = zeros(length(edges_vs)-1,1);
sum_mean{3} = zeros(length(edges_vy)-1,1);
sum_mean{4} = zeros(length(edges_angle)-1,1);
figure(Name=['Zscore vs behaviour, trial ', num2str(nTrial)]);clf
if ~contains(expMd.expName{1},'LAL')
    for roi = 1:size(roiData,1)
        % vf
        activity = Z.zScore(Z.roiName == roi);
        behaviour = vf; 
        [vf_zscore, centers_vf] = binData(activity, behaviour, edges_vf);
        sum_mean{1} = sum_mean{1} + vf_zscore; 

        l(1) = subplot(4,1,1);
        plot(centers_vf,vf_zscore)
        colororder(parula(roi))
        ylabel('Z')
        xlabel('vf (mm/s)')
        hold on

        % vs 
        behaviour = vs; 
        [vs_zscore, centers_vs] = binData(activity, behaviour, edges_vs);
        sum_mean{2} = sum_mean{2} + vs_zscore; 

        l(2) = subplot(4,1,2);
        plot(centers_vs,vs_zscore)
        colororder(parula(roi))
        ylabel('Z')
        xlabel('vs (mm/s)')
        hold on

        % vy 
        [vy_zscore, centers_vy] = binData(activity, vy, edges_vy);
        sum_mean{3} = sum_mean{3} + vy_zscore; 


        l(3) = subplot(4,1,3);
        plot(centers_vy,vy_zscore)
        colororder(parula(roi))
        ylabel('Z')
        xlabel('vy (deg/s)')
        hold on

        % angle
        [angle_zscore, centers_angle] = binData(activity, angle, edges_angle);
        sum_mean{4} = sum_mean{4} + angle_zscore; 


        l(4) = subplot(4,1,4);
        plot(centers_angle,angle_zscore)
        colororder(parula(roi))
        ylabel('Z')
        xlabel('cue pos (deg)')
        hold on
    end


        subplot(4,1,1)
        plot(centers_vf,sum_mean{1}/size(roiData,1),'k','LineWidth',1.5)
        subplot(4,1,2)
        plot(centers_vs,sum_mean{2}/size(roiData,1),'k','LineWidth',1.5)
        subplot(4,1,3)
        plot(centers_vy,sum_mean{3}/size(roiData,1),'k','LineWidth',1.5)
        subplot(4,1,4)
        plot(centers_angle,sum_mean{4}/size(roiData,1),'k','LineWidth',1.5)
else
       for roi = 1:size(roiData,1)
        % vf
        activity = Z.zScore(Z.roiName == roi);
        behaviour = vf; 
        [vf_zscore, centers_vf] = binData(activity, behaviour, edges_vf);
        sum_mean{1} = sum_mean{1} + vf_zscore; 

        l(1) = subplot(4,1,1);
        plot(centers_vf,vf_zscore)
        ylabel('Z')
        xlabel('vf (mm/s)')
        hold on


        % vs 
        behaviour = vs; 
        [vs_zscore, centers_vs] = binData(activity, behaviour, edges_vs);
        sum_mean{2} = sum_mean{2} + vs_zscore; 

        l(2) = subplot(4,1,2);
        plot(centers_vs,vs_zscore)
        ylabel('Z')
        xlabel('vs (mm/s)')
        hold on

        % vy 
        [vy_zscore, centers_vy] = binData(activity, vy, edges_vy);
        sum_mean{3} = sum_mean{3} + vy_zscore; 


        l(3) = subplot(4,1,3);
        plot(centers_vy,vy_zscore)
        ylabel('Z')
        xlabel('vy (deg/s)')
        hold on

        % angle
        [angle_zscore, centers_angle] = binData(activity, angle, edges_angle);
        sum_mean{4} = sum_mean{4} + angle_zscore; 


        l(4) = subplot(4,1,4);
        plot(centers_angle,angle_zscore)
        ylabel('Z')
        xlabel('cue pos (deg)')
        hold on 
       end
end

if savePlots == 1
    fig=gcf;
    saveas(gcf, fullfile(imagesDir,[expID,'_',num2str(nTrial),'_zScore_behaviour_lineplots.fig']));
end

%% heading distribution plots
behaviourData.vel_for = vf; 
behaviourData.vel_side = vs;
behaviourData.vel_yaw = wrapTo180((vy/ (2*pi) ) * 360);
behaviourData.angle = angle;
minVel = 1.5; 
window = 60; 
sampRate = round(volRate); 


[~, ~, ~, f, g] = plotHeadingDist(window, minVel, behaviourData, sampRate, 1);


if savePlots == 1
    saveas(f, fullfile(imagesDir,[expID,'_',num2str(nTrial),'_headingVectors.fig']));
    saveas(g, fullfile(imagesDir,[expID,'_',num2str(nTrial),'_headingDist.fig']));
clear
end

