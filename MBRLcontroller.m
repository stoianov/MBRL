% Bayesian Model-Based Reinforcement Learning controller
% (C) Ivilin Stoianov, ISTC-CNR, Italy. Please cite: 
% Stoianov, Pennartz, Lansink, Pezzulo (2018) Model-Based Spatial Navigation in the Hyppocampus-Ventral Striatum Circuit: A Computational Analysis.  Plos Computational Biology

function [m,stim] = MBRLcontroller(m,stim,i)
% Input:
% m:    model parameters and state
% stim: external environment
% i:    discrete time tick
% Output:
% m:    updated model params
% stim: updated environment

%% INPUT & Model Initialization
go=stim.ss(1);                          % Goal-index
x=stim.ss(2);                           % (grid/head_dir) Input to be clustered
if i==1, m=init_model(m,x);   end    	% First-time model initialization
if ~m.Exp(x), m=extend_model(m,x); end  % Extend the model with unexperienced stimuli
PC=m.Pc(x,:);                          	% probability of each category given the input x
[~,st]=max(PC);                         % the state is the most probable one

%% CONTROL (policy and action selection)
[a,swl_act,swcert_act,~]=action_selection(m,go,st); % Pick-up the expectedly most valuable action

%% Exernal effect of action (not really transition in the environment; this could be improved)
pos1=ymaze_action(m.task,stim.pos,a);   % Get the effect of the action (in terms of new sensory input). It does not change the environment. 
                                        % We do this outside of this function (not so efficient..).
% Encode the (input at the) new position into category
[stim,x1]=ymaze_input(m.task,stim,pos1);% The grid-input at the new position
if ~m.Exp(x1),                          % Init if the curretn context has not been experienced
  m=extend_model(m,x1); PC=m.Pc(x,:);   % Extend and update PC with the extended probability distribution
end  
PC1=m.Pc(x1,:);                         % Probability of each state given the new input
[~,st1]=max(PC1);                       % the new state is the most probable one

% OBSERVE the LOCAL VALUE (the immediate reward)
r0=ymaze_isgoal(stim,pos1);             % is the new position a goal-position ? (then it receives reward: r0=1) 
r=r0; if r==1, r=rand<stim.rewprob(stim.goal.room); end % .. but the reward is given with certain probability 
R=[1-r;r];                              % Encode the local-reward as a distribution
R=R*stim.rewscale;                      % Room-specific reward (it is the same in Phase1 and it is asymmetric in Phase2; see the paper for description) 
R=R.*m.Nr(:,go,st1);                    % Turn the observed reward to Dirichlet counters

%% LEARN the transition MODEL
m.Nm(st1,st,a) = m.Nm(st1,st,a) + 1;    % Update the Dirichlet distribution with the new transition evidence (arrive to s1, startig from s and applying a)
m.Pm(:,st,a)   = m.Nm(:,st,a) /sum(m.Nm(:,st,a)); % The posterior of the model transition distribution (just normalize its Dirichlet prior)

%% LEARN the clustering 
PC=PC.*reshape(m.Pm(st1,:,a),1,m.nCAT); % for all CAT together     Using the actual transition
normPC=single(PC/sum(PC));              % normalize  to probabilities
m.Pc(x ,:) = normPC;                    % update the posterior    

%% LEARN the REWARD function p(r|s2,c)
[NswpR,swl_lrn]=rewardsweep(m,go,x1);   % Make a reward-learning sweep 
tdmom=min(1,m.tdmom0/log10(i+1));       % momentum term
m.Nr(:,go,st1) = m.Nr(:,go,st1) + tdmom * (R+NswpR-m.Nr(:,go,st1)); % TD-like learning over the Dirichlet of the reward model
m.Pr(:,go,st1) = m.Nr(:,go,st1)/sum(m.Nr(:,go,st1)); % normalize to calculate the posterior of the reward model

%% Update stimulus
stim.pos=pos1;                          % Next position is that of the transition
stim.lpath=stim.lpath+1;                % Update the info about path length
if r0,                                  % Is the goal reached ?
  stim.state=1;                         % Yes, goal is reached => new learing path
