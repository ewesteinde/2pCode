        expID = get_expID(folder);
        expList = {expID};
        % Load FicTrac data
        [~,ftData_DAQ,~] = load_ft_data(expList, folder, 1, 0);

        cd(folder)
        
        myVideo = VideoWriter('flyTrajectory'); %open video file
        myVideo.FrameRate = 120;  %can adjust this, 5 - 10 works well for me
        open(myVideo)

        yawAngPos = ftData_DAQ.cueAngle{1};
        fwdAngVel = ftData_DAQ.velFor{1};
        slideAngVel = ftData_DAQ.velSide{1};

        sampRate = 30; % check
        % conversion factor between degrees and mm
        circum = 9 * pi; % circumference of ball, in mm
        mmPerDeg = circum / 360; % mm per degree of ball

        % position incorporating heading - as if fly were walking on x-y plane,
        %  x-y coordinates at each time point
        % start with fly at (0,0) and facing 0 deg
        zeroedYawAngPos = yawAngPos - yawAngPos(1); 

        % movement in x (in degrees) at each time point
        xChangePos = (fwdAngVel ./ sampRate) .* sind(zeroedYawAngPos) + ...
            (slideAngVel ./ sampRate) .* sind(zeroedYawAngPos + 90);  

        % x position in mm (i.e. x-coordinate of fly's position at each time 
        %  point), starts at 0
        xPos = (cumsum(xChangePos) - xChangePos(1)) .* mmPerDeg;
        minX = min(xPos);
        maxX = max(xPos);

        % movement in y (in degrees) at each time point
        yChangePos = (fwdAngVel ./ sampRate) .* cosd(zeroedYawAngPos) + ...
            (slideAngVel ./ sampRate) .* cosd(zeroedYawAngPos + 90);

        % y position in mm (i.e. y-coordinate of fly's position at each time 
        %  point), starts at 0
        yPos = (cumsum(yChangePos) - yChangePos(1)) .* mmPerDeg;
        minY = min(yPos);
        maxY = max(yPos);

        xPos = xPos(3000:end);
        yPos = yPos(3000:end); 
        for t = 1:length(xPos)
            figure(77);
            hold on
            patch('xData',xPos(t),'yData',yPos(t),'EdgeColor','k','FaceColor','none','LineStyle','none','Marker','.', 'MarkerSize',3);
            set(gcf,'Renderer','painters')
            set(gcf,'color','w');
            xlabel('mm')
            xlim([min(minX,minY),max(maxX, maxY)])
            ylim([min(minX,minY),max(maxX, maxY)])
            frame = getframe(gcf); %get frame
            writeVideo(myVideo, frame);
        end

close(myVideo)