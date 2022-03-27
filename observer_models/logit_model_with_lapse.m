%
% logit_model_with_lapse demonstrates utility in Palamedes library.  This 
% is an example of a logistic model with guessing rates (leftward lapse)
% and lapse rate (rightward lapse).  I generate a simulated observer below
% and am able to recover the input parameters.  In another script, I will
% run this multiple times to show that as the number of stimlevels
% increases, the hand-picked values and calculated values converge.
% Finally, I determine the goodness-of-fit of the logit model via both
% monte carlo simulations and chi-squared.

% 1. still need to add error bars with standard error
% 2. Want to try with multiple classes.
% 3. Show that as number of StimLevels increase, the error goes to 0. 

% This script needs to be run with all PFML files 
%

clear all;      %Clear all existing variables from memory

tic

%Nelder-Mead search options (optimization strategy similar to fminsearch)
%still uses searchgrid, could use fmincon or fminunc
%options struct used in PAL_minimize.m
options = PAL_minimize('options');  %decrease tolerance (i.e., increase
options.TolX = 1e-09;              %precision).
options.TolFun = 1e-09;
options.MaxIter = 10000;
options.MaxFunEvals = 10000;

%prepare plot
figure('units','pixels','position',[100 100 400 200]);
h = axes('units','pixels','position',[50 50 300 100]);
set(h,'xtick',[-10 -2:1:2 10],'xlim',[-11 11],'ylim',[.4 1],'xticklabel',{'-10','-2','-1','0','1','2','10'});
xlabel('Stimulus intensity');    
ylabel('Proportion correct'); 
title({'Logistic Psychometric Function', 'with Lapses on Simulated Observer Data'})
hold on;

StimLevels = [-10 -2 -1 0 1 2 10];

OutOfNum = [150 150 150 150 150 150 150];    

PF = @PAL_Logistic;                     % psychometricfunction
% paramsValues = [0 1 .5 .05];            %generating values (alternate
% form using Palamedes)

% Generating values
alpha = 0; % threshold
beta = 1; % slope
gamma = 0.5; % guessing rate
lambda = 0.05; % lapse rate 

% Simulate observer (logistic psychometric function)
% pcorrect = PF(paramsValues, StimLevels); (alternate form using Palamedes)
pcorrect = gamma + (1 - gamma - lambda).*(1./(1+exp(-1*(beta).*(StimLevels-alpha))));

NumPos = zeros(1,length(StimLevels));
for Level = 1:length(StimLevels)
    Pos = rand(OutOfNum(Level),1);
    Pos(Pos < pcorrect(Level)) = 1;
    Pos(Pos ~= 1) = 0;
    NumPos(Level) = sum(Pos);
end
plot(h,StimLevels,NumPos./OutOfNum,'ko','markersize',6,'markerfacecolor','k');

%Fit Psychometric Function using searchgrid and Nelder-Mead optimization
searchGrid.alpha = [-1:.05:1];    %structure defining grid to
searchGrid.beta = 10.^[-1:.05:2]; %search for initial values
searchGrid.gamma = .5;
searchGrid.lambda = [0:.005:.1];
lapseFit = 'nAPLE';

paramsFree = [1 1 0 1]; %[threshold slope guess lapse] 1: free, 0:fixed

[paramsFitted LL exitflag] = PAL_PFML_Fit(StimLevels, NumPos, OutOfNum, searchGrid, paramsFree, PF,'lapseLimits',[0 1],'searchOptions',options,'lapseFit',lapseFit);

plot(h,-10.5:.01:10.5,PF(paramsFitted,-10.5:.01:10.5),'-','color',[0 .7 0],'linewidth',2);

% Display calculated parameters (should be closed to generated values
% above)
disp(sprintf('\n'));
disp(['Threshold: ' num2str(paramsFitted(1),'%4.3f')]);
disp(['Slope: ' num2str(paramsFitted(2),'%4.3f')]);
disp(['Guess Rate: ' num2str(paramsFitted(3),'%4.3f')]);
disp(['Lapse Rate: ' num2str(paramsFitted(4),'%4.3f')]);
disp(sprintf('\n'));    

% Display goodness of fit scores via Monte Carlo and via chi^2
[Dev pDev DevSim converged] = PAL_PFML_GoodnessOfFit(StimLevels, NumPos, OutOfNum, ...
paramsFitted, paramsFree, 100, PF, 'searchGrid', searchGrid, 'lapseLimits',[0 1],'lapseFit',lapseFit);

disp([sprintf('\n') 'Goodness-of-fit by Monte Carlo: ' num2str(pDev,'%4.4f')])

if exist('chi2pdf.m') == 2
    disp(['Goodness-of-fit by chi-square approximation: ' num2str(1-chi2cdf(Dev,6-sum(paramsFree)),'%4.4f')])
end
