
function [visual_stim_pos] = process_panel_360(rawData, pixels)

%obtain the visual stimulus position in deg (angle) using the raw panel
%dara (rawData) and the number of x pixels (pixels)

% Initial variables
settings = sensor_settings;
maxVal = 10;
minVal = 0;
initialPx = 3; %my x=1 positon is 3 pixels to the right of the animal
initialAngle = initialPx*360/pixels;

%invert the direction of the data to match my convention
inv_data = 10 - rawData;

%compute in deg
deg_data = inv_data*360/10;

%shift according to the panels pos
shifted_data = deg_data + initialAngle;

%wrap
visual_stim_pos = wrapTo360(shifted_data);

%downsample data
visual_stim_pos = resample(visual_stim_pos, 25, settings.sampRate);
