%Function to obtain bump parameters from the fit of a von Mises function to the DF/F data

function [bump_mag,bump_width,adj_rs,bump_pos] = fitVonMises(midline_distances,dff_data)

%INPUTS
%midline_distances = distances along the PB midline
%dff_data = dff matrix;

%OUTPUTS
%bump_mag = bump magnitude, in DF/F
%bump_width = bump full width at half maximum, in radians
%adj_rs = adjusted r square (goodness of fit metric)
%bump_pos = bump position


%1) Convert the distances along the PB midline to angular distances, taking
%into account that the full length of the PB corresponds to 2pi + (7/8)pi
%in angular distances (since we are grouping the middle glomeruli)
angular_midline_distances = midline_distances*(2*pi + 2*pi*(1/8))/max(midline_distances);
%put back on circle
angular_midline_distances_2pi = mod(angular_midline_distances,2*pi);

%2) Create the fit function
fo = fitoptions('Method','NonlinearLeastSquares',...
    'Lower',[0,0,0,-inf],... % [a,c,k,u]
    'StartPoint',[1,0,1,0]);

ft = fittype('a*exp(k*cos(x-u))+c','options',fo);

for timepoint = 1:length(dff_data)
    
    %4) Fit the data
    data_to_fit = dff_data(timepoint,:);
    [model_data, gof] = fit(angular_midline_distances_2pi,data_to_fit',ft,...
        'MaxIter',20000,'MaxFunEvals',20000);
    adj_rs(timepoint) = gof.adjrsquare;
    
    %5) Get the coefficient values.
    coeff_names = coeffnames(ft);
    coefficientValues = coeffvalues(model_data);
    a = coefficientValues(strcmp(coeff_names,'a'));
    k = coefficientValues(strcmp(coeff_names,'k'));
    u = coefficientValues(strcmp(coeff_names,'u'));
    c = coefficientValues(strcmp(coeff_names,'c'));
    
    %6) Get bump parameters
    bump_pos(timepoint) = mod(u,2*pi);
    bump_mag(timepoint) = a * ( exp(k) - exp(-k) );
    bump_width(timepoint) = 2 * abs( acos( 1/k * log( 1/2 *( exp(k) + exp(-k) ))));
     
    
%     %7) Uncomment to plot the original data and the fit
%     figure,
%     subplot(2,1,1)
%     plot(angular_midline_distances,dff_data(timepoint,:)')
%     hold on
%     plot(angular_midline_distances,feval(model_data,angular_midline_distances))
%     %add the bump position estimate
%     plot(bump_pos(timepoint),feval(model_data,bump_pos(timepoint)),'ro')
%     xlabel('Angular distance (radians)');
%     ylabel('DF/F');
%     title(['Frame #',num2str(timepoint),' AdjR2 =',num2str(gof.adjrsquare)]);
%     legend('data','fit');
%     %Add the bump parameters
%     subplot(2,1,2)
%     text(0,0.5,['Bump magnitude = ',num2str(bump_mag(timepoint))]);
%     hold on
%     text(0.5,0.5,['Bump width = ',num2str(bump_width(timepoint))]);
%     text(0.25,0,['Bump pos = ',num2str(u)]); axis off
%     
%     pause
    
end


end
