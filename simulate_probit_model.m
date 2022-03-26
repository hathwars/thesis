% simulate_probit_model.m
%
% Simulate data from a probit regression model

stimvals = (10:20)'; % raw stimulus values
ntrials = 500;  % number of samples

% Set true model params
mu = 14.3;
sig = 3.5;

% Simulate data
stim = randsample(stimvals,ntrials, 'true');  % sample with replacement

% Compute probability of R choice
pchoice = normcdf(stim,mu,sig);

% Sample response
resp = binornd(1,pchoice);


%% Now let's plot the raw data on top of the true model

nstim = length(stimvals);
stimCount = zeros(nstim,1); % number of times each stim was presented
respMu = zeros(nstim,1);  % mean response to each stimulus

% compute empirical pchoice for every stimulus value
for jj = 1:nstim
    stiminds = (stim == stimvals(jj));  % indices where this stimulus was presented
    stimCount(jj) = sum(stiminds);  % number of times this stimulus was presented
    respMu(jj) = sum(resp(stiminds))/stimCount(jj); % average response
end

% compute 95% CI
respCI = 1.96*sqrt(respMu.*(1-respMu)./stimCount);

sgrid = stimvals(1)-.5:.1:stimvals(end)+0.5; % grid of stimulus values
plot(sgrid,normcdf(sgrid,mu,sig), stimvals, respMu,'o'); % plot data

% add error bars
clrs = get(gca,'colororder');  % get colors
hold on;
plot([stimvals'; stimvals'], [respMu'+respCI';respMu'-respCI'], 'color', clrs(2,:)); % plot CIs
hold off; 

% add a legend & axis labels
legend('true model', 'data', 'location', 'northwest');
set(gca,'ylim', [0 1]);
xlabel('stimulus value');
ylabel('P("higher" choice)');
box off;