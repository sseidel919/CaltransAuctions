clear

% for 1,3 combination 
[costS_13, costL_13] = estimation_cost(1,3); 

% for 2,2 combination 
[costS_22, costL_22] = estimation_cost(2,2); 

[costS_23, costL_23] = estimation_cost(2,3); 

COST_small = [costS_13;costS_22; costS_23];

COST_large = [costL_13;costL_22;costL_23];

COST_small = COST_small(COST_small > 0);
COST_large = COST_large(COST_large > 0);
COST_small = sortrows(COST_small(:));
COST_large = sortrows(COST_large(:));

load ('caltransfiltered.mat')
format long g

meanS = mean(COST_small);
meanL = mean(COST_large);
medianS = median(COST_small);
medianL = median(COST_large);
minS = min(COST_small);
minL = min(COST_large);
maxS = max(COST_small);
maxL = max(COST_large);
stdS = std(COST_small);
stdL = std(COST_large);

disp([num2str(meanS) ', ' num2str(medianS) ', ' num2str(stdS) ', '  num2str(minS) ', '  num2str(maxS)]);
disp([num2str(meanL) ', ' num2str(medianL) ', ' num2str(stdL) ', ' num2str(minL) ', ' num2str(maxL)]);

%%
Fs_estimate = ksdensity(COST_small, COST_small, 'function','cdf','Support', 'positive','BoundaryCorrection','reflection');
fs_estimate = ksdensity(COST_small, COST_small, 'function', 'pdf','Support', 'positive','BoundaryCorrection','reflection');

Fl_estimate = ksdensity(COST_large, COST_large, 'function','cdf', 'Support', 'positive','BoundaryCorrection','reflection');
fl_estimate = ksdensity(COST_large, COST_large, 'function', 'pdf','Support', 'positive','BoundaryCorrection','reflection');

Fs_estimate = Fs_estimate ./ max(Fs_estimate);
% fs_estimate = fs_estimate ./ max(fs_estimate);
Fl_estimate = Fl_estimate ./ max(Fl_estimate);
% fl_estimate = fl_estimate ./ max(fl_estimate);


%%
figure;
hold on 
plot(COST_small, Fs_estimate)
plot(COST_large, Fl_estimate)
hold off

title('Conditional Cost CDF', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('Cost Amount ($)', 'FontSize', 12);
ylabel('Probability', 'FontSize', 12);
legend('Small Bidder','Large Bidder', 'FontSize', 10);


%%
figure;
hold on 
plot(COST_small, fs_estimate)
plot(COST_large, fl_estimate)
hold off

title('Conditional Cost PDF', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('Cost Amount ($)', 'FontSize', 12);
ylabel('Probability', 'FontSize', 12);
legend('Small Bidder','Large Bidder', 'FontSize', 10);

%%


% Interpolating using 'pchip'
% Fs_estimate =  interp1(COST_small, Fs_estimate, r, 'pchip');
% fs_estimate = interp1(COST_small, fs_estimate, r, 'pchip');
% Fl_estimate = @(r) interp1(COST_large, Fl_estimate, r, 'pchip');
% fl_estimate = @(r) interp1(COST_large, fl_estimate, r, 'pchip');

% Remainder of the root-finding and reserve price calculation code follows...
% Assuming COST_small and COST_large contain the sample data from which to estimate the PDF and CDF.

% Define the equations using ksdensity within the function handle
equation_small = @(r) 526000 - r - (ksdensity(COST_small, r, 'Function', 'cdf') ./ ksdensity(COST_small, r, 'Function', 'pdf'));
equation_large = @(r) 526000 - r - (ksdensity(COST_large, r, 'Function', 'cdf') ./ ksdensity(COST_large, r, 'Function', 'pdf'));

% Initial guess for r*
initial_guess = 500000;

% Solve for r*
r_s = fzero(equation_small, initial_guess);
r_l = fzero(equation_large, initial_guess);




%%

Ns_fixed = 1;
Nl_fixed = 3;


winBid = NaN(1000,1);

for i = 1:1000
    sCost = randomdraw(COST_small, Fs_estimate, Ns_fixed);
    lCost = randomdraw(COST_large, Fl_estimate, Nl_fixed);
    sCost = sCost(sCost < r_s);
    lCost = lCost(lCost < r_l);
    temp = sortrows(lCost(:));
    
    %ask how to chooose which reserve price for type specific
    if isempty(sCost) && isempty(lCost)
        winBid(i,1) = 526000;
    elseif ~isempty(sCost) && isempty(lCost)
        winBid(i,1) = r_s; % want the smallest sCost when lCost is empty
    elseif isempty(sCost) && ~isempty(lCost)
        if numel(temp) >= 2
            winBid(i,1) = temp(2); % Second smallest element in lCost if it has at least two elements
        elseif numel(temp) == 1
            winBid(i,1) = r_l; % Only element in lCost if there is only one
        end
    elseif ~isempty(sCost) && ~isempty(lCost)
        newTemp = [sCost; lCost];
        newTemp = sortrows(newTemp(:));
        winBid(i,1) = newTemp(2); % Second smallest element in lCost if it has at least two elements
  
    end

end

meanWin = mean(winBid);
disp(meanWin);


