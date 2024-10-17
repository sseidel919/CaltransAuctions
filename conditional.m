function  [CDF_, PDF_]= conditional(BID, X, b)

%%%%%
% written for auction theory and practice class 
% by gaurab aryal. 
% read the notes carefully
%%%%

% Note 
% the function estimates Pr(Bid <=b| X=median(X)) and conditional PDF
% Pr(Bid=b|X=median(X)) using KDE 
% it uses a slighly lengthy but numerically stable approach (I think!:-) )  

%Input
% BID = N x 1 vector of bids  
% X  = N x 1 vector of apprisal value 
% b   = K x 1 bid where you want to evaluate. K can be 1 or > 1
% b  vector has to have unique elements. 
%Output 
% CDF_ = K x 1 vector of Pr(Bid <=b| X=median(X)) (notice this is k x 1)
% PDF_ = K x 1 vector of Pr(Bid =b| X=median(X)) (notice this is k x 1)

% Use: 
% [CDF, PDF] = conditional(BID, X, b)


%%
% step 1 joint PDF of bid and X evlauated at BID and median 
medEst = 526000;

fun_1 = ksdensity([BID, X], [BID, repmat(medEst,length(BID),1)], 'Function', 'pdf');


%%
% step 2 marginal of X evaluated at its median 
fun_2 = ksdensity(X, medEst, 'Function', 'pdf');

%%
% step3 conditonal bid BUT evaluated at BID (not b) 
fun_3 = fun_1./fun_2; 

%%
% step 4 to take fun_3 and evaluate it at another point b
[~,ia,~]  = unique(BID);
pp        = spline(BID(ia),fun_3(ia)); 
b         = sortrows(unique(b)); 
fun_4     = ppval(pp,b);
PDF_      = fun_4; % the conditional PDF we want

%%
% step 5 numerically integrate conditional PDF to get conditonal CDF
pp1   = spline(b,fun_4);
fun_5 = @(x0)integral(@(bid)ppval(pp1,bid), min(b),x0);
fun_6 = arrayfun(@(bb)fun_5(bb),b) ;
CDF_ = fun_6; 
end