folder = 'Z:\2photon_data\test_exampleFly\PFL2\20220411-2_PFL2_fly1_FB';
lineplotDir = 'Z:\2photon_data\test_exampleFly\PFL3\meno_andnoMeno\20220506-1_PFL2_3_fly2_LAL\images';
expID = get_expID(folder);
expList = {expID};

% Load metadata 
[expMd, trialMd] = load_metadata(expList, folder);
% goal1_idx = find(seconds(ftT.trialTime{1}) > 0 & seconds(ftT.trialTime{1}) < 224.5);
% 
% % goal1_idx = find(seconds(ftT.trialTime{1}) > 0 & seconds(ftT.trialTime{1}) < seconds(ftT.trialTime{1}(end)));
% 
% ftT_goal1 = ftT;
% for col = 3:size(ftT,2)
%     ftT_goal1.(col){1} = ftT.(col){1}(goal1_idx);
% end
%                     
% dffData_goal1 = dffData;
% ZData_goal1 = ZData;
% for roi = 1:size(dffData,1)
%     dffData_goal1.roiTime{roi} = dffData.roiTime{roi}(goal1_idx); 
%     dffData_goal1.dff{roi} = dffData.dff{roi}(goal1_idx); 
%     
%     ZData_goal1.roiTime{roi} = ZData.roiTime{roi}(goal1_idx); 
%     ZData_goal1.Z{roi} = ZData.Z{roi}(goal1_idx); 
% end
% %activityVSbehaviour_no0vel_PosterPlots(ftT_goal1, ZData_goal1, roiData, 1, 3, expMd,0,lineplotDir)
% %bump_paramsGoal1 = bump_params.amp(goal1_idx);
% %bumpAmpVSbehaviour_no0vel_PosterPlots(ftT_goal1, bump_paramsGoal1, roiData, 1, 3, expMd,0,lineplotDir)
% 
% %% calc segment heading:
%     speed = sqrt(ftT.velFor{1}(goal1_idx).^2 + ftT.velSide{1}(goal1_idx).^2);
%     trial_angle = ftT.cueAngle{1}(goal1_idx);
%     trial_angle = trial_angle(speed > 1.5);
%     xTrial = cosd(trial_angle);
%     yTrial = sind(trial_angle); 
%     trialHeadingVector(1) = sum(xTrial)/length(xTrial);
%     trialHeadingVector(2) = sum(yTrial)/length(yTrial);
%     rho_goal1 = sqrt(trialHeadingVector(1).^2 + trialHeadingVector(2).^2); 
%     theta_goal1 = atan2(trialHeadingVector(2),trialHeadingVector(1));

%%
goal2_idx = find(seconds(ftT.trialTime{1}) > 468 & seconds(ftT.trialTime{1}) < 600);
ftT_goal2 = ftT;
for col = 3:size(ftT,2)
    ftT_goal2.(col){1} = ftT.(col){1}(goal2_idx);
end
dffData_goal2 = dffData;
ZData_goal2 = ZData;
for roi = 1:size(dffData,1)
    dffData_goal2.roiTime{roi} = dffData.roiTime{roi}(goal2_idx); 
    dffData_goal2.dff{roi} = dffData.dff{roi}(goal2_idx); 
    
    ZData_goal2.roiTime{roi} = ZData.roiTime{roi}(goal2_idx); 
    ZData_goal2.Z{roi} = ZData.Z{roi}(goal2_idx); 
end
%bump_paramsGoal2 = bump_params.amp(goal2_idx);
%activityVSbehaviour_no0vel_PosterPlots(ftT_goal2, ZData_goal2, roiData, 1, 3, expMd,0,lineplotDir)
%bumpAmpVSbehaviour_no0vel_PosterPlots(ftT_goal2, bump_paramsGoal2, roiData, 1, 3, expMd,0,lineplotDir)

% calc segment heading:
    speed = sqrt(ftT.velFor{1}(goal2_idx).^2 + ftT.velSide{1}(goal2_idx).^2);
    trial_angle = ftT.cueAngle{1}(goal2_idx);
    trial_angle = trial_angle(speed > 1.5);
    xTrial = cosd(trial_angle);
    yTrial = sind(trial_angle); 
    trialHeadingVector(1) = sum(xTrial)/length(xTrial);
    trialHeadingVector(2) = sum(yTrial)/length(yTrial);
    rho_goal2 = sqrt(trialHeadingVector(1).^2 + trialHeadingVector(2).^2); 
    theta_goal2 = atan2(trialHeadingVector(2),trialHeadingVector(1));

%[x,y] = pol2cart([theta_goal1;theta_goal2],[rho_goal1;rho_goal2]);
[x,y] = pol2cart([theta_goal2,0],[rho_goal2,0.6]);
figure();
set(gcf,'Renderer','painters')
set(gcf,'color','w')
hC = compass(x,y,'k');
for i=1:numel(hC)
    hC(i).XData(end-2:end)=nan;       % HG won't display NaN points (arrows)
end
