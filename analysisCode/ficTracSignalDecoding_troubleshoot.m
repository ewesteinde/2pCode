function [ velocityOut , accumulatedPositionOut, nonSmoothVel ] = ficTracSignalDecoding_troubleshoot(ficTracBallPosition , sampleRate , lowPassFilterCutOff, fictrac_rate, maxFlyVelocity)
%FICTRACSIGNALDECODING takes a fictrac position value and extracts ball velocity 
%  This function will take a FicTrac output signal as aquired by the DAQ
%  as an analog signal and solve for the ball's angular velocity in the given 
%  dimention. To do this the signal is then UNWRAPPED to handle the abrupt
%  transitions caused by when the ball rotates completely and the signal
%  resets (0->10 volts or 10 volts -> 0) transistions.  Then the signal will be
%  further CLEANED to remove extra position values surrounding those signal
%  reset time points. Then the position signal is LOW PASS FILTERED to
%  remove noise. Then the velocity of the ball with be solved for in
%  degree/s by using the diff function, and taking into consideration the  
%  sample rate the data was collected at.  Velocity values above what a
%  resonable fly would turn the ball at (maxFlyVelocity) are discarded
%  
%   INPUTS
%   ficTracBallPosition  - array containing data from 0-10 volts relating
%   to the balls position
%
%   sampleRate - Rate the data was aquired at ( samples/ second )
%   
%   lowPassFilterCutOff - frequency that the position signal will be low
%   pass filtered at (Hz)
%
%   maxFlyVelocity - max value of realistic fly movement (deg/s) 
%
%   OUTPUT
%   velocityOut -array containing's instentanous velocity (degree/sec)
%   accumulatedPositionOut - array containing the filtered and unwraped
%   position signal
%
%   Yvette Fisher 1/2018
%   Modified by Jenny Lu 2/2019 for better derivative -- 3/2019 reverted to
%   butterworth filter for consistency
% ------------------------------
FICTRAC_MAX_VOLTAGE = 10;  % volts

% transfrom ficTrac signal into radians  
posRadians = ficTracBallPosition .* 2 .* pi ./ FICTRAC_MAX_VOLTAGE; 

% upwrap position signal
unwrappedPos = unwrap( posRadians );

% find indexes where the unwrapping happened (tolerace = pi)
upwrappedIndexes = find ( abs( diff( posRadians )) > pi); 

NUM_SAMPLES_FROM_WRAP_TO_REPLACE = 2;
% handle edge case so we don't fill off the edge of the trace
upwrappedIndexes = upwrappedIndexes( upwrappedIndexes > NUM_SAMPLES_FROM_WRAP_TO_REPLACE & upwrappedIndexes < (length ( unwrappedPos ) - NUM_SAMPLES_FROM_WRAP_TO_REPLACE) ); 

cleanedPos = unwrappedPos;
% replace potentially problematic indexes with Nan
for i = 1: length ( upwrappedIndexes )
    index_start = upwrappedIndexes(i) -  NUM_SAMPLES_FROM_WRAP_TO_REPLACE ; 
    index_end = upwrappedIndexes(i) +  NUM_SAMPLES_FROM_WRAP_TO_REPLACE ; 
    
    cleanedPos( index_start : index_end ) = NaN;
end

% replace NaN values with the last preceding value that was a real number
nanIDX = find( isnan( cleanedPos ) ); % find NaN indexes
% replace with preceeding value
while( ~isempty( nanIDX ) )
    cleanedPos(nanIDX) = cleanedPos(nanIDX - 1);
    
    % find any remaining NaN
    nanIDX  = find( isnan(cleanedPos) );
end



% low pass filter the position array
%filteredPosition = lowPassFilter( cleanedPos, lowPassFilterCutOff, sampleRate );
rate = 2*(lowPassFilterCutOff/sampleRate);
[kb, ka] = butter(2,rate);
filteredPosition = filtfilt(kb, ka, cleanedPos);
%filteredPosition = cleanedPos;

