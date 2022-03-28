%
% here is a 'fuller model' which allows each condition to have its own
% threshold and slope, but assumes equal lapse rates
%

clear all

rand('state',sum(100*clock));

%Nelder-Mead search options for minimization
options = PAL_minimize('options');  %decrease tolerance (i.e., increase
options.TolX = 1e-09;              %precision).
options.TolFun = 1e-09;
options.MaxIter = 10000;
options.MaxFunEvals = 10000;

%prepare plots
figure('units','pixels','position',[100 100 400 450]);
for cond = 1:4
    h(cond) = axes('units','pixels','position',[50 350-(cond-1)*100 300 75]);%125 300 100]);
    set(h(cond),'xtick',[-10 -2:1:2 10],'xlim',[-11 11],'ylim',[.4 1],'xticklabel',{'-10', '-2','-1','0','1','2','10'});
    ylabel('prop correct');    
    hold on;
end

xlabel('Stimulus Intensity');    
h(5) = axes('units','pixels','position',[50 425 300 40]);
set(h(5),'xlim',[0 1],'ylim',[0 1]);
line([.05 .15],[.5 .5],'color',[.7 0 0],'linewidth',2)
text(.2,.5,'lesser model');
line([.5 .6],[.5 .5],'color',[0 .7 0],'linewidth',2)
text(.65,.5,'fuller model');
axis off;

%Stimulus intensities. Generating logistic (F) evaluates to near unity
%at 10
StimLevels = repmat([-10 -2 -1 0 1 2 10],[4 1]); % 4 conditions

OutOfNum = [100 100 100 100 100 100 100;    %N need not be equal
           150 150 150 150 150 150 150;
           100 100 100 100 100 100 100;
           150 150 150 150 150 150 150];

PF = @PAL_Logistic;                     %PF function
paramsValues = [0 1 .5 .05];            %generating values
% paramsValues = [threshold slope guessrate lapserate]

%Simulate observer
lapseFit = 'nAPLE';
for cond = 1:4 % once for each condition
    % Generating values
    alpha = paramsValues(1); % threshold
    beta = paramsValues(2); % slope
    gamma = paramsValues(3); % guessing rate
    lambda = paramsValues(4); % lapse rate 
    
    % Simulate observer (logistic psychometric function)
    % pcorrect = PF(paramsValues, StimLevels); (alternate form using Palamedes)
    pcorrect = gamma + (1 - gamma - lambda).*(1./(1+exp(-1*(beta).*(StimLevels(cond, :)-alpha))));
    
    NumPos(cond, :) = zeros(1,length(StimLevels(cond, :)));
    for Level = 1:length(StimLevels(cond, :))
        Pos = rand(OutOfNum(cond, Level),1);
        Pos(Pos < pcorrect(Level)) = 1;
        Pos(Pos ~= 1) = 0;
        NumPos(cond, Level) = sum(Pos);
    end
    plot(h(cond),StimLevels(cond,:),NumPos(cond,:)./OutOfNum(cond,:),'ko','markersize',6,'markerfacecolor','k');
end

%Define fuller model
thresholdsfuller = 'unconstrained';  %Each condition gets own threshold
slopesfuller = 'unconstrained';      %Each condition gets own slope
guessratesfuller = 'fixed';          %Guess rate fixed
lapseratesfuller = 'constrained';    %Common lapse rate

%Fit fuller model
[paramsFuller LL exitflag trash trash numParamsFuller] = PAL_PFML_FitMultiple(StimLevels, NumPos, OutOfNum, ...
  paramsValues, PF,'searchOptions',options,'lapserates',lapseratesfuller,'thresholds',thresholdsfuller,...
  'slopes',slopesfuller,'guessrates',guessratesfuller,'lapseLimits',[0 1],'lapseFit',lapseFit);

disp(sprintf('\n'))
disp('Fuller Model:')
disp(sprintf('\n'));
disp(['Thresholds: ' num2str(paramsFuller(1,1),'%4.3f') ', ' num2str(paramsFuller(2,1),'%4.3f') ', ' num2str(paramsFuller(3,1),'%4.3f') ', ' num2str(paramsFuller(4,1),'%4.3f')]);
disp(['Slopes: ' num2str(paramsFuller(1,2),'%4.3f') ', ' num2str(paramsFuller(2,2),'%4.3f') ', ' num2str(paramsFuller(3,2),'%4.3f') ', ' num2str(paramsFuller(4,2),'%4.3f')]);
disp(['Guess Rates: ' num2str(paramsFuller(1,3),'%4.3f') ', ' num2str(paramsFuller(2,3),'%4.3f') ', ' num2str(paramsFuller(3,3),'%4.3f') ', ' num2str(paramsFuller(4,3),'%4.3f')]);
disp(['Lapse Rates: ' num2str(paramsFuller(1,4),'%4.3f') ', ' num2str(paramsFuller(2,4),'%4.3f') ', ' num2str(paramsFuller(3,4),'%4.3f') ', ' num2str(paramsFuller(4,4),'%4.3f')]);
disp(sprintf('\n'));
disp(['Akaike''s Informaton Criterion: ' num2str(-2*LL + 2*numParamsFuller,'%4.3f')]);
disp(sprintf('\n'));


%plot fuller model
for cond = 1:4
    plot(h(cond),-10.5:.01:10.5,PF(paramsFuller(cond,:),-10.5:.01:10.5),'-','color',[0 .7 0],'linewidth',2);
end
drawnow