elseif stim.lpath>m.task.path_max_length
  stim.state=-1;                        % No, and Too-long path => Try a new path.
else
  stim.state=0;                         % Otherwise, just go on
end

%% STORE interesting info
m.npath=stim.npath;                     % How many paths thus far
m.itrial=stim.npath;
m.i=i;                                  % How many steps thus far
m.ss(i,:)     = single(stim.ss);        % Complete info about the stimulus and correct action
m.state(i)    = int8(stim.state);       % Model state after executing this step
m.action(i)   = uint8(a);               % Selected action 
m.rseq(i)     = uint8(r);               % Obtained reward 
if not(stim.state==0)                   % If the search has finished
  m.path.success(stim.npath)=(stim.state>0); % Success in this path
  m.path.len(stim.npath)=stim.lpath;    % Path length
  m.path.goal(stim.npath,:)=[stim.goal.s stim.goal.room stim.goal.x stim.goal.y];   % Index,Room,X,Y of goal
  m.path.start(stim.npath,:)=[stim.start.x stim.start.y stim.start.d];            % X,Y,Dir at start
end
% m.Ncat(i,1)   = sum(max(m.Pc));       % Estimate the number of used task sets % Too much of calculi !!

% Action sweep
m.lsweep(i) = uint8(swl_act);           % length of action-sweeps
m.cert(i)    = swcert_act(swl_act);     % Certainty at the point of decision
% Reward learning sweep
m.lsweep_lrn(i)  = uint8(swl_lrn);      % length of action-sweeps

end 

function st=localmax(Pm,Pr)             % Select the action that locally brings to max reward at this step of the sweep. Input is Pm(st1:,state,iA:) and Pr(2,st1:,target)
 [~,S]=max(Pm,[],1);                    % The most probable set of States (search on the 1st dimension) following  each possible action (the action is the 3rd dimension in Pm and the new state is the 1st dimension)
 [~,a]=max(Pr(S));                      % The action with max local reward (at each selected state)
 st=S(a);                               % "Apply" the action to go to the next state of the sweep (the most probable state for this action)
end

function [PrN,swl]=rewardsweep(m,g,st)  % predict the next actions & states that bring to reward
 % g: target state, st: point of departure for the sweep
 PrN=zeros(2,1);                        % Accumualtor for the predicted reward, 
 if m.rewpolicy==1, lsweepR=1; else lsweepR=m.lsweepR; end
 for swl=1:lsweepR
   st=localmax(m.Pm(:,st,:),m.Pr(2,g,:)); % Next state based on selecting the action with greatest chance for reward 
   PrN=PrN+m.Nr(:,g,st)*m.td_gamj(swl); %gam^j
 end
 PrN=PrN/swl;
end

function m=init_model(m,st)
m.ntrials=m.task.ntrials;               % Learning trials to be done
m.nticks=m.task.nticks;                 % Expected time ticks
m.npaths=m.task.npaths;                 % Expected paths
m.i=0;                                  % Trials done
m.ipath=0;                              % trial-time

%% Params
m.alpha = m.task.params(1);             % Dirichlet alpha param
m.beta = m.task.params(2);              % softmax choice inverse temperature
m.actpolicy=m.task.params(3);              
m.lsweepA=m.task.params(4);             % 5-6 Length of forward sweep for action selection
m.actSweepCertThr=m.task.params(5);     % Best 0.15. Acceptable 0.20-0.30;  log-probability difference to stop a sweep. (btw 1st and 2nd most probable action)
m.rewpolicy=m.task.params(6);
m.lsweepR=m.task.params(7); 
m.td_gam=0.90;                          % discount factor
m.td_gamj=exp(log(m.td_gam)*(1:12));    % j^1 j^2 .. j^k (the discount at each lookup-distance, to reduce calculations)
m.td_sweep=m.lsweepR;                   % max length of reward sweep
m.tdmom0=1.5;                           % momentum coef for the momentum curve

