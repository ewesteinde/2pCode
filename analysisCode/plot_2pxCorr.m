function plot_2pxCorr(ftT_down, lag, roiData, pro_roiData, roi_angle_max)

roi_num = unique(pro_roiData.roiName);


heading = ftT_down.cueAngle{1}; 
vy =  ftT_down.yawSpeed{1}; 
vf =  ftT_down.fwSpeed{1}; 
vs =  ftT_down.sideSpeed{1}; 
vy_abs = abs(vy); 
vs_abs = abs(vs);
mSpeed = ftT_down.moveSpeed{1};
volRate = roiData.sampRate(1); 
sec_interval = 1/volRate; 
maxLag = round(volRate*lag);

vf_corr_sum = zeros(maxLag*2+1,1);
vy_corr_sum = zeros(maxLag*2+1,1);
vs_corr_sum = zeros(maxLag*2+1,1);
vy_abs_corr_sum = zeros(maxLag*2+1,1);
vs_abs_corr_sum = zeros(maxLag*2+1,1);
heading_corr_sum = zeros(maxLag*2+1,1);
mSpeed_corr_sum = zeros(maxLag*2+1,1);


figure(); 
for roi = 1:max(roi_num)
    dff = pro_roiData.data(pro_roiData.roiName == roi); 
    [vf_corr,vf_lags] = xcorr(dff,vf,maxLag,'coeff');
    vf_corr_sum = vf_corr_sum + vf_corr;
    subplot(1,5,1)
    plot(vf_lags,vf_corr)
    xlabel('vf')
    hold on
%     [vy_corr,vy_lags] = xcorr(dff,vy,maxLag,'coeff');
%     vy_corr_sum = vy_corr_sum + vy_corr;
%     subplot(1,5,2)
%     plot(vy_lags,vy_corr)

    [mSpeed_corr,mSpeed_lags] = xcorr(dff,mSpeed,maxLag,'coeff');
    mSpeed_corr_sum = mSpeed_corr_sum + mSpeed_corr;
    subplot(1,5,2)
    plot(mSpeed_lags,mSpeed_corr)
    xlabel('move Speed')
    hold on
%     [vs_corr,vs_lags] = xcorr(dff,vs,maxLag,'coeff');
%     vs_corr_sum = vs_corr_sum + vs_corr;
%     subplot(1,5,3)
%     plot(vs_lags,vs_corr)
    [vs_abs_corr,vs_abs_lags] = xcorr(dff,vs_abs,maxLag,'coeff');
    vs_abs_corr_sum = vs_abs_corr_sum + vs_abs_corr;
    subplot(1,5,3)
    plot(vs_abs_lags,vs_abs_corr)
    xlabel('abs vs')
    hold on
    [vy_abs_corr,vy_abs_lags] = xcorr(dff,vy_abs,maxLag,'coeff');
    vy_abs_corr_sum = vy_abs_corr_sum + vy_abs_corr;
    subplot(1,5,4)
    plot(vy_abs_lags,vy_abs_corr)
    xlabel('abs vy')
    hold on
    % converts heading to a value b/w 0 to 1 based on estimated ROI pref
    % head & assuming a cosine rel b/w activity & heading 
    cos_heading = (cosd(heading-roi_angle_max(roi)) - min(cosd(heading-roi_angle_max(roi))))/(max(cosd(heading-roi_angle_max(roi)))-min(cosd(heading-roi_angle_max(roi))));
    [heading_corr,heading_lags] = xcorr(dff,cos_heading,maxLag,'coeff');
    heading_corr_sum = heading_corr_sum + heading_corr;
    subplot(1,5,5)
    plot(heading_lags,heading_corr)
    xlabel('cue pos')
    hold on
end