% downsample position data to reduce velocity noise
[downsampled_filteredPos,~] = resample_with_padding(filteredPosition,fictrac_rate/2,sampleRate);


% plotting to check how well unwrapping, cleaning and filtering worked
% can be commented out once you are happy with the parameters
 
figure('Position',[50, 50, 1000, 400]);  set(gcf, 'Color', 'w');
ax(1) = subplot(2, 1, 1);
plot( posRadians ); hold on;
ylabel ('rad');
ax(2) = subplot (2, 1, 2);
plot( unwrappedPos ); hold on;
plot( cleanedPos )
plot( filteredPosition )
legend({'unwrapped', 'cleaned', 'filtered'})
linkaxes(ax,'x');


%% In radians, uncomment to convert to degrees
%accumulatedPositionOut = ( filteredPosition / (2*pi) ) * 360;
accumulatedPositionOut = downsampled_filteredPos;

%% take derivative and ajust for sample rate to solve for deg/s
%velocityOut = diff( accumulatedPositionOut ) .* sampleRate ; % degees / sec
% USE SMOOTH_DIFF

%smooth_n = 200; %filter length = smooth_n/4000 s
%velocityOut = filter(-smooth_diff(smooth_n), 1, accumulatedPositionOut).* sampleRate;
velocityTemp = gradient( accumulatedPositionOut ) .* fictrac_rate/2 ; % rad / sec

%% remove velocity values that are too large to be possible for the fly
velocityclamped = velocityTemp;
velocityclamped(velocityclamped>maxFlyVelocity)=maxFlyVelocity;
velocityclamped(velocityclamped<=-maxFlyVelocity)=-maxFlyVelocity;

% smooth velocity & bring back up to the fictrac rate for consistancy 
velocityOut = resample_with_padding(smoothdata(velocityclamped,'loess',10),fictrac_rate,fictrac_rate/2);
accumulatedPositionOut = resample_with_padding(accumulatedPositionOut,fictrac_rate,fictrac_rate/2);
nonSmoothVel = resample_with_padding(velocityclamped,fictrac_rate,fictrac_rate/2);

figure('Position',[50, 50, 1000, 400]);  set(gcf, 'Color', 'w');
bx(1) = subplot(3, 1, 1);
plot( downsampled_filteredPos ); hold on;
ylabel('accumulated position')
bx(2) = subplot (3, 1, 2);
plot( velocityclamped ); hold on;
ylabel('down vel')
subplot (3, 1, 3);
plot( velocityOut); hold on;
plot(resample_with_padding(velocityclamped,fictrac_rate,fictrac_rate/2));
legend({'smooth vel','not smoothed vel'})
linkaxes(bx,'x');



%% plotting to check degree calulation and velocity
 %{ 
figure('Position',[50, 50, 1000, 400]);  set(gcf, 'Color', 'w');
bx(1) = subplot(3, 1, 1);
plot( filteredPosition ); hold on;
bx(1) = subplot(3, 1, 2);
plot( accumulatedPositionOut ); hold on;
ylabel ('deg');
bx(2) = subplot (3, 1, 3);
plot( velocityOut ); hold on;
linkaxes(bx,'x');
%}

% %% 4-5-19 downsampling
% settings = sensor_settings;
% 
% n = floor(settings.sampRate/settings.sensorPollFreq);
% % dt = settings.sampRate/settings.sensorPollFreq;
% % x = floor(length(velocityOut)/dt);
% % cut_length = x*n;
% %velocityOut = squeeze(mean(reshape(velocityOut(1:cut_length), [n, x])));
% velocityOut = downsample(velocityOut, n);
% %accumulatedPositionOut = squeeze(mean(reshape(accumulatedPositionOut(1:cut_length), [n, x])));
% accumulatedPositionOut = downsample(accumulatedPositionOut, n);


end

