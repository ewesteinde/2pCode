function [ t ] = process_time( time )

settings = sensor_settings;

%% 4-5-19 downsampling
% dt = floor(settings.sampRate/settings.sensorPollFreq);
% x = floor(length(time)/dt);
% cut_length = x*dt;
% time_downsampled = squeeze(mean(reshape(time(1:cut_length), [dt, x])));

n = floor(settings.sampRate/settings.sensorPollFreq);
time_downsampled = downsample(time, n);

t = time_downsampled;

end


