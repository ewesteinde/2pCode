dff_matrix = dff_data'; 
transform = fft(dff_matrix,10,1);
transform(1,:) = []; % why do we remove this? is this the autocorrelation e.g. period of 1?
n = 10;
freq = (1:n/2)/(n/2); % FREQUENCY X-AXIS for fft
phase = angle(transform(1:5,:));
phase_value = -squeeze(phase(2, :)); %% This is actually the negative of the phase. However, in order to maintain consistency with Green et al., I realized I had to make the FFT phase negative.

s = .5.^(1:.025:5); % create a geometric series for the periodogram -- this is the FREQUENCY
pxx = periodogram(dff_matrix, [], s, 1, 'power'); % POWER SPECTRA
position_five = find(s == (1/8)); % Look for Period of 5 glomeruli
power_value = pxx(position_five, :);