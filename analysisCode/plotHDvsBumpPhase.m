%[MenoData, nMenoData] = Group_Meno_notMeno(rootDir);
folder = 'Z:\2photon_data\PFL2_3_processedData\20220413\20220413-2_PFL2_Fly1_PB';
load(fullfile(folder,'processed_data','bump_parameters_Trial001.mat'))
load(fullfile(folder,'processed_data','fictracData_Trial_001.mat'))

total_mov_mm = abs(ftT.velFor{1} + abs(ftT.velSide{1}) + abs(ftT.velYaw{1})*4.5);
no0vel_idx = find(total_mov_mm > 2);
bPhase = -wrapToPi(bump_params.pos_rad(no0vel_idx) + pi); % convert to agree with ROI & head direction
rValue = bump_params.adj_rs(no0vel_idx);
bPhase = bPhase(rValue > 0.1);
angle = ftT.cueAngle{1}(no0vel_idx);
angle = angle(rValue > 0.1);
% heading = ftT.cueAngle{1}; %wrapTo180(wrapTo180(ftT.cueAngle{1})-wrapTo180(125)); 
% heading = -deg2rad(heading); % convert to HD from cue pos
% heading = heading;

changebPhase = [];
changeHD = []; 



for lags = 0:0.2:1
    lag = round(60 * lags); % s lag bump phase relative to HD
    window = 1.5*60; % 5 sec windows
    count = 1;
    for i = 1+lag:window:length(bPhase)
        est_goal = EstimateGoal(ftT, i, 30, [],60);
        idx = i:i + window; 
        if (idx(end) <= length(bPhase)) && idx(1) >= 1 
            heading = -deg2rad( wrapTo180(wrapTo180(angle(idx - lag ))-wrapTo180(rad2deg(est_goal)))); 
            bPhaseStart = bPhase(idx(1));
            bPhaseEnd = bPhase(idx(end));
            changebPhase(count) = angdiff(bPhaseStart,bPhaseEnd); % 2nd - 1st + = clockwise change, - = counterclockwise in phase
            HDstart = heading(1); 
            HDend = heading(end); 
            changeHD(count) = angdiff(HDstart,HDend); % 2nd - 1st + = clockwise change, - = counterclockwise in HD
            count = count + 1; 
        end
    end
    
    nanIdx = isnan(changeHD) | isnan(changebPhase);
    changebPhase(nanIdx) = []; 
    changeHD(nanIdx) = []; 
    
    figure()
    set(gcf,'color','w','renderer','painters')
    hold on
    scatter(rad2deg(changeHD),rad2deg(changebPhase))
    [p,S] = polyfit(changeHD,changebPhase,1); 
    x = linspace(-180,180,1000);
    fit1 = polyval(p,x);
    plot(x,fit1)
    ylim([-180,180])
    xlim([-180,180])
    [R,P] = corrcoef(changeHD,changebPhase);
    annotation('textbox',[0.5,0.8,0.1,0.1],'String',['R = ',num2str(R(1,2)),' p = ',num2str(P(1,2))], 'EdgeColor','none')
    title(['lag: ',num2str(lags)])
    xlabel(folder)
end