%% Storage for learning hystory
ntm=m.nticks;                           % How many learning trials to be done
m.ss     = zeros(ntm,7,'single');       % Full trial Info
m.state  = zeros(ntm,1,'int8');         % State at the end of the trial
m.rseq   = zeros(ntm,1,'uint8');        % reward
m.action = zeros(ntm,1, 'uint8');       % chosen action
m.Ncat   = zeros(ntm,1,'single');       % Approximate number of categories formed 
m.lsweep = zeros(ntm,1,'uint8');        % length of action-sweeps
m.cert   = zeros(ntm,1,'single');       % certainty of sweep
m.lsweep_lrn = zeros(ntm,1,'uint8');    % length of action-sweeps

ntr=m.ntrials;                          % How many expected paths
m.path.success=zeros(ntr,1, 'uint8');   % Success of each expected search path
m.path.len    =zeros(ntr ,1, 'uint8');  % Length of each search path
m.path.goal   =zeros(ntr ,4, 'single'); % Index,Room,X,Y of goal
m.path.start  =zeros(ntr ,3, 'single'); % X,Y,Dir of start

%% Problem-size
m.nA=m.task.act.n;                      % number of actions
m.nC=m.task.nStim(1);                   % Number of goals
m.nS=m.task.nStim(2);                   % Max number of dirichlett-states 
m.Exp=[]; m.nExp=0;                     % Indicator of experienced to-be-categorized states &  number of different experienced contexts at a goven moment
m.Pc=[];  m.nCAT=0;                     % P(TS|Ci) & number of categories learned 
m.Pm=[]; m.Nm=[];                       % P(s'|s,a) Probabily of next state given state and action & Conjugate prior
m.Pr=[]; m.Nr=[];                       % P(r|c,s) Probabily of reward given s' and goal & Conjugate prior
m.Exp=zeros(m.nS,1);                    % Bitmap of experienced dirichlett-states
m.Exp(st)=1;                            % Indicate that this state is experienced
m.nExp    =1;                           % The number of experienced states
m.nCAT    =1;                           % The number of dirichlett-categories learned
m.Pc=zeros(m.nS,m.nCAT,'single');       % P(TS|Si)
m.Pc(st)=1;                             % Init P(TS|C) with P(single task set | single conext thus far)
m.Pm=ones(m.nCAT,m.nCAT,m.nA,'single')/1;% P(s'|s,a) Probabily of next state given state and action
m.Nm=ones(m.nCAT,m.nCAT,m.nA,'single'); % Conjugate prior (dirichlett)
m.Pr=ones(2,m.nC,m.nCAT,'single')/2;    % P(r|C,TS) Reward-binomial
m.Nr=ones(2,m.nC,m.nCAT,'single');      % Conjugate priod (beta)

end

% Add a context experienced for the 1st time (to a TavolaCinese in a ChineseRestorant)
function m=extend_model(m,st)
% 1) Record this context in a list of experienced context 
m.nExp=m.nExp+1;                        % Increase number of experienced states
m.Exp(st)=m.nExp;                       % Add this state to the list of experienced states

% 2) Add a new task set that could potentially get this context 
m.Pc(st,m.nCAT+1)=0;                    % add a new column to P(TS|S)
% The probabilut of assigning the new context to a new TaskSet depends on parameter alpha
m.Pc(st,m.nCAT+1)=m.alpha/(m.alpha+m.nExp); % Set the prob of the new task-set 
% The probability of selecting "old" TSs depens their popularity accross all other contexts
m.Pc(st,1:m.nCAT)=sum(m.Pc(:,1:m.nCAT))/(m.alpha+m.nExp); % Rescale to account for the new entry

% 3) Extend the multinomial transition model P(s'|s,a) with a new TS
m.Nm(m.nCAT+1,:,:)=ones(1,m.nCAT  ,m.nA,'single'); 
m.Nm(:,m.nCAT+1,:)=ones(m.nCAT+1,1,m.nA,'single');
m.Pm = m.Nm ./ repmat(sum(m.Nm),[size(m.Nm,1) 1 1]); % Turn into conditional probabilities

% 4) Extend the binomial model of reward P(r|goal,state) with a new category(model state)
m.Nr(:,:,m.nCAT+1)=ones(2,m.nC,1,'single');
m.Pr(:,:,m.nCAT+1)=ones(2,m.nC,1,'single')/2;

% Finally, extend the number of learned categories (states)
m.nCAT=m.nCAT+1;         
end
