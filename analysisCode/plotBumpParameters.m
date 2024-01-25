function plotBumpParameters(folder,dffData, ftT, nTrial, bump_params)

% figure();
% h1 = subplot(5,1,1);
% plot(ftT.trialTime{1},bump_params.mag)
% ylabel('amp')
% h2 = subplot(5,1,2);
% plot(ftT.trialTime{1},bump_params.width)
% ylabel('width')
% h3 = subplot(5,1,3);
% plot(ftT.trialTime{1},bump_params.pos_idx)
% ylabel('pos')
% h4 = subplot(5,1,4);
% plot(ftT.trialTime{1},ftT.velFor{1})
% ylabel('vf')
% h5 = subplot(5,1,5);
% plot(ftT.trialTime{1},bump_params.adj_rs)
% ylabel('R')
% 
% linkaxes([h1,h2,h3,h4,h5],'x')

offset = bump_params.offset; 
offset(bump_params.adj_rs < 0.1) = nan; 
amp = bump_params.amp; 
amp(bump_params.adj_rs < 0.1) = nan; 
pos = bump_params.pos_idx; 
pos(bump_params.adj_rs < 0.1) = nan; 


dff = [];
for roi = 1:size(dffData,1)
    dff(roi,:) = dffData.dff{roi};
end



fig1 = figure('Renderer', 'painters', 'Position', [100 300 1500 700],'color','w');
h6=subplot(5,1,1);
imagesc(dff)
colormap(flipud(gray))
title('PFL2 activity');
set(gca,'YDir','normal')
box off
h1 = subplot(5,1,2);
plot(ftT.trialTime{1},amp)
ylabel('amp')
xlim([min(ftT.trialTime{1}),max(ftT.trialTime{1})])
box off
h3 = subplot(5,1,3);
plot(ftT.trialTime{1},pos,'.','MarkerSize',2)
ylabel('pos')
xlim([min(ftT.trialTime{1}),max(ftT.trialTime{1})])
box off
h4 = subplot(5,1,4);
plot(ftT.trialTime{1},offset,'.','MarkerSize',2)
ylabel('offset')
xlim([min(ftT.trialTime{1}),max(ftT.trialTime{1})])
box off
h5 = subplot(5,1,5);
plot(ftT.trialTime{1},ftT.cueAngle{1},'.','MarkerSize',2)
ylabel('angle')
xlim([min(ftT.trialTime{1}),max(ftT.trialTime{1})])
box off,
linkaxes([h1,h3,h4,h5],'x')

saveas(fig1,fullfile(folder,'images',['bumpParams_Trial00',num2str(nTrial),'.fig']))
saveas(fig1,fullfile(folder,'images',['bumpParams_Trial00',num2str(nTrial),'.svg']))

fig2 = figure('Renderer', 'painters','color','w');
subplot(2,1,1)
histogram(ftT.cueAngle{1},100),hold on, histogram(wrapTo180(rad2deg(bump_params.pos_rad)),100)
legend('cuePos','bumpPos')
box off
subplot(2,1,2)
histogram(ftT.cueAngle{1},100),hold on, histogram(wrapTo180(rad2deg(offset)),100)
legend('cuePos','offset')
box off
saveas(fig2,fullfile(folder,'images',['bumpHist_Trial00',num2str(nTrial),'.fig']))
saveas(fig2,fullfile(folder,'images',['bumpHist_Trial00',num2str(nTrial),'.svg']))





% subplot(4,1,2)
% plot(bump_params.pos_idx,'.')
% title('Bump pos');
% xlim([1 length(bump_params.pos_idx)]);
% 
% subplot(4,1,3)
% plot(bump_params.width)
% title('Bump magnitude');
% xlim([1 length(bump_params.mag)]);
% 
% subplot(4,1,4)
% plot(bump_params.width)
% title('Bump width');
% xlim([1 length(bump_params.width)]);

%% bin data & compare
r2_idx = find(bump_params.adj_rs > 0.5);
fig = figure('Renderer', 'painters', 'Position', [100 100 800 1000],'color','w');

activity = bump_params.amp(r2_idx); 
edges = [-4:0.5:10];
%sum_mean{1} = zeros(length(edges_angle)-1,1);
behaviour = ftT.velFor{1}(r2_idx);

[mean_bin, centers] = binData(activity, behaviour, edges);

subplot(4,1,1);
plot(centers,mean_bin)
ylabel('bump amp')
xlabel('vf (mm/s')
box off


activity = bump_params.amp(r2_idx); 
edges = [-200:10:200];
%sum_mean{1} = zeros(length(edges_angle)-1,1);
behaviour = wrapTo180(rad2deg(ftT.velYaw{1}(r2_idx)));

[mean_bin, centers] = binData(activity, behaviour, edges);

subplot(4,1,2);
plot(centers,mean_bin)
ylabel('bump amp')
xlabel('vy (deg/s)')
box off


activity = bump_params.amp(r2_idx); 
edges = [-6:0.5:6];
%sum_mean{1} = zeros(length(edges_angle)-1,1);
behaviour = ftT.velSide{1}(r2_idx);

[mean_bin, centers] = binData(activity, behaviour, edges);

subplot(4,1,3);
plot(centers,mean_bin)
ylabel('bump amp')
xlabel('vs (deg/s)')
box off

activity = bump_params.amp(r2_idx); 
edges = [-180:10:180];
%sum_mean{1} = zeros(length(edges_angle)-1,1);
behaviour = ftT.cueAngle{1}(r2_idx);

[mean_bin, centers] = binData(activity, behaviour, edges);

subplot(4,1,4);
plot(centers,mean_bin)
ylabel('bump amp')
xlabel('cue pos')
box off

saveas(fig,fullfile(folder,'images',['bumpParams_linePlots_Trial00',num2str(nTrial),'.fig']))
saveas(fig,fullfile(folder,'images',['bumpParams_linePlots_Trial00',num2str(nTrial),'.svg']))
end