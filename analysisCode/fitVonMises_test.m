%Function to obtain bump parameters from the fit of a sum of von Mises functions to the DF/F data

function [bump_mag,bump_width,adj_rs,bump_pos] = fitVonMises_test(midline_distances,dff_data)

%INPUTS
%midline_distances = distances along the PB midline
%dff_data = dff matrix;

%OUTPUTS
%bump_mag = bump magnitude, in DF/F
%bump_width = bump full width at half maximum, in radians
%adj_rs = adjusted r square (goodness of fit metric)
%u = bump position


%1) Convert the distances along the PB midline to angular distances, taking
%into account that the full length of the PB corresponds to 2pi + (7/8)pi
%in angular distances (since we are grouping the middle glomeruli)
%angular_midline_distances = midline_distances*(2*pi + 2*pi*(7/8))/max(midline_distances);
angular_midline_distances = midline_distances*(pi)/abs(min(midline_distances));
%put back on circle
angular_midline_distances_2pi = mod(angular_midline_distances,(2*pi));

%2) Create the fit function
ft = fittype('a*exp(k*cos(x-u))');
% a = amplitude
% k = involved in bump mag & width
% x = data
% u = bump pos


%3) Change the maximum number of iterations
% options = fitoptions(ft);
% options.MaxIter = 4000;
% options.MaxFunEvals = 4000;

for timepoint = 1:length(dff_data)
    %4) Fit the data
    % add the minimum value
    offset = min(dff_data(timepoint,:));
    data_to_fit = dff_data(timepoint,:) - offset;
    [model_data,gof] = fit(angular_midline_distances_2pi',data_to_fit',ft,'StartPoint',[1,1,0],...
        'Lower',[-inf,0,-inf]);
    adj_rs(timepoint) = gof.adjrsquare;
    
    %5) Get the coefficient values.
    coeff_names = coeffnames(ft);
    coefficientValues = coeffvalues(model_data);
    a = coefficientValues(strcmp(coeff_names,'a'));
    k = coefficientValues(strcmp(coeff_names,'k'));
    u = coefficientValues(strcmp(coeff_names,'u'));
%     % Correct for negative k values (ambiguity in fit)
%     if k < 0
%         k = -k;
%         u = u + pi;
%     end
%     bump_pos(timepoint) = wrapToPi(u);
%     
%     %6) Get bump parameteres
%     bump_mag(timepoint) = a * exp(k);
%     bump_width(timepoint) = 2 * abs(acos(1-log(2)/k));
%     
        % Get bump parameters
    bump_pos = mod(u,2*pi);
    bump_mag = a * ( exp(k) - exp(-k) );
    bump_width = 2 * abs( acos( 1/k * log( 1/2 *( exp(k) + exp(-k) ))));
    
    
%    6) Plot the original data and the fit
    figure,
    subplot(2,1,1)
    plot(angular_midline_distances,dff_data(timepoint,:)')
    hold on
    plot(angular_midline_distances,feval(model_data,angular_midline_distances)+offset)
    %add the bump position estimate
    plot(wrapToPi(u),feval(model_data,u)+offset,'ro')
    xlabel('Angular distance (radians)');
    ylabel('DF/F');
    title(['Frame #',num2str(timepoint),' AdjR2 =',num2str(gof.adjrsquare)]);
    legend('data','fit');
    %Add the bump parameters
    subplot(2,1,2)
    text(0,0.5,['Bump magnitude = ',num2str(bump_mag(timepoint))]);
    hold on
    text(0.5,0.5,['Bump width = ',num2str(bump_width(timepoint))]);
    text(0.25,0,['Bump pos = ',num2str(u)]); axis off
    
end


end
