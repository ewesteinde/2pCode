
fakeStim = zeros(1*30,1); 
fakeStim(15) = 1;
smoothStim = smoothdata(fakeStim,'loess',10);

accumulatedPositionOut = resample_new(smoothStim,60,30); 
velocitySmooth = resample_new(gradient( smoothStim ) .* 30,60,30);
velocity = resample_new(gradient( fakeStim ) .* 30,60,30);

x = -1:2/30:1;
y = dirac(x);
idx = y == Inf; % find Inf
y(idx) = 1;     % set Inf to finite value
smoothy = smoothdata(y,'loess',10);
figure();
stem(x,y)
hold on
stem(x,smoothy)

figure();
plot(x,y)
hold on
plot(x,smoothy)


time = linspace(0,1,30);
time2 = linspace(0,1,60);
figure();
plot(time,fakeStim)
hold on
plot(time,smoothStim)
hold on
plot(time2, accumulatedPositionOut)

time = linspace(0,1,30);
time2 = linspace(0,1,60);
figure();
plot(time2,velocity)
hold on
plot(time2,velocitySmooth)
