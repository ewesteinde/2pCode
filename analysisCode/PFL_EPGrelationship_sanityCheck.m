% 
% 
% shift = 0; % + shift in epg bump means it moved counterclockwise --> fly moved clockwise (right) 
% default = [0:pi/4:2*pi] - pi/2;
% baseSine = sin(default - pi/2);
% goal = default;
% figure();
% %plot(sin(goal),'--g')
% hold on
% epg = default + shift;
% leftPFL3 = epg - pi/2; % -90 deg shift (right)
% rightPFL3 = epg + pi/2; % + 90 deg shift (left)
% PFL2 = epg + pi; % 180 deg shift
% %plot(leftPFL3,'b')
% %plot(rightPFL3,'r')
% %plot(sin(epg),'k')
% 
% %plot(sin(leftPFL3) + sin(goal), 'b')
% %plot(sin(rightPFL3) + sin(goal), 'r')
% plot(sin(PFL2) + sin(goal),'y')
% %plot(sin(PFL2),'--y')
% title('fly slight slight right goal')
% %legend({'Goal','EPG','L PFL3', 'R PFL3', 'PFL2'})
% legend({'Goal','EPG','PFL2'})
% %ylim([-2,2])


%%
goal = [0:deg2rad(1):2*pi] - pi/2;
figure();
for s = 1:721
    %hold off
    shift = deg2rad(721-1 -s);
    PFL2 = sin(goal + shift + pi) .* sin(goal); 
    plot(linspace(1,9,361),PFL2)
    hold on
    %xline(5)
    EPG = sin(goal + shift); 
    %plot(linspace(1,9,361),EPG,'k')
    ylim([-2 2])
    PFL2pos = find(PFL2 == max(PFL2));
    EPGpos = find(EPG == max(EPG));
    wrapTo180(EPGpos-PFL2pos)
    if length(PFL2pos) > 1
        PFL2pos = sum(PFL2pos)/length(PFL2pos); 
    end
    peakPos = zeros(1,361);
    peakPos(round(PFL2pos)) = 1;
    plot(linspace(1,9,361),peakPos,'ro')
%     PFL2_pos(s) = pos;
%     PFL2_mag(s) = max(PFL2(s));
%     turn(s) = s-1; 
    pause
end

% 1) for a 360 deg rotation of the fly the bump moves once around the whole FB
% (1:1 relationship b/w EPG pos & fly heading) but the PFL2 bump position
% would only move 180 deg, it only travels through 1/2 of the FB. Which
% half depends on the phase of the goal sinusoid. 

% 2) The offset between the position of the PFL2 bump & the EPG bump is not
% set. It depends on the phase difference between the EPG sinusoid & the
% goal sinusoid. As the fly rotates 360 degrees, starting from facing
% towards its goal the offset changes from -90 --> +/-180 --> + 90 (or opp
% depending on rotation direction)


    