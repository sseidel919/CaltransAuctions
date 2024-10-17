function [costEstS, costEstL] = estimation_cost(commonSmall, commonLarge)


load ('caltransfiltered.mat')



% Find rows matching the most common instance
rowsMatching = (caltransfiltered.NumberofSmallBusinessBidders == commonSmall) & (caltransfiltered.NumberofLargeBusinessBidders == commonLarge);

% Create a new table with only these rows

trainSet = caltransfiltered(rowsMatching, :);

small = trainSet.SmallBusinessPreference == 1;

large = trainSet.SmallBusinessPreference == 0;

smallRows = (trainSet.SmallBusinessPreference == 1);

smallSet = trainSet(smallRows,:);




largeRows= (trainSet.SmallBusinessPreference == 0);

largeSet= trainSet(largeRows,:);

%sB = smallSet.Bid;
%lB = largeSet.Bid;

%(uncomment later)
 outlierIndexS = isoutlier(smallSet.Bid, 'percentiles', [5,90]);
 outlierIndexL = isoutlier(largeSet.Bid, 'percentiles', [5,90]);
% 
% remove projectIDs
outlierProjectIDS = unique(smallSet.ProjectID(outlierIndexS));
outlierProjectIDL = unique(largeSet.ProjectID(outlierIndexL));

% Create an indicator for rows to keep
rowsToKeepS = ~ismember(smallSet.ProjectID, outlierProjectIDS);
rowsToKeepL = ~ismember(largeSet.ProjectID, outlierProjectIDL);


 smallSet = smallSet(rowsToKeepS, :); % Remove outliers
 largeSet = largeSet(rowsToKeepL, :); % Remove outliers

smallBid = sortrows(smallSet.Bid(:));
%meanSmallBid = mean(smallBid);
smallEst = smallSet.Estimate;

largeBid = sortrows(largeSet.Bid(:));
largeEst = largeSet.Estimate;



%%
discount = 1.05;
[Hs_s, hs_s] = conditional(smallBid, smallEst, smallBid);
[Hs_l, hs_l] = conditional(smallBid, smallEst, largeBid./discount);

Hs_l = Hs_l ./ max(Hs_l);
Hs_s = Hs_s./max(Hs_s);


%hs_sNew = max(hs_s, 0.00001);
%hs_lNew = max(hs_l, 0.00001);


[Hl_l, hl_l]= conditional(largeBid, largeEst, unique(largeBid));
[Hl_s, hl_s]= conditional(largeBid, largeEst, smallBid.*discount);

Hl_s = Hl_s./max(Hl_s);
Hl_l = Hl_l./max(Hl_l);



%%

figure;
hold on 
plot(smallBid,Hs_s)
plot(unique(largeBid), Hl_l)
hold off
title('Conditional Bid CDF', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('Bid Amount ($)', 'FontSize', 12);
ylabel('Probability', 'FontSize', 12);
legend('Small Bidder', 'Large Bidder','FontSize', 10);



%%
figure;
hold on 
plot(smallBid,hs_s)
plot(unique(largeBid), hl_l)
hold off
title('Conditional Bid PDF', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('Bid Amount ($)', 'FontSize', 12);
ylabel('Probability', 'FontSize', 12);
legend('Small Bidder', 'Large Bidder','FontSize', 10);

disp(['Min and Max of hs_s: ', num2str(min(hs_s)), ', ', num2str(max(hs_s))]);
disp(['Min and Max of hl_l: ', num2str(min(hl_l)), ', ', num2str(max(hl_l))]);
disp(['Min and Max of hs_l: ', num2str(min(hs_l)), ', ', num2str(max(hs_l))]);
disp(['Min and Max of hl_s: ', num2str(min(hl_s)), ', ', num2str(max(hl_s))]);



costFunS = @(b) b - 1 ./ ( (discount .* 3 .* hl_s) ./ (1 - Hl_s));
costEstS = costFunS(smallBid);

costFunL = @(b) b - 1 ./ (((1 .* hs_l) ./ (discount .* (1 - Hs_l))) + ((2 .* hl_l) ./ (1 - Hl_l)));


costEstL = costFunL(unique(largeBid));

largeBid= unique(largeBid);

end
