%trouble shoot fictrac traces

% .dat yaw vs DAQ yaw vs Panels Feedback
figure(1);clf
plot(seconds(ftData.trialTime{1}),ftData.intHD{1} * 10. / (2 * pi),'r','DisplayName','fictrac yaw');
hold on;
plot(trialData.Time, trialData.ficTracYaw,'b','DisplayName','fictrac-daq yaw');
hold on;
plot(seconds(ftData.trialTime{1}),ftData.PanelsX{1},'k','DisplayName','panelsX');
plot(seconds(ftData.trialTime{1}),ftData.PanelsY{1},'g','DisplayName','panelsY');
legend;

figure(2);clf; % yaw position plotted against .dat fictrac sample time & downsampled DAQ clock time
a = ficTracYaw(start_delay+1:end_cut,:);
b = ficTracYawReSamp;
plot(seconds(ftData.trialTime{1}) - seconds(ftData.trialTime{1})(1),ftData.intHD * 10. / (2 * pi),'r','DisplayName','fictrac Time');
hold on;
plot(ftData.trialTime,ftData.intHD * 10. / (2 * pi),'b','DisplayName','DAQ Time');
legend;

figure(3);clf; %panelsX feedback plotted against .dat fictrac sample time, DAQ downsampled clock time, DAQ original sampling clock time
plot(seconds(ftData.trialTime{1}) - seconds(ftData.trialTime{1})(1),ftData.PanelsX,'r','DisplayName','dat time');
hold on;
plot(ftData.trialTime,ftData.PanelsX,'--b','DisplayName','DAQ downsampled time');
hold on;
plot(trialData.Time,trialData.PanelsXDimTelegraph,'k','DisplayName','DAQ time');
legend;

figure(5);clf; %DAQ yaw position plotted against .dat fictrac sample time, DAQ downsampled clock time, DAQ original sampling clock time
plot(seconds(ftData.trialTime{1}) - seconds(ftData.trialTime{1})(1),ficTracYawReSamp  / 10. * (2 * pi),'r','DisplayName','DAQ yaw dat time');
hold on;
plot(ftData.trialTime,ficTracYawReSamp / 10. * (2 * pi),'--b','DisplayName','DAQ yaw DAQ downsampled time');
hold on;
plot(trialData.Time,trialData.ficTracYaw / 10. * (2 * pi),'k','DisplayName','DAQ yaw DAQ time');
hold on; 
plot(seconds(ftData.trialTime{1}) - seconds(ftData.trialTime{1})(1),ftData.intHD ,'--g','DisplayName','dat yaw dat time');
legend;

% .dat IntSide vs DAQ IntSide
figure(4);clf; 
plot(seconds(ftData.trialTime{1}) - seconds(ftData.trialTime{1})(1),ftData.ficTracIntSide,'r','DisplayName','dat Int side dat time');
hold on;
plot(ftData.trialTime,ftData.ficTracIntSide,'--b','DisplayName','dat Int side DAQ downsampled time');
hold on;
plot(trialData.Time,trialData.ficTracIntSide,'k','DisplayName','DAQ Int side DAQ time');
legend;

% .dat yaw vs DAQ yaw
figure(6);clf;
plot(seconds(ftData.trialTime{1}) - seconds(ftData.trialTime{1})(1),ftData.ficTracYaw,'r','DisplayName','dat yaw dat time');
hold on;
plot(ftData.trialTime,ftData.ficTracYaw,'--b','DisplayName','dat yaw DAQ downsampled time');
hold on;
plot(trialData.Time,trialData.ficTracYaw,'k','DisplayName','DAQ yaw DAQ time');
legend;

% .dat IntForward vs DAQ IntForward
figure(7);clf; 
plot(seconds(ftData.trialTime{1}) - seconds(ftData.trialTime{1})(1),ftData.ficTracIntForward,'r','DisplayName','dat Int side dat time');
hold on;
plot(ftData.trialTime,ftData.ficTracIntForward,'--b','DisplayName','dat Int side DAQ downsampled time');
hold on;
plot(trialData.Time,trialData.ficTracIntForward,'k','DisplayName','DAQ Int side DAQ time');
legend;

% compare yaw speeds calc from .dat vs DAQ
ftData.deltaTimestamp(1) = (0);
ftFrameTimes = cumsum(ftData.deltaTimestamp) ./ 1e9;

% Copy important variables, converting units as needed
IFI = [ftFrameTimes(1); diff(ftFrameTimes)];

datYaw = [0; diff(smoothdata(unwrap(ftData.intHD, [], 1), 1, 'loess', 10), 1)] ./ IFI;
DAQYaw = [0; diff(smoothdata(unwrap((trialData.ficTracYaw / 10. * (2 * pi)), [], 1), 1, 'loess', 2000), 1)] ./ (1/sampRate);

figure(8);clf;
plot(ftData.trialTime,datYaw,'b','DisplayName','fictrac yaw');
hold on; 
plot(seconds(trialData.Time),DAQYaw,'k','DisplayName','DAQ yaw');
legend;
