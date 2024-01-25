
activityTable = Z;

% vy 
figure();
set(gcf,'color','w')
set(gcf,'Renderer','painters')
label = 'Z'; 

activity = activityTable.(3){1};
activity = activity(no0vel_idx);
behaviour = vy; 
[zscore, centers_vy, SEM] = binData(activity, behaviour, edges_vy);
keepIndex = ~isnan(SEM);
SEMhigh = [zscore(keepIndex) + SEM(keepIndex)]'; 
SEMlow = [zscore(keepIndex) - SEM(keepIndex)]';
patch([centers_vy(keepIndex) fliplr(centers_vy(keepIndex))],[SEMhigh fliplr(SEMlow)],'b','FaceAlpha',.3,'EdgeColor','none')
hold on
plot(centers_vy,zscore)
ylabel(label)
xlabel('vy (deg/s)')


activity = activityTable.(3){2};
activity = activity(no0vel_idx);
behaviour = vy; 
[zscore, centers_vy, SEM] = binData(activity, behaviour, edges_vy); 
keepIndex = ~isnan(SEM);
SEMhigh = [zscore(keepIndex) + SEM(keepIndex)]'; 
SEMlow = [zscore(keepIndex) - SEM(keepIndex)]';
patch([centers_vy(keepIndex) fliplr(centers_vy(keepIndex))],[SEMhigh fliplr(SEMlow)],'r','FaceAlpha',.3,'EdgeColor','none')
hold on
plot(centers_vy,zscore)
ylabel(label)
xlabel('vy (deg/s)')

%vy L-R
figure();
set(gcf,'color','w')
set(gcf,'Renderer','painters')
label = 'Z'; 

activity = activityTable.(3){2} - activityTable.(3){1};
activity = activity(no0vel_idx);
behaviour = vy; 
[zscore, centers_vy, SEM] = binData(activity, behaviour, edges_vy);
keepIndex = ~isnan(SEM);
SEMhigh = [zscore(keepIndex) + SEM(keepIndex)]'; 
SEMlow = [zscore(keepIndex) - SEM(keepIndex)]';
patch([centers_vy(keepIndex) fliplr(centers_vy(keepIndex))],[SEMhigh fliplr(SEMlow)],'k','FaceAlpha',.3,'EdgeColor','none')
hold on
plot(centers_vy,zscore,'k')
yline(0,'--r')
ylabel('R - L')
xlabel('vy (deg/s)')


% cue Pos 
figure();
set(gcf,'color','w')
set(gcf,'Renderer','painters')
label = 'Z'; 

activity = activityTable.(3){1};
activity = activity(no0vel_idx);
behaviour = wrapTo180(wrapTo180(angle)-wrapTo180(rad2deg(3.03849561556943))); 
[zscore, centers_angle, SEM] = binData(activity, behaviour, edges_angle);
keepIndex = ~isnan(SEM);
SEMhigh = [zscore(keepIndex) + SEM(keepIndex)]'; 
SEMlow = [zscore(keepIndex) - SEM(keepIndex)]';
patch([centers_angle(keepIndex) fliplr(centers_angle(keepIndex))],[SEMhigh fliplr(SEMlow)],'b','FaceAlpha',.3,'EdgeColor','none')
hold on
plot(centers_angle,zscore)
ylabel(label)
xlabel('Cue Position from Goal')
 
activity = activityTable.(3){2};
activity = activity(no0vel_idx);
[zscore, centers_angle, SEM] = binData(activity, behaviour, edges_angle); 
keepIndex = ~isnan(SEM);
SEMhigh = [zscore(keepIndex) + SEM(keepIndex)]'; 
SEMlow = [zscore(keepIndex) - SEM(keepIndex)]';
patch([centers_angle(keepIndex) fliplr(centers_angle(keepIndex))],[SEMhigh fliplr(SEMlow)],'r','FaceAlpha',.3,'EdgeColor','none')
hold on
plot(centers_angle,zscore)
ylabel(label)
xlabel('Cue Position from Goal')

%cue Pos L-R
figure();
set(gcf,'color','w')
set(gcf,'Renderer','painters')
label = 'Z'; 

activity = activityTable.(3){2} - activityTable.(3){1};
activity = activity(no0vel_idx);
[zscore, centers_angle, SEM] = binData(activity, behaviour, edges_angle);
keepIndex = ~isnan(SEM);
SEMhigh = [zscore(keepIndex) + SEM(keepIndex)]'; 
SEMlow = [zscore(keepIndex) - SEM(keepIndex)]';
patch([centers_angle(keepIndex) fliplr(centers_angle(keepIndex))],[SEMhigh fliplr(SEMlow)],'k','FaceAlpha',.3,'EdgeColor','none')
hold on
plot(centers_angle,zscore,'k')
yline(0,'--r')
ylabel('R - L')
xlabel('Cue Position from Goal')