subplot(1,5,1)
aveCorr_vf = vf_corr_sum/max(roi_num); 
plot(vf_lags,aveCorr_vf,'k',"LineWidth",1.5)
xline(vf_lags(aveCorr_vf == max(aveCorr_vf)),'-',num2str(vf_lags(aveCorr_vf == max(aveCorr_vf))))
subplot(1,5,2)
aveCorr_mSpeed = mSpeed_corr_sum/max(roi_num); 
plot(mSpeed_lags,aveCorr_mSpeed,'k',"LineWidth",1.5)
xline(mSpeed_lags(aveCorr_mSpeed == max(aveCorr_mSpeed)),'-',num2str(mSpeed_lags(aveCorr_mSpeed == max(aveCorr_mSpeed))))
subplot(1,5,3)
aveCorr_vs_abs = vs_abs_corr_sum/max(roi_num); 
plot(vs_abs_lags,aveCorr_vs_abs,'k',"LineWidth",1.5)
xline(vs_abs_lags(aveCorr_vs_abs == max(aveCorr_vs_abs)),'-',num2str(vs_abs_lags(aveCorr_vs_abs == max(aveCorr_vs_abs))))
%plot(vs_lags,vs_corr_sum/max(roi_num),'k',"LineWidth",1.5)
subplot(1,5,4)
aveCorr_vy_abs = vy_abs_corr_sum/max(roi_num); 
plot(vy_abs_lags,aveCorr_vy_abs,'k',"LineWidth",1.5)
xline(vy_abs_lags(aveCorr_vy_abs == max(aveCorr_vy_abs)),'-',num2str(vy_abs_lags(aveCorr_vy_abs == max(aveCorr_vy_abs))))
subplot(1,5,5)
aveCorr_heading = heading_corr_sum/max(roi_num); 
plot(heading_lags,aveCorr_heading,'k',"LineWidth",1.5)
xline(heading_lags(aveCorr_heading == max(aveCorr_heading)),'-',num2str(heading_lags(aveCorr_heading == max(aveCorr_heading))))


%% auto correlations

% vf_corr_sum = zeros(length(heading)*2-1,1);
% figure(); 
% for roi = 1:max(roi_num)
%     dff = Z.data(Z.roiName == roi); 
%     [vf_corr,vf_lags] = xcorr(dff,'coeff');
%     vf_corr_sum = vf_corr_sum + vf_corr;
%     plot(vf_lags,vf_corr)
%     hold on
% end
% 
% plot(vf_lags,vf_corr_sum/max(roi_num),'k',"LineWidth",1.5)
% 
% 
% vf_corr_sum = zeros(length(heading)*2-1,1);
% roi_corr_sum = zeros(length(heading)*2-1,1);
% vy_corr_sum = zeros(length(heading)*2-1,1);
% vs_corr_sum = zeros(length(heading)*2-1,1);
% vy_abs_corr_sum = zeros(length(heading)*2-1,1);
% heading_corr_sum = zeros(length(heading)*2-1,1);
% 
% 
% figure(); 
% for roi = 1:max(roi_num)
%     dff = Z.data(Z.roiName == roi); 
%     [roi_corr,roi_lags] = xcorr(dff);
%     roi_corr_sum = roi_corr_sum + roi_corr;
%     plot(roi_lags,roi_corr)
%     hold on
% end
% plot(roi_lags,roi_corr_sum/max(roi_num),'k',"LineWidth",1.5)
% 
% figure();
%     [vf_corr,vf_lags] = xcorr(vf);
%     vf_corr_sum = vf_corr_sum + vf_corr;
%     subplot(1,5,1)
%     plot(vf_lags,vf_corr)
%     
%     [vy_corr,vy_lags] = xcorr(vy);
%     vy_corr_sum = vy_corr_sum + vy_corr;
%     subplot(1,5,2)
%     plot(vy_lags,vy_corr)
% 
%     [vs_corr,vs_lags] = xcorr(vs);
%     vs_corr_sum = vs_corr_sum + vs_corr;
%     subplot(1,5,3)
%     plot(vs_lags,vs_corr)
% 
%     [vy_abs_corr,vy_abs_lags] = xcorr(vy_abs);
%     vy_abs_corr_sum = vy_abs_corr_sum + vy_abs_corr;
%     subplot(1,5,4)
%     plot(vy_abs_lags,vy_abs_corr)
% 
%     [heading_corr,heading_lags] = xcorr(heading);
%     heading_corr_sum = heading_corr_sum + heading_corr;
%     subplot(1,5,5)
%     plot(heading_lags,heading_corr)
% 
% 
% 
